import 'package:flutter/foundation.dart';

enum FileManagerEntryType { file, folder }

enum FileCategory { document, image, video, audio, archive, other }

@immutable
class FileManagerEntry {
  final String id;
  final String projectKey;
  final String name;
  final FileManagerEntryType type;
  final String? parentId;
  final String extension; // includes leading dot, or empty string
  final FileCategory category;
  final int sizeBytes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastOpenedAt;
  final bool pinned;

  const FileManagerEntry({
    required this.id,
    required this.projectKey,
    required this.name,
    required this.type,
    required this.parentId,
    required this.extension,
    required this.category,
    required this.sizeBytes,
    required this.createdAt,
    required this.updatedAt,
    required this.lastOpenedAt,
    required this.pinned,
  });

  bool get isFolder => type == FileManagerEntryType.folder;
  bool get isFile => type == FileManagerEntryType.file;

  FileManagerEntry copyWith({
    String? name,
    String? parentId,
    String? extension,
    FileCategory? category,
    int? sizeBytes,
    DateTime? updatedAt,
    DateTime? lastOpenedAt,
    bool? pinned,
  }) {
    return FileManagerEntry(
      id: id,
      projectKey: projectKey,
      name: name ?? this.name,
      type: type,
      parentId: parentId ?? this.parentId,
      extension: extension ?? this.extension,
      category: category ?? this.category,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      pinned: pinned ?? this.pinned,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'projectKey': projectKey,
      'name': name,
      'type': describeEnum(type),
      'parentId': parentId,
      'extension': extension,
      'category': describeEnum(category),
      'sizeBytes': sizeBytes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastOpenedAt': lastOpenedAt?.toIso8601String(),
      'pinned': pinned,
    };
  }

  static FileManagerEntry fromJson(Map<String, Object?> json) {
    FileManagerEntryType parseType(Object? v) {
      if (v is String && v.toLowerCase() == 'folder') {
        return FileManagerEntryType.folder;
      }
      return FileManagerEntryType.file;
    }

    FileCategory parseCategory(Object? v) {
      if (v is! String) return FileCategory.other;
      switch (v.toLowerCase()) {
        case 'document':
          return FileCategory.document;
        case 'image':
          return FileCategory.image;
        case 'video':
          return FileCategory.video;
        case 'audio':
          return FileCategory.audio;
        case 'archive':
          return FileCategory.archive;
        default:
          return FileCategory.other;
      }
    }

    DateTime parseDate(Object? v) {
      if (v is String) return DateTime.parse(v);
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    DateTime? parseNullableDate(Object? v) {
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    return FileManagerEntry(
      id: (json['id'] as String?) ?? '',
      projectKey: (json['projectKey'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      type: parseType(json['type']),
      parentId: json['parentId'] as String?,
      extension: (json['extension'] as String?) ?? '',
      category: parseCategory(json['category']),
      sizeBytes: (json['sizeBytes'] as int?) ?? 0,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      lastOpenedAt: parseNullableDate(json['lastOpenedAt']),
      pinned: (json['pinned'] as bool?) ?? false,
    );
  }
}

