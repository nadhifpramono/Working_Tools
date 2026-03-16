import 'package:flutter/material.dart';

import '../../models/project_item.dart';
import 'project_file_manager_page.dart';

class FileManagerHomePage extends StatefulWidget {
  const FileManagerHomePage({super.key});

  @override
  State<FileManagerHomePage> createState() => _FileManagerHomePageState();
}

class _FileManagerHomePageState extends State<FileManagerHomePage> {
  static const Color NAVY = Color(0xFF101D6E);
  static const Color BG = Color(0xFFF2F9FF);
  static const Color CARD = Colors.white;
  static const Color BORDER = Color(0xFFE3E1E1);
  static const Color MUTED = Color(0xFF6B7280);
  static const Color TRACK = Color(0xFFC5C5C5);

  final TextEditingController _searchC = TextEditingController();

  final List<ProjectItem> _items = const [
    ProjectItem(
      title: 'Renovasi Kantor',
      subtitle: 'Membenarkan Plafon yang rusak',
      progress: 0.90,
      status: 'In Progress',
      priority: 'High',
      totalTask: 12,
      doneTask: 10,
      deadline: '25 Feb 2026',
    ),
    ProjectItem(
      title: 'Working Tools',
      subtitle: 'Membuat Aplikasi Mobile',
      progress: 0.75,
      status: 'In Progress',
      priority: 'Medium',
      totalTask: 10,
      doneTask: 7,
      deadline: '25 Mar 2026',
    ),
    ProjectItem(
      title: 'Renovasi Rumah',
      subtitle: 'Membenarkan Genteng Rusak',
      progress: 0.50,
      status: 'To Do',
      priority: 'Low',
      totalTask: 5,
      doneTask: 1,
      deadline: '25 Juni 2026',
    ),
  ];

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  List<ProjectItem> _filtered() {
    final q = _searchC.text.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items
        .where(
          (p) =>
              p.title.toLowerCase().contains(q) ||
              p.subtitle.toLowerCase().contains(q),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filtered();

    return Scaffold(
      backgroundColor: BG,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: 'File Manager',
              onBack: () => Navigator.pop(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: _SearchBox(
                controller: _searchC,
                hint: 'Search project',
                onChanged: (_) => setState(() {}),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: visible.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (_, i) {
                  final p = visible[i];
                  return _ProjectCard(
                    item: p,
                    navy: NAVY,
                    border: BORDER,
                    track: TRACK,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProjectFileManagerPage(project: p),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  const _SearchBox({
    required this.controller,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _FileManagerHomePageState.CARD,
        border: Border.all(color: const Color(0xFFDCECFF)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 22, color: _FileManagerHomePageState.MUTED),
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
                  color: _FileManagerHomePageState.MUTED,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectItem item;
  final Color navy;
  final Color border;
  final Color track;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.item,
    required this.navy,
    required this.border,
    required this.track,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (item.progress * 100).clamp(0, 100).toStringAsFixed(0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _FileManagerHomePageState.CARD,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: navy.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.folder_rounded, color: navy),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _FileManagerHomePageState.MUTED,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      color: navy,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: item.progress,
                  minHeight: 8,
                  backgroundColor: track,
                  valueColor: AlwaysStoppedAnimation<Color>(navy),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MetaChip(
                    icon: Icons.flag_rounded,
                    label: item.priority,
                    color: navy,
                  ),
                  const SizedBox(width: 10),
                  _MetaChip(
                    icon: Icons.calendar_month_rounded,
                    label: item.deadline,
                    color: navy,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

