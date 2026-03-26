import 'package:flutter/material.dart';
import '../widgets/sidebar_feature_shell.dart';

class NotepadPage extends StatelessWidget {
  const NotepadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SidebarFeatureShell(
      title: 'Notepad',
      icon: Icons.sticky_note_2_outlined,
      sections: [
        FeatureSectionData(
          title: 'Quick Notes',
          items: [
            FeatureActionItemData(
              title: 'Catatan follow up klien',
              subtitle: '3 poin penting',
              detail:
                  'Klien meminta revisi layout, tambahan estimasi biaya, dan penyesuaian deadline presentasi.',
              icon: Icons.note_outlined,
              badge: 'Quick',
            ),
            FeatureActionItemData(
              title: 'Checklist lapangan',
              subtitle: 'Persiapan inspeksi',
              detail:
                  'Checklist lapangan berisi APD, alat ukur, lembar inspeksi, dokumentasi foto, dan approval supervisor.',
              icon: Icons.fact_check_outlined,
              badge: 'Check',
            ),
          ],
        ),
        FeatureSectionData(
          title: 'Templates',
          items: [
            FeatureActionItemData(
              title: 'Template meeting notes',
              subtitle: 'Siap dipakai',
              detail:
                  'Template standar untuk mencatat peserta, agenda, keputusan, dan action items hasil meeting.',
              icon: Icons.article_outlined,
              badge: 'Template',
            ),
          ],
        ),
      ],
    );
  }
}