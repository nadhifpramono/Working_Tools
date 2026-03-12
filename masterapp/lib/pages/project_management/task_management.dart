import 'package:flutter/material.dart';

import '../../models/project_item.dart';
import 'document_management.dart';
import '../file_manager/file_manager.dart';
import 'note_management.dart';

class TaskManagementPage extends StatefulWidget {
  final ProjectItem project;
  final int initialSegmentIndex;

  const TaskManagementPage({
    super.key,
    required this.project,
    this.initialSegmentIndex = 0,
  });

  @override
  State<TaskManagementPage> createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage> {
  static const Color NAVY = Color(0xFF101D6E);
  static const Color BG = Color(0xFFF3F9FF);
  static const Color CARD = Colors.white;
  static const Color BORDER = Color(0xFFDCECFF);
  static const Color TEXT = Color(0xFF111827);
  static const Color MUTED = Color(0xFF5E5E5E);

  final TextEditingController _searchC = TextEditingController();
  final _filesKey = GlobalKey<ProjectFilesViewState>();

  int _segmentIndex = 0; // 0 task, 1 note, 2 document, 3 files
  String _statusFilter = 'All status';
  String _deadlineFilter = 'Deadline';

  String _projectKey() {
    final lower = widget.project.title.trim().toLowerCase();
    final sanitized = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return sanitized.replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_|_$'), '');
  }

  List<NoteItem> _notes = const [
    NoteItem(
      title: 'Meeting Safety Brief',
      note:
          'Pastikan semua pekerja menggunakan helm\n'
          'dan sepatu safety sebelum memasuki area\n'
          'proyek utama.',
      created: '18 Feb 2026',
      updated: '19 Feb 2026',
    ),
    NoteItem(
      title: 'Progress Mingguan',
      note: 'Show progress yang sudah dikerjakan selama\nseminggu',
      created: '20 Feb 2026',
      updated: '21 Feb 2026',
    ),
  ];

  List<DocumentItem> _documents = const [
    DocumentItem(
      fileName: 'RAB Renovasi',
      uploadBy: 'Admin',
      description: 'Rincian anggaran dan kebutuhan material.',
      created: '17 Feb 2026',
      updated: '18 Feb 2026',
    ),
    DocumentItem(
      fileName: 'Gambar Kerja',
      uploadBy: 'Admin',
      description: 'Revisi gambar kerja versi 2.',
      created: '20 Feb 2026',
      updated: '22 Feb 2026',
    ),
  ];

  final List<_TaskItem> _tasks = [
    _TaskItem(
      title: 'Membenarkan Plafon',
      subtitle: 'Membenarkan Plafon yang rusak',
      deadline: '28 Feb 2026',
      priority: 'High',
      assignees: ['RA', 'FN', 'BK', 'DK'],
      status: _TaskStatus.toDo,
    ),
    _TaskItem(
      title: 'Renovasi Kantor',
      subtitle: 'Membersihkan dan mengganti\nbarang yang sudah rusak',
      deadline: '28 Feb 2026',
      priority: 'Medium',
      assignees: ['RA', 'FN', 'BK', 'DK'],
      status: _TaskStatus.toDo,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSegmentIndex;
    if (initial >= 0 && initial <= 3) {
      _segmentIndex = initial;
    }
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  Future<void> _handleAddNote() async {
    final created = formatNoteDate(DateTime.now());
    final note = await showUpsertNoteDialog(
      context,
      createdDefault: created,
      navy: NAVY,
    );
    if (note == null) return;

    setState(() => _notes = [note, ..._notes]);
  }

  Future<void> _handleEditNote(NoteItem existing) async {
    final index = _notes.indexOf(existing);
    if (index < 0) return;

    final updated = formatNoteDate(DateTime.now());
    final result = await showUpsertNoteDialog(
      context,
      existing: existing,
      updatedValue: updated,
      navy: NAVY,
    );
    if (result == null) return;

    setState(() {
      final copy = [..._notes];
      copy[index] = result;
      _notes = copy;
    });
  }

  Future<void> _handleAddDocument() async {
    final created = formatDocumentDate(DateTime.now());
    final doc = await showUpsertDocumentDialog(
      context,
      createdDefault: created,
      navy: NAVY,
    );
    if (doc == null) return;

    setState(() => _documents = [doc, ..._documents]);
  }

  Future<void> _handleEditDocument(DocumentItem existing) async {
    final index = _documents.indexOf(existing);
    if (index < 0) return;

    final updated = formatDocumentDate(DateTime.now());
    final result = await showUpsertDocumentDialog(
      context,
      existing: existing,
      updatedValue: updated,
      navy: NAVY,
    );
    if (result == null) return;

    setState(() {
      final copy = [..._documents];
      copy[index] = result;
      _documents = copy;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleTasks = _filteredTasks();
    final query = _searchC.text;

    return Scaffold(
      backgroundColor: BG,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _TopBar(
                  title: widget.project.title,
                  onBack: () => Navigator.pop(context),
                  onSettings: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings clicked')),
                    );
                  },
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
                    children: [
                      _SearchBox(
                        controller: _searchC,
                        hint: _segmentIndex == 0
                            ? 'Search Task'
                            : _segmentIndex == 1
                            ? 'Search Note'
                            : _segmentIndex == 2
                            ? 'Search Document'
                            : 'Search Files',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      _SegmentBar(
                        currentIndex: _segmentIndex,
                        onChanged: (i) => setState(() => _segmentIndex = i),
                      ),
                      const SizedBox(height: 12),
                      if (_segmentIndex == 0) ...[
                        Row(
                          children: [
                            Expanded(
                              child: _FilterBox(
                                label: _statusFilter,
                                onTap: () async {
                                  final result = await _showPicker(
                                    context,
                                    title: 'All status',
                                    options: const [
                                      'All status',
                                      'To do',
                                      'In progress',
                                      'Complecated',
                                    ],
                                  );
                                  if (result != null) {
                                    setState(() => _statusFilter = result);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _FilterBox(
                                label: _deadlineFilter,
                                onTap: () async {
                                  final result = await _showPicker(
                                    context,
                                    title: 'Deadline',
                                    options: const [
                                      'Deadline',
                                      'Nearest',
                                      'Farthest',
                                    ],
                                  );
                                  if (result != null) {
                                    setState(() => _deadlineFilter = result);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (_segmentIndex == 0) ...[
                        ...visibleTasks.map(
                          (task) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _TaskCard(
                              item: task,
                              onStatusChanged: (v) {
                                setState(() => task.status = v);
                              },
                            ),
                          ),
                        ),
                      ] else if (_segmentIndex == 1) ...[
                        ProjectNotesView(
                          query: query,
                          notes: _notes,
                          onEdit: _handleEditNote,
                        ),
                      ] else if (_segmentIndex == 2) ...[
                        ProjectDocumentsView(
                          query: query,
                          documents: _documents,
                          onEdit: _handleEditDocument,
                        ),
                      ] else ...[
                        ProjectFilesView(
                          key: _filesKey,
                          projectKey: _projectKey(),
                          query: query,
                          navy: NAVY,
                          card: CARD,
                          muted: MUTED,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              right: 16,
              bottom: 16,
              child: _AddActionButton(
                label: _segmentIndex == 0
                    ? 'Add Task'
                    : _segmentIndex == 1
                    ? 'Add Note'
                    : _segmentIndex == 2
                    ? 'Add Doc'
                    : 'New',
                onTap: () async {
                  if (_segmentIndex == 0) {
                    final task = await _showAddTaskDialog(context);
                    if (task != null) {
                      setState(() {
                        _tasks.insert(0, task);
                        _segmentIndex = 0;
                      });
                    }
                    return;
                  }

                  if (_segmentIndex == 1) {
                    await _handleAddNote();
                    return;
                  }

                  if (_segmentIndex == 2) {
                    await _handleAddDocument();
                    return;
                  }

                  final action = await showModalBottomSheet<String>(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    builder: (_) {
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
                              leading: const Icon(Icons.upload_rounded),
                              title: const Text('Upload file'),
                              onTap: () => Navigator.pop(context, 'upload'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.create_new_folder_rounded),
                              title: const Text('New folder'),
                              onTap: () => Navigator.pop(context, 'folder'),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      );
                    },
                  );

                  if (action == 'upload') {
                    await _filesKey.currentState?.promptUpload();
                  } else if (action == 'folder') {
                    await _filesKey.currentState?.promptNewFolder();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_TaskItem> _filteredTasks() {
    final q = _searchC.text.trim().toLowerCase();

    final items = _tasks.where((task) {
      final matchSearch =
          q.isEmpty ||
          task.title.toLowerCase().contains(q) ||
          task.subtitle.toLowerCase().contains(q);

      final matchStatus =
          _statusFilter == 'All status' ||
          (_statusFilter == 'To do' && task.status == _TaskStatus.toDo) ||
          (_statusFilter == 'In progress' &&
              task.status == _TaskStatus.inProgress) ||
          ((_statusFilter == 'Complecated' || _statusFilter == 'Completed') &&
              task.status == _TaskStatus.complecated);

      return matchSearch && matchStatus;
    }).toList();

    if (_deadlineFilter == 'Nearest') {
      items.sort((a, b) => a.deadline.compareTo(b.deadline));
    } else if (_deadlineFilter == 'Farthest') {
      items.sort((a, b) => b.deadline.compareTo(a.deadline));
    }

    return items;
  }

  Future<String?> _showPicker(
    BuildContext context, {
    required String title,
    required List<String> options,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
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
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              ...options.map(
                (e) => ListTile(
                  title: Text(
                    e,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onTap: () => Navigator.pop(context, e),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<_TaskItem?> _showAddTaskDialog(BuildContext context) {
    final titleC = TextEditingController();
    final subC = TextEditingController();
    final deadlineC = TextEditingController(text: '28 Feb 2026');
    String priority = 'Medium';

    return showDialog<_TaskItem>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: CARD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Add Task',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: StatefulBuilder(
            builder: (context, setLocal) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _InputField(
                      label: 'Task Name',
                      controller: titleC,
                      hint: 'Membenarkan Plafon',
                    ),
                    const SizedBox(height: 10),
                    _InputField(
                      label: 'Description',
                      controller: subC,
                      hint: 'Membenarkan Plafon yang rusak',
                    ),
                    const SizedBox(height: 10),
                    _InputField(
                      label: 'Deadline',
                      controller: deadlineC,
                      hint: '28 Feb 2026',
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'High', child: Text('High')),
                        DropdownMenuItem(
                          value: 'Medium',
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setLocal(() => priority = v);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NAVY,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (titleC.text.trim().isEmpty) return;

                Navigator.pop(
                  context,
                  _TaskItem(
                    title: titleC.text.trim(),
                    subtitle: subC.text.trim().isEmpty ? '-' : subC.text.trim(),
                    deadline: deadlineC.text.trim().isEmpty
                        ? '-'
                        : deadlineC.text.trim(),
                    priority: priority,
                    assignees: const ['RA', 'FN', 'BK', 'DK'],
                    status: _TaskStatus.toDo,
                  ),
                );
              },
              child: const Text(
                'Create',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TaskItem {
  final String title;
  final String subtitle;
  final String deadline;
  final String priority;
  final List<String> assignees;
  _TaskStatus status;

  _TaskItem({
    required this.title,
    required this.subtitle,
    required this.deadline,
    required this.priority,
    required this.assignees,
    required this.status,
  });
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onSettings;

  const _TopBar({
    required this.title,
    required this.onBack,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: _TaskManagementPageState.NAVY,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onSettings,
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchBox({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _TaskManagementPageState.CARD,
        border: Border.all(color: _TaskManagementPageState.BORDER),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.13),
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 22, color: _TaskManagementPageState.MUTED),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _TaskManagementPageState.MUTED,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const _SegmentBar({required this.currentIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = ['Task', 'Note', 'Document', 'Files'];
    const trackColor = Color(0xFFE7EDFD);

    return Container(
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: trackColor,
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final active = index == currentIndex;
          final isFirst = index == 0;
          final isLast = index == items.length - 1;

          return Expanded(
            child: InkWell(
              onTap: () => onChanged(index),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isFirst ? 30 : 0),
                bottomLeft: Radius.circular(isFirst ? 30 : 0),
                topRight: Radius.circular(isLast ? 30 : 0),
                bottomRight: Radius.circular(isLast ? 30 : 0),
              ),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? _TaskManagementPageState.NAVY : trackColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isFirst ? 30 : 0),
                    bottomLeft: Radius.circular(isFirst ? 30 : 0),
                    topRight: Radius.circular(isLast ? 30 : 0),
                    bottomRight: Radius.circular(isLast ? 30 : 0),
                  ),
                ),
                child: Text(
                  items[index],
                  style: TextStyle(
                    color: active
                        ? Colors.white
                        : _TaskManagementPageState.TEXT,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FilterBox extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterBox({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _TaskManagementPageState.CARD,
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 41,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(Icons.chevron_right, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final _TaskItem item;
  final ValueChanged<_TaskStatus> onStatusChanged;

  const _TaskCard({required this.item, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: _TaskManagementPageState.CARD,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _TaskManagementPageState.NAVY, width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusIcon(status: item.status, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _TaskManagementPageState.TEXT,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _TaskManagementPageState.MUTED,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status :',
                      style: TextStyle(
                        color: _TaskManagementPageState.MUTED,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _StatusPicker(
                      value: item.status,
                      onChanged: onStatusChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: _TaskManagementPageState.MUTED,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.deadline,
                    style: const TextStyle(
                      color: _TaskManagementPageState.MUTED,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _TaskStatus { toDo, inProgress, complecated }

extension _TaskStatusX on _TaskStatus {
  String get label {
    switch (this) {
      case _TaskStatus.toDo:
        return 'To do';
      case _TaskStatus.inProgress:
        return 'In progress';
      case _TaskStatus.complecated:
        return 'Complecated';
    }
  }

  Color get color {
    switch (this) {
      case _TaskStatus.toDo:
        return const Color(0xFF9CA3AF);
      case _TaskStatus.inProgress:
        return const Color(0xFF2563EB);
      case _TaskStatus.complecated:
        return const Color(0xFF16A34A);
    }
  }
}

class _StatusPicker extends StatelessWidget {
  final _TaskStatus value;
  final ValueChanged<_TaskStatus> onChanged;

  const _StatusPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_TaskStatus>(
      tooltip: 'Change status',
      onSelected: onChanged,
      itemBuilder: (context) {
        return _TaskStatus.values
            .map(
              (s) => PopupMenuItem<_TaskStatus>(
                value: s,
                child: Row(
                  children: [
                    _StatusIcon(status: s, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      s.label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            )
            .toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _TaskManagementPageState.MUTED.withOpacity(0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusIcon(status: value, size: 18),
            const SizedBox(width: 8),
            Text(
              value.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _TaskManagementPageState.TEXT,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.expand_more,
              size: 18,
              color: _TaskManagementPageState.MUTED,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final _TaskStatus status;
  final double size;

  const _StatusIcon({required this.status, required this.size});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case _TaskStatus.toDo:
        return _DashedCircle(size: size, color: status.color, strokeWidth: 2);
      case _TaskStatus.inProgress:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: status.color, width: 2),
          ),
          child: Center(
            child: Container(
              width: size * 0.36,
              height: size * 0.36,
              decoration: BoxDecoration(
                color: status.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      case _TaskStatus.complecated:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: status.color, width: 2),
          ),
          child: Icon(Icons.check, size: size * 0.7, color: status.color),
        );
    }
  }
}

class _DashedCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const _DashedCircle({
    required this.size,
    required this.color,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _DashedCirclePainter(
        color: color,
        strokeWidth: strokeWidth,
        dashLength: 4,
        gapLength: 3,
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  const _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Offset.zero & size;
    final path = Path()..addOval(rect.deflate(strokeWidth / 2));

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        var next = distance + dashLength;
        if (next > metric.length) next = metric.length;
        final segment = metric.extractPath(distance, next);
        canvas.drawPath(segment, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}

class _AddTaskButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddTaskButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 82,
          height: 66,
          decoration: BoxDecoration(
            color: _TaskManagementPageState.CARD,
            borderRadius: BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.13),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 17,
                backgroundColor: _TaskManagementPageState.NAVY,
                child: Icon(Icons.add, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 5),
              const Text(
                'Add Task',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: _TaskManagementPageState.TEXT,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 82,
          height: 66,
          decoration: BoxDecoration(
            color: _TaskManagementPageState.CARD,
            borderRadius: BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.13),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 17,
                backgroundColor: _TaskManagementPageState.NAVY,
                child: Icon(Icons.add, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: _TaskManagementPageState.TEXT,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const _InputField({
    required this.label,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptySection({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 46, color: Colors.black38),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
