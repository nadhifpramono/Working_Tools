import 'package:flutter/material.dart';
import '../widgets/sidebar_feature_shell.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SidebarFeatureShell(
      title: 'Notes',
      icon: Icons.note_alt_outlined,
      sections: [
        FeatureSectionData(
          title: 'Project Notes',
          items: [
            FeatureActionItemData(
              title: 'Catatan UI Inventory',
              subtitle: 'Versi revisi 2',
              detail:
                  'Perubahan fokus pada quick stats, shortcut fitur, dan body scroll tunggal agar layout lebih natural.',
              icon: Icons.design_services_outlined,
              badge: 'UI',
            ),
            FeatureActionItemData(
              title: 'Catatan backend integrasi',
              subtitle: 'Node + Flutter',
              detail:
                  'Pastikan API response konsisten, validasi error jelas, dan file upload memakai endpoint yang stabil.',
              icon: Icons.settings_ethernet_outlined,
              badge: 'API',
            ),
          ],
        ),
        FeatureSectionData(
          title: 'Personal Notes',
          items: [
            FeatureActionItemData(
              title: 'Ide sidebar baru',
              subtitle: 'Draft awal',
              detail:
                  'Sidebar dipisah jadi section Akun, Workspace, Notes & Arsip, dan Monitoring agar lebih rapi.',
              icon: Icons.lightbulb_outline,
              badge: 'Idea',
            ),
          ],
        ),
      ],
    );
  }
}