import 'package:flutter/material.dart';
import '../widgets/sidebar_feature_shell.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SidebarFeatureShell(
      title: 'Archive',
      icon: Icons.folder_zip_outlined,
      sections: [
        FeatureSectionData(
          title: 'Backup & Bundles',
          items: [
            FeatureActionItemData(
              title: 'Backup database',
              subtitle: 'Terakhir diperbarui kemarin',
              detail:
                  'Backup data dilakukan rutin untuk menjaga keamanan data dan memudahkan proses restore bila dibutuhkan.',
              icon: Icons.backup_outlined,
              badge: 'Safe',
            ),
            FeatureActionItemData(
              title: 'ZIP dokumen vendor',
              subtitle: '8 bundle arsip',
              detail:
                  'Dokumen vendor yang sudah tidak aktif disimpan dalam format ZIP untuk efisiensi storage.',
              icon: Icons.folder_zip_outlined,
              badge: 'ZIP',
            ),
          ],
        ),
      ],
    );
  }
}