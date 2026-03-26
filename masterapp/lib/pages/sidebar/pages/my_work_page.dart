import 'package:flutter/material.dart';
import '../widgets/sidebar_feature_shell.dart';

class MyWorkPage extends StatelessWidget {
  const MyWorkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SidebarFeatureShell(
      title: 'My Work',
      icon: Icons.work_outline,
      sections: [
        FeatureSectionData(
          title: 'Prioritas Hari Ini',
          items: [
            FeatureActionItemData(
              title: 'Review dokumen tender',
              subtitle: 'Deadline hari ini • 14:00',
              detail:
                  'Dokumen tender perlu dicek ulang sebelum dikirim. Fokus pada kelengkapan berkas, nominal, dan lampiran pendukung.',
              icon: Icons.description_outlined,
              badge: 'High',
            ),
            FeatureActionItemData(
              title: 'Follow up approval pembelian',
              subtitle: 'Menunggu persetujuan manager',
              detail:
                  'Tindak lanjuti approval pembelian alat kerja dan pastikan semua vendor quotation sudah lengkap.',
              icon: Icons.approval_outlined,
              badge: 'Pending',
            ),
          ],
        ),
        FeatureSectionData(
          title: 'Progress Mingguan',
          items: [
            FeatureActionItemData(
              title: 'Update progress dashboard',
              subtitle: 'Progress 75%',
              detail:
                  'Halaman dashboard sudah hampir selesai. Sisa pekerjaan ada pada responsive layout dan final QA.',
              icon: Icons.dashboard_outlined,
              badge: '75%',
            ),
            FeatureActionItemData(
              title: 'Monitoring task tim',
              subtitle: '5 task aktif',
              detail:
                  'Pantau task anggota tim, cek blocker, dan bantu distribusi ulang workload bila diperlukan.',
              icon: Icons.groups_outlined,
              badge: '5',
            ),
          ],
        ),
      ],
    );
  }
}