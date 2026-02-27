import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum EditField {
  profile,
  email,
  phone,
  employeeId,
  department,
  joinDate,
  password,
}

/// =======================================================
/// ✅ 1) HALAMAN LIST EDIT PROFILE (sesuai screenshot)
/// + Foto profil bisa dipilih (tap avatar)
/// =======================================================
class EditProfileListPage extends StatefulWidget {
  const EditProfileListPage({super.key});

  @override
  State<EditProfileListPage> createState() => _EditProfileListPageState();
}

class _EditProfileListPageState extends State<EditProfileListPage> {
  // ===== Theme Tokens =====
  static const Color NAVY = Color(0xFF101D6E);
  static const Color BG = Color(0xFFF2F9FF);
  static const Color CARD = Color(0xFFFAFEFF);
  static const Color SOFT = Color(0xFFF4F5FF);
  static const Color BORDER = Color(0xFFDCECFF);

  // ===== Dummy data (nanti ambil dari API) =====
  String name = "Hanyakra Narendra";
  String role = "Supervisor";
  String email = "Hanyakra@gmail.com";
  String phone = "+62 34 5678 5678";
  String employeeId = "4567800";
  String department = "Safety";
  String joinDate = "16 Februari 2026";

  // ===== Foto profil =====
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  Future<void> _pickProfileImage() async {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Ubah foto profil",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
                const SizedBox(height: 12),

                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text("Pilih dari Galeri"),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? picked = await _picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (picked != null && mounted) {
                      setState(() => _profileImage = File(picked.path));
                    }
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text("Ambil dari Kamera"),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? picked = await _picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                    );
                    if (picked != null && mounted) {
                      setState(() => _profileImage = File(picked.path));
                    }
                  },
                ),

                if (_profileImage != null)
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text(
                      "Hapus foto",
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (mounted) setState(() => _profileImage = null);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editHeader() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileFormPage(
          field: EditField.profile,
          initialName: name,
          initialRole: role,
        ),
      ),
    );

    if (!mounted) return;

    if (result is Map) {
      setState(() {
        name = (result["name"] ?? name).toString();
        role = (result["role"] ?? role).toString();
      });
    }
  }

  Future<void> _editSingle(EditField field, String initial) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileFormPage(
          field: field,
          initialValue: initial,
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      switch (field) {
        case EditField.email:
          email = result.toString();
          break;
        case EditField.phone:
          phone = result.toString();
          break;
        case EditField.employeeId:
          employeeId = result.toString();
          break;
        case EditField.department:
          department = result.toString();
          break;
        case EditField.joinDate:
          joinDate = result.toString();
          break;
        case EditField.profile:
        case EditField.password:
          break;
      }
    });
  }

  Future<void> _editPassword() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfileFormPage(field: EditField.password),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BG,

      appBar: AppBar(
        backgroundColor: NAVY,
        foregroundColor: Colors.white,
        title: const Text("Edit profile page"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          )
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Profil",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),

              // ===== Card profil atas =====
              Material(
                color: CARD,
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E0E0)),
                  ),
                  child: Row(
                    children: [
                      // ✅ avatar bisa dipencet untuk pilih foto
                      GestureDetector(
                        onTap: _pickProfileImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0xFFE5E7EB),
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : const NetworkImage(
                                      "https://placehold.co/120x120",
                                    ) as ImageProvider,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.08),
                                  ),
                                ),
                                child: const Icon(Icons.camera_alt, size: 14),
                              ),
                            )
                          ],
                        ),
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
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              role,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withOpacity(0.55),
                              ),
                            ),
                          ],
                        ),
                      ),

                      InkWell(
                        onTap: _editHeader,
                        borderRadius: BorderRadius.circular(10),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.edit, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ===== List Card =====
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: SOFT,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: BORDER),
                ),
                child: Column(
                  children: [
                    _RowItem(
                      icon: Icons.email_outlined,
                      title: "Email",
                      value: email,
                      onEdit: () => _editSingle(EditField.email, email),
                    ),
                    _line(),
                    _RowItem(
                      icon: Icons.phone_outlined,
                      title: "Telepon",
                      value: phone,
                      onEdit: () => _editSingle(EditField.phone, phone),
                    ),
                    _line(),
                    _RowItem(
                      icon: Icons.badge_outlined,
                      title: "ID Pegawai",
                      value: employeeId,
                      onEdit: () => _editSingle(EditField.employeeId, employeeId),
                    ),
                    _line(),
                    _RowItem(
                      icon: Icons.apartment_outlined,
                      title: "Departement",
                      value: department,
                      onEdit: () => _editSingle(EditField.department, department),
                    ),
                    _line(),
                    _RowItem(
                      icon: Icons.calendar_month_outlined,
                      title: "Tanggal Bergabung",
                      value: joinDate,
                      onEdit: () => _editSingle(EditField.joinDate, joinDate),
                    ),
                    _line(),

                    // Password row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline, size: 22),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Kata sandi",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  "*********",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: _editPassword,
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Text(
                                "Ubah >",
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
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

  Widget _line() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: Colors.black.withOpacity(0.12),
      );
}

class _RowItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onEdit;

  const _RowItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.edit, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================================================
/// ✅ 2) HALAMAN FORM EDIT (per-field / profile / password)
/// =======================================================
class EditProfileFormPage extends StatefulWidget {
  final EditField field;
  final String? initialValue;
  final String? initialName;
  final String? initialRole;

  const EditProfileFormPage({
    super.key,
    required this.field,
    this.initialValue,
    this.initialName,
    this.initialRole,
  });

  @override
  State<EditProfileFormPage> createState() => _EditProfileFormPageState();
}

class _EditProfileFormPageState extends State<EditProfileFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _valueC;
  late final TextEditingController _nameC;
  late final TextEditingController _roleC;

  final TextEditingController _newPassC = TextEditingController();
  final TextEditingController _confirmPassC = TextEditingController();

  static const Color BG = Color(0xFFF2F9FF);
  static const Color NAVY = Color(0xFF101D6E);
  static const Color CARD = Color(0xFFFAFEFF);
  static const Color BORDER = Color(0xFFDCECFF);
  static const Color MUTED = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _valueC = TextEditingController(text: widget.initialValue ?? "");
    _nameC = TextEditingController(text: widget.initialName ?? "");
    _roleC = TextEditingController(text: widget.initialRole ?? "");
  }

  @override
  void dispose() {
    _valueC.dispose();
    _nameC.dispose();
    _roleC.dispose();
    _newPassC.dispose();
    _confirmPassC.dispose();
    super.dispose();
  }

  bool get _isProfile => widget.field == EditField.profile;
  bool get _isPassword => widget.field == EditField.password;

  String get _title {
    switch (widget.field) {
      case EditField.profile:
        return "Edit Profil";
      case EditField.email:
        return "Edit Email";
      case EditField.phone:
        return "Edit Telepon";
      case EditField.employeeId:
        return "Edit ID Pegawai";
      case EditField.department:
        return "Edit Departement";
      case EditField.joinDate:
        return "Edit Tanggal Bergabung";
      case EditField.password:
        return "Ubah Kata Sandi";
    }
  }

  String get _hint {
    switch (widget.field) {
      case EditField.email:
        return "contoh@domain.com";
      case EditField.phone:
        return "+62xxxxxxxxxxx";
      case EditField.employeeId:
        return "contoh: 4567800";
      case EditField.department:
        return "contoh: Safety";
      case EditField.joinDate:
        return "contoh: 16 Februari 2026";
      case EditField.profile:
      case EditField.password:
        return "";
    }
  }

  TextInputType get _keyboardType {
    switch (widget.field) {
      case EditField.phone:
        return TextInputType.phone;
      case EditField.email:
        return TextInputType.emailAddress;
      default:
        return TextInputType.text;
    }
  }

  String? _required(String? v, String msg) {
    if ((v ?? "").trim().isEmpty) return msg;
    return null;
  }

  String? _validateSingle(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Field tidak boleh kosong";

    switch (widget.field) {
      case EditField.email:
        if (!value.contains("@") || !value.contains(".")) {
          return "Format email tidak valid";
        }
        return null;

      case EditField.phone:
        if (value.length < 8) return "Nomor telepon terlalu pendek";
        return null;

      case EditField.employeeId:
        final cleaned = value.replaceAll(" ", "");
        if (int.tryParse(cleaned) == null) return "ID Pegawai sebaiknya angka";
        return null;

      case EditField.department:
      case EditField.joinDate:
        return null;

      case EditField.profile:
      case EditField.password:
        return null;
    }
  }

  String? _validatePassword(String? v) {
    final value = (v ?? "");
    if (value.isEmpty) return "Password tidak boleh kosong";
    if (value.length < 6) return "Minimal 6 karakter";
    return null;
  }

  void _save() {
    if (_isProfile) {
      if (_formKey.currentState!.validate()) {
        Navigator.pop(context, {
          "name": _nameC.text.trim(),
          "role": _roleC.text.trim(),
        });
      }
      return;
    }

    if (_isPassword) {
      if (!_formKey.currentState!.validate()) return;

      if (_newPassC.text != _confirmPassC.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Konfirmasi password tidak cocok")),
        );
        return;
      }

      Navigator.pop(context, "***changed***");
      return;
    }

    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _valueC.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BG,
      appBar: AppBar(
        backgroundColor: NAVY,
        foregroundColor: Colors.white,
        title: Text(_title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Material(
            color: CARD,
            elevation: 2,
            borderRadius: BorderRadius.circular(16),
            shadowColor: Colors.black.withOpacity(0.08),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BORDER, width: 1),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isProfile
                          ? "Ubah data nama dan jabatan, lalu simpan."
                          : _isPassword
                              ? "Masukkan password baru dan konfirmasi."
                              : "Ubah data lalu tekan simpan.",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: MUTED,
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (_isProfile) ...[
                      TextFormField(
                        controller: _nameC,
                        decoration: InputDecoration(
                          labelText: "Nama lengkap",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => _required(v, "Nama wajib diisi"),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _roleC,
                        decoration: InputDecoration(
                          labelText: "Jabatan",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => _required(v, "Jabatan wajib diisi"),
                      ),
                    ] else if (_isPassword) ...[
                      TextFormField(
                        controller: _newPassC,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password baru",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPassC,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Konfirmasi password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: _validatePassword,
                      ),
                    ] else ...[
                      TextFormField(
                        controller: _valueC,
                        keyboardType: _keyboardType,
                        decoration: InputDecoration(
                          labelText: _title,
                          hintText: _hint,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: _validateSingle,
                      ),
                    ],

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: BORDER),
                            ),
                            child: const Text(
                              "Batal",
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NAVY,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Simpan",
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}