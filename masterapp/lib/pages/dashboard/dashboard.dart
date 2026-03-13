import 'package:flutter/material.dart';
import '../profile/profile.dart';
import '../inventory/inventory.dart';
import '../inventory/updateinventory.dart';
import '../project_management/project_management.dart';
import '../notifications/notification.dart';
import '../chat/chat.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color bg = Color(0xFFF2F9FF);

  int _navIndex = 0;

  final LayerLink _settingsLink = LayerLink();
  final SettingsPopupController _popup = SettingsPopupController();

  bool _darkMode = false;
  bool _pinEnabled = false;
  String _language = 'Indonesia';

  @override
  void dispose() {
    _popup.hide();
    super.dispose();
  }

  void _openNotificationPage() {
    _popup.hide();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _DashboardHomeBody(
            settingsLink: _settingsLink,
            popup: _popup,
            darkMode: _darkMode,
            pinEnabled: _pinEnabled,
            language: _language,
            onDarkModeChanged: (v) => setState(() => _darkMode = v),
            onPinChanged: (v) => setState(() => _pinEnabled = v),
            onLanguageChanged: (v) => setState(() => _language = v),
            onTapNotification: _openNotificationPage,
          ),
          const ChatPage(),
          const _PlaceholderPage(title: 'File Manager'),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          _popup.hide();
          setState(() => _navIndex = i);
        },
      ),
    );
  }
}

class _DashboardHomeBody extends StatelessWidget {
  final LayerLink settingsLink;
  final SettingsPopupController popup;

  final bool darkMode;
  final bool pinEnabled;
  final String language;

  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onPinChanged;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onTapNotification;

  const _DashboardHomeBody({
    required this.settingsLink,
    required this.popup,
    required this.darkMode,
    required this.pinEnabled,
    required this.language,
    required this.onDarkModeChanged,
    required this.onPinChanged,
    required this.onLanguageChanged,
    required this.onTapNotification,
  });

  static const Color navy = Color(0xFF101D6E);
  static const Color card = Color(0xFFFAFEFF);
  static const Color soft = Color(0xFFF4F5FF);
  static const Color border = Color(0xFFDCECFF);
  static const Color text = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 768;

    final gridCrossAxisCount = isTablet ? 4 : 3;
    final gridSpacing = isTablet ? 16.0 : 12.0;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: isTablet ? 90 : 80,
              decoration: const BoxDecoration(color: navy),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Dasboard (home page)',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isTablet ? 18 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onTapNotification,
                    icon: const Icon(Icons.notifications_none_rounded),
                    color: Colors.white,
                    tooltip: 'Notifications',
                  ),
                  CompositedTransformTarget(
                    link: settingsLink,
                    child: InkWell(
                      onTap: () {
                        popup.show(
                          context: context,
                          link: settingsLink,
                          darkMode: darkMode,
                          pinEnabled: pinEnabled,
                          language: language,
                          onDarkModeChanged: onDarkModeChanged,
                          onPinChanged: onPinChanged,
                          onLanguageChanged: onLanguageChanged,
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.settings, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _DashboardProfileCard(
                    cardColor: card,
                    borderColor: const Color(0xFFE2E0E0),
                    name: 'Hanyakra Narendra',
                    role: 'Supervisor',
                    onTap: () {},
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, c) {
                      const spacing = 12.0;
                      final itemW = (c.maxWidth - spacing * 3) / 4;
                      final itemH = isTablet ? 80.0 : 62.0;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (i) {
                          return _QuickButton(
                            width: itemW,
                            height: itemH,
                            color: navy,
                            onTap: () {},
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridCrossAxisCount,
                        crossAxisSpacing: gridSpacing,
                        mainAxisSpacing: gridSpacing,
                        childAspectRatio: isTablet ? 1.1 : 1.05,
                      ),
                      children: [
                        _MenuTile(
                          label: 'file manager',
                          icon: Icons.description_outlined,
                          bg: soft,
                          border: border,
                          onTap: () {},
                        ),
                        _MenuTile(
                          label: 'project management',
                          icon: Icons.assignment_outlined,
                          bg: soft,
                          border: border,
                          onTap: () {
                            popup.hide();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProjectManagementPage(),
                              ),
                            );
                          },
                        ),
                        _MenuTile(
                          label: 'inventory',
                          icon: Icons.inventory_2_outlined,
                          bg: soft,
                          border: border,
                          onTap: () {
                            popup.hide();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const InventoryPage(),
                              ),
                            );
                          },
                        ),
                        _MenuTile(
                          label: 'notes',
                          icon: Icons.event_note_outlined,
                          bg: soft,
                          border: border,
                          onTap: () {},
                        ),
                        _MenuTile(
                          label: 'finance',
                          icon: Icons.account_balance_wallet_outlined,
                          bg: soft,
                          border: border,
                          onTap: () {},
                        ),
                        _MenuTile(
                          label: 'service all',
                          icon: Icons.grid_view_rounded,
                          bg: soft,
                          border: border,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Recent Activities',
                    style: TextStyle(
                      fontSize: isTablet ? 22 : 18,
                      fontWeight: FontWeight.w700,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ActivityCard(
                    bg: soft,
                    border: border,
                    items: const [
                      _ActivityItemData(
                        title: 'Safety inspection Completed',
                        icon: Icons.check_circle,
                      ),
                      _ActivityItemData(
                        title: 'Inventory Update',
                        icon: Icons.inventory,
                      ),
                      _ActivityItemData(
                        title: 'New Task Assigned',
                        icon: Icons.assignment,
                      ),
                    ],
                    onTapItem: (index) {
                      if (index == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UpdateInventoryPage(),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardProfileCard extends StatelessWidget {
  final Color cardColor;
  final Color borderColor;
  final String name;
  final String role;
  final VoidCallback onTap;

  const _DashboardProfileCard({
    required this.cardColor,
    required this.borderColor,
    required this.name,
    required this.role,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 768;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Color(0xFFEFEFEF),
                child: Icon(Icons.person_outline, color: Colors.black54),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827).withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final VoidCallback onTap;

  const _QuickButton({
    required this.width,
    required this.height,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(width: width, height: height),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final Color border;
  final VoidCallback onTap;

  const _MenuTile({
    required this.label,
    required this.icon,
    required this.bg,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 768;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: border, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isTablet ? 30 : 26,
                color: const Color(0xFF111827),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Color bg;
  final Color border;
  final List<_ActivityItemData> items;
  final void Function(int index) onTapItem;

  const _ActivityCard({
    required this.bg,
    required this.border,
    required this.items,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 768;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;

          return InkWell(
            onTap: () => onTapItem(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isLast ? Colors.transparent : border,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    color: const Color(0xFF16A34A),
                    size: isTablet ? 26 : 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ActivityItemData {
  final String title;
  final IconData icon;

  const _ActivityItemData({
    required this.title,
    required this.icon,
  });
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF111827),
      unselectedItemColor: const Color(0xFF6B7280),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder_open),
          label: 'File Manager',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}

class SettingsPopupController {
  OverlayEntry? _entry;

  void show({
    required BuildContext context,
    required LayerLink link,
    required bool darkMode,
    required bool pinEnabled,
    required String language,
    required ValueChanged<bool> onDarkModeChanged,
    required ValueChanged<bool> onPinChanged,
    required ValueChanged<String> onLanguageChanged,
  }) {
    hide();

    _entry = OverlayEntry(
      builder: (_) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: hide,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(),
              ),
            ),
            CompositedTransformFollower(
              link: link,
              showWhenUnlinked: false,
              offset: const Offset(-260, 38),
              child: Material(
                color: Colors.transparent,
                child: _SettingsPopupCard(
                  darkMode: darkMode,
                  pinEnabled: pinEnabled,
                  language: language,
                  onClose: hide,
                  onDarkModeChanged: onDarkModeChanged,
                  onPinChanged: onPinChanged,
                  onLanguageChanged: onLanguageChanged,
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_entry!);
  }

  void hide() {
    _entry?.remove();
    _entry = null;
  }
}

class _SettingsPopupCard extends StatelessWidget {
  final bool darkMode;
  final bool pinEnabled;
  final String language;

  final VoidCallback onClose;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onPinChanged;
  final ValueChanged<String> onLanguageChanged;

  const _SettingsPopupCard({
    required this.darkMode,
    required this.pinEnabled,
    required this.language,
    required this.onClose,
    required this.onDarkModeChanged,
    required this.onPinChanged,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cardW = w < 360 ? w - 24 : 285.0;

    return SafeArea(
      child: Container(
        width: cardW,
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFDCECFF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.arrow_back, size: 18),
                  ),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Pengaturan',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(
                  Icons.settings,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SectionCard(
              title: 'Tampilan',
              child: Column(
                children: [
                  _RowSwitch(
                    icon: Icons.dark_mode_outlined,
                    label: 'Mode gelap',
                    value: darkMode,
                    onChanged: onDarkModeChanged,
                  ),
                  const SizedBox(height: 8),
                  _RowDropdown(
                    icon: Icons.language_outlined,
                    label: 'Bahasa',
                    value: language,
                    items: const ['Indonesia', 'English'],
                    onChanged: onLanguageChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _SectionCard(
              title: 'Keamanan',
              child: Column(
                children: [
                  _RowAction(
                    icon: Icons.lock_outline,
                    label: 'Ganti kata sandi',
                    onTap: onClose,
                  ),
                  const SizedBox(height: 8),
                  _RowSwitch(
                    icon: Icons.pin_outlined,
                    label: 'Aktifkan pin',
                    value: pinEnabled,
                    onChanged: onPinChanged,
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

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCECFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _RowSwitch extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _RowSwitch({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF111827)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _RowDropdown extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _RowDropdown({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF111827)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            items: items
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}

class _RowAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RowAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF111827)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}