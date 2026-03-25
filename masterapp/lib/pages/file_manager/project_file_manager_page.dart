import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/file_manager_entry.dart';
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
  final ValueNotifier<FileManagerEntry?> _selected = ValueNotifier(null);
  final ValueNotifier<String?> _currentFolderId = ValueNotifier(null);
  final Map<String, List<_FileContextChatMessage>> _messagesByContext = {};

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
    _selected.dispose();
    _currentFolderId.dispose();
    super.dispose();
  }

  String _contextKey(String projectKey, FileManagerEntry? selected) {
    return '$projectKey:${selected?.id ?? 'root'}';
  }

  @override
  Widget build(BuildContext context) {
    final projectKey = _projectKey();

    return Scaffold(
      backgroundColor: BG,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              _TopBar(
                title: 'File Manager',
                subtitle: widget.project.title,
                onBack: () => Navigator.pop(context),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
                child: TabBar(
                  indicatorColor: NAVY,
                  labelColor: NAVY,
                  unselectedLabelColor: MUTED,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w900),
                  tabs: const [
                    Tab(text: 'Activity'),
                    Tab(text: 'Chat'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
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
                                projectKey: projectKey,
                                query: _searchC.text,
                                navy: NAVY,
                                card: CARD,
                                muted: MUTED,
                                onContextChanged: (selected, folderId) {
                                  _selected.value = selected as FileManagerEntry?;
                                  _currentFolderId.value = folderId as String?;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    _FileContextChatTab(
                      projectKey: projectKey,
                      navy: NAVY,
                      muted: MUTED,
                      selectedListenable: _selected,
                      messagesByContext: _messagesByContext,
                      contextKeyFor: (selected) =>
                          _contextKey(projectKey, selected),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileContextChatMessage {
  final String text;
  final bool isMe;
  final DateTime at;

  const _FileContextChatMessage({
    required this.text,
    required this.isMe,
    required this.at,
  });
}

class _FileContextChatTab extends StatefulWidget {
  final String projectKey;
  final Color navy;
  final Color muted;
  final ValueListenable<FileManagerEntry?> selectedListenable;
  final Map<String, List<_FileContextChatMessage>> messagesByContext;
  final String Function(FileManagerEntry? selected) contextKeyFor;

  const _FileContextChatTab({
    required this.projectKey,
    required this.navy,
    required this.muted,
    required this.selectedListenable,
    required this.messagesByContext,
    required this.contextKeyFor,
  });

  @override
  State<_FileContextChatTab> createState() => _FileContextChatTabState();
}

class _FileContextChatTabState extends State<_FileContextChatTab> {
  final TextEditingController _inputC = TextEditingController();
  final ScrollController _scrollC = ScrollController();

  @override
  void dispose() {
    _inputC.dispose();
    _scrollC.dispose();
    super.dispose();
  }

  void _send(String contextKey) {
    final text = _inputC.text.trim();
    if (text.isEmpty) return;

    final list = widget.messagesByContext.putIfAbsent(contextKey, () => []);
    setState(() {
      list.add(
        _FileContextChatMessage(text: text, isMe: true, at: DateTime.now()),
      );
      _inputC.clear();
    });

    // Scroll after layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollC.hasClients) return;
      _scrollC.animateTo(
        _scrollC.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FileManagerEntry?>(
      valueListenable: widget.selectedListenable,
      builder: (context, selected, _) {
        final contextKey = widget.contextKeyFor(selected);
        final messages = widget.messagesByContext[contextKey] ?? const [];

        final title = selected == null
            ? 'Root'
            : selected.isFolder
                ? 'Folder: ${selected.name}'
                : 'File: ${selected.name}${selected.extension}';

        return Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: widget.navy.withOpacity(0.10),
                    child: Icon(
                      selected == null
                          ? Icons.home_rounded
                          : selected.isFolder
                              ? Icons.folder_rounded
                              : Icons.insert_drive_file_rounded,
                      color: widget.navy,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada chat untuk context ini.',
                        style: TextStyle(
                          color: widget.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollC,
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      itemCount: messages.length,
                      itemBuilder: (context, i) {
                        final m = messages[i];
                        final align = m.isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft;
                        final bg = m.isMe
                            ? widget.navy.withOpacity(0.10)
                            : Colors.white;
                        final border = m.isMe
                            ? widget.navy.withOpacity(0.20)
                            : Colors.black12;
                        return Align(
                          alignment: align,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 320),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: border),
                            ),
                            child: Text(
                              m.text,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDCECFF)),
                      ),
                      child: TextField(
                        controller: _inputC,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(contextKey),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Tulis pesan...',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    style:
                        FilledButton.styleFrom(backgroundColor: widget.navy),
                    onPressed: () => _send(contextKey),
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
