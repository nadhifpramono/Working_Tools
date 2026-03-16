import 'dart:typed_data';

import '../models/file_manager_entry.dart';

class ProjectFileStore {
  String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  FileCategory categoryFromFileName(String name) => FileCategory.other;

  String extensionFromFileName(String name) => '';

  Future<List<FileManagerEntry>> load(String projectKey) async => const [];

  Future<void> save(String projectKey, List<FileManagerEntry> entries) async {}

  Future<String?> filePath(String projectKey, FileManagerEntry entry) async =>
      null;

  Future<Uint8List?> readFileBytes(
    String projectKey,
    FileManagerEntry entry,
  ) async =>
      null;

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
    return FileManagerEntry(
      id: newId(),
      projectKey: projectKey,
      name: displayName.trim().isEmpty ? originalName : displayName.trim(),
      type: FileManagerEntryType.file,
      parentId: parentId,
      extension: extensionFromFileName(originalName),
      category: categoryFromFileName(originalName),
      sizeBytes: bytes.lengthInBytes,
      createdAt: now,
      updatedAt: now,
      lastOpenedAt: null,
      pinned: false,
    );
  }

  Future<void> deleteFileContent(
    String projectKey,
    FileManagerEntry entry,
  ) async {}
}

