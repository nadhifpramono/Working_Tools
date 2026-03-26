import 'package:flutter/material.dart';
import '../profile/profile.dart';
import '../inventory/inventory.dart';
import '../inventory/updateinventory.dart';
import '../project_management/project_management.dart';
import '../file_manager/file_manager_home.dart';
import '../notifications/notification.dart';
import '../chat/chat.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color bg = Color(0xFFF2F9FF);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _navIndex = 0;
  String _dashboardKeyword = '';
  String _dashboardFilter = 'Semua';

  void _openNotificationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationPage(),
      ),
    );
  }

  void _clearDashboardSearch() {
    setState(() {
      _dashboardKeyword = '';
      _dashboardFilter = 'Semua';
    });
  }

  Future<void> _openDashboardSearch() async {
    final keywordC = TextEditingController(text: _dashboardKeyword);
    String selectedFilter = _dashboardFilter;

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final filters = ['Semua', 'Menu', 'Aktivitas', 'Statistik'];

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Search Dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: keywordC,
                      decoration: InputDecoration(
                        hintText: 'Cari menu, aktivitas, statistik...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xFFF4F6FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Filter',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: filters.map((filter) {
                        return ChoiceChip(
                          label: Text(filter),
                          selected: selectedFilter == filter,
                          onSelected: (_) {
                            setSheetState(() => selectedFilter = filter);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(sheetContext, {
                                'keyword': '',
                                'filter': 'Semua',
                              });
                            },
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(sheetContext, {
                                'keyword': keywordC.text.trim(),
                                'filter': selectedFilter,
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF101D6E),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Terapkan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _dashboardKeyword = result['keyword'] ?? '';
        _dashboardFilter = result['filter'] ?? 'Semua';
      });
    }
  }

  void _openSidebarFeature({
    required String title,
    required IconData icon,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FeaturePage(
          title: title,
          icon: icon,
          sections: _getFeatureSections(title),
        ),
      ),
    );
  }

  List<_FeatureSectionData> _getFeatureSections(String title) {
    switch (title) {
      case 'My Work':
        return const [
          _FeatureSectionData(
            title: 'Prioritas Hari Ini',
            items: [
              _FeatureItemData(
                title: 'Review dokumen tender',
                subtitle: 'Deadline hari ini • 14:00',
                detail:
                    'Dokumen tender perlu dicek ulang sebelum dikirim. Fokus pada kelengkapan berkas, nominal, dan lampiran pendukung.',
                icon: Icons.description_outlined,
                badge: 'High',
              ),
              _FeatureItemData(
                title: 'Follow up approval pembelian',
                subtitle: 'Menunggu persetujuan manager',
                detail:
                    'Tindak lanjuti approval pembelian alat kerja dan pastikan semua vendor quotation sudah lengkap.',
                icon: Icons.approval_outlined,
                badge: 'Pending',
              ),
            ],
          ),
          _FeatureSectionData(
            title: 'Progress Mingguan',
            items: [
              _FeatureItemData(
                title: 'Update progress dashboard',
                subtitle: 'Progress 75%',
                detail:
                    'Halaman dashboard hampir selesai. Sisa pekerjaan fokus pada responsive layout dan final QA.',
                icon: Icons.dashboard_outlined,
                badge: '75%',
              ),
              _FeatureItemData(
                title: 'Monitoring task tim',
                subtitle: '5 task aktif',
                detail:
                    'Pantau task anggota tim, cek blocker, dan bantu distribusi workload bila diperlukan.',
                icon: Icons.groups_outlined,
                badge: '5',
              ),
            ],
          ),
        ];

      case 'Task':
        return const [
          _FeatureSectionData(
            title: 'To Do',
            items: [
              _FeatureItemData(
                title: 'Buat laporan mingguan',
                subtitle: 'Belum dimulai',
                detail:
                    'Susun laporan mingguan berisi progres kerja, hambatan, dan rencana minggu berikutnya.',
                icon: Icons.assignment_outlined,
                badge: 'Todo',
              ),
              _FeatureItemData(
                title: 'Cek stok safety equipment',
                subtitle: 'Perlu verifikasi gudang',
                detail:
                    'Lakukan pengecekan stok perlengkapan safety untuk memastikan data inventory sesuai kondisi lapangan.',
                icon: Icons.inventory_2_outlined,
                badge: 'Todo',
              ),
            ],
          ),
          _FeatureSectionData(
            title: 'In Progress',
            items: [
              _FeatureItemData(
                title: 'Revisi halaman inventory',
                subtitle: 'Sedang dikerjakan',
                detail:
                    'Perubahan fokus pada quick stats, fitur shortcut, dan struktur scroll agar semua bagian ikut bergerak.',
                icon: Icons.build_circle_outlined,
                badge: 'Progress',
              ),
            ],
          ),
        ];

      case 'Meeting':
        return const [
          _FeatureSectionData(
            title: 'Hari Ini',
            items: [
              _FeatureItemData(
                title: 'Daily standup',
                subtitle: '09:00 - 09:30',
                detail:
                    'Bahas progres kemarin, target hari ini, dan hambatan utama yang perlu dibantu tim.',
                icon: Icons.today_outlined,
                badge: 'Today',
              ),
              _FeatureItemData(
                title: 'Koordinasi vendor',
                subtitle: '13:30 - 14:30',
                detail:
                    'Meeting untuk membahas timeline pengadaan, harga final, dan dokumen vendor.',
                icon: Icons.handshake_outlined,
                badge: 'Vendor',
              ),
            ],
          ),
        ];

      case 'Notepad':
        return const [
          _FeatureSectionData(
            title: 'Quick Notes',
            items: [
              _FeatureItemData(
                title: 'Catatan follow up klien',
                subtitle: '3 poin penting',
                detail:
                    'Klien meminta revisi layout, tambahan estimasi biaya, dan penyesuaian deadline presentasi.',
                icon: Icons.note_outlined,
                badge: 'Quick',
              ),
              _FeatureItemData(
                title: 'Checklist lapangan',
                subtitle: 'Persiapan inspeksi',
                detail:
                    'Checklist lapangan berisi APD, alat ukur, lembar inspeksi, dokumentasi foto, dan approval supervisor.',
                icon: Icons.fact_check_outlined,
                badge: 'Check',
              ),
            ],
          ),
        ];

      case 'Notes':
        return const [
          _FeatureSectionData(
            title: 'Project Notes',
            items: [
              _FeatureItemData(
                title: 'Catatan UI Inventory',
                subtitle: 'Versi revisi 2',
                detail:
                    'Perubahan fokus pada quick stats, shortcut fitur, dan body scroll tunggal agar layout lebih natural.',
                icon: Icons.design_services_outlined,
                badge: 'UI',
              ),
              _FeatureItemData(
                title: 'Catatan backend integrasi',
                subtitle: 'Node + Flutter',
                detail:
                    'Pastikan API response konsisten, validasi error jelas, dan file upload memakai endpoint yang stabil.',
                icon: Icons.settings_ethernet_outlined,
                badge: 'API',
              ),
            ],
          ),
        ];

      case 'Arsip':
        return const [
          _FeatureSectionData(
            title: 'Arsip Dokumen',
            items: [
              _FeatureItemData(
                title: 'Dokumen project selesai',
                subtitle: '12 file tersimpan',
                detail:
                    'Berisi dokumen project yang sudah closed, termasuk laporan akhir dan lampiran pendukung.',
                icon: Icons.folder_copy_outlined,
                badge: '12',
              ),
              _FeatureItemData(
                title: 'Invoice lama',
                subtitle: 'Periode Januari - Maret',
                detail:
                    'Invoice lama dipindahkan ke arsip untuk memudahkan pencarian dan audit data keuangan.',
                icon: Icons.receipt_long_outlined,
                badge: 'Q1',
              ),
            ],
          ),
        ];

      case 'Archive':
        return const [
          _FeatureSectionData(
            title: 'Backup & Bundles',
            items: [
              _FeatureItemData(
                title: 'Backup database',
                subtitle: 'Terakhir diperbarui kemarin',
                detail:
                    'Backup data dilakukan rutin untuk menjaga keamanan data dan memudahkan restore saat dibutuhkan.',
                icon: Icons.backup_outlined,
                badge: 'Safe',
              ),
              _FeatureItemData(
                title: 'ZIP dokumen vendor',
                subtitle: '8 bundle arsip',
                detail:
                    'Dokumen vendor yang sudah tidak aktif disimpan dalam format ZIP untuk efisiensi storage.',
                icon: Icons.folder_zip_outlined,
                badge: 'ZIP',
              ),
            ],
          ),
        ];

      case 'Activity Log':
        return const [
          _FeatureSectionData(
            title: 'Aktivitas User',
            items: [
              _FeatureItemData(
                title: 'Admin update inventory',
                subtitle: 'Hari ini • 09:10',
                detail:
                    'Admin melakukan update jumlah stok dan perubahan status item inventory.',
                icon: Icons.inventory_2_outlined,
                badge: 'Today',
              ),
              _FeatureItemData(
                title: 'User login dari tablet',
                subtitle: 'Hari ini • 07:45',
                detail:
                    'Terjadi aktivitas login dari perangkat tablet yang terhubung ke sistem absensi.',
                icon: Icons.tablet_mac_outlined,
                badge: 'Login',
              ),
            ],
          ),
        ];

      case 'Reports':
        return const [
          _FeatureSectionData(
            title: 'Laporan Utama',
            items: [
              _FeatureItemData(
                title: 'Laporan harian operasional',
                subtitle: 'Generate PDF / Excel',
                detail:
                    'Laporan ini berisi aktivitas operasional harian, jumlah task selesai, dan update penting lainnya.',
                icon: Icons.picture_as_pdf_outlined,
                badge: 'Daily',
              ),
              _FeatureItemData(
                title: 'Laporan inventory',
                subtitle: 'Stock in / Stock out',
                detail:
                    'Berisi data pergerakan stok, item tersedia, item habis, dan histori perubahan inventory.',
                icon: Icons.summarize_outlined,
                badge: 'Stock',
              ),
            ],
          ),
        ];

      case 'Help Center':
        return const [
          _FeatureSectionData(
            title: 'Bantuan Cepat',
            items: [
              _FeatureItemData(
                title: 'Cara menambah item inventory',
                subtitle: 'Panduan singkat',
                detail:
                    'Masuk ke halaman Inventory, tekan tombol Tambah Item, lalu isi nama, kategori, jumlah, dan status barang.',
                icon: Icons.inventory_outlined,
                badge: 'Guide',
              ),
              _FeatureItemData(
                title: 'Cara export laporan',
                subtitle: 'PDF dan Excel',
                detail:
                    'Masuk ke halaman Reports, pilih jenis laporan, atur periode, lalu pilih format export yang diinginkan.',
                icon: Icons.file_download_outlined,
                badge: 'Export',
              ),
            ],
          ),
        ];

      default:
        return const [
          _FeatureSectionData(
            title: 'Informasi',
            items: [
              _FeatureItemData(
                title: 'Fitur siap digunakan',
                subtitle: 'Silakan pilih item',
                detail:
                    'Fitur ini sudah aktif. Kamu bisa tekan item untuk melihat detail isi.',
                icon: Icons.info_outline,
                badge: 'Ready',
              ),
            ],
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bg,
      drawer: _AppSidebar(
        onTapProfile: () {
          Navigator.pop(context);
          setState(() => _navIndex = 3);
        },
        onTapSettings: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const _SettingsPage()),
          );
        },
        onTapHelpCenter: () {
          Navigator.pop(context);
          _openSidebarFeature(
            title: 'Help Center',
            icon: Icons.help_outline,
          );
        },
        onTapMyWork: () {
          Navigator.pop(context);
          _openSidebarFeature(
            title: 'My Work',
            icon: Icons.work_outline,
          );
        },
        onTapTask: () {
          Navigator.pop(context);
          _openSidebarFeature(
            title: 'Task',
            icon: Icons.task_alt_outlined,
          );
        },
        onTapMeeting: () {
          Navigator.pop(context);
          _openSidebarFeature(
            title: 'Meeting',
            icon: Icons.groups_2_outlined,
          );
        },
        onTapNotepad: () {
          Navigator.pop(context);
          _openSidebarFeature(
            title: 'Notepad',
            icon: Icons.sticky_note_2_outlined,
          );
        },
        onTapNotes: () {
          Navigator.pop(context);
          _openSidebarFeature(
            title: 'Notes',
            icon: Icons.note_alt_outlined,
          );
        },
        onTapArsip: () {
          Navigator.pop(context);
          _openSidebarFeature(
            title: 'Arsip',
            icon: Icons.archive_outlined,
          );
        },
        onTapArchive: () {
          Navigator.pop(context);
          _openSidebarFeature(
            title: 'Archive',
            icon: Icons.folder_zip_outlined,
          );
        },
        onTapActivityLog: () {
          Navigator.pop(context);
          _openSidebarFeature(
            title: 'Activity Log',
            icon: Icons.history,
          );
        },
        onTapReports: () {
          Navigator.pop(context);
          _openSidebarFeature(
            title: 'Reports',
            icon: Icons.assessment_outlined,
          );
        },
      ),
      body: IndexedStack(
        index: _navIndex,
        children: [
          _DashboardHomeBody(
            onTapMenu: () => _scaffoldKey.currentState?.openDrawer(),
            onTapNotification: _openNotificationPage,
            onTapSearch: _openDashboardSearch,
            onClearSearch: _clearDashboardSearch,
            onTapProfileShortcut: () => setState(() => _navIndex = 3),
            searchKeyword: _dashboardKeyword,
            searchFilter: _dashboardFilter,
          ),
          ChatPage(),
          FileManagerHomePage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
        },
      ),
    );
  }
}

class _DashboardHomeBody extends StatelessWidget {
  final VoidCallback onTapMenu;
  final VoidCallback onTapNotification;
  final VoidCallback onTapSearch;
  final VoidCallback onClearSearch;
  final VoidCallback onTapProfileShortcut;
  final String searchKeyword;
  final String searchFilter;

  const _DashboardHomeBody({
    required this.onTapMenu,
    required this.onTapNotification,
    required this.onTapSearch,
    required this.onClearSearch,
    required this.onTapProfileShortcut,
    required this.searchKeyword,
    required this.searchFilter,
  });

  static const Color navy = Color(0xFF101D6E);
  static const Color card = Color(0xFFFAFEFF);
  static const Color soft = Color(0xFFF4F5FF);
  static const Color border = Color(0xFFDCECFF);
  static const Color text = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 768;

    final gridCrossAxisCount = isTablet ? 4 : 3;
    final gridSpacing = isTablet ? 16.0 : 12.0;

    final keyword = searchKeyword.trim().toLowerCase();

    bool matches(String value) {
      if (keyword.isEmpty) return true;
      return value.toLowerCase().contains(keyword);
    }

    final stats = <_DashboardStatData>[
      _DashboardStatData(value: '24', label: 'Pending', onTap: () {}),
      _DashboardStatData(
        value: '5',
        label: 'Projects',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectManagementPage(),
            ),
          );
        },
      ),
      _DashboardStatData(value: '12', label: 'Reports', onTap: () {}),
      _DashboardStatData(value: '3', label: 'Members', onTap: () {}),
    ];

    final menus = <_DashboardMenuData>[
      _DashboardMenuData(
        label: 'file manager',
        icon: Icons.description_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FileManagerHomePage(),
            ),
          );
        },
      ),
      _DashboardMenuData(
        label: 'project management',
        icon: Icons.assignment_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectManagementPage(),
            ),
          );
        },
      ),
      _DashboardMenuData(
        label: 'inventory',
        icon: Icons.inventory_2_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InventoryPage(),
            ),
          );
        },
      ),
      _DashboardMenuData(
        label: 'notes',
        icon: Icons.event_note_outlined,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Halaman notes ada di sidebar')),
          );
        },
      ),
      _DashboardMenuData(
        label: 'finance',
        icon: Icons.account_balance_wallet_outlined,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Halaman finance belum dibuat')),
          );
        },
      ),
      _DashboardMenuData(
        label: 'service all',
        icon: Icons.grid_view_rounded,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service all ditekan')),
          );
        },
      ),
    ];

    final activities = const <_ActivityItemData>[
      _ActivityItemData(
        title: 'Safety inspection Completed',
        icon: Icons.check_circle,
        iconColor: Color(0xFF16A34A),
      ),
      _ActivityItemData(
        title: 'Inventory Update',
        icon: Icons.inventory,
        iconColor: Color(0xFFD4AF37),
      ),
      _ActivityItemData(
        title: 'New Task Assigned',
        icon: Icons.assignment,
        iconColor: Color(0xFF7F1D1D),
      ),
    ];

    final showStats = searchFilter == 'Semua' || searchFilter == 'Statistik';
    final showMenus = searchFilter == 'Semua' || searchFilter == 'Menu';
    final showActivities =
        searchFilter == 'Semua' || searchFilter == 'Aktivitas';

    final filteredStats =
        stats.where((e) => matches('${e.label} ${e.value}')).toList();
    final filteredMenus = menus.where((e) => matches(e.label)).toList();
    final filteredActivities =
        activities.where((e) => matches(e.title)).toList();

    final hasSearch = searchKeyword.isNotEmpty || searchFilter != 'Semua';
    final hasAnyResult =
        (showStats && filteredStats.isNotEmpty) ||
        (showMenus && filteredMenus.isNotEmpty) ||
        (showActivities && filteredActivities.isNotEmpty);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: isTablet ? 90 : 80,
              decoration: const BoxDecoration(color: navy),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onTapMenu,
                    icon: const Icon(Icons.menu_rounded),
                    color: Colors.white,
                    tooltip: 'Menu',
                  ),
                  Expanded(
                    child: Text(
                      'Dasboard (home page)',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isTablet ? 18 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onTapSearch,
                    icon: const Icon(Icons.search_rounded),
                    color: Colors.white,
                    tooltip: 'Search',
                  ),
                  IconButton(
                    onPressed: onTapNotification,
                    icon: const Icon(Icons.notifications_none_rounded),
                    color: Colors.white,
                    tooltip: 'Notifications',
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _DashboardProfileCard(
                    cardColor: card,
                    borderColor: const Color(0xFFE2E0E0),
                    name: 'Hanyakra Narendra',
                    role: 'Supervisor',
                    onTap: onTapProfileShortcut,
                  ),
                  if (hasSearch) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.tune, size: 18, color: navy),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pencarian: "${searchKeyword.isEmpty ? '-' : searchKeyword}" • Filter: $searchFilter',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: text,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: onClearSearch,
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (showStats && filteredStats.isNotEmpty) ...[
                    LayoutBuilder(
                      builder: (context, c) {
                        const spacing = 12.0;
                        final columns =
                            filteredStats.length >= 4 ? 4 : filteredStats.length;
                        final itemW =
                            (c.maxWidth - spacing * (columns - 1)) / columns;
                        final itemH = isTablet ? 96.0 : 78.0;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: filteredStats.map((item) {
                            return _StatQuickButton(
                              width: itemW,
                              height: itemH,
                              color: navy,
                              value: item.value,
                              label: item.label,
                              onTap: item.onTap,
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (showMenus && filteredMenus.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: filteredMenus.length < gridCrossAxisCount
                              ? filteredMenus.length
                              : gridCrossAxisCount,
                          crossAxisSpacing: gridSpacing,
                          mainAxisSpacing: gridSpacing,
                          childAspectRatio: isTablet ? 1.1 : 1.05,
                        ),
                        children: filteredMenus.map((item) {
                          return _MenuTile(
                            label: item.label,
                            icon: item.icon,
                            bg: soft,
                            border: border,
                            onTap: item.onTap,
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (showActivities && filteredActivities.isNotEmpty) ...[
                    Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 18,
                        fontWeight: FontWeight.w700,
                        color: text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ActivityCard(
                      bg: soft,
                      border: border,
                      items: filteredActivities,
                      onTapItem: (index) {
                        final tapped = filteredActivities[index];
                        if (tapped.title == 'Inventory Update') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UpdateInventoryPage(),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (hasSearch && !hasAnyResult)
                    const _SearchEmptyState(
                      title: 'Data tidak ditemukan',
                      subtitle: 'Coba ganti keyword atau filter pencarian.',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardProfileCard extends StatelessWidget {
  final Color cardColor;
  final Color borderColor;
  final String name;
  final String role;
  final VoidCallback onTap;

  const _DashboardProfileCard({
    required this.cardColor,
    required this.borderColor,
    required this.name,
    required this.role,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 768;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Color(0xFFEFEFEF),
                child: Icon(Icons.person_outline, color: Colors.black54),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827).withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatQuickButton extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final String value;
  final String label;
  final VoidCallback onTap;

  const _StatQuickButton({
    required this.width,
    required this.height,
    required this.color,
    required this.value,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = height < 85;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(15),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withOpacity(0.92),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmall ? 18 : 24,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmall ? 11 : 13,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final Color border;
  final VoidCallback onTap;

  const _MenuTile({
    required this.label,
    required this.icon,
    required this.bg,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: const Color(0xFF111827)),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Color bg;
  final Color border;
  final List<_ActivityItemData> items;
  final ValueChanged<int> onTapItem;

  const _ActivityCard({
    required this.bg,
    required this.border,
    required this.items,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              InkWell(
                onTap: () => onTapItem(index),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  child: Row(
                    children: [
                      Icon(item.icon, color: item.iconColor, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                ),
              ),
              if (index != items.length - 1)
                const Divider(height: 1, color: Color(0xFFDCECFF)),
            ],
          );
        }),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF101D6E),
      unselectedItemColor: const Color(0xFF6B7280),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder_outlined),
          label: 'File Manager',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _AppSidebar extends StatelessWidget {
  final VoidCallback onTapProfile;
  final VoidCallback onTapSettings;
  final VoidCallback onTapHelpCenter;
  final VoidCallback onTapMyWork;
  final VoidCallback onTapTask;
  final VoidCallback onTapMeeting;
  final VoidCallback onTapNotepad;
  final VoidCallback onTapNotes;
  final VoidCallback onTapArsip;
  final VoidCallback onTapArchive;
  final VoidCallback onTapActivityLog;
  final VoidCallback onTapReports;

  const _AppSidebar({
    required this.onTapProfile,
    required this.onTapSettings,
    required this.onTapHelpCenter,
    required this.onTapMyWork,
    required this.onTapTask,
    required this.onTapMeeting,
    required this.onTapNotepad,
    required this.onTapNotes,
    required this.onTapArsip,
    required this.onTapArchive,
    required this.onTapActivityLog,
    required this.onTapReports,
  });

  static const Color navy = Color(0xFF101D6E);
  static const Color text = Color(0xFF111827);
  static const Color muted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              decoration: const BoxDecoration(color: navy),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person_outline, color: Colors.white, size: 28),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Hanyakra Narendra',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Supervisor • WorkingTools',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8),
                children: [
                  const _SidebarSectionTitle(title: 'Akun'),
                  _SidebarTile(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: onTapProfile,
                  ),
                  _SidebarTile(
                    icon: Icons.settings_outlined,
                    label: 'Pengaturan',
                    onTap: onTapSettings,
                  ),
                  _SidebarTile(
                    icon: Icons.help_outline,
                    label: 'Help Center',
                    onTap: onTapHelpCenter,
                  ),
                  const Divider(height: 20),
                  const _SidebarSectionTitle(title: 'Workspace'),
                  _SidebarTile(
                    icon: Icons.work_outline,
                    label: 'My Work',
                    onTap: onTapMyWork,
                  ),
                  _SidebarTile(
                    icon: Icons.task_alt_outlined,
                    label: 'Task',
                    onTap: onTapTask,
                  ),
                  _SidebarTile(
                    icon: Icons.groups_2_outlined,
                    label: 'Meeting',
                    onTap: onTapMeeting,
                  ),
                  const Divider(height: 20),
                  const _SidebarSectionTitle(title: 'Notes & Arsip'),
                  _SidebarTile(
                    icon: Icons.sticky_note_2_outlined,
                    label: 'Notepad',
                    onTap: onTapNotepad,
                  ),
                  _SidebarTile(
                    icon: Icons.note_alt_outlined,
                    label: 'Notes',
                    onTap: onTapNotes,
                  ),
                  _SidebarTile(
                    icon: Icons.archive_outlined,
                    label: 'Arsip',
                    onTap: onTapArsip,
                  ),
                  _SidebarTile(
                    icon: Icons.folder_zip_outlined,
                    label: 'Archive',
                    onTap: onTapArchive,
                  ),
                  const Divider(height: 20),
                  const _SidebarSectionTitle(title: 'Monitoring'),
                  _SidebarTile(
                    icon: Icons.history,
                    label: 'Activity Log',
                    onTap: onTapActivityLog,
                  ),
                  _SidebarTile(
                    icon: Icons.assessment_outlined,
                    label: 'Reports',
                    onTap: onTapReports,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarSectionTitle extends StatelessWidget {
  final String title;

  const _SidebarSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          color: _AppSidebar.muted,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: _AppSidebar.text),
      title: Text(
        label,
        style: const TextStyle(
          color: _AppSidebar.text,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: _AppSidebar.muted),
      onTap: onTap,
    );
  }
}

class _FeaturePage extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_FeatureSectionData> sections;

  const _FeaturePage({
    required this.title,
    required this.icon,
    required this.sections,
  });

  static const Color bg = Color(0xFFF2F9FF);
  static const Color navy = Color(0xFF101D6E);
  static const Color card = Color(0xFFFAFEFF);
  static const Color soft = Color(0xFFF4F5FF);
  static const Color border = Color(0xFFDCECFF);
  static const Color text = Color(0xFF111827);
  static const Color muted = Color(0xFF6B7280);

  void _showItemDetail(BuildContext context, _FeatureItemData item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: text,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.badge.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EEFF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.badge,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: soft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: Text(
                    item.detail,
                    style: const TextStyle(
                      color: text,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: const Text('Tutup'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${item.title} dipilih')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navy,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Pilih'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, _FeatureSectionData section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: text,
              ),
            ),
            const SizedBox(height: 10),
            ...section.items.map(
              (item) => InkWell(
                onTap: () => _showItemDetail(context, item),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: soft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                        ),
                        child: Icon(item.icon, color: navy),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.badge.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EEFF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.badge,
                            style: const TextStyle(
                              color: navy,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: muted),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$title Workspace',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...sections.map((section) => _buildSection(context, section)),
        ],
      ),
    );
  }
}

class _SettingsPage extends StatefulWidget {
  const _SettingsPage();

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  static const Color bg = Color(0xFFF2F9FF);
  static const Color navy = Color(0xFF101D6E);
  static const Color card = Color(0xFFFAFEFF);
  static const Color soft = Color(0xFFF4F5FF);
  static const Color border = Color(0xFFDCECFF);

  bool _darkMode = false;
  bool _pinEnabled = true;
  bool _notificationEnabled = true;
  String _language = 'Indonesia';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                  title: const Text('Mode gelap'),
                  subtitle: const Text('Aktifkan tampilan gelap'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                ),
                SwitchListTile.adaptive(
                  value: _pinEnabled,
                  onChanged: (v) => setState(() => _pinEnabled = v),
                  title: const Text('Aktifkan PIN'),
                  subtitle: const Text('Keamanan login tambahan'),
                  secondary: const Icon(Icons.pin_outlined),
                ),
                SwitchListTile.adaptive(
                  value: _notificationEnabled,
                  onChanged: (v) => setState(() => _notificationEnabled = v),
                  title: const Text('Notifikasi'),
                  subtitle: const Text('Izinkan notifikasi aplikasi'),
                  secondary: const Icon(Icons.notifications_active_outlined),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: soft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _language,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'Indonesia',
                          child: Text('Indonesia'),
                        ),
                        DropdownMenuItem(
                          value: 'English',
                          child: Text('English'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _language = v);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureSectionData {
  final String title;
  final List<_FeatureItemData> items;

  const _FeatureSectionData({
    required this.title,
    required this.items,
  });
}

class _FeatureItemData {
  final String title;
  final String subtitle;
  final String detail;
  final IconData icon;
  final String badge;

  const _FeatureItemData({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.icon,
    this.badge = '',
  });
}

class _DashboardStatData {
  final String value;
  final String label;
  final VoidCallback onTap;

  const _DashboardStatData({
    required this.value,
    required this.label,
    required this.onTap,
  });
}

class _DashboardMenuData {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardMenuData({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class _ActivityItemData {
  final String title;
  final IconData icon;
  final Color iconColor;

  const _ActivityItemData({
    required this.title,
    required this.icon,
    required this.iconColor,
  });
}

class _SearchEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SearchEmptyState({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCECFF)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 42,
            color: Color(0xFF6B7280),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
           ),
        ],
      ),
    );
  }
}