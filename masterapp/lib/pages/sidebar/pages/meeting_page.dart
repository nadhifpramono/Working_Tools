import 'package:flutter/material.dart';
import '../widgets/sidebar_feature_shell.dart';

class MeetingPage extends StatelessWidget {
  const MeetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SidebarFeatureShell(
      title: 'Meeting',
      icon: Icons.groups_2_outlined,
      sections: [
        FeatureSectionData(
          title: 'Hari Ini',
          items: [
            FeatureActionItemData(
              title: 'Daily standup',
              subtitle: '09:00 - 09:30',
              detail:
                  'Bahas progres kemarin, target hari ini, dan hambatan utama yang perlu dibantu tim.',
              icon: Icons.today_outlined,
              badge: 'Today',
            ),
            FeatureActionItemData(
              title: 'Koordinasi vendor',
              subtitle: '13:30 - 14:30',
              detail:
                  'Meeting untuk membahas timeline pengadaan, harga final, dan dokumen pendukung vendor.',
              icon: Icons.handshake_outlined,
              badge: 'Vendor',
            ),
          ],
        ),
        FeatureSectionData(
          title: 'Minggu Ini',
          items: [
            FeatureActionItemData(
              title: 'Review progress project',
              subtitle: 'Kamis • 10:00',
              detail:
                  'Review milestone project, kesiapan deploy, dan rencana penutupan sprint.',
              icon: Icons.event_available_outlined,
              badge: 'Weekly',
            ),
            FeatureActionItemData(
              title: 'Meeting evaluasi',
              subtitle: 'Jumat • 15:00',
              detail:
                  'Evaluasi performa tim, capaian target mingguan, dan area perbaikan yang perlu diprioritaskan.',
              icon: Icons.insights_outlined,
              badge: 'Eval',
            ),
          ],
        ),
      ],
    );
  }
}