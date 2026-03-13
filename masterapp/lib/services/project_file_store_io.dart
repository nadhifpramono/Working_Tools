import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../models/file_manager_entry.dart';

class ProjectFileStore {
  static const _rootFolderName = 'working_tools_files';

  Future<Directory> _ensureProjectDir(String projectKey) async {
    final base = await getApplicationDocumentsDirectory();
    final root = Directory(
      '${base.path}${Platform.pathSeparator}$_rootFolderName',
    );
    if (!await root.exists()) {
      await root.create(recursive: true);
    }

    final projectDir =
        Directory('${root.path}${Platform.pathSeparator}$projectKey');
    if (!await projectDir.exists()) {
      await projectDir.create(recursive: true);
    }

    final filesDir =
        Directory('${projectDir.path}${Platform.pathSeparator}files');
    if (!await filesDir.exists()) {
      await filesDir.create(recursive: true);
    }

    return projectDir;
  }

  Future<File> _indexFile(String projectKey) async {
    final dir = await _ensureProjectDir(projectKey);
    return File('${dir.path}${Platform.pathSeparator}index.json');
  }

  Future<Directory> _filesDir(String projectKey) async {
    final dir = await _ensureProjectDir(projectKey);
    return Directory('${dir.path}${Platform.pathSeparator}files');
  }

  String newId() {
    final r = Random.secure();
    final ts = DateTime.now().microsecondsSinceEpoch.toString();
    final salt = r.nextInt(1 << 32).toRadixString(16);
    return '${ts}_$salt';
  }

  FileCategory categoryFromFileName(String name) {
    final lower = name.toLowerCase();
    bool hasExt(String ext) => lower.endsWith(ext);

    if (hasExt('.png') ||
        hasExt('.jpg') ||
        hasExt('.jpeg') ||
        hasExt('.jfif') ||
        hasExt('.gif') ||
        hasExt('.webp') ||
        hasExt('.avif') ||
        hasExt('.bmp') ||
        hasExt('.tif') ||
        hasExt('.tiff') ||
        hasExt('.heif') ||
        hasExt('.heic')) {
      return FileCategory.image;
    }
    if (hasExt('.mp4') || hasExt('.mov') || hasExt('.mkv') || hasExt('.avi')) {
      return FileCategory.video;
    }
    if (hasExt('.mp3') || hasExt('.wav') || hasExt('.m4a') || hasExt('.aac')) {
      return FileCategory.audio;
    }
    if (hasExt('.zip') ||
        hasExt('.rar') ||
        hasExt('.7z') ||
        hasExt('.tar') ||
        hasExt('.gz')) {
      return FileCategory.archive;
    }
    if (hasExt('.pdf') ||
        hasExt('.doc') ||
        hasExt('.docx') ||
        hasExt('.xls') ||
        hasExt('.xlsx') ||
        hasExt('.ppt') ||
        hasExt('.pptx') ||
        hasExt('.txt') ||
        hasExt('.md')) {
      return FileCategory.document;
    }
    return FileCategory.other;
  }

  String extensionFromFileName(String name) {
    final trimmed = name.trim();
    final i = trimmed.lastIndexOf('.');
    if (i <= 0 || i == trimmed.length - 1) return '';
    final ext = trimmed.substring(i);
    if (ext.length > 10) return '';
    return ext.toLowerCase();
  }

  Future<List<FileManagerEntry>> load(String projectKey) async {
    final file = await _indexFile(projectKey);
    if (!await file.exists()) return const [];

    try {
      final content = await file.readAsString();
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, Object?>) return const [];
      final entries = decoded['entries'];
      if (entries is! List) return const [];
      return entries
          .whereType<Map>()
          .map((e) => FileManagerEntry.fromJson(e.cast<String, Object?>()))
          .where((e) => e.id.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(String projectKey, List<FileManagerEntry> entries) async {
    final file = await _indexFile(projectKey);
    final payload = <String, Object?>{
      'version': 1,
      'updatedAt': DateTime.now().toIso8601String(),
      'entries': entries.map((e) => e.toJson()).toList(growable: false),
    };
    await file.writeAsString(jsonEncode(payload));
  }

  Future<String?> filePath(String projectKey, FileManagerEntry entry) async {
    if (!entry.isFile) return null;
    final dir = await _filesDir(projectKey);
    return '${dir.path}${Platform.pathSeparator}${entry.id}${entry.extension}';
  }

  Future<Uint8List?> readFileBytes(
    String projectKey,
    FileManagerEntry entry,
  ) async {
    final path = await filePath(projectKey, entry);
    if (path == null) return null;
    final f = File(path);
    if (!await f.exists()) return null;
    return f.readAsBytes();
  }

  Future<FileManagerEntry> createFolder({
    required String projectKey,
    required String name,
    required String? parentId,
    required DateTime now,
  }) async {
    return FileManagerEntry(
      id: newId(),
      projectKey: projectKey,
      name: name.trim(),
      type: FileManagerEntryType.folder,
      parentId: parentId,
      extension: '',
      category: FileCategory.other,
      sizeBytes: 0,
      createdAt: now,
      updatedAt: now,
      lastOpenedAt: null,
      pinned: false,
    );
  }

  Future<FileManagerEntry> writeImportedFile({
    required String projectKey,
    required String displayName,
    required String originalName,
    required Uint8List bytes,
    required String? parentId,
    required DateTime now,
  }) async {
    final safeName =
        displayName.trim().isEmpty ? originalName : displayName.trim();
    final ext = extensionFromFileName(originalName);
    final entry = FileManagerEntry(
      id: newId(),
      projectKey: projectKey,
      name: safeName,
      type: FileManagerEntryType.file,
      parentId: parentId,
      extension: ext,
      category: categoryFromFileName(originalName),
      sizeBytes: bytes.lengthInBytes,
      createdAt: now,
      updatedAt: now,
      lastOpenedAt: null,
      pinned: false,
    );

    final path = await filePath(projectKey, entry);
    if (path != null) {
      final f = File(path);
      await f.writeAsBytes(bytes, flush: true);
    }
    return entry;
  }

  Future<void> deleteFileContent(String projectKey, FileManagerEntry entry) async {
    final path = await filePath(projectKey, entry);
    if (path == null) return;
    final f = File(path);
    if (await f.exists()) {
      await f.delete();
    }
  }
}
