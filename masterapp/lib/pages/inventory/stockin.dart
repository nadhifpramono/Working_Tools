import 'package:flutter/material.dart';

class StockInPage extends StatefulWidget {
  const StockInPage({super.key});

  @override
  State<StockInPage> createState() => _StockInPageState();
}

class _StockInPageState extends State<StockInPage> {
  static const Color navy = Color(0xFF101D6E);
  static const Color bg = Color(0xFFF3F7FB);
  static const Color card = Colors.white;
  static const Color border = Color(0xFFD9D9D9);
  static const Color text = Color(0xFF1F2937);
  static const Color muted = Color(0xFF6B7280);
  static const Color success = Color(0xFF16A34A);

  final TextEditingController _searchC = TextEditingController();
  final TextEditingController _itemNameC = TextEditingController();
  final TextEditingController _qtyC = TextEditingController();
  final TextEditingController _supplierC = TextEditingController();
  final TextEditingController _noteC = TextEditingController();

  String _selectedCategory = 'Semua';
  final List<String> _categories = [
    'Semua',
    'Bahan Baku',
    'Peralatan',
    'Aksesoris',
    'Lainnya',
  ];

  final List<Map<String, dynamic>> _stockInHistory = [
    {
      'name': 'Jaket Safety',
      'caegory': 'Bahan Baku',
      'qty': 20,
      'unit': 'Pcs',
      'date': '10 Mar 2026',
      'supplier': 'Toko Matrial Jaya',
      'note': 'Barang datang sesuai PO',
    },
    {
      'name': 'Tracktor',
      'category': 'Aksesoris',
      'qty': 100,
      'unit': 'Unit',
      'date': '09 Mar 2026',
      'supplier': 'Toko Matrial Makmur',
      'note': 'Tambahan stok gudang',
    },
    {
      'name': 'Loader',
      'category': 'Peralatan',
      'qty': 1,
      'unit': 'Unit',
      'date': '08 Mar 2026',
      'supplier': 'Toko Matrial Sentosa',
      'note': 'Pembelian alat baru',
    },
  ];

  @override
  void dispose() {
    _searchC.dispose();
    _itemNameC.dispose();
    _qtyC.dispose();
    _supplierC.dispose();
    _noteC.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredItems {
    final query = _searchC.text.toLowerCase().trim();

    return _stockInHistory.where((item) {
      final matchCategory = _selectedCategory == 'Semua'
          ? true
          : item['category'] == _selectedCategory;

      final matchQuery = query.isEmpty
          ? true
          : item['name'].toString().toLowerCase().contains(query) ||
              item['supplier'].toString().toLowerCase().contains(query);

      return matchCategory && matchQuery;
    }).toList();
  }

  int get _totalInToday {
    return _stockInHistory.fold<int>(
      0,
      (sum, item) => sum + ((item['qty'] as int?) ?? 0),
    );
  }

  void _showAddStockInSheet() {
    _itemNameC.clear();
    _qtyC.clear();
    _supplierC.clear();
    _noteC.clear();

    String selectedUnit = 'Pcs';
    String selectedCategory = 'Bahan Baku';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 52,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Tambah Stock In',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('Nama Barang'),
                      _buildTextField(
                        controller: _itemNameC,
                        hint: 'Masukkan nama barang',
                      ),
                      const SizedBox(height: 14),
                      _buildLabel('Kategori'),
                      _buildDropdown(
                        value: selectedCategory,
                        items: _categories.where((e) => e != 'Semua').toList(),
                        onChanged: (value) {
                          setModalState(() => selectedCategory = value!);
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Jumlah'),
                                _buildTextField(
                                  controller: _qtyC,
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Satuan'),
                                _buildDropdown(
                                  value: selectedUnit,
                                  items: const ['Pcs', 'Roll', 'Kg', 'Box'],
                                  onChanged: (value) {
                                    setModalState(() => selectedUnit = value!);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildLabel('Supplier'),
                      _buildTextField(
                        controller: _supplierC,
                        hint: 'Masukkan supplier',
                      ),
                      const SizedBox(height: 14),
                      _buildLabel('Catatan'),
                      _buildTextField(
                        controller: _noteC,
                        hint: 'Contoh: barang masuk dari supplier',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                side: const BorderSide(color: border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final name = _itemNameC.text.trim();
                                final qty =
                                    int.tryParse(_qtyC.text.trim()) ?? 0;
                                final supplier = _supplierC.text.trim();
                                final note = _noteC.text.trim();

                                if (name.isEmpty || qty <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Nama barang dan jumlah wajib diisi',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  _stockInHistory.insert(0, {
                                    'name': name,
                                    'category': selectedCategory,
                                    'qty': qty,
                                    'unit': selectedUnit,
                                    'date': 'Hari ini',
                                    'supplier':
                                        supplier.isEmpty ? '-' : supplier,
                                    'note': note.isEmpty ? '-' : note,
                                  });
                                });

                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: navy,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(52),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Simpan',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  static Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: navy, width: 1.4),
        ),
      ),
    );
  }

  static Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: navy, width: 1.4),
        ),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(e),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Stock In',
          style: TextStyle(
            color: text,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStockInSheet,
        backgroundColor: navy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_box_outlined),
        label: const Text(
          'Tambah In',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: success.withOpacity(.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: success,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Barang Masuk',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_totalInToday item',
                                style: const TextStyle(
                                  color: text,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchC,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari barang masuk...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: card,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: navy, width: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final active = _selectedCategory == category;

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedCategory = category);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: active ? navy : card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: active ? navy : border,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              category,
                              style: TextStyle(
                                color: active ? Colors.white : text,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        'Data stock in belum ada',
                        style: TextStyle(
                          color: muted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: success.withOpacity(.10),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.arrow_downward_rounded,
                                  color: success,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: text,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item['category']} • ${item['date']}',
                                      style: const TextStyle(
                                        color: muted,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Qty: ${item['qty']} ${item['unit']}',
                                      style: const TextStyle(
                                        color: success,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Supplier: ${item['supplier']}',
                                      style: const TextStyle(
                                        color: text,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['note'],
                                      style: const TextStyle(
                                        color: muted,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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