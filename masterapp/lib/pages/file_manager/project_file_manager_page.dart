import 'package:flutter/material.dart';

import '../../models/project_item.dart';
import 'file_manager.dart';

class ProjectFileManagerPage extends StatefulWidget {
  final ProjectItem project;

  const ProjectFileManagerPage({super.key, required this.project});

  @override
  State<ProjectFileManagerPage> createState() => _ProjectFileManagerPageState();
}

class _ProjectFileManagerPageState extends State<ProjectFileManagerPage> {
  static const Color NAVY = Color(0xFF101D6E);
  static const Color BG = Color(0xFFF3F9FF);
  static const Color CARD = Colors.white;
  static const Color MUTED = Color(0xFF5E5E5E);

  final TextEditingController _searchC = TextEditingController();

  String _projectKey() {
    final lower = widget.project.title.trim().toLowerCase();
    final sanitized = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return sanitized
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BG,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: 'File Manager',
              subtitle: widget.project.title,
              onBack: () => Navigator.pop(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: _SearchBox(
                controller: _searchC,
                hint: 'Search files & folders',
                onChanged: (_) => setState(() {}),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                children: [
                  ProjectFilesView(
                    projectKey: _projectKey(),
                    query: _searchC.text,
                    navy: NAVY,
                    card: CARD,
                    muted: MUTED,
                  ),
                ],
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
  final String subtitle;
  final VoidCallback onBack;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
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
        color: _ProjectFileManagerPageState.CARD,
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
          Icon(
            Icons.search,
            size: 22,
            color: _ProjectFileManagerPageState.MUTED,
          ),
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
                  color: _ProjectFileManagerPageState.MUTED,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

