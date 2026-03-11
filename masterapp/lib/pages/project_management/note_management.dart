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

/// Standalone preview entrypoint (optional).
void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Note Page',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF3F9FF),
      ),
      home: const Note11Dk(),
    );
  }
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

class Note11Dk extends StatefulWidget {
  const Note11Dk({super.key});

  @override
  State<Note11Dk> createState() => _Note11DkState();
}

class _Note11DkState extends State<Note11Dk> {
  int selectedTab = 1; // 0 Task, 1 Note, 2 Document
  int bottomNavIndex = 2; // contoh aktif di File Manager
  String searchQuery = '';
  late List<NoteItem> _notes;

  static const Color navy = Color(0xFF101D6E);
  static const Color bg = Color(0xFFF3F9FF);

  @override
  void initState() {
    super.initState();
    _notes = const [
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
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(
                          onChanged: (v) => setState(() => searchQuery = v),
                        ),
                        const SizedBox(height: 14),
                        _buildTabs(),
                        const SizedBox(height: 28),
                        ProjectNotesView(
                          query: searchQuery,
                          notes: _notes,
                          onEdit: _handleEditNote,
                        ),
                      ],
                    ),
                  ),
                  _buildAddNoteButton(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: navy,
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const Expanded(
            child: Text(
              'Renovasi Kantor',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar({required ValueChanged<String> onChanged}) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE3E1E1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Search Note',
          hintStyle: TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black87,
            size: 22,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTabItem('Task', 0, isLeft: true),
          _buildTabItem('Note', 1),
          _buildTabItem('Document', 2, isRight: true),
        ],
      ),
    );
  }

  Widget _buildTabItem(
    String label,
    int index, {
    bool isLeft = false,
    bool isRight = false,
  }) {
    final bool active = selectedTab == index;

    BorderRadius radius = BorderRadius.zero;
    if (isLeft) {
      radius = const BorderRadius.horizontal(left: Radius.circular(30));
    } else if (isRight) {
      radius = const BorderRadius.horizontal(right: Radius.circular(30));
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: active ? navy : Colors.transparent,
            borderRadius: radius,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddNoteButton() {
    return Positioned(
      right: 20,
      bottom: 18,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleAddNote,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 82,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: navy,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add Note',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAddNote() async {
    final created = formatNoteDate(DateTime.now());
    final note = await showUpsertNoteDialog(context, createdDefault: created, navy: navy);
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
      navy: navy,
    );
    if (result == null) return;

    setState(() {
      final copy = [..._notes];
      copy[index] = result;
      _notes = copy;
    });
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: bottomNavIndex,
      onTap: (index) {
        setState(() {
          bottomNavIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Urbanist',
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Urbanist',
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notification',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder),
          label: 'File Manager',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined),
          label: 'Profile',
        ),
      ],
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
