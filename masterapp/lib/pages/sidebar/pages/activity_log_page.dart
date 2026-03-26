import 'package:flutter/material.dart';
import '../widgets/sidebar_feature_shell.dart';

class ActivityLogPage extends StatelessWidget {
  const ActivityLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SidebarFeatureShell(
      title: 'Activity Log',
      icon: Icons.history,
      sections: [
        FeatureSectionData(
          title: 'Aktivitas User',
          items: [
            FeatureActionItemData(
              title: 'Admin update inventory',
              subtitle: 'Hari ini • 09:10',
              detail:
                  'Admin melakukan update jumlah stok dan perubahan status item inventory.',
              icon: Icons.inventory_2_outlined,
              badge: 'Today',
            ),
            FeatureActionItemData(
              title: 'User login dari tablet',
              subtitle: 'Hari ini • 07:45',
              detail:
                  'Terjadi aktivitas login dari perangkat tablet yang terhubung ke sistem absensi.',
              icon: Icons.tablet_mac_outlined,
              badge: 'Login',
            ),
          ],
        ),
        FeatureSectionData(
          title: 'Aktivitas Sistem',
          items: [
            FeatureActionItemData(
              title: 'Backup otomatis selesai',
              subtitle: 'Kemarin • 23:00',
              detail:
                  'Sistem berhasil menjalankan backup otomatis tanpa error.',
              icon: Icons.cloud_done_outlined,
              badge: 'Done',
            ),
          ],
        ),
      ],
    );
  }
}