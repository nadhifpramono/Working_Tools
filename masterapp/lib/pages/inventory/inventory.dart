import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  // ===== Theme Tokens (sesuai UI kamu) =====
  static const Color NAVY = Color(0xFF101D6E);
  static const Color BG = Color(0xFFF2F9FF);
  static const Color CARD = Color(0xFFFAFEFF);
  static const Color SOFT = Color(0xFFF4F5FF);
  static const Color BORDER = Color(0xFFDCECFF);
  static const Color TEXT = Color(0xFF111827);
  static const Color MUTED = Color(0xFF6B7280);

  // ===== State =====
  final TextEditingController _searchC = TextEditingController();
  String _category = 'Semua';
  String _sort = 'Nama A-Z';
  int _navIndex = 0;

  final List<_InventoryItem> _items = [
    _InventoryItem(
      name: 'Helm Keselamatan',
      icon: Icons.engineering,
      current: 50,
      max: 50,
      status: _StockStatus.runOut, category: '',
    ),
    _InventoryItem(
      name: 'Drill Machine',
      icon: Icons.handyman,
      current: 23,
      max: 5,
      status: _StockStatus.available, category: '',
    ),
    _InventoryItem(
      name: 'Jaket Safety',
      icon: Icons.checkroom,
      current: 50,
      max: 25,
      status: _StockStatus.available, category: '',
    ),
    _InventoryItem(
      name: 'Gergaji Machine',
      icon: Icons.construction,
      current: 20,
      max: 7,
      status: _StockStatus.available, category: '',
    ),
    _InventoryItem(
      name: 'Unit Tractor',
      icon: Icons.agriculture,
      current: 10,
      max: 3,
      status: _StockStatus.available, category: '',
    ),
    _InventoryItem(
      name: 'Unit Loader',
      icon: Icons.agriculture_outlined,
      current: 10,
      max: 4,
      status: _StockStatus.available, category: '',
    ),
  ];

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  List<_InventoryItem> get _filtered {
    final q = _searchC.text.trim().toLowerCase();

    var list = _items.where((e) {
      final matchQ = q.isEmpty || e.name.toLowerCase().contains(q);
      final matchCat = _category == 'Semua' ? true : e.category == _category;
      return matchQ && matchCat;
    }).toList();

    switch (_sort) {
      case 'Nama Z-A':
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Stok Terbanyak':
        list.sort((a, b) => (b.current).compareTo(a.current));
        break;
      case 'Stok Tersedikit':
        list.sort((a, b) => (a.current).compareTo(b.current));
        break;
      default: // Nama A-Z
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 768;

    return Scaffold(
      backgroundColor: BG,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 16,
            vertical: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Top Header =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Inventory',
                    style: TextStyle(
                      color: TEXT,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // TODO: open settings
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: CARD,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: BORDER),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 10,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.settings, color: NAVY),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ===== Search + Add =====
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: CARD,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: BORDER),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: MUTED, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchC,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: 'Cari inventory...',
                                hintStyle: TextStyle(color: MUTED),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_searchC.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchC.clear();
                                setState(() {});
                              },
                              child: const Icon(Icons.close,
                                  color: MUTED, size: 18),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _PrimaryButton(
                    label: 'Tambah item',
                    icon: Icons.add,
                    onTap: () {
                      // TODO: open add-item form
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ===== Filter Row =====
              Row(
                children: [
                  Expanded(
                    child: _DropdownPill(
                      prefix: 'Kategori : ',
                      value: _category,
                      items: const ['Semua', 'Safety', 'Tools', 'Unit'],
                      onChanged: (v) => setState(() => _category = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DropdownPill(
                      prefix: 'Urutkan : ',
                      value: _sort,
                      items: const [
                        'Nama A-Z',
                        'Nama Z-A',
                        'Stok Terbanyak',
                        'Stok Tersedikit',
                      ],
                      onChanged: (v) => setState(() => _sort = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ===== List =====
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 6),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final item = _filtered[i];
                    return _InventoryCard(item: item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // ===== Bottom Navigation =====
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onChanged: (i) {
          setState(() => _navIndex = i);
          // TODO: routing sesuai project kamu
          // contoh:
          // if (i == 0) context.go('/home');
        },
      ),
    );
  }
}

/* ─────────────────────────────────────────────
   Widgets
───────────────────────────────────────────── */

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  static const Color NAVY = Color(0xFF101D6E);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: NAVY,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownPill extends StatelessWidget {
  const _DropdownPill({
    required this.prefix,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String prefix;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  static const Color CARD = Color(0xFFFAFEFF);
  static const Color BORDER = Color(0xFFDCECFF);
  static const Color TEXT = Color(0xFF111827);
  static const Color MUTED = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: CARD,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BORDER),
      ),
      child: Row(
        children: [
          Text(
            prefix,
            style: const TextStyle(
              color: MUTED,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isDense: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: MUTED),
                style: const TextStyle(
                  color: TEXT,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                items: items
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({required this.item});

  final _InventoryItem item;

  static const Color SOFT = Color(0xFFF4F5FF);
  static const Color BORDER = Color(0xFFDCECFF);
  static const Color TEXT = Color(0xFF111827);
  static const Color MUTED = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final badge = _StockBadge(status: item.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: SOFT,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BORDER),
      ),
      child: Row(
        children: [
          // icon box (gambar alat)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BORDER),
            ),
            child: Icon(item.icon, color: Colors.orange.shade700),
          ),
          const SizedBox(width: 10),

          // name
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                color: TEXT,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 10),

          // qty + badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.current} | ${item.max}',
                style: const TextStyle(
                  color: MUTED,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              badge,
            ],
          ),
        ],
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.status});

  final _StockStatus status;

  @override
  Widget build(BuildContext context) {
    final isRunOut = status == _StockStatus.runOut;

    final Color bg = isRunOut ? const Color(0xFFE8E8EA) : const Color(0xFFDDE9FF);
    final Color fg = isRunOut ? const Color(0xFF6B7280) : const Color(0xFF2F56D9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isRunOut ? 'Run out' : 'Available',
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5EEF9))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              label: 'Home',
              icon: Icons.home_rounded,
              active: currentIndex == 0,
              onTap: () => onChanged(0),
            ),
            _NavItem(
              label: 'Notification',
              icon: Icons.notifications_rounded,
              active: currentIndex == 1,
              onTap: () => onChanged(1),
            ),
            _NavItem(
              label: 'File Manager',
              icon: Icons.folder_rounded,
              active: currentIndex == 2,
              onTap: () => onChanged(2),
            ),
            _NavItem(
              label: 'Profile',
              icon: Icons.person_rounded,
              active: currentIndex == 3,
              onTap: () => onChanged(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  static const Color NAVY = Color(0xFF101D6E);
  static const Color MUTED = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final color = active ? NAVY : MUTED;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: SizedBox(
        width: 86,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ─────────────────────────────────────────────
   Models (Dummy)
───────────────────────────────────────────── */

enum _StockStatus { available, runOut }

class _InventoryItem {
  final String name;
  final IconData icon;
  final int current;
  final int max;
  final _StockStatus status;

  // optional
  final String category;

  _InventoryItem({
    required this.name,
    required this.icon,
    required this.current,
    required this.max,
    required this.status, required this.category,
  });
}