import 'package:flutter/material.dart';
import '../dashboard/dashboard.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  static const Color NAVY = Color(0xFF101D6E);
  static const Color BG = Color(0xFFF2F9FF);
  static const Color CARD = Color(0xFFFAFEFF);
  static const Color SOFT = Color(0xFFF4F5FF);
  static const Color BORDER = Color(0xFFDCECFF);
  static const Color TEXT = Color(0xFF111827);
  static const Color MUTED = Color(0xFF6B7280);

  final TextEditingController _searchC = TextEditingController();
  String _category = 'Semua';
  String _sort = 'Nama A-Z';

  final List<_InventoryItem> _items = [
    _InventoryItem(
      name: 'Helm Keselamatan',
      icon: Icons.engineering,
      current: 50,
      max: 50,
      status: _StockStatus.runOut,
      category: 'Safety',
    ),
    _InventoryItem(
      name: 'Drill Machine',
      icon: Icons.handyman,
      current: 23,
      max: 5,
      status: _StockStatus.available,
      category: 'Tools',
    ),
    _InventoryItem(
      name: 'Jaket Safety',
      icon: Icons.checkroom,
      current: 50,
      max: 25,
      status: _StockStatus.available,
      category: 'Safety',
    ),
    _InventoryItem(
      name: 'Gergaji Machine',
      icon: Icons.construction,
      current: 20,
      max: 7,
      status: _StockStatus.available,
      category: 'Tools',
    ),
    _InventoryItem(
      name: 'Unit Tractor',
      icon: Icons.agriculture,
      current: 10,
      max: 3,
      status: _StockStatus.available,
      category: 'Unit',
    ),
    _InventoryItem(
      name: 'Unit Loader',
      icon: Icons.agriculture_outlined,
      current: 10,
      max: 4,
      status: _StockStatus.available,
      category: 'Unit',
    ),
  ];

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  void _goBackDashboard() {
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    }
  }

  List<_InventoryItem> get _filtered {
    final q = _searchC.text.trim().toLowerCase();

    var list = _items.where((e) {
      final matchQ =
          q.isEmpty ||
          e.name.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q);
      final matchCat = _category == 'Semua' ? true : e.category == _category;
      return matchQ && matchCat;
    }).toList();

    switch (_sort) {
      case 'Nama Z-A':
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Stok Terbanyak':
        list.sort((a, b) => b.current.compareTo(a.current));
        break;
      case 'Stok Tersedikit':
        list.sort((a, b) => a.current.compareTo(b.current));
        break;
      default:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return list;
  }

  IconData _iconFromKey(String key) {
    switch (key) {
      case 'engineering':
        return Icons.engineering;
      case 'handyman':
        return Icons.handyman;
      case 'checkroom':
        return Icons.checkroom;
      case 'construction':
        return Icons.construction;
      case 'agriculture':
        return Icons.agriculture;
      case 'agriculture_outlined':
        return Icons.agriculture_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  Future<void> _showAddItemPopup() async {
    final nameC = TextEditingController();
    final currentC = TextEditingController();
    final maxC = TextEditingController();

    String selectedCategory = 'Safety';
    String selectedIconKey = 'engineering';
    _StockStatus selectedStatus = _StockStatus.available;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Tambah Item Inventory',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: TEXT,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _FormLabel(label: 'Nama item'),
                    _FormField(
                      controller: nameC,
                      hintText: 'Masukkan nama item',
                    ),
                    const SizedBox(height: 12),
                    _FormLabel(label: 'Kategori'),
                    _PopupDropdown<String>(
                      value: selectedCategory,
                      items: const ['Safety', 'Tools', 'Unit'],
                      itemLabel: (e) => e,
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() => selectedCategory = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _FormLabel(label: 'Icon item'),
                    _PopupDropdown<String>(
                      value: selectedIconKey,
                      items: const [
                        'engineering',
                        'handyman',
                        'checkroom',
                        'construction',
                        'agriculture',
                        'agriculture_outlined',
                      ],
                      itemLabel: (e) {
                        switch (e) {
                          case 'engineering':
                            return 'Helm / Safety';
                          case 'handyman':
                            return 'Handyman / Tools';
                          case 'checkroom':
                            return 'Jaket / Pakaian';
                          case 'construction':
                            return 'Construction / Alat';
                          case 'agriculture':
                            return 'Tractor / Unit';
                          case 'agriculture_outlined':
                            return 'Loader / Unit';
                          default:
                            return e;
                        }
                      },
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() => selectedIconKey = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 64,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: SOFT,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: BORDER),
                      ),
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: BORDER),
                          ),
                          child: Icon(
                            _iconFromKey(selectedIconKey),
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FormLabel(label: 'Jumlah saat ini'),
                              _FormField(
                                controller: currentC,
                                hintText: '0',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FormLabel(label: 'Jumlah maksimal'),
                              _FormField(
                                controller: maxC,
                                hintText: '0',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _FormLabel(label: 'Status'),
                    _PopupDropdown<_StockStatus>(
                      value: selectedStatus,
                      items: const [
                        _StockStatus.available,
                        _StockStatus.runOut,
                      ],
                      itemLabel: (e) =>
                          e == _StockStatus.available ? 'Available' : 'Run out',
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() => selectedStatus = value);
                      },
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                              side: const BorderSide(color: BORDER),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final name = nameC.text.trim();
                              final current =
                                  int.tryParse(currentC.text.trim()) ?? -1;
                              final max = int.tryParse(maxC.text.trim()) ?? -1;

                              if (name.isEmpty || current < 0 || max < 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Mohon isi semua data dengan benar.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                _items.insert(
                                  0,
                                  _InventoryItem(
                                    name: name,
                                    icon: _iconFromKey(selectedIconKey),
                                    current: current,
                                    max: max,
                                    status: selectedStatus,
                                    category: selectedCategory,
                                  ),
                                );
                              });

                              Navigator.pop(context);

                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text('$name berhasil ditambahkan'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NAVY,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Simpan',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameC.dispose();
    currentC.dispose();
    maxC.dispose();
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
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _goBackDashboard,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: CARD,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: BORDER),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: NAVY,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Inventory',
                      style: TextStyle(
                        color: TEXT,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
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
                              child: const Icon(
                                Icons.close,
                                color: MUTED,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _PrimaryButton(
                    label: 'Tambah item',
                    icon: Icons.add,
                    onTap: _showAddItemPopup,
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
              Expanded(
                child: _filtered.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: CARD,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: BORDER),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 42,
                              color: MUTED,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Data inventory tidak ditemukan',
                              style: TextStyle(
                                color: TEXT,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
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
    );
  }
}

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

    final Color bg = isRunOut
        ? const Color(0xFFE8E8EA)
        : const Color(0xFFDDE9FF);
    final Color fg = isRunOut
        ? const Color(0xFF6B7280)
        : const Color(0xFF2F56D9);

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

class _FormLabel extends StatelessWidget {
  const _FormLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _InventoryPageState.TEXT,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _InventoryPageState.CARD,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _InventoryPageState.BORDER),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: _InventoryPageState.MUTED),
            border: InputBorder.none,
            isDense: true,
          ),
        ),
      ),
    );
  }
}

class _PopupDropdown<T> extends StatelessWidget {
  const _PopupDropdown({
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _InventoryPageState.CARD,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _InventoryPageState.BORDER),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: _InventoryPageState.MUTED,
          ),
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(
                    itemLabel(e),
                    style: const TextStyle(
                      color: _InventoryPageState.TEXT,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

enum _StockStatus { available, runOut }

class _InventoryItem {
  final String name;
  final IconData icon;
  final int current;
  final int max;
  final _StockStatus status;
  final String category;

  _InventoryItem({
    required this.name,
    required this.icon,
    required this.current,
    required this.max,
    required this.status,
    required this.category,
  });
}