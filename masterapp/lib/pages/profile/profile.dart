import 'package:flutter/material.dart';
import 'editprofile.dart'; // ✅ menuju EditProfileListPage

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ===== Theme Tokens (samakan dengan dashboard) =====
  static const Color NAVY = Color(0xFF101D6E);
  static const Color BG = Color(0xFFF2F9FF);
  static const Color CARD = Color(0xFFFAFEFF);
  static const Color SOFT = Color(0xFFF4F5FF);
  static const Color BORDER = Color(0xFFDCECFF);
  static const Color TEXT = Color(0xFF111827);

  int _navIndex = 3; // profile aktif

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
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.settings, color: Colors.white),
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
                    // ===== Profile Card =====
                    _ProfileCard(
                      name: 'Hanyakra Narendra',
                      role: 'Supervisor',
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileListPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // ===== Quick Buttons (4 kotak biru) =====
                    LayoutBuilder(
                      builder: (context, c) {
                        final spacing = 12.0;
                        final itemW = (c.maxWidth - spacing * 3) / 4;
                        final itemH = isTablet ? 80.0 : 62.0;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(4, (i) {
                            return _QuickButton(
                              width: itemW,
                              height: itemH,
                              color: NAVY,
                              onTap: () {},
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
                          onTap: () {},
                        ),
                        const _DividerLine(),
                        _MenuRow(
                          icon: Icons.check_circle,
                          iconColor: const Color(0xFF16A34A),
                          label: 'Available',
                          onTap: () {},
                        ),
                        const _DividerLine(),
                        _MenuRow(
                          icon: Icons.history,
                          iconColor: Colors.black,
                          label: 'History',
                          onTap: () {},
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
                          onTap: () {},
                        ),
                        const _DividerLine(),
                        _MenuRow(
                          icon: Icons.inventory_2_outlined,
                          iconColor: Colors.black,
                          label: 'Stock in',
                          onTap: () {},
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
                      onTap: () {},
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        children: [
                          const Icon(Icons.logout, size: 18, color: Color(0xFFDC2626)),
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