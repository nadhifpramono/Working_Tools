import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

bool _isImageBytes(Uint8List bytes) {
  if (bytes.length < 12) return false;

  // PNG: 89 50 4E 47 0D 0A 1A 0A
  const png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  var isPng = true;
  for (var i = 0; i < png.length; i++) {
    if (bytes[i] != png[i]) {
      isPng = false;
      break;
    }
  }
  if (isPng) return true;

  // JPEG/JFIF: FF D8 FF
  if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return true;

  // GIF: "GIF87a" or "GIF89a"
  if (bytes[0] == 0x47 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x38 &&
      (bytes[4] == 0x37 || bytes[4] == 0x39) &&
      bytes[5] == 0x61) {
    return true;
  }

  // WEBP: "RIFF" .... "WEBP"
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
  if (bytes[0] == 0x42 && bytes[1] == 0x4D) return true;

  return false;
}

bool _isImageFileName(String name) {
  final lower = name.toLowerCase();
  return lower.endsWith('.png') ||
      lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.jfif') ||
      lower.endsWith('.gif') ||
      lower.endsWith('.webp') ||
      lower.endsWith('.bmp');
}

bool _isPreviewableImage({String? fileName, Uint8List? fileBytes}) {
  if (fileBytes != null && _isImageBytes(fileBytes)) return true;
  if (fileName == null) return false;
  return _isImageFileName(fileName);
}

String formatDocumentDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final dd = date.day.toString().padLeft(2, '0');
  final mm = months[date.month - 1];
  final yyyy = date.year.toString();
  return '$dd $mm $yyyy';
}

class DocumentItem {
  final String description;
  final String fileName;
  final String uploadBy;
  final String created;
  final String updated;
  final String? pickedFileName;
  final String? pickedFilePath;
  final Uint8List? fileBytes;
  final int? fileSizeBytes;

  const DocumentItem({
    required this.description,
    required this.fileName,
    required this.uploadBy,
    required this.created,
    required this.updated,
    this.pickedFileName,
    this.pickedFilePath,
    this.fileBytes,
    this.fileSizeBytes,
  });
}

Future<DocumentItem?> showUpsertDocumentDialog(
  BuildContext context, {
  DocumentItem? existing,
  String? createdDefault,
  String? updatedValue,
  Color navy = const Color(0xFF101D6E),
}) {
  final isUpdate = existing != null;
  final resolvedCreatedDefault =
      createdDefault ?? existing?.created ?? formatDocumentDate(DateTime.now());

  final descC = TextEditingController(text: existing?.description ?? '');
  final fileNameC = TextEditingController(text: existing?.fileName ?? '');
  final uploadByC = TextEditingController(text: existing?.uploadBy ?? '');
  final createdC = TextEditingController(
    text: existing?.created ?? resolvedCreatedDefault,
  );

  String? pickedFileName = existing?.pickedFileName;
  String? pickedFilePath = existing?.pickedFilePath;
  Uint8List? fileBytes = existing?.fileBytes;
  int? fileSizeBytes = existing?.fileSizeBytes;

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    createdC.text = formatDocumentDate(picked);
  }

  return showDialog<DocumentItem>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setLocalState) {
          String prettyBytes(int bytes) {
            const units = ['B', 'KB', 'MB', 'GB'];
            var size = bytes.toDouble();
            var unitIndex = 0;
            while (size >= 1024 && unitIndex < units.length - 1) {
              size /= 1024;
              unitIndex++;
            }
            final fixed = unitIndex == 0 ? size.toStringAsFixed(0) : size.toStringAsFixed(1);
            return '$fixed ${units[unitIndex]}';
          }

          Future<Uint8List?> resolveFileBytes(PlatformFile file) async {
            if (file.bytes != null) return file.bytes;
            final stream = file.readStream;
            if (stream == null) return null;

            final builder = BytesBuilder(copy: false);
            await for (final chunk in stream) {
              builder.add(chunk);
            }
            return builder.takeBytes();
          }

          Future<void> pickFile() async {
            try {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.any,
                allowMultiple: false,
                withData: true,
                withReadStream: true,
              );
              if (result == null || result.files.isEmpty) return;

              final file = result.files.single;
              final resolvedName = file.name.isNotEmpty ? file.name : 'selected_file';
              final resolvedBytes = await resolveFileBytes(file);

              setLocalState(() {
                pickedFileName = resolvedName;
                pickedFilePath = kIsWeb ? null : file.path;
                fileBytes = resolvedBytes;
                fileSizeBytes = file.size;
                if (fileNameC.text.trim().isEmpty && resolvedName.trim().isNotEmpty) {
                  fileNameC.text = resolvedName.replaceAll(RegExp(r'\\.[^.]+$'), '');
                }
              });
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Upload file gagal: $e')),
              );
            }
          }

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              isUpdate ? 'Update Document' : 'Add Document',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DialogField(
                    label: 'File Name',
                    controller: fileNameC,
                    hint: 'RAB Renovasi',
                  ),
                  const SizedBox(height: 10),
                  _DialogField(
                    label: 'Description',
                    controller: descC,
                    hint: 'Keterangan dokumen...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Upload File',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            pickedFileName ?? 'Belum ada file dipilih',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navy,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: pickFile,
                        child: const Text(
                          'Choose',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _DialogField(
                    label: 'Upload by',
                    controller: uploadByC,
                    hint: 'Nama uploader',
                  ),
                  const SizedBox(height: 10),
                  _DialogField(
                    label: 'Create',
                    controller: createdC,
                    hint: resolvedCreatedDefault,
                    suffixIcon: IconButton(
                      onPressed: pickDate,
                      icon: const Icon(Icons.calendar_today_outlined, size: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'File preview',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: pickedFileName == null
                        ? const Center(
                            child: Text(
                              'Preview akan tampil di sini',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: (_isPreviewableImage(
                                      fileName: pickedFileName,
                                      fileBytes: fileBytes,
                                    ) &&
                                    fileBytes != null)
                                ? Image.memory(
                                    fileBytes!,
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.insert_drive_file_outlined,
                                            size: 34,
                                            color: Colors.black54,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            pickedFileName!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          if (fileSizeBytes != null)
                                            Text(
                                              prettyBytes(fileSizeBytes!),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black54,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final fileName = fileNameC.text.trim();
                  final uploadBy = uploadByC.text.trim();
                  final desc = descC.text.trim();
                  final created = createdC.text.trim();

                  if (fileName.isEmpty || uploadBy.isEmpty || created.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mohon lengkapi File Name, Upload by, dan Create.')),
                    );
                    return;
                  }
                  if (pickedFileName == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mohon pilih file dulu.')),
                    );
                    return;
                  }
                  if (kIsWeb && fileBytes == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Di Web, file harus dibaca sebagai bytes. Coba pilih file lagi.')),
                    );
                    return;
                  }
                  if (!kIsWeb && fileBytes == null && pickedFilePath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File tidak terbaca. Coba pilih file lagi.')),
                    );
                    return;
                  }

                  final updated = isUpdate
                      ? (updatedValue ?? formatDocumentDate(DateTime.now()))
                      : created;

                  Navigator.pop(
                    context,
                    DocumentItem(
                      fileName: fileName,
                      uploadBy: uploadBy,
                      description: desc,
                      created: created,
                      updated: updated,
                      pickedFileName: pickedFileName,
                      pickedFilePath: pickedFilePath,
                      fileBytes: fileBytes,
                      fileSizeBytes: fileSizeBytes,
                    ),
                  );
                },
                child: Text(
                  isUpdate ? 'Update' : 'Create',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

class ProjectDocumentsView extends StatelessWidget {
  final String query;
  final List<DocumentItem>? documents;
  final ValueChanged<DocumentItem>? onEdit;

  const ProjectDocumentsView({
    super.key,
    required this.query,
    this.documents,
    this.onEdit,
  });

  static const Color muted = Color(0xFF5E5E5E);
  static const Color textDark = Color(0xFF111111);
  static const Color cardBorder = Color(0xFF1E2E97);

  List<DocumentItem> _seedItems() {
    return const [
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
  }

  @override
  Widget build(BuildContext context) {
    final source = documents ?? _seedItems();
    final q = query.trim().toLowerCase();
    final visible = source.where((d) {
      if (q.isEmpty) return true;
      return d.fileName.toLowerCase().contains(q) ||
          d.uploadBy.toLowerCase().contains(q) ||
          d.description.toLowerCase().contains(q);
    }).toList();

    if (visible.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Text(
          'Belum ada document',
          style: TextStyle(
            color: muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'Urbanist',
          ),
        ),
      );
    }

    return Column(
      children: [
        ...visible.map(
          (doc) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _DocumentCard(
              fileName: doc.fileName,
              uploadBy: doc.uploadBy,
              description: doc.description,
              created: doc.created,
              updated: doc.updated,
              fileBytes: doc.fileBytes,
              pickedFileName: doc.pickedFileName,
              fileSizeBytes: doc.fileSizeBytes,
              textDark: textDark,
              muted: muted,
              cardBorder: cardBorder,
              onEdit: onEdit == null ? null : () => onEdit!(doc),
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final String fileName;
  final String uploadBy;
  final String description;
  final String created;
  final String updated;
  final Uint8List? fileBytes;
  final String? pickedFileName;
  final int? fileSizeBytes;
  final Color textDark;
  final Color muted;
  final Color cardBorder;
  final VoidCallback? onEdit;

  const _DocumentCard({
    required this.fileName,
    required this.uploadBy,
    required this.description,
    required this.created,
    required this.updated,
    required this.fileBytes,
    required this.pickedFileName,
    required this.fileSizeBytes,
    required this.textDark,
    required this.muted,
    required this.cardBorder,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    String prettyBytes(int bytes) {
      const units = ['B', 'KB', 'MB', 'GB'];
      var size = bytes.toDouble();
      var unitIndex = 0;
      while (size >= 1024 && unitIndex < units.length - 1) {
        size /= 1024;
        unitIndex++;
      }
      final fixed = unitIndex == 0 ? size.toStringAsFixed(0) : size.toStringAsFixed(1);
      return '$fixed ${units[unitIndex]}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5F5),
        borderRadius: BorderRadius.circular(18),
        border: Border(
          top: BorderSide(color: cardBorder, width: 2),
          left: BorderSide(color: cardBorder, width: 2),
          right: BorderSide(color: cardBorder, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 24,
                color: Colors.black87,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  fileName,
                  style: TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),
              if (onEdit != null)
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.edit_outlined, size: 18),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Upload by : $uploadBy',
            style: TextStyle(
              color: muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'Urbanist',
            ),
          ),
          const SizedBox(height: 10),
          if (pickedFileName != null || fileBytes != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: (pickedFileName != null &&
                        _isPreviewableImage(fileName: pickedFileName, fileBytes: fileBytes) &&
                        fileBytes != null)
                    ? Image.memory(
                        fileBytes!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: const Color(0xFFF3F3F3),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.insert_drive_file_outlined,
                                  size: 30,
                                  color: Colors.black54,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  pickedFileName ?? fileName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Urbanist',
                                  ),
                                ),
                                if (fileSizeBytes != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    prettyBytes(fileSizeBytes!),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (description.trim().isNotEmpty) ...[
            Text(
              description,
              style: TextStyle(
                color: textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  'Create : $created',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),
              Text(
                'Update : $updated',
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Urbanist',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final Widget? suffixIcon;

  const _DialogField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
