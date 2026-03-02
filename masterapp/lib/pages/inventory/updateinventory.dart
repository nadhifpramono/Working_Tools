import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateInventoryPage extends StatefulWidget {
  const UpdateInventoryPage({super.key});

  @override
  State<UpdateInventoryPage> createState() => _UpdateInventoryPageState();
}

class _UpdateInventoryPageState extends State<UpdateInventoryPage> {
  // ===== Theme Tokens (samakan dengan dashboard) =====
  static const Color NAVY = Color(0xFF101D6E);
  static const Color BG = Color(0xFFF2F9FF);
  static const Color CARD = Color(0xFFFAFEFF);
  static const Color BORDER_GREY = Color(0xFFE2E0E0);

  // ===== Dummy data (nanti bisa ganti dari database/api) =====
  String itemName = 'Unit Tracktor';
  String itemRole = 'Supervisor';

  // ===== Stock state =====
  int tersedia = 7;
  int dipakai = 3;

  int tambah = 1;
  int kurang = 1;

  int get total => tersedia + dipakai;

  // ===== Catatan =====
  final TextEditingController noteC = TextEditingController();

  // ===== Image Picker (web + mobile safe) =====
  final ImagePicker _picker = ImagePicker();
  Uint8List? _pickedImageBytes;

  Future<void> pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;

    setState(() => _pickedImageBytes = bytes);
  }

  @override
  void dispose() {
    noteC.dispose();
    super.dispose();
  }

  void _submit() {
    final next = tersedia + tambah - kurang;
    if (next < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok tersedia tidak boleh kurang dari 0')),
      );
      return;
    }

    setState(() {
      tersedia = next;
      tambah = 1;
      kurang = 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inventory berhasil diperbarui')),
    );

    // TODO: simpan ke backend / database
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 768;

    return Scaffold(
      backgroundColor: BG,
      body: SafeArea(
        child: Column(
          children: [
            // ===== Header biru (back + title + settings) =====
            Container(
              height: isTablet ? 90 : 80,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(color: NAVY),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Update Inventory',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w700,
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

            // ===== Content =====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== Card Item (gambar + nama + chips) =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: CARD,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: BORDER_GREY, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ✅ Foto item bisa dipilih
                          GestureDetector(
                            onTap: pickImage,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: _pickedImageBytes != null
                                  ? Image.memory(
                                      _pickedImageBytes!,
                                      width: 63,
                                      height: 63,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 63,
                                      height: 63,
                                      color: Colors.grey.shade200,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.add_a_photo,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  itemName,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'Itim',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  itemRole,
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.45),
                                    fontSize: 14,
                                    fontFamily: 'Itim',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _ChipStat(label: 'Tersedia: $tersedia'),
                                    _ChipStat(label: 'Dipakai: $dipakai'),
                                    _ChipStat(label: 'Total: $total'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ===== Perbarui Stok =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: CARD,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: BORDER_GREY, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Perbarui Stok',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Itim',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 12),

                          _StockLine(
                            title: 'Tambah Stok',
                            value: tambah,
                            onMinus: () => setState(() {
                              if (tambah > 0) tambah--;
                            }),
                            onPlus: () => setState(() => tambah++),
                          ),

                          const SizedBox(height: 14),

                          _StockLine(
                            title: 'Kurangi Stok',
                            value: kurang,
                            onMinus: () => setState(() {
                              if (kurang > 0) kurang--;
                            }),
                            onPlus: () => setState(() => kurang++),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ===== Catatan =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: CARD,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: BORDER_GREY, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Catatan',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'Itim',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(opsional)',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.35),
                                  fontSize: 20,
                                  fontFamily: 'Itim',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: CARD,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFEBEBEB)),
                            ),
                            child: TextField(
                              controller: noteC,
                              minLines: 4,
                              maxLines: 6,
                              decoration: InputDecoration(
                                hintText: 'Tambahkan Catatan......',
                                hintStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.49),
                                  fontSize: 16,
                                  fontFamily: 'Itim',
                                  fontWeight: FontWeight.w400,
                                ),
                                contentPadding: const EdgeInsets.all(16),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ===== Buttons =====
                    Row(
                      children: [
                        Expanded(
                          child: _OutlineBtn(
                            label: 'Batal',
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _PrimaryBtn(
                            label: 'Perbarui',
                            onTap: _submit,
                          ),
                        ),
                      ],
                    ),
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

/* =================== widgets =================== */

class _ChipStat extends StatelessWidget {
  const _ChipStat({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE5FBFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD6D6D6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black.withOpacity(0.49),
          fontSize: 16,
          fontFamily: 'Itim',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _StockLine extends StatelessWidget {
  const _StockLine({
    required this.title,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String title;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFEFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E0E0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Itim',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          _Stepper(value: value, onMinus: onMinus, onPlus: onPlus),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onMinus,
          child: Container(
            width: 31,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFD72856),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              border: Border.all(color: const Color(0xFFD6D6D6)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: const Text(
              '-',
              style: TextStyle(
                color: Color(0xFF060606),
                fontSize: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Container(
          width: 31,
          height: 29,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF3FAFC),
            border: Border.all(color: const Color(0xFFD6D6D6)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Text(
            '$value',
            style: const TextStyle(
              color: Color(0xFF020202),
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        InkWell(
          onTap: onPlus,
          child: Container(
            width: 31,
            height: 29,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF849),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: const Color(0xFFD6D6D6)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: const Text(
              '+',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  const _OutlineBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD6D6D6)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.76),
            fontSize: 20,
            fontFamily: 'Itim',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  const _PrimaryBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  static const Color NAVY = Color(0xFF101D6E);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: NAVY,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD6D6D6)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.76),
            fontSize: 20,
            fontFamily: 'Itim',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}