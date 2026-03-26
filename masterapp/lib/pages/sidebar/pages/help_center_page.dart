import 'package:flutter/material.dart';
import '../widgets/sidebar_feature_shell.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SidebarFeatureShell(
      title: 'Help Center',
      icon: Icons.help_outline,
      sections: [
        FeatureSectionData(
          title: 'Bantuan Cepat',
          items: [
            FeatureActionItemData(
              title: 'Cara menambah item inventory',
              subtitle: 'Panduan singkat',
              detail:
                  'Masuk ke halaman Inventory, tekan tombol Tambah Item, lalu isi nama, kategori, jumlah, dan status barang.',
              icon: Icons.inventory_outlined,
              badge: 'Guide',
            ),
            FeatureActionItemData(
              title: 'Cara export laporan',
              subtitle: 'PDF dan Excel',
              detail:
                  'Masuk ke halaman Reports, pilih jenis laporan, atur periode, lalu pilih format export yang diinginkan.',
              icon: Icons.file_download_outlined,
              badge: 'Export',
            ),
          ],
        ),
        FeatureSectionData(
          title: 'Support',
          items: [
            FeatureActionItemData(
              title: 'Hubungi admin sistem',
              subtitle: 'Respon kerja 1x24 jam',
              detail:
                  'Gunakan menu ini saat ada bug, kendala login, atau masalah akses fitur tertentu.',
              icon: Icons.support_agent_outlined,
              badge: 'Support',
            ),
          ],
        ),
      ],
    );
  }
}