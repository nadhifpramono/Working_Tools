import 'package:flutter/material.dart';

import '../../models/project_item.dart';
import 'notes_shared.dart';
import 'task_management.dart';

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

  static const ProjectItem _defaultProject = ProjectItem(
    title: 'Renovasi Kantor',
    subtitle: 'Membenarkan Plafon yang rusak',
    progress: 0.90,
    status: 'In Progress',
    priority: 'High',
    totalTask: 12,
    doneTask: 10,
    deadline: '25 Feb 2026',
  );

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
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
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
          if (index == selectedTab) return;

          if (index == 1) {
            setState(() => selectedTab = 1);
            return;
          }

          // Reuse the unified Task/Note/Document screen for Task + Document tabs.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TaskManagementPage(
                project: _defaultProject,
                initialSegmentIndex: index,
              ),
            ),
          );
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
