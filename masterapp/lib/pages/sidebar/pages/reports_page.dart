import 'package:flutter/material.dart';
import '../widgets/sidebar_feature_shell.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SidebarFeatureShell(
      title: 'Reports',
      icon: Icons.assessment_outlined,
      sections: [
        FeatureSectionData(
          title: 'Laporan Utama',
          items: [
            FeatureActionItemData(
              title: 'Laporan harian operasional',
              subtitle: 'Generate PDF / Excel',
              detail:
                  'Laporan ini berisi aktivitas operasional harian, jumlah task selesai, dan update penting lainnya.',
              icon: Icons.picture_as_pdf_outlined,
              badge: 'Daily',
            ),
            FeatureActionItemData(
              title: 'Laporan inventory',
              subtitle: 'Stock in / Stock out',
              detail:
                  'Berisi data pergerakan stok, item tersedia, item habis, dan histori perubahan inventory.',
              icon: Icons.summarize_outlined,
              badge: 'Stock',
            ),
          ],
        ),
        FeatureSectionData(
          title: 'Monitoring',
          items: [
            FeatureActionItemData(
              title: 'Laporan progress project',
              subtitle: '5 project aktif',
              detail:
                  'Ringkasan progres project aktif lengkap dengan persentase penyelesaian dan potensi kendala.',
              icon: Icons.stacked_line_chart_outlined,
              badge: '5',
            ),
          ],
        ),
      ],
    );
  }
}