import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color bg = Color(0xFFF2F9FF);
  static const Color navy = Color(0xFF101D6E);
  static const Color card = Color(0xFFFAFEFF);
  static const Color soft = Color(0xFFF4F5FF);
  static const Color border = Color(0xFFDCECFF);
  static const Color text = Color(0xFF111827);
  static const Color muted = Color(0xFF6B7280);

  bool _darkMode = false;
  bool _pinEnabled = true;
  bool _notificationEnabled = true;
  String _language = 'Indonesia';

  void _showInfo(String title, String message) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: soft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: text,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navy,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _settingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: soft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: Icon(icon, color: navy),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: text,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: muted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                  title: const Text(
                    'Mode gelap',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Aktifkan tampilan gelap'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                ),
                SwitchListTile.adaptive(
                  value: _pinEnabled,
                  onChanged: (v) => setState(() => _pinEnabled = v),
                  title: const Text(
                    'Aktifkan PIN',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Keamanan login tambahan'),
                  secondary: const Icon(Icons.pin_outlined),
                ),
                SwitchListTile.adaptive(
                  value: _notificationEnabled,
                  onChanged: (v) => setState(() => _notificationEnabled = v),
                  title: const Text(
                    'Notifikasi',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Izinkan notifikasi aplikasi'),
                  secondary: const Icon(Icons.notifications_active_outlined),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: soft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _language,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'Indonesia',
                          child: Text('Indonesia'),
                        ),
                        DropdownMenuItem(
                          value: 'English',
                          child: Text('English'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _language = v);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _settingCard(
            icon: Icons.lock_outline,
            title: 'Ubah password',
            subtitle: 'Atur ulang kata sandi akun',
            onTap: () => _showInfo(
              'Ubah password',
              'Di sini nantinya kamu bisa menambahkan form ubah password lama, password baru, dan konfirmasi password.',
            ),
          ),
          _settingCard(
            icon: Icons.privacy_tip_outlined,
            title: 'Privasi akun',
            subtitle: 'Kelola akses dan data pribadi',
            onTap: () => _showInfo(
              'Privasi akun',
              'Bagian ini bisa diisi pengaturan akses akun, kontrol data pribadi, dan izin penggunaan perangkat.',
            ),
          ),
          _settingCard(
            icon: Icons.backup_outlined,
            title: 'Backup & sinkronisasi',
            subtitle: 'Kelola backup data aplikasi',
            onTap: () => _showInfo(
              'Backup & sinkronisasi',
              'Bagian ini bisa digunakan untuk sinkronisasi data ke server dan pengecekan backup terbaru.',
            ),
          ),
        ],
      ),
    );
  }
}