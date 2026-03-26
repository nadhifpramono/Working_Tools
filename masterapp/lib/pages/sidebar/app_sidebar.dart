import 'package:flutter/material.dart';

enum WorkingToolsMenu {
  dashboard,
  chat,
  fileManager,
  profile,
  myWork,
  notepad,
  arsip,
  activityLog,
  reports,
  taskBoard,
  meeting,
  notes,
  archive,
}

class WorkingToolsSidebar extends StatelessWidget {
  final WorkingToolsMenu activeMenu;

  const WorkingToolsSidebar({
    super.key,
    required this.activeMenu,
  });

  static const Color navy = Color(0xFF101D6E);
  static const Color bg = Color(0xFFF2F9FF);
  static const Color border = Color(0xFFDCECFF);

  void _goTo(BuildContext context, String routeName) {
    Navigator.pop(context);

    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == routeName) return;

    Navigator.pushReplacementNamed(context, routeName);
  }

  void _comingSoon(BuildContext context, String title) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title belum dibuat')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: bg,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              decoration: const BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.workspaces_rounded, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Working Tools',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Main Navigation',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
                children: [
                  _SidebarTile(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    active: activeMenu == WorkingToolsMenu.dashboard,
                    onTap: () => _goTo(context, '/dashboard'),
                  ),
                  _SidebarTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Chat',
                    active: activeMenu == WorkingToolsMenu.chat,
                    onTap: () => _goTo(context, '/chat'),
                  ),
                  _SidebarTile(
                    icon: Icons.folder_open_rounded,
                    label: 'File Manager',
                    active: activeMenu == WorkingToolsMenu.fileManager,
                    onTap: () => _goTo(context, '/file-manager'),
                  ),
                  _SidebarTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                    active: activeMenu == WorkingToolsMenu.profile,
                    onTap: () => _goTo(context, '/profile'),
                  ),

                  const SizedBox(height: 12),
                  const _SidebarSectionTitle(title: 'Workspace'),

                  _SidebarTile(
                    icon: Icons.work_outline_rounded,
                    label: 'My Work',
                    active: activeMenu == WorkingToolsMenu.myWork,
                    onTap: () => _comingSoon(context, 'My Work'),
                  ),
                  _SidebarTile(
                    icon: Icons.sticky_note_2_outlined,
                    label: 'Notepad',
                    active: activeMenu == WorkingToolsMenu.notepad,
                    onTap: () => _comingSoon(context, 'Notepad'),
                  ),
                  _SidebarTile(
                    icon: Icons.archive_outlined,
                    label: 'Arsip',
                    active: activeMenu == WorkingToolsMenu.arsip,
                    onTap: () => _comingSoon(context, 'Arsip'),
                  ),
                  _SidebarTile(
                    icon: Icons.history_rounded,
                    label: 'Activity Log',
                    active: activeMenu == WorkingToolsMenu.activityLog,
                    onTap: () => _comingSoon(context, 'Activity Log'),
                  ),
                  _SidebarTile(
                    icon: Icons.bar_chart_rounded,
                    label: 'Reports',
                    active: activeMenu == WorkingToolsMenu.reports,
                    onTap: () => _comingSoon(context, 'Reports'),
                  ),
                  _SidebarTile(
                    icon: Icons.task_alt_rounded,
                    label: 'Task Board',
                    active: activeMenu == WorkingToolsMenu.taskBoard,
                    onTap: () => _comingSoon(context, 'Task Board'),
                  ),
                  _SidebarTile(
                    icon: Icons.groups_rounded,
                    label: 'Meeting',
                    active: activeMenu == WorkingToolsMenu.meeting,
                    onTap: () => _comingSoon(context, 'Meeting'),
                  ),
                  _SidebarTile(
                    icon: Icons.description_outlined,
                    label: 'Notes',
                    active: activeMenu == WorkingToolsMenu.notes,
                    onTap: () => _comingSoon(context, 'Notes'),
                  ),
                  _SidebarTile(
                    icon: Icons.inventory_2_outlined,
                    label: 'Archive',
                    active: activeMenu == WorkingToolsMenu.archive,
                    onTap: () => _comingSoon(context, 'Archive'),
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

class _SidebarSectionTitle extends StatelessWidget {
  final String title;

  const _SidebarSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color navy = Color(0xFF101D6E);
    const Color border = Color(0xFFDCECFF);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: active ? navy.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active ? navy : border,
                width: active ? 1.2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 21,
                  color: active ? navy : const Color(0xFF374151),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: active ? navy : const Color(0xFF111827),
                    ),
                  ),
                ),
                if (active)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: navy,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}