import 'package:flutter/material.dart';

String formatNoteDate(DateTime date) {
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

class NoteItem {
  final String title;
  final String note;
  final String created;
  final String updated;

  const NoteItem({
    required this.title,
    required this.note,
    required this.created,
    required this.updated,
  });
}

Future<NoteItem?> showUpsertNoteDialog(
  BuildContext context, {
  NoteItem? existing,
  String? createdDefault,
  String? updatedValue,
  Color navy = const Color(0xFF101D6E),
}) {
  final isUpdate = existing != null;
  final resolvedCreatedDefault =
      createdDefault ?? existing?.created ?? formatNoteDate(DateTime.now());

  final titleC = TextEditingController(text: existing?.title ?? '');
  final noteC = TextEditingController(text: existing?.note ?? '');
  final createdC = TextEditingController(
    text: existing?.created ?? resolvedCreatedDefault,
  );

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    createdC.text = formatNoteDate(picked);
  }

  return showDialog<NoteItem>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          isUpdate ? 'Update Note' : 'Add Note',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(
                label: 'Title',
                controller: titleC,
                hint: 'Meeting Safety Brief',
              ),
              const SizedBox(height: 10),
              _DialogField(
                label: 'Note',
                controller: noteC,
                hint: 'Tulis catatan...',
                maxLines: 4,
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
              final title = titleC.text.trim();
              final note = noteC.text.trim();
              final created = createdC.text.trim();

              if (title.isEmpty || note.isEmpty || created.isEmpty) return;

              final updated = isUpdate
                  ? (updatedValue ?? formatNoteDate(DateTime.now()))
                  : created;

              Navigator.pop(
                context,
                NoteItem(
                  title: title,
                  note: note,
                  created: created,
                  updated: updated,
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
}

class ProjectNotesView extends StatelessWidget {
  final String query;
  final List<NoteItem>? notes;
  final ValueChanged<NoteItem>? onEdit;

  const ProjectNotesView({
    super.key,
    required this.query,
    this.notes,
    this.onEdit,
  });

  static const Color muted = Color(0xFF5E5E5E);
  static const Color textDark = Color(0xFF111111);
  static const Color cardBorder = Color(0xFF1E2E97);
  static const Color navy = Color(0xFF101D6E);

  List<NoteItem> _seedItems() {
    return const [
      NoteItem(
        title: 'Meeting Safety Brief',
        note: 'Pastikan semua pekerja menggunakan helm\n'
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
  }

  @override
  Widget build(BuildContext context) {
    final source = notes ?? _seedItems();
    final q = query.trim().toLowerCase();
    final visibleNotes = source.where((n) {
      if (q.isEmpty) return true;
      return n.title.toLowerCase().contains(q) ||
          n.note.toLowerCase().contains(q);
    }).toList();

    if (visibleNotes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Text(
          'Belum ada note',
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
        ...visibleNotes.map(
          (note) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _NoteCard(
              title: note.title,
              note: note.note,
              created: note.created,
              updated: note.updated,
              textDark: textDark,
              muted: muted,
              cardBorder: cardBorder,
              navy: navy,
              onEdit: onEdit == null ? null : () => onEdit!(note),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String title;
  final String note;
  final String created;
  final String updated;
  final Color navy;
  final Color textDark;
  final Color muted;
  final Color cardBorder;
  final VoidCallback? onEdit;

  const _NoteCard({
    required this.title,
    required this.note,
    required this.created,
    required this.updated,
    required this.navy,
    required this.textDark,
    required this.muted,
    required this.cardBorder,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
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
                Icons.event_note_outlined,
                size: 24,
                color: Colors.black87,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Text(
              note,
              style: TextStyle(
                color: muted,
                fontSize: 12.5,
                height: 1.35,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontFamily: 'Urbanist',
                          ),
                          children: [
                            const TextSpan(
                              text: 'Created : ',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: created,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontFamily: 'Urbanist',
                          ),
                          children: [
                            const TextSpan(
                              text: 'Updated : ',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: updated,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 28,
                  child: OutlinedButton(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: navy,
                      side: BorderSide(color: navy, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

