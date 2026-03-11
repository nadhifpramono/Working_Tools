import 'package:flutter/material.dart';

import 'task_management.dart';
import '../../models/project_item.dart';

class ProjectManagementPage extends StatefulWidget {
  const ProjectManagementPage({super.key});

  @override
  State<ProjectManagementPage> createState() => _ProjectManagementPageState();
}

class _ProjectManagementPageState extends State<ProjectManagementPage> {
  // ✅ Theme tokens (samakan dengan dashboard temanmu)
  static const Color NAVY = Color(0xFF101D6E);
  static const Color BG = Color(0xFFF2F9FF);
  static const Color CARD = Color(0xFFFFFFFF);
  static const Color BORDER = Color(0xFFE3E1E1);
  static const Color MUTED = Color(0xFF6B7280);
  static const Color TRACK = Color(0xFFC5C5C5);

  String _priorityFilter = 'Priority';
  String _sortFilter = 'Deadline';
  final TextEditingController _searchC = TextEditingController();

  final List<ProjectItem> _items = [
    ProjectItem(
      title: 'Renovasi Kantor',
      subtitle: 'Membenarkan Plafon yang rusak',
      progress: 0.90,
      status: 'In Progress',
      priority: 'High',
      totalTask: 12,
      doneTask: 10,
      deadline: '25 Feb 2026',
    ),
    ProjectItem(
      title: 'Working Tools',
      subtitle: 'Membuat Aplikasi Mobile',
      progress: 0.75,
      status: 'In Progress',
      priority: 'Medium',
      totalTask: 10,
      doneTask: 7,
      deadline: '25 Mar 2026',
    ),
    ProjectItem(
      title: 'Renovasi Rumah',
      subtitle: 'Membenarkan Genteng Rusak',
      progress: 0.50,
      status: 'To Do',
      priority: 'Low',
      totalTask: 5,
      doneTask: 1,
      deadline: '25 Juni 2026',
    ),
  ];

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // untuk antisipasi kalau halaman ini dibuka dari dashboard yang punya bottom nav
    // kita kasih padding bawah supaya tombol "New Project" tidak ketiban.
    const bottomSafePad = 90.0;

    return Scaffold(
      backgroundColor: BG,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _TopBar(
                  title: 'Project Management',
                  onBack: () => Navigator.pop(context),
                  onGear: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings clicked')),
                    );
                  },
                ),

                // CONTENT
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      bottomSafePad,
                    ),
                    children: [
                      _SearchBox(
                        controller: _searchC,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _FilterButton(
                              label: _priorityFilter,
                              onTap: () async {
                                final v = await _pickOption(
                                  context,
                                  title: 'Priority',
                                  options: const [
                                    'Priority',
                                    'Low',
                                    'Medium',
                                    'High',
                                  ],
                                  selected: _priorityFilter,
                                );
                                if (v != null)
                                  setState(() => _priorityFilter = v);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _FilterButton(
                              label: _sortFilter,
                              onTap: () async {
                                final v = await _pickOption(
                                  context,
                                  title: 'Sort',
                                  options: const [
                                    'Deadline',
                                    'Progress',
                                    'A-Z',
                                  ],
                                  selected: _sortFilter,
                                );
                                if (v != null) setState(() => _sortFilter = v);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      ..._filteredAndSorted().map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TaskManagementPage(project: p),
                                  ),
                                );
                              },
                              child: ProjectCard(
                                item: p,
                                navy: NAVY,
                                border: const Color(0xFFE2E0E0),
                                track: TRACK,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ✅ "New Project" button (match gambar: box putih + plus + label)
            Positioned(
              right: 16,
              bottom: 16,
              child: _NewProjectButton(
                onTap: () async {
                  final project = await _showAddProjectDialog(context);
                  if (project == null) return;
                  setState(() => _items.insert(0, project));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ProjectItem> _filteredAndSorted() {
    final q = _searchC.text.trim().toLowerCase();

    var list = _items.where((p) {
      final matchSearch =
          q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.subtitle.toLowerCase().contains(q);

      final matchPriority =
          (_priorityFilter == 'Priority') || (p.priority == _priorityFilter);

      return matchSearch && matchPriority;
    }).toList();

    if (_sortFilter == 'Progress') {
      list.sort((a, b) => b.progress.compareTo(a.progress));
    } else if (_sortFilter == 'A-Z') {
      list.sort((a, b) => a.title.compareTo(b.title));
    } else {
      // Deadline (demo): biarkan urutan input (atau nanti parse date beneran)
    }

    return list;
  }

  Future<String?> _pickOption(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String selected,
  }) async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),
                ...options.map((opt) {
                  final active = opt == selected;
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      opt,
                      style: TextStyle(
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    trailing: active
                        ? const Icon(Icons.check, color: Color(0xFF101D6E))
                        : null,
                    onTap: () => Navigator.pop(context, opt),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<ProjectItem?> _showAddProjectDialog(BuildContext context) {
    final titleC = TextEditingController();
    final descC = TextEditingController();
    final deadlineC = TextEditingController(text: '25 Mar 2026');
    final totalTaskC = TextEditingController(text: '1');
    final doneTaskC = TextEditingController(text: '0');

    String priority = 'Medium';
    String? errorText;

    return showDialog<ProjectItem>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            final total = int.tryParse(totalTaskC.text.trim()) ?? 0;
            final done = int.tryParse(doneTaskC.text.trim()) ?? 0;

            final safeTotal = total < 0 ? 0 : total;
            final safeDone = done < 0 ? 0 : done;
            final clampedDone = safeTotal <= 0
                ? 0
                : safeDone.clamp(0, safeTotal);
            final progress = safeTotal <= 0 ? 0.0 : (clampedDone / safeTotal);

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'New Project',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleC,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        isDense: true,
                      ),
                      onChanged: (_) => setLocal(() => errorText = null),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descC,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        isDense: true,
                      ),
                      onChanged: (_) => setLocal(() => errorText = null),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: priority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                        DropdownMenuItem(
                          value: 'Medium',
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(value: 'High', child: Text('High')),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setLocal(() {
                          priority = v;
                          errorText = null;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: deadlineC,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal (Deadline)',
                        isDense: true,
                      ),
                      onChanged: (_) => setLocal(() => errorText = null),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: totalTaskC,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Total Task',
                              isDense: true,
                            ),
                            onChanged: (_) => setLocal(() => errorText = null),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: doneTaskC,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Task Done',
                              isDense: true,
                            ),
                            onChanged: (_) => setLocal(() => errorText = null),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Progress: ${(progress * 100).round()}%',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          errorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NAVY,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final title = titleC.text.trim();
                    final desc = descC.text.trim();
                    final deadline = deadlineC.text.trim();
                    final totalValue =
                        int.tryParse(totalTaskC.text.trim()) ?? 0;
                    final doneValue = int.tryParse(doneTaskC.text.trim()) ?? 0;

                    if (title.isEmpty) {
                      setLocal(() => errorText = 'Title wajib diisi.');
                      return;
                    }
                    if (totalValue <= 0) {
                      setLocal(() => errorText = 'Total Task minimal 1.');
                      return;
                    }
                    if (doneValue < 0 || doneValue > totalValue) {
                      setLocal(() {
                        errorText = 'Task Done harus 0 sampai Total Task.';
                      });
                      return;
                    }

                    final progressValue = (doneValue / totalValue).clamp(
                      0.0,
                      1.0,
                    );
                    final status = doneValue == 0
                        ? 'To Do'
                        : doneValue == totalValue
                        ? 'Done'
                        : 'In Progress';

                    Navigator.pop(
                      context,
                      ProjectItem(
                        title: title,
                        subtitle: desc.isEmpty ? '-' : desc,
                        progress: progressValue,
                        status: status,
                        priority: priority,
                        totalTask: totalValue,
                        doneTask: doneValue,
                        deadline: deadline.isEmpty ? '-' : deadline,
                      ),
                    );
                  },
                  child: const Text(
                    'Create',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      titleC.dispose();
      descC.dispose();
      deadlineC.dispose();
      totalTaskC.dispose();
      doneTaskC.dispose();
    });
  }
}

// ===================== UI COMPONENTS =====================

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onGear;

  const _TopBar({
    required this.title,
    required this.onBack,
    required this.onGear,
  });

  static const Color NAVY = Color(0xFF101D6E);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 768;

    return Container(
      height: isTablet ? 90 : 80,
      decoration: const BoxDecoration(color: NAVY),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: onGear,
            icon: const Icon(Icons.settings),
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBox({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE3E1E1)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF111827)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Search Project',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 41,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewProjectButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NewProjectButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 86,
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(height: 4),
              Icon(Icons.add_box_rounded, size: 38, color: Color(0xFF101D6E)),
              SizedBox(height: 4),
              Text(
                'New Project',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== CARD =====================

class ProjectCard extends StatelessWidget {
  final ProjectItem item;
  final Color navy;
  final Color border;
  final Color track;

  const ProjectCard({
    super.key,
    required this.item,
    required this.navy,
    required this.border,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (item.totalTask - item.doneTask).clamp(0, item.totalTask);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border.withOpacity(0.9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // icon folder
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDCECFF)),
                ),
                child: const Icon(
                  Icons.folder_rounded,
                  color: Color(0xFF101D6E),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFBDBDBD),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Container(
                width: 56,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: navy,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${(item.progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final fillW = (w * item.progress).clamp(0.0, w);

                return Stack(
                  children: [
                    Container(height: 14, width: w, color: track),
                    Container(height: 14, width: fillW, color: navy),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Priority : ${item.priority}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Task : ${item.totalTask} Total | ${item.doneTask} Done | $remaining Remaining',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Deadline : ${item.deadline}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===================== MODEL =====================
