import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  // ===== Theme Tokens =====
  static const Color NAVY = Color(0xFF101D6E);
  static const Color BG = Color(0xFFF2F9FF);
  static const Color CARD = Color(0xFFFAFEFF);
  static const Color SOFT = Color(0xFFF4F5FF);
  static const Color BORDER = Color(0xFFDCECFF);
  static const Color TEXT = Color(0xFF111827);
  static const Color MUTED = Color(0xFF6B7280);
  static const Color SUCCESS = Color(0xFF16A34A);
  static const Color WARNING = Color(0xFFF59E0B);
  static const Color DANGER = Color(0xFFEF4444);

  final TextEditingController _toolNameC = TextEditingController();
  final TextEditingController _unitCodeC = TextEditingController();
  final TextEditingController _projectLocationC = TextEditingController();
  final TextEditingController _problemC = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  String _category = 'Alat Berat';
  String _priority = 'Normal';

  final List<String> _categories = [
    'Alat Berat',
    'Mesin Potong',
    'Mesin Bor',
    'Concrete Mixer',
    'Genset',
    'Scaffolding',
    'Alat Ukur',
    'Las / Welding',
    'Pompa Air',
    'Lainnya',
  ];

  final List<String> _priorities = [
    'Low',
    'Normal',
    'High',
    'Urgent',
  ];

  final List<_ServiceTicket> _tickets = [
    _ServiceTicket(
      code: 'SRV-001',
      itemName: 'Excavator Hitachi ZX200',
      category: 'Alat Berat',
      date: '10 Mar 2026',
      status: 'Diproses',
      priority: 'Urgent',
      location: 'Proyek Gudang BOMA - Bandung',
      note: 'Mesin sulit dinyalakan dan hidrolik terasa lemah.',
      imageBytes: null,
      imageName: null,
    ),
    _ServiceTicket(
      code: 'SRV-002',
      itemName: 'Genset 5000 Watt',
      category: 'Genset',
      date: '08 Mar 2026',
      status: 'Selesai',
      priority: 'High',
      location: 'Proyek Renovasi Kantor',
      note: 'Output listrik sempat tidak stabil saat digunakan.',
      imageBytes: null,
      imageName: null,
    ),
    _ServiceTicket(
      code: 'SRV-003',
      itemName: 'Concrete Mixer Portable',
      category: 'Concrete Mixer',
      date: '06 Mar 2026',
      status: 'Menunggu',
      priority: 'Normal',
      location: 'Proyek Rumah Tinggal 2 Lantai',
      note: 'Putaran tabung lambat dan terdengar bunyi kasar.',
      imageBytes: null,
      imageName: null,
    ),
  ];

  @override
  void dispose() {
    _toolNameC.dispose();
    _unitCodeC.dispose();
    _projectLocationC.dispose();
    _problemC.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 75,
      );

      if (picked == null) return;

      final bytes = await picked.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = picked.name;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e')),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: BORDER,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pilih Sumber Foto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: TEXT,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _imageSourceButton(
                        icon: Icons.photo_camera_outlined,
                        label: 'Kamera',
                        onTap: () async {
                          Navigator.pop(context);
                          await _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _imageSourceButton(
                        icon: Icons.photo_library_outlined,
                        label: 'Galeri',
                        onTap: () async {
                          Navigator.pop(context);
                          await _pickImage(ImageSource.gallery);
                        },
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
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
    });
  }

  void _submitService() {
    if (_toolNameC.text.trim().isEmpty ||
        _unitCodeC.text.trim().isEmpty ||
        _projectLocationC.text.trim().isEmpty ||
        _problemC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mohon lengkapi nama alat, kode unit, lokasi proyek, dan keluhan.',
          ),
        ),
      );
      return;
    }

    final newTicket = _ServiceTicket(
      code: 'SRV-00${_tickets.length + 1}',
      itemName: _toolNameC.text.trim(),
      category: _category,
      date: 'Hari ini',
      status: 'Menunggu',
      priority: _priority,
      location: _projectLocationC.text.trim(),
      note: _problemC.text.trim(),
      imageBytes: _selectedImageBytes,
      imageName: _selectedImageName,
    );

    setState(() {
      _tickets.insert(0, newTicket);
      _toolNameC.clear();
      _unitCodeC.clear();
      _projectLocationC.clear();
      _problemC.clear();
      _category = 'Alat Berat';
      _priority = 'Normal';
      _selectedImageBytes = null;
      _selectedImageName = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengajuan service peralatan proyek berhasil dibuat.'),
      ),
    );
  }

  int _countByStatus(String status) {
    return _tickets.where((e) => e.status == status).length;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Selesai':
        return SUCCESS;
      case 'Diproses':
        return WARNING;
      case 'Menunggu':
        return DANGER;
      default:
        return MUTED;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Urgent':
        return DANGER;
      case 'High':
        return WARNING;
      case 'Normal':
        return NAVY;
      case 'Low':
        return SUCCESS;
      default:
        return MUTED;
    }
  }

  void _showFullImage(Uint8List bytes, String? name) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name ?? 'Foto Kerusakan',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: TEXT,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.memory(
                  bytes,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BG,
      appBar: AppBar(
        backgroundColor: BG,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: TEXT),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Service Peralatan',
          style: TextStyle(
            color: TEXT,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildStatsRow(),
              const SizedBox(height: 16),
              _buildFormCard(),
              const SizedBox(height: 16),
              const Text(
                'Riwayat Service Peralatan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TEXT,
                ),
              ),
              const SizedBox(height: 12),
              ..._tickets.map(_buildTicketCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: NAVY,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.construction_rounded, color: Colors.white, size: 28),
          SizedBox(height: 12),
          Text(
            'Ajukan Service Peralatan Proyek',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Gunakan halaman ini untuk melaporkan kerusakan, gangguan, atau kebutuhan perbaikan alat dan peralatan proyek.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Menunggu',
            _countByStatus('Menunggu').toString(),
            DANGER,
            Icons.schedule_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            'Diproses',
            _countByStatus('Diproses').toString(),
            WARNING,
            Icons.autorenew_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            'Selesai',
            _countByStatus('Selesai').toString(),
            SUCCESS,
            Icons.check_circle_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: CARD,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BORDER),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: TEXT,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: MUTED,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CARD,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: BORDER),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Form Pengajuan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: TEXT,
            ),
          ),
          const SizedBox(height: 14),
          _buildLabel('Nama Alat / Peralatan'),
          _buildTextField(
            controller: _toolNameC,
            hint: 'Contoh: Excavator Hitachi ZX200',
            icon: Icons.precision_manufacturing_outlined,
          ),
          const SizedBox(height: 12),
          _buildLabel('Jenis Peralatan'),
          _buildDropdown(
            value: _category,
            items: _categories,
            onChanged: (value) {
              if (value != null) {
                setState(() => _category = value);
              }
            },
            icon: Icons.category_outlined,
          ),
          const SizedBox(height: 12),
          _buildLabel('Kode Unit / Nomor Aset'),
          _buildTextField(
            controller: _unitCodeC,
            hint: 'Contoh: EQP-EXC-001',
            icon: Icons.qr_code_2_rounded,
          ),
          const SizedBox(height: 12),
          _buildLabel('Lokasi Proyek'),
          _buildTextField(
            controller: _projectLocationC,
            hint: 'Contoh: Proyek Gudang BOMA - Bandung',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),
          _buildLabel('Prioritas'),
          _buildDropdown(
            value: _priority,
            items: _priorities,
            onChanged: (value) {
              if (value != null) {
                setState(() => _priority = value);
              }
            },
            icon: Icons.flag_outlined,
          ),
          const SizedBox(height: 12),
          _buildLabel('Keluhan / Kerusakan'),
          _buildTextField(
            controller: _problemC,
            hint: 'Jelaskan kerusakan atau kendala alat proyek...',
            icon: Icons.description_outlined,
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          _buildLabel('Foto Kerusakan / Kondisi Alat'),
          _buildImagePickerSection(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _submitService,
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              label: const Text(
                'Kirim Pengajuan Service',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: NAVY,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _showImagePickerOptions,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
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
                    color: NAVY.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.add_a_photo_outlined,
                    color: NAVY,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedImageName ?? 'Tambah foto dari kamera atau galeri',
                    style: TextStyle(
                      color: _selectedImageName == null ? MUTED : TEXT,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: NAVY,
                ),
              ],
            ),
          ),
        ),
        if (_selectedImageBytes != null) ...[
          const SizedBox(height: 12),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.memory(
                  _selectedImageBytes!,
                  width: double.infinity,
                  height: 190,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _removeSelectedImage,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTicketCard(_ServiceTicket ticket) {
    final statusColor = _statusColor(ticket.status);
    final priorityColor = _priorityColor(ticket.priority);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CARD,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: BORDER),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.build_circle_outlined, color: NAVY, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ticket.itemName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: TEXT,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  ticket.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  ticket.priority,
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Kode', ticket.code),
          _buildInfoRow('Kategori', ticket.category),
          _buildInfoRow('Lokasi', ticket.location),
          _buildInfoRow('Tanggal', ticket.date),
          _buildInfoRow('Catatan', ticket.note),
          if (ticket.imageBytes != null) ...[
            const SizedBox(height: 10),
            const Text(
              'Foto Kerusakan',
              style: TextStyle(
                color: MUTED,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showFullImage(ticket.imageBytes!, ticket.imageName),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  ticket.imageBytes!,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                color: MUTED,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              color: MUTED,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: TEXT,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: TEXT,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: TEXT),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: MUTED),
        prefixIcon: Icon(icon, color: NAVY),
        filled: true,
        fillColor: SOFT,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: BORDER),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: NAVY, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: NAVY),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: NAVY),
        filled: true,
        fillColor: SOFT,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: BORDER),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: NAVY, width: 1.2),
        ),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(
                e,
                style: const TextStyle(
                  color: TEXT,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _imageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: SOFT,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: BORDER),
        ),
        child: Column(
          children: [
            Icon(icon, color: NAVY, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: TEXT,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTicket {
  final String code;
  final String itemName;
  final String category;
  final String date;
  final String status;
  final String priority;
  final String location;
  final String note;
  final Uint8List? imageBytes;
  final String? imageName;

  _ServiceTicket({
    required this.code,
    required this.itemName,
    required this.category,
    required this.date,
    required this.status,
    required this.priority,
    required this.location,
    required this.note,
    required this.imageBytes,
    required this.imageName,
  });
}