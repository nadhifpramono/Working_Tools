import 'package:flutter/material.dart';
import 'chating.dart';
import '../notifications/notification.dart';
import '../sidebar/app_sidebar.dart ';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const Color navy = Color(0xFF101D6E);
  static const Color bg = Color(0xFFF7F7FB);
  static const Color card = Color(0xFFFFFFFF);
  static const Color soft = Color(0xFFEBEDFF);
  static const Color deleteBg = Color(0xFFFFE7E5);
  static const Color border = Color(0xFFE6E6E6);
  static const Color text = Color(0xFF010101);
  static const Color muted = Color(0xFF3C3C3C);
  static const Color purple = navy;
  static const Color blueBadge = Color(0xFF3641B7);

  int _segment = 0; // 0 = Chats, 1 = Groups
  final TextEditingController _searchC = TextEditingController();
  String _chatFilter = 'Semua';

  final LayerLink _settingsLink = LayerLink();
  final SettingsPopupController _popup = SettingsPopupController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _darkMode = false;
  bool _pinEnabled = false;
  String _language = 'Indonesia';

  final List<_ChatItem> _items = [
    _ChatItem(
      employeeId: "PGW-001",
      name: "Kaitlyn",
      roleOrStatus: "online",
      lastMessage: "Have a good one!",
      time: "3:02 PM",
      avatarUrl: "",
      unread: 0,
      verified: true,
      messages: const [
        ChatMessage(text: "Hello!", isMe: false),
        ChatMessage(text: "Have a good one!", isMe: false),
      ],
    ),
    _ChatItem(
      employeeId: "PGW-002",
      name: "Chloe",
      roleOrStatus: "offline",
      lastMessage: "Hello! Are you available for toni...",
      time: "2:58 PM",
      avatarUrl: "",
      unread: 2,
      verified: false,
      messages: const [
        ChatMessage(text: "Hello! Are you available for tonight?", isMe: false),
      ],
    ),
    _ChatItem(
      employeeId: "PGW-003",
      name: "X Client",
      roleOrStatus: "online",
      lastMessage: "I’m not gonna pay you.",
      time: "2:46 PM",
      avatarUrl: "",
      unread: 0,
      verified: true,
      highlighted: true,
      messages: const [
        ChatMessage(text: "I’m not gonna pay you.", isMe: false),
      ],
    ),
    _ChatItem(
      employeeId: "PGW-004",
      name: "Phoebe",
      roleOrStatus: "online",
      lastMessage: "Good bye!",
      time: "2:41 PM",
      avatarUrl: "",
      unread: 0,
      verified: true,
      messages: const [
        ChatMessage(text: "Good bye!", isMe: false),
      ],
    ),
    _ChatItem(
      employeeId: "PGW-005",
      name: "Jack",
      roleOrStatus: "online",
      lastMessage: "See you again!",
      time: "2:27 PM",
      avatarUrl: "",
      unread: 0,
      verified: true,
      messages: const [
        ChatMessage(text: "See you again!", isMe: false),
      ],
    ),
    _ChatItem(
      employeeId: "PGW-006",
      name: "Gibson",
      roleOrStatus: "offline",
      lastMessage: "Okay, Thank you!",
      time: "2:16 PM",
      avatarUrl: "",
      unread: 0,
      verified: false,
      messages: const [
        ChatMessage(text: "Okay, Thank you!", isMe: false),
      ],
    ),
  ];

  final List<_ChatItem> _groups = [
    _ChatItem(
      name: "Group Contoh",
      roleOrStatus: "8 anggota",
      lastMessage: "Diskusi umum grup...",
      time: "4:10 PM",
      avatarUrl: "",
      unread: 0,
      verified: false,
      messages: const [
        ChatMessage(text: "Selamat datang di grup.", isMe: false),
        ChatMessage(text: "Diskusi umum grup...", isMe: false),
      ],
    ),
    _ChatItem(
      name: "Group Proyek 1",
      roleOrStatus: "12 anggota",
      lastMessage: "Update progress hari ini...",
      time: "3:40 PM",
      avatarUrl: "",
      unread: 3,
      verified: false,
      messages: const [
        ChatMessage(text: "Update progress hari ini...", isMe: false),
      ],
    ),
    _ChatItem(
      name: "Group Proyek 2",
      roleOrStatus: "5 anggota",
      lastMessage: "Revisi dokumen sudah diupload",
      time: "3:05 PM",
      avatarUrl: "",
      unread: 0,
      verified: false,
      messages: const [
        ChatMessage(text: "Revisi dokumen sudah diupload", isMe: false),
      ],
    ),
    _ChatItem(
      name: "Group Proyek 3",
      roleOrStatus: "6 anggota",
      lastMessage: "Meeting jam 5 sore ya",
      time: "2:30 PM",
      avatarUrl: "",
      unread: 1,
      verified: false,
      messages: const [
        ChatMessage(text: "Meeting jam 5 sore ya", isMe: false),
      ],
    ),
    _ChatItem(
      name: "Group Proyek 4",
      roleOrStatus: "9 anggota",
      lastMessage: "Checklist task minggu ini",
      time: "1:55 PM",
      avatarUrl: "",
      unread: 0,
      verified: false,
      messages: const [
        ChatMessage(text: "Checklist task minggu ini", isMe: false),
      ],
    ),
  ];

  @override
  void dispose() {
    _popup.hide();
    _searchC.dispose();
    super.dispose();
  }

  void _clearChatSearch() {
    setState(() {
      _searchC.clear();
      _chatFilter = 'Semua';
    });
  }

  int _extractMemberCount(String text) {
    final match = RegExp(r'(\d+)').firstMatch(text);
    return int.tryParse(match?.group(1) ?? '0') ?? 0;
  }

  String _formatCurrentTime() {
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _openChatSearchFilter() async {
    _popup.hide();

    final keywordC = TextEditingController(text: _searchC.text);
    String selectedFilter = _chatFilter;

    final filters = _segment == 0
        ? ['Semua', 'Online', 'Offline', 'Unread', 'Verified']
        : ['Semua', 'Unread', 'Member Banyak', 'Member Sedikit'];

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Chat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: keywordC,
                    decoration: InputDecoration(
                      hintText: 'Cari nama, pesan, status, ID pegawai...',
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
                            backgroundColor: navy,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Terapkan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    keywordC.dispose();

    if (result != null) {
      setState(() {
        _searchC.text = result['keyword'] ?? '';
        _chatFilter = result['filter'] ?? 'Semua';
      });
    }
  }

  Future<void> _openNewMessageByEmployeeId() async {
    _popup.hide();

    final idC = TextEditingController();
    final nameC = TextEditingController();

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Message',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Buat chat baru menggunakan ID pegawai.',
                style: TextStyle(
                  fontSize: 13,
                  color: muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: idC,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'ID Pegawai',
                  hintText: 'Contoh: PGW-001',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  filled: true,
                  fillColor: const Color(0xFFF4F6FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameC,
                decoration: InputDecoration(
                  labelText: 'Nama Pegawai (opsional)',
                  hintText: 'Contoh: Hanyaka Narendra',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: const Color(0xFFF4F6FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext, {
                          'employeeId': idC.text.trim(),
                          'name': nameC.text.trim(),
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: navy,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Buat Chat'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    idC.dispose();
    nameC.dispose();

    if (result == null) return;

    final employeeId = (result['employeeId'] ?? '').trim().toUpperCase();
    final employeeName = (result['name'] ?? '').trim();

    if (employeeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID pegawai wajib diisi.'),
        ),
      );
      return;
    }

    final existingIndex = _items.indexWhere(
      (item) => item.employeeId.toLowerCase() == employeeId.toLowerCase(),
    );

    if (existingIndex != -1) {
      _segment = 0;
      _openChat(_items[existingIndex], isGroup: false);
      return;
    }

    final newItem = _ChatItem(
      employeeId: employeeId,
      name: employeeName.isEmpty ? 'Pegawai $employeeId' : employeeName,
      roleOrStatus: 'offline',
      lastMessage: 'Mulai percakapan...',
      time: _formatCurrentTime(),
      avatarUrl: '',
      unread: 0,
      verified: false,
      messages: [
        ChatMessage(
          text: 'Chat baru dibuat untuk ID pegawai $employeeId.',
          isMe: false,
        ),
      ],
    );

    setState(() {
      _segment = 0;
      _items.insert(0, newItem);
    });

    _openChat(newItem, isGroup: false);
  }

  void _openChat(_ChatItem item, {required bool isGroup}) {
    _popup.hide();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatingPage(
          chatName: item.name,
          subtitle: isGroup
              ? item.roleOrStatus
              : '${item.roleOrStatus} • ID: ${item.employeeId}',
          isGroup: isGroup,
          avatarUrl: item.avatarUrl,
          initialMessages: item.messages,
        ),
      ),
    );
  }

  void _openNotificationPage() {
    _popup.hide();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationPage(),
      ),
    );
  }

  void _openSettingsPopup() {
    _popup.show(
      context: context,
      link: _settingsLink,
      darkMode: _darkMode,
      pinEnabled: _pinEnabled,
      language: _language,
      onDarkModeChanged: (v) => setState(() => _darkMode = v),
      onPinChanged: (v) => setState(() => _pinEnabled = v),
      onLanguageChanged: (v) => setState(() => _language = v),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final maxContent = w > 420 ? 420.0 : w;
    final padH = (w - maxContent) / 2;

    final sourceList = (_segment == 0) ? _items : _groups;
    final keyword = _searchC.text.trim().toLowerCase();

    final listData = sourceList.where((item) {
      final textOk = keyword.isEmpty ||
          item.name.toLowerCase().contains(keyword) ||
          item.employeeId.toLowerCase().contains(keyword) ||
          item.roleOrStatus.toLowerCase().contains(keyword) ||
          item.lastMessage.toLowerCase().contains(keyword);

      bool filterOk = true;

      if (_segment == 0) {
        switch (_chatFilter) {
          case 'Online':
            filterOk = item.roleOrStatus.toLowerCase() == 'online';
            break;
          case 'Offline':
            filterOk = item.roleOrStatus.toLowerCase() == 'offline';
            break;
          case 'Unread':
            filterOk = item.unread > 0;
            break;
          case 'Verified':
            filterOk = item.verified;
            break;
          default:
            filterOk = true;
        }
      } else {
        switch (_chatFilter) {
          case 'Unread':
            filterOk = item.unread > 0;
            break;
          case 'Member Banyak':
            filterOk = _extractMemberCount(item.roleOrStatus) >= 8;
            break;
          case 'Member Sedikit':
            filterOk = _extractMemberCount(item.roleOrStatus) < 8;
            break;
          default:
            filterOk = true;
        }
      }

      return textOk && filterOk;
    }).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bg,
      drawer: const WorkingToolsSidebar(
        activeMenu: WorkingToolsMenu.chat,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _TopBarNavy(
              title: "Chat (home page)",
              settingsLink: _settingsLink,
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
              onGear: _openSettingsPopup,
              onBell: _openNotificationPage,
              onSearch: _openChatSearchFilter,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padH),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const _ChatProfileCard(
                      name: "Hanyaka Narendra",
                      role: "Supervisor",
                      avatarUrl: "",
                    ),
                    const SizedBox(height: 12),
                    _Segmented(
                      value: _segment,
                      onChanged: (v) {
                        _popup.hide();
                        setState(() {
                          _segment = v;
                          _chatFilter = 'Semua';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _SearchRow(
                      controller: _searchC,
                      onChanged: (_) => setState(() {}),
                      onNewMessage: _openNewMessageByEmployeeId,
                    ),
                    if (_searchC.text.trim().isNotEmpty ||
                        _chatFilter != 'Semua') ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (_searchC.text.trim().isNotEmpty)
                                    Chip(
                                      label: Text(
                                        'Keyword: ${_searchC.text.trim()}',
                                      ),
                                      deleteIcon: const Icon(
                                        Icons.close,
                                        size: 18,
                                      ),
                                      onDeleted: () {
                                        setState(() => _searchC.clear());
                                      },
                                    ),
                                  if (_chatFilter != 'Semua')
                                    Chip(
                                      label: Text('Filter: $_chatFilter'),
                                      deleteIcon: const Icon(
                                        Icons.close,
                                        size: 18,
                                      ),
                                      onDeleted: () {
                                        setState(() => _chatFilter = 'Semua');
                                      },
                                    ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _clearChatSearch,
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Expanded(
                      child: listData.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: _SearchEmptyState(
                                title: 'Chat tidak ditemukan',
                                subtitle: 'Coba ubah keyword atau filter.',
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.only(
                                bottom: 16,
                                left: 16,
                                right: 16,
                              ),
                              itemCount: listData.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final item = listData[i];

                                return _SwipeTile(
                                  key: ValueKey(
                                    "${item.employeeId}-${item.name}-${item.time}-$i-$_segment",
                                  ),
                                  item: item,
                                  borderColor:
                                      item.highlighted ? blueBadge : border,
                                  isGroup: _segment == 1,
                                  onTap: () {
                                    _openChat(item, isGroup: _segment == 1);
                                  },
                                  onArchive: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Archived: ${item.name}"),
                                      ),
                                    );
                                  },
                                  onDelete: () {
                                    setState(() {
                                      if (_segment == 0) {
                                        _items.remove(item);
                                      } else {
                                        _groups.remove(item);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBarNavy extends StatelessWidget {
  final String title;
  final LayerLink settingsLink;
  final VoidCallback onMenu;
  final VoidCallback onGear;
  final VoidCallback onBell;
  final VoidCallback onSearch;

  const _TopBarNavy({
    required this.title,
    required this.settingsLink,
    required this.onMenu,
    required this.onGear,
    required this.onBell,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 768;

    return Container(
      height: isTablet ? 90 : 80,
      decoration: const BoxDecoration(color: _ChatPageState.navy),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenu,
            icon: const Icon(Icons.menu_rounded),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isTablet ? 18 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: onSearch,
            icon: const Icon(Icons.search_rounded),
            color: Colors.white,
          ),
          IconButton(
            onPressed: onBell,
            icon: const Icon(Icons.notifications_none_rounded),
            color: Colors.white,
          ),
          CompositedTransformTarget(
            link: settingsLink,
            child: InkWell(
              onTap: onGear,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.settings, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatProfileCard extends StatelessWidget {
  final String name;
  final String role;
  final String avatarUrl;

  const _ChatProfileCard({
    required this.name,
    required this.role,
    required this.avatarUrl,
  });

  ImageProvider? _avatarProvider() {
    if (avatarUrl.isEmpty) return null;
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      return NetworkImage(avatarUrl);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final image = _avatarProvider();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEDED)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFEFEFEF),
              backgroundImage: image,
              child: image == null
                  ? const Icon(Icons.person_outline, color: Colors.black54)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9A9A9A),
                      fontWeight: FontWeight.w600,
                    ),
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

class _Segmented extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _Segmented({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.05, 0.10),
            end: Alignment(1.27, 1.27),
            colors: [_ChatPageState.navy, Color(0x3FEBD4F3)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: _SegBtn(
                active: value == 0,
                label: "Chats",
                onTap: () => onChanged(0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SegBtn(
                active: value == 1,
                label: "Groups",
                onTap: () => onChanged(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegBtn extends StatelessWidget {
  final bool active;
  final String label;
  final VoidCallback onTap;

  const _SegBtn({
    required this.active,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: active ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onNewMessage;

  const _SearchRow({
    required this.controller,
    required this.onChanged,
    required this.onNewMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      decoration: const InputDecoration(
                        hintText: "Search",
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onNewMessage,
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.add, size: 16, color: _ChatPageState.purple),
                  SizedBox(width: 4),
                  Text(
                    "New message",
                    style: TextStyle(
                      color: _ChatPageState.purple,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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

class _SwipeTile extends StatelessWidget {
  final _ChatItem item;
  final Color borderColor;
  final bool isGroup;
  final VoidCallback onTap;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const _SwipeTile({
    super.key,
    required this.item,
    required this.borderColor,
    required this.isGroup,
    required this.onTap,
    required this.onArchive,
    required this.onDelete,
  });

  ImageProvider? _avatarProvider() {
    if (item.avatarUrl.isEmpty) return null;
    if (item.avatarUrl.startsWith('http://') ||
        item.avatarUrl.startsWith('https://')) {
      return NetworkImage(item.avatarUrl);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final image = _avatarProvider();

    return Dismissible(
      key: key!,
      direction: DismissDirection.horizontal,
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          onArchive();
          return false;
        }
        return true;
      },
      onDismissed: (_) => onDelete(),
      background: const _ActionBG(
        color: _ChatPageState.soft,
        icon: Icons.folder_open,
        alignLeft: true,
      ),
      secondaryBackground: const _ActionBG(
        color: _ChatPageState.deleteBg,
        icon: Icons.delete_outline,
        alignLeft: false,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 82,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _ChatPageState.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0CB3B3B3),
                  blurRadius: 40,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFEFEFEF),
                  backgroundImage: image,
                  child: image == null
                      ? const Icon(Icons.person_outline, color: Colors.black54)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ChatPageState.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (!isGroup && item.employeeId.isNotEmpty)
                        Text(
                          'ID: ${item.employeeId}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _ChatPageState.blueBadge,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (item.verified)
                            const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.black54,
                            ),
                          if (item.verified) const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _ChatPageState.muted,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.time,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (item.unread > 0)
                      Container(
                        width: 18,
                        height: 18,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _ChatPageState.blueBadge,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "${item.unread}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionBG extends StatelessWidget {
  final Color color;
  final IconData icon;
  final bool alignLeft;

  const _ActionBG({
    required this.color,
    required this.icon,
    required this.alignLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 24, color: Colors.black87),
      ),
    );
  }
}

class _ChatItem {
  final String employeeId;
  final String name;
  final String roleOrStatus;
  final String lastMessage;
  final String time;
  final String avatarUrl;
  final int unread;
  final bool verified;
  final bool highlighted;
  final List<ChatMessage> messages;

  const _ChatItem({
    this.employeeId = '',
    required this.name,
    required this.roleOrStatus,
    required this.lastMessage,
    required this.time,
    required this.avatarUrl,
    required this.unread,
    required this.verified,
    required this.messages,
    this.highlighted = false,
  });
}

class SettingsPopupController {
  OverlayEntry? _entry;

  void show({
    required BuildContext context,
    required LayerLink link,
    required bool darkMode,
    required bool pinEnabled,
    required String language,
    required ValueChanged<bool> onDarkModeChanged,
    required ValueChanged<bool> onPinChanged,
    required ValueChanged<String> onLanguageChanged,
  }) {
    hide();

    _entry = OverlayEntry(
      builder: (_) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: hide,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(),
              ),
            ),
            CompositedTransformFollower(
              link: link,
              showWhenUnlinked: false,
              offset: const Offset(-260, 38),
              child: Material(
                color: Colors.transparent,
                child: _SettingsPopupCard(
                  darkMode: darkMode,
                  pinEnabled: pinEnabled,
                  language: language,
                  onClose: hide,
                  onDarkModeChanged: onDarkModeChanged,
                  onPinChanged: onPinChanged,
                  onLanguageChanged: onLanguageChanged,
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_entry!);
  }

  void hide() {
    _entry?.remove();
    _entry = null;
  }
}

class _SettingsPopupCard extends StatelessWidget {
  final bool darkMode;
  final bool pinEnabled;
  final String language;

  final VoidCallback onClose;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onPinChanged;
  final ValueChanged<String> onLanguageChanged;

  const _SettingsPopupCard({
    required this.darkMode,
    required this.pinEnabled,
    required this.language,
    required this.onClose,
    required this.onDarkModeChanged,
    required this.onPinChanged,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cardW = w < 360 ? w - 24 : 285.0;

    return SafeArea(
      child: Container(
        width: cardW,
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFDCECFF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.arrow_back, size: 18),
                  ),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Pengaturan',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(
                  Icons.settings,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SectionCard(
              title: 'Tampilan',
              child: Column(
                children: [
                  _RowSwitch(
                    icon: Icons.dark_mode_outlined,
                    label: 'Mode gelap',
                    value: darkMode,
                    onChanged: onDarkModeChanged,
                  ),
                  const SizedBox(height: 8),
                  _RowDropdown(
                    icon: Icons.language_outlined,
                    label: 'Bahasa',
                    value: language,
                    items: const ['Indonesia', 'English'],
                    onChanged: onLanguageChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _SectionCard(
              title: 'Keamanan',
              child: Column(
                children: [
                  _RowAction(
                    icon: Icons.lock_outline,
                    label: 'Ganti kata sandi',
                    onTap: onClose,
                  ),
                  const SizedBox(height: 8),
                  _RowSwitch(
                    icon: Icons.pin_outlined,
                    label: 'Aktifkan pin',
                    value: pinEnabled,
                    onChanged: onPinChanged,
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

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCECFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _RowSwitch extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _RowSwitch({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF111827)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _RowDropdown extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _RowDropdown({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF111827)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            items: items
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}

class _RowAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RowAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF111827)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }
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
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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