import 'package:flutter/material.dart';
import 'editprofile.dart';
import '../notifications/notification.dart';
import 'stockout.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ===== Theme Tokens =====
  static const Color NAVY = Color(0xFF101D6E);
  static const Color BG = Color(0xFFF2F9FF);
  static const Color CARD = Color(0xFFFAFEFF);
  static const Color SOFT = Color(0xFFF4F5FF);
  static const Color BORDER = Color(0xFFDCECFF);
  static const Color TEXT = Color(0xFF111827);

  // ===== Settings Popup State =====
  final SettingsPopupController _popup = SettingsPopupController();

  bool _darkMode = false;
  bool _pinEnabled = false;
  String _language = 'Indonesia';

  @override
  void dispose() {
    _popup.hide();
    super.dispose();
  }

  void _onTapNotification() {
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
    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 768;

    return Scaffold(
      backgroundColor: BG,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ===== Top Header =====
            SliverToBoxAdapter(
              child: Container(
                height: isTablet ? 90 : 80,
                color: NAVY,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Profil',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isTablet ? 18 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // ===== Notification icon =====
                    IconButton(
                      onPressed: _onTapNotification,
                      icon: const Icon(Icons.notifications_none_rounded),
                      color: Colors.white,
                      tooltip: "Notifications",
                    ),

                    // ===== Settings icon =====
                    Builder(
                      builder: (btnCtx) {
                        return InkWell(
                          onTap: () {
                            _popup.showAnchored(
                              context: context,
                              targetContext: btnCtx,
                              darkMode: _darkMode,
                              pinEnabled: _pinEnabled,
                              language: _language,
                              onDarkModeChanged: (v) =>
                                  setState(() => _darkMode = v),
                              onPinChanged: (v) =>
                                  setState(() => _pinEnabled = v),
                              onLanguageChanged: (v) =>
                                  setState(() => _language = v),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.settings, color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ===== Content =====
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // ===== Profile Card =====
                    _ProfileCard(
                      name: 'Hanyakra Narendra',
                      role: 'Supervisor',
                      onEdit: () {
                        _popup.hide();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileListPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // ===== Quick Buttons =====
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
                              color: NAVY,
                              onTap: () => _popup.hide(),
                            );
                          }),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // ===== Menu Card 1 =====
                    _MenuGroupCard(
                      children: [
                        _MenuRow(
                          icon: Icons.build_outlined,
                          iconColor: Colors.black,
                          label: 'Service',
                          onTap: () => _popup.hide(),
                        ),
                        const _DividerLine(),
                        _MenuRow(
                          icon: Icons.check_circle,
                          iconColor: Color(0xFF16A34A),
                          label: 'Available',
                          onTap: () => _popup.hide(),
                        ),
                        const _DividerLine(),
                        _MenuRow(
                          icon: Icons.history,
                          iconColor: Colors.black,
                          label: 'History',
                          onTap: () => _popup.hide(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ===== Menu Card 2 =====
                    _MenuGroupCard(
                      children: [
                        _MenuRow(
                          icon: Icons.school_outlined,
                          iconColor: Colors.black,
                          label: 'Stock out',
                          onTap: () {
                            _popup.hide();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const StockOutPage(),
                              ),
                            );
                          },
                        ),
                        const _DividerLine(),
                        _MenuRow(
                          icon: Icons.inventory_2_outlined,
                          iconColor: Colors.black,
                          label: 'Stock in',
                          onTap: () {
                            _popup.hide();
                            
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        const Icon(Icons.help_outline, size: 18, color: TEXT),
                        const SizedBox(width: 8),
                        Text(
                          'Butuh bantuan?',
                          style: TextStyle(
                            color: TEXT,
                            fontSize: isTablet ? 14 : 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    InkWell(
                      onTap: () => _popup.hide(),
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        children: [
                          const Icon(Icons.logout,
                              size: 18, color: Color(0xFFDC2626)),
                          const SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              color: const Color(0xFFDC2626),
                              fontSize: isTablet ? 14 : 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================== COMPONENTS ===================

class _ProfileCard extends StatelessWidget {
  final String name;
  final String role;
  final VoidCallback onEdit;

  static const Color CARD = Color(0xFFFAFEFF);

  const _ProfileCard({
    required this.name,
    required this.role,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 768;

    return Material(
      color: CARD,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E0E0), width: 1),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage("https://placehold.co/120x120"),
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
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.edit, size: 16, color: Color(0xFF2563EB)),
                  ],
                ),
              ),
            ),
          ],
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

class _MenuGroupCard extends StatelessWidget {
  final List<Widget> children;
  static const Color CARD = Color(0xFFFAFEFF);

  const _MenuGroupCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CARD,
      borderRadius: BorderRadius.circular(16),
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.07),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E0E0), width: 1),
        ),
        child: Column(children: children),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: const Color(0xFFE5E7EB),
      margin: const EdgeInsets.symmetric(vertical: 2),
    );
  }
}

// =======================================================
// SETTINGS POPUP
// =======================================================

class SettingsPopupController {
  OverlayEntry? _entry;

  void showAnchored({
    required BuildContext context,
    required BuildContext targetContext,
    required bool darkMode,
    required bool pinEnabled,
    required String language,
    required ValueChanged<bool> onDarkModeChanged,
    required ValueChanged<bool> onPinChanged,
    required ValueChanged<String> onLanguageChanged,
  }) {
    hide();

    const double cardW = 320;
    const double topGap = 10;
    const double safe = 12;

    final overlay = Overlay.of(context);
    final overlayBox = overlay.context.findRenderObject() as RenderBox;

    final targetBox = targetContext.findRenderObject() as RenderBox;
    final targetTopLeft =
        targetBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final targetSize = targetBox.size;

    final screenW = overlayBox.size.width;
    final screenH = overlayBox.size.height;

    double left = targetTopLeft.dx - (cardW - targetSize.width);
    double top = targetTopLeft.dy + targetSize.height + topGap;

    left = left.clamp(safe, screenW - cardW - safe);

    const estimatedH = 330.0;
    if (top + estimatedH > screenH - safe) {
      top = (targetTopLeft.dy - estimatedH - topGap).clamp(
        safe,
        screenH - estimatedH - safe,
      );
    }

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
            Positioned(
              left: left,
              top: top,
              width: cardW,
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

    overlay.insert(_entry!);
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
    return SafeArea(
      child: Container(
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
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
                const Icon(Icons.settings, size: 18, color: Color(0xFF6B7280)),
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

  const _SectionCard({required this.title, required this.child});

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
            const Icon(Icons.chevron_right,
                size: 18, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }
}