import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/file_manager_entry.dart';
import '../../services/project_file_store.dart';

enum _FileSortField { name, modified, created, size }

class ProjectFilesView extends StatefulWidget {
  final String projectKey;
  final String query;
  final Color navy;
  final Color card;
  final Color muted;

  const ProjectFilesView({
    super.key,
    required this.projectKey,
    required this.query,
    required this.navy,
    required this.card,
    required this.muted,
  });

  @override
  State<ProjectFilesView> createState() => ProjectFilesViewState();
}

class ProjectFilesViewState extends State<ProjectFilesView> {
  final _store = ProjectFileStore();
  bool _loading = true;

  List<FileManagerEntry> _entries = const [];
  String? _currentFolderId;

  FileCategory? _categoryFilter;
  bool _pinnedOnly = false;
  bool _foldersOnly = false;
  bool _filesOnly = false;

  _FileSortField _sortField = _FileSortField.modified;
  bool _sortAsc = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await _store.load(widget.projectKey);
    if (!mounted) return;
    setState(() {
      _entries = items;
      _loading = false;
    });
  }

  Future<void> _persist(List<FileManagerEntry> next) async {
    setState(() => _entries = next);
    await _store.save(widget.projectKey, next);
  }

  List<FileManagerEntry> _childrenOf(String? parentId) {
    return _entries
        .where((e) => e.parentId == parentId)
        .toList(growable: false);
  }


  

  List<FileManagerEntry> _applyQueryFilterSort(List<FileManagerEntry> items) {
    final q = widget.query.trim().toLowerCase();

    var out = items.where((e) {
      if (q.isNotEmpty && !e.name.toLowerCase().contains(q)) return false;
      if (_pinnedOnly && !e.pinned) return false;
      if (_foldersOnly && !e.isFolder) return false;
      if (_filesOnly && !e.isFile) return false;
      if (_categoryFilter != null && e.isFile && e.category != _categoryFilter) {
        return false;
      }
      return true;
    }).toList();

    int cmpStr(String a, String b) =>
        a.toLowerCase().compareTo(b.toLowerCase());

    int cmp(FileManagerEntry a, FileManagerEntry b) {
      if (a.isFolder != b.isFolder) return a.isFolder ? -1 : 1;
      switch (_sortField) {
        case _FileSortField.name:
          return cmpStr(a.name, b.name);
        case _FileSortField.created:
          return a.createdAt.compareTo(b.createdAt);
        case _FileSortField.size:
          return a.sizeBytes.compareTo(b.sizeBytes);
        case _FileSortField.modified:
          return a.updatedAt.compareTo(b.updatedAt);
      }
    }

    out.sort((a, b) => _sortAsc ? cmp(a, b) : cmp(b, a));
    return out;
  }

  List<FileManagerEntry> _visibleItems() {
    final items = _childrenOf(_currentFolderId);
    return _applyQueryFilterSort(items);
  }

  List<FileManagerEntry> _recentFiles() {
    final items = _entries
        .where((e) => e.isFile && e.lastOpenedAt != null)
        .toList(growable: false);
    items.sort((a, b) => b.lastOpenedAt!.compareTo(a.lastOpenedAt!));
    return items.take(10).toList(growable: false);
  }

  List<FileManagerEntry> _breadcrumb() {
    final byId = {for (final e in _entries) e.id: e};
    final chain = <FileManagerEntry>[];
    var current = _currentFolderId == null ? null : byId[_currentFolderId!];
    while (current != null) {
      chain.insert(0, current);
      current = current.parentId == null ? null : byId[current.parentId!];
    }
    return chain;
  }

  String _prettyBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    final fixed =
        unitIndex == 0 ? size.toStringAsFixed(0) : size.toStringAsFixed(1);
    return '$fixed ${units[unitIndex]}';
  }

  String _categoryLabel(FileCategory c) {
    switch (c) {
      case FileCategory.document:
        return 'Document';
      case FileCategory.image:
        return 'Image';
      case FileCategory.video:
        return 'Video';
      case FileCategory.audio:
        return 'Audio';
      case FileCategory.archive:
        return 'Archive';
      case FileCategory.other:
        return 'Other';
    }
  }

  bool _looksLikeImageExtension(String ext) {
    final lower = ext.trim().toLowerCase();
    return lower == '.png' ||
        lower == '.jpg' ||
        lower == '.jpeg' ||
        lower == '.jfif' ||
        lower == '.gif' ||
        lower == '.webp' ||
        lower == '.avif' ||
        lower == '.bmp' ||
        lower == '.tif' ||
        lower == '.tiff' ||
        lower == '.heif' ||
        lower == '.heic';
  }

  bool _looksLikeImageBytes(Uint8List bytes) {
    if (bytes.lengthInBytes < 12) return false;

    // PNG: 89 50 4E 47 0D 0A 1A 0A
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return true;
    }

    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return true;
    }

    // GIF: "GIF87a" or "GIF89a"
    if (bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38 &&
        (bytes[4] == 0x37 || bytes[4] == 0x39) &&
        bytes[5] == 0x61) {
      return true;
    }

    // WEBP: "RIFF"...."WEBP"
    if (bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return true;
    }

    // BMP: "BM"
    if (bytes[0] == 0x42 && bytes[1] == 0x4D) {
      return true;
    }

    // HEIF/HEIC: ISO BMFF "ftyp" box often starts at offset 4: 66 74 79 70
    if (bytes[4] == 0x66 &&
        bytes[5] == 0x74 &&
        bytes[6] == 0x79 &&
        bytes[7] == 0x70) {
      return true;
    }

    return false;
  }

  IconData _iconFor(FileManagerEntry e) {
    if (e.isFolder) return Icons.folder_rounded;
    switch (e.category) {
      case FileCategory.document:
        return Icons.description_rounded;
      case FileCategory.image:
        return Icons.image_rounded;
      case FileCategory.video:
        return Icons.movie_rounded;
      case FileCategory.audio:
        return Icons.audiotrack_rounded;
      case FileCategory.archive:
        return Icons.archive_rounded;
      case FileCategory.other:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _colorFor(FileManagerEntry e) {
    if (e.isFolder) return const Color(0xFF8B5CF6);
    switch (e.category) {
      case FileCategory.document:
        return const Color(0xFF2563EB);
      case FileCategory.image:
        return const Color(0xFF16A34A);
      case FileCategory.video:
        return const Color(0xFFDC2626);
      case FileCategory.audio:
        return const Color(0xFFF59E0B);
      case FileCategory.archive:
        return const Color(0xFF6B7280);
      case FileCategory.other:
        return const Color(0xFF111827);
    }
  }

  Future<void> promptNewFolder() async {
    final name = await _promptText(
      title: 'New Folder',
      hint: 'Folder name',
      primaryLabel: 'Create',
    );
    if (name == null) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();
    final folder = await _store.createFolder(
      projectKey: widget.projectKey,
      name: trimmed,
      parentId: _currentFolderId,
      now: now,
    );
    await _persist([folder, ..._entries]);
  }

  Future<void> promptUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
        withReadStream: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;

      Uint8List? bytes = file.bytes;
      if (bytes == null && file.readStream != null) {
        final builder = BytesBuilder(copy: false);
        await for (final chunk in file.readStream!) {
          builder.add(chunk);
        }
        bytes = builder.takeBytes();
      }
      if (bytes == null) return;

      final displayName = await _promptText(
        title: 'Upload File',
        hint: 'Display name (optional)',
        initialValue: file.name,
        primaryLabel: 'Upload',
      );

      final now = DateTime.now();
      final entry = await _store.writeImportedFile(
        projectKey: widget.projectKey,
        displayName: displayName ?? file.name,
        originalName: file.name,
        bytes: bytes,
        parentId: _currentFolderId,
        now: now,
      );

      await _persist([entry, ..._entries]);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload file.')),
      );
    }
  }

  Future<String?> _promptText({
    required String title,
    required String hint,
    required String primaryLabel,
    String? initialValue,
  }) async {
    final c = TextEditingController(text: initialValue ?? '');
    final result = await showDialog<String?>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: c,
            decoration: InputDecoration(hintText: hint),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: widget.navy),
              onPressed: () => Navigator.pop(context, c.text),
              child: Text(primaryLabel),
            ),
          ],
        );
      },
    );
    c.dispose();
    return result;
  }

  Future<void> _togglePin(FileManagerEntry entry) async {
    final now = DateTime.now();
    final next = _entries.map((e) {
      if (e.id != entry.id) return e;
      return e.copyWith(pinned: !e.pinned, updatedAt: now);
    }).toList(growable: false);
    await _persist(next);
  }

  Future<void> _rename(FileManagerEntry entry) async {
    final name = await _promptText(
      title: entry.isFolder ? 'Rename Folder' : 'Rename File',
      hint: 'Name',
      initialValue: entry.name,
      primaryLabel: 'Save',
    );
    if (name == null) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();
    final next = _entries.map((e) {
      if (e.id != entry.id) return e;
      return e.copyWith(name: trimmed, updatedAt: now);
    }).toList(growable: false);
    await _persist(next);
  }

  Future<void> _delete(FileManagerEntry entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete'),
          content: Text(
            entry.isFolder
                ? 'Delete folder and all its contents?'
                : 'Delete this file?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (ok != true) return;

    final toDelete = <String>{entry.id};
    bool changed;
    do {
      changed = false;
      for (final e in _entries) {
        if (e.parentId != null && toDelete.contains(e.parentId)) {
          if (toDelete.add(e.id)) changed = true;
        }
      }
    } while (changed);

    final removed = _entries.where((e) => toDelete.contains(e.id)).toList();
    final remaining = _entries.where((e) => !toDelete.contains(e.id)).toList();
    await _persist(remaining);

    for (final e in removed) {
      if (e.isFile) {
        await _store.deleteFileContent(widget.projectKey, e);
      }
    }

    if (_currentFolderId != null && toDelete.contains(_currentFolderId)) {
      setState(() => _currentFolderId = null);
    }
  }

  Future<void> _move(FileManagerEntry entry) async {
    final destination = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        final folders =
            _entries.where((e) => e.isFolder).toList(growable: false);
        final byParent = <String?, List<FileManagerEntry>>{};
        for (final f in folders) {
          byParent.putIfAbsent(f.parentId, () => []).add(f);
        }
        for (final list in byParent.values) {
          list.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
        }

        Widget buildNode(String? parentId, int depth) {
          final list = byParent[parentId] ?? const [];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (parentId == null)
                ListTile(
                  leading: const Icon(Icons.home_rounded),
                  title: const Text('Root'),
                  onTap: () => Navigator.pop(context, null),
                ),
              for (final f in list) ...[
                ListTile(
                  leading: const Icon(Icons.folder_rounded),
                  title: Padding(
                    padding: EdgeInsets.only(left: depth * 12.0),
                    child: Text(f.name),
                  ),
                  onTap: () => Navigator.pop(context, f.id),
                ),
                buildNode(f.id, depth + 1),
              ],
            ],
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Move to...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  buildNode(null, 0),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (destination == entry.id) return;
    if (destination != null && entry.isFolder) {
      final descendants = <String>{entry.id};
      bool changed;
      do {
        changed = false;
        for (final e in _entries) {
          if (e.parentId != null && descendants.contains(e.parentId)) {
            if (descendants.add(e.id)) changed = true;
          }
        }
      } while (changed);
      if (descendants.contains(destination)) return;
    }

    final now = DateTime.now();
    final next = _entries.map((e) {
      if (e.id != entry.id) return e;
      return e.copyWith(parentId: destination, updatedAt: now);
    }).toList(growable: false);
    await _persist(next);
  }

  Future<void> _share(FileManagerEntry entry) async {
    if (entry.isFolder) return;
    final path = await _store.filePath(widget.projectKey, entry);
    final text = path ?? '${entry.name}${entry.extension}';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied file path to clipboard (Share).')),
    );
  }

  Future<void> _open(FileManagerEntry entry) async {
    if (entry.isFolder) {
      setState(() => _currentFolderId = entry.id);
      return;
    }

    final now = DateTime.now();
    final next = _entries.map((e) {
      if (e.id != entry.id) return e;
      return e.copyWith(lastOpenedAt: now, updatedAt: now);
    }).toList(growable: false);
    await _persist(next);

    final bytes = await _store.readFileBytes(widget.projectKey, entry);
    if (!mounted) return;

    final shouldPreviewAsImage = bytes != null &&
        (entry.category == FileCategory.image ||
            _looksLikeImageExtension(entry.extension) ||
            _looksLikeImageBytes(bytes));

    if (shouldPreviewAsImage) {
      // ignore: use_build_context_synchronously
      await showDialog<void>(
        context: context,
        builder: (_) {
          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: widget.navy,
                  child: Text(
                    entry.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Flexible(
                  child: InteractiveViewer(
                    child: Image.memory(
                      bytes,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Preview not available for this image format.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
      return;
    }

    final path = await _store.filePath(widget.projectKey, entry);
    await Clipboard.setData(ClipboardData(text: path ?? entry.name));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied file path to clipboard.')),
    );
  }

  Future<void> _showFilterSheet() async {
    final result = await showModalBottomSheet<_FilterState>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        var category = _categoryFilter;
        var pinnedOnly = _pinnedOnly;
        var foldersOnly = _foldersOnly;
        var filesOnly = _filesOnly;

        Widget chip({
          required String label,
          required bool selected,
          required VoidCallback onTap,
        }) {
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => onTap(),
          );
        }

        return StatefulBuilder(
          builder: (context, setLocal) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          chip(
                            label: 'All',
                            selected: category == null,
                            onTap: () => setLocal(() => category = null),
                          ),
                          for (final c in FileCategory.values)
                            chip(
                              label: _categoryLabel(c),
                              selected: category == c,
                              onTap: () => setLocal(() => category = c),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilterChip(
                            label: const Text('Pinned only'),
                            selected: pinnedOnly,
                            onSelected: (v) => setLocal(() => pinnedOnly = v),
                          ),
                          FilterChip(
                            label: const Text('Folders only'),
                            selected: foldersOnly,
                            onSelected: (v) {
                              setLocal(() {
                                foldersOnly = v;
                                if (v) filesOnly = false;
                              });
                            },
                          ),
                          FilterChip(
                            label: const Text('Files only'),
                            selected: filesOnly,
                            onSelected: (v) {
                              setLocal(() {
                                filesOnly = v;
                                if (v) foldersOnly = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(
                              context,
                              const _FilterState(
                                categoryFilter: null,
                                pinnedOnly: false,
                                foldersOnly: false,
                                filesOnly: false,
                              ),
                            ),
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: widget.navy,
                            ),
                            onPressed: () => Navigator.pop(
                              context,
                              _FilterState(
                                categoryFilter: category,
                                pinnedOnly: pinnedOnly,
                                foldersOnly: foldersOnly,
                                filesOnly: filesOnly,
                              ),
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (result == null) return;
    setState(() {
      _categoryFilter = result.categoryFilter;
      _pinnedOnly = result.pinnedOnly;
      _foldersOnly = result.foldersOnly;
      _filesOnly = result.filesOnly;
    });
  }

  Future<void> _showSortSheet() async {
    final result = await showModalBottomSheet<_SortState>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        var field = _sortField;
        var asc = _sortAsc;

        return StatefulBuilder(
          builder: (context, setLocal) {
            Widget radio(_FileSortField f, String label) {
              return RadioListTile<_FileSortField>(
                value: f,
                groupValue: field,
                onChanged: (v) => setLocal(() => field = v ?? field),
                title: Text(label),
              );
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sort',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    radio(_FileSortField.modified, 'Modified'),
                    radio(_FileSortField.created, 'Created'),
                    radio(_FileSortField.name, 'Name'),
                    radio(_FileSortField.size, 'Size'),
                    SwitchListTile(
                      value: asc,
                      onChanged: (v) => setLocal(() => asc = v),
                      title: const Text('Ascending'),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.navy,
                        ),
                        onPressed: () => Navigator.pop(
                          context,
                          _SortState(field: field, asc: asc),
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (result == null) return;
    setState(() {
      _sortField = result.field;
      _sortAsc = result.asc;
    });
  }

  Future<void> _showEntryMenu(FileManagerEntry entry) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        Widget item(IconData icon, String label, String value) {
          return ListTile(
            leading: Icon(icon),
            title: Text(label),
            onTap: () => Navigator.pop(context, value),
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: Icon(_iconFor(entry), color: _colorFor(entry)),
                title: Text(
                  entry.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: entry.isFolder
                    ? const Text('Folder')
                    : Text(
                        '${_categoryLabel(entry.category)} • ${_prettyBytes(entry.sizeBytes)}',
                      ),
              ),
              const Divider(height: 1),
              item(
                entry.isFolder
                    ? Icons.folder_open_rounded
                    : Icons.open_in_new_rounded,
                'Open',
                'open',
              ),
              if (entry.isFile)
                item(Icons.share_rounded, 'Share (copy path)', 'share'),
              item(
                entry.pinned ? Icons.star_rounded : Icons.star_border_rounded,
                entry.pinned ? 'Unpin' : 'Pin',
                'pin',
              ),
              item(Icons.drive_file_rename_outline_rounded, 'Rename', 'rename'),
              item(Icons.drive_file_move_rounded, 'Move', 'move'),
              item(Icons.delete_rounded, 'Delete', 'delete'),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (action == null) return;
    switch (action) {
      case 'open':
        await _open(entry);
        return;
      case 'share':
        await _share(entry);
        return;
      case 'pin':
        await _togglePin(entry);
        return;
      case 'rename':
        await _rename(entry);
        return;
      case 'move':
        await _move(entry);
        return;
      case 'delete':
        await _delete(entry);
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 30),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final breadcrumb = _breadcrumb();
    final visible = _visibleItems();
    final pinned = visible.where((e) => e.pinned).toList(growable: false);
    final others = visible.where((e) => !e.pinned).toList(growable: false);
    final recent =
        _currentFolderId == null ? _recentFiles() : const <FileManagerEntry>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  TextButton.icon(
                    onPressed: () => setState(() => _currentFolderId = null),
                    icon: const Icon(Icons.home_rounded, size: 18),
                    label: const Text('Root'),
                  ),
                  for (final f in breadcrumb) ...[
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Colors.black45,
                    ),
                    TextButton(
                      onPressed: () => setState(() => _currentFolderId = f.id),
                      child: Text(f.name),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: 'Sort',
              onPressed: _showSortSheet,
              icon: const Icon(Icons.sort_rounded),
            ),
            IconButton(
              tooltip: 'Filter',
              onPressed: _showFilterSheet,
              icon: const Icon(Icons.filter_list_rounded),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        if (recent.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Recent',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recent.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final e = recent[i];
                return ActionChip(
                  avatar: Icon(
                    _iconFor(e),
                    size: 18,
                    color: _colorFor(e),
                  ),
                  label: Text(e.name, overflow: TextOverflow.ellipsis),
                  onPressed: () => _open(e),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                _currentFolderId == null ? 'Files' : 'Folder',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),
            OutlinedButton.icon(
              onPressed: promptNewFolder,
              icon: const Icon(Icons.create_new_folder_rounded, size: 18),
              label: const Text('New Folder'),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: widget.navy),
              onPressed: promptUpload,
              icon: const Icon(Icons.upload_rounded, size: 18),
              label: const Text('Upload'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 28),
            child: Center(
              child: Text(
                widget.query.trim().isEmpty ? 'No files yet.' : 'No results.',
                style: TextStyle(
                  color: widget.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
        else ...[
          if (pinned.isNotEmpty) ...[
            const Text(
              'Pinned',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            ...pinned.map(
              (e) => _EntryTile(
                entry: e,
                icon: _iconFor(e),
                color: _colorFor(e),
                subtitle: e.isFolder
                    ? '${_childrenOf(e.id).length} items'
                    : '${_categoryLabel(e.category)} • ${_prettyBytes(e.sizeBytes)}',
                onOpen: () => _open(e),
                onMenu: () => _showEntryMenu(e),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
          ],
          ...others.map(
            (e) => _EntryTile(
              entry: e,
              icon: _iconFor(e),
              color: _colorFor(e),
              subtitle: e.isFolder
                  ? '${_childrenOf(e.id).length} items'
                  : '${_categoryLabel(e.category)} • ${_prettyBytes(e.sizeBytes)}',
              onOpen: () => _open(e),
              onMenu: () => _showEntryMenu(e),
            ),
          ),
        ],
      ],
    );
  }
}

@immutable
class _FilterState {
  final FileCategory? categoryFilter;
  final bool pinnedOnly;
  final bool foldersOnly;
  final bool filesOnly;

  const _FilterState({
    required this.categoryFilter,
    required this.pinnedOnly,
    required this.foldersOnly,
    required this.filesOnly,
  });
}

@immutable
class _SortState {
  final _FileSortField field;
  final bool asc;

  const _SortState({required this.field, required this.asc});
}

class _EntryTile extends StatelessWidget {
  final FileManagerEntry entry;
  final IconData icon;
  final Color color;
  final String subtitle;
  final VoidCallback onOpen;
  final VoidCallback onMenu;

  const _EntryTile({
    required this.entry,
    required this.icon,
    required this.color,
    required this.subtitle,
    required this.onOpen,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (entry.pinned)
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            entry.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onMenu,
                icon: const Icon(Icons.more_vert_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
