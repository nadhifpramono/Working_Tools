import 'package:flutter/material.dart';
import '../widgets/sidebar_feature_shell.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SidebarFeatureShell(
      title: 'Task',
      icon: Icons.task_alt_outlined,
      sections: [
        FeatureSectionData(
          title: 'To Do',
          items: [
            FeatureActionItemData(
              title: 'Buat laporan mingguan',
              subtitle: 'Belum dimulai',
              detail:
                  'Susun laporan mingguan berisi progres kerja, hambatan, dan rencana tindak lanjut minggu berikutnya.',
              icon: Icons.assignment_outlined,
              badge: 'Todo',
            ),
            FeatureActionItemData(
              title: 'Cek stok safety equipment',
              subtitle: 'Perlu verifikasi gudang',
              detail:
                  'Lakukan pengecekan stok perlengkapan safety untuk memastikan data inventory sesuai kondisi lapangan.',
              icon: Icons.inventory_2_outlined,
              badge: 'Todo',
            ),
          ],
        ),
        FeatureSectionData(
          title: 'In Progress',
          items: [
            FeatureActionItemData(
              title: 'Revisi halaman inventory',
              subtitle: 'Sedang dikerjakan',
              detail:
                  'Perubahan fokus pada quick stats, fitur shortcut, dan struktur scroll agar semua bagian ikut bergerak.',
              icon: Icons.build_circle_outlined,
              badge: 'Progress',
            ),
            FeatureActionItemData(
              title: 'Testing form input',
              subtitle: '8 dari 12 test case selesai',
              detail:
                  'Lakukan pengujian validasi input form untuk memastikan error handling berjalan dengan baik.',
              icon: Icons.rule_folder_outlined,
              badge: '8/12',
            ),
          ],
        ),
      ],
    );
  }
}