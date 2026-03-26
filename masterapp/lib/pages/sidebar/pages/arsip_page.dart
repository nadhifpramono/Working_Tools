import 'package:flutter/material.dart';
import '../widgets/sidebar_feature_shell.dart';

class ArsipPage extends StatelessWidget {
  const ArsipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SidebarFeatureShell(
      title: 'Arsip',
      icon: Icons.archive_outlined,
      sections: [
        FeatureSectionData(
          title: 'Arsip Dokumen',
          items: [
            FeatureActionItemData(
              title: 'Dokumen project selesai',
              subtitle: '12 file tersimpan',
              detail:
                  'Berisi dokumen project yang sudah closed, termasuk laporan akhir, BAST, dan lampiran pendukung.',
              icon: Icons.folder_copy_outlined,
              badge: '12',
            ),
            FeatureActionItemData(
              title: 'Invoice lama',
              subtitle: 'Periode Januari - Maret',
              detail:
                  'Invoice lama dipindahkan ke arsip untuk memudahkan pencarian dan audit data keuangan.',
              icon: Icons.receipt_long_outlined,
              badge: 'Q1',
            ),
          ],
        ),
      ],
    );
  }
}