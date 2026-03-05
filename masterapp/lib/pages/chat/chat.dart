// lib/pages/chat.dart
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // ===== Theme Tokens =====
  static const Color NAVY = Color(0xFF101D6E);
  static const Color BG = Color(0xFFF7F7FB);
  static const Color CARD = Color(0xFFFFFFFF);
  static const Color SOFT = Color(0xFFEBEDFF);
  static const Color DELETE_BG = Color(0xFFFFE7E5);
  static const Color BORDER = Color(0xFFE6E6E6);
  static const Color TEXT = Color(0xFF010101);
  static const Color MUTED = Color(0xFF3C3C3C);
  static const Color PURPLE = Color(0xFF6B257F);
  static const Color BLUE_BADGE = Color(0xFF3641B7);

  int _segment = 1; // ✅ default ke Groups (0=Chats, 1=Groups)
  final TextEditingController _searchC = TextEditingController();

  final List<_ChatItem> _items = [
    _ChatItem(
      name: "Kaitlyn",
      lastMessage: "Have a good one!",
      time: "3:02 PM",
      avatarUrl: "https://placehold.co/80x80",
      unread: 0,
      verified: true,
    ),
    _ChatItem(
      name: "Chloe",
      lastMessage: "Hello! Are you available for toni...",
      time: "2:58 PM",
      avatarUrl: "https://placehold.co/80x80",
      unread: 2,
      verified: false,
    ),
    _ChatItem(
      name: "X Client",
      lastMessage: "I’m not gonna pay you.",
      time: "2:46 PM",
      avatarUrl: "https://placehold.co/80x80",
      unread: 0,
      verified: true,
      highlighted: true,
    ),
    _ChatItem(
      name: "Phoebe",
      lastMessage: "Good bye!",
      time: "2:41 PM",
      avatarUrl: "https://placehold.co/80x80",
      unread: 0,
      verified: true,
    ),
    _ChatItem(
      name: "Jack",
      lastMessage: "See you again!",
      time: "2:27 PM",
      avatarUrl: "https://placehold.co/80x80",
      unread: 0,
      verified: true,
    ),
    _ChatItem(
      name: "Gibson",
      lastMessage: "Okay, Thank you!",
      time: "2:16 PM",
      avatarUrl: "https://placehold.co/80x80",
      unread: 0,
      verified: false,
    ),
  ];

  // ✅ DATA GROUPS
  final List<_ChatItem> _groups = const [
    _ChatItem(
      name: "Group Contoh",
      lastMessage: "Diskusi umum grup...",
      time: "4:10 PM",
      avatarUrl: "https://placehold.co/80x80",
      unread: 0,
      verified: false,
    ),
    _ChatItem(
      name: "Group Proyek 1",
      lastMessage: "Update progress hari ini...",
      time: "3:40 PM",
      avatarUrl: "https://placehold.co/80x80",
      unread: 3,
      verified: false,
    ),
    _ChatItem(
      name: "Group Proyek 2",
      lastMessage: "Revisi dokumen sudah diupload",
      time: "3:05 PM",
      avatarUrl: "https://placehold.co/80x80",
      unread: 0,
      verified: false,
    ),
    _ChatItem(
      name: "Group Proyek 3",
      lastMessage: "Meeting jam 5 sore ya",
      time: "2:30 PM",
      avatarUrl: "https://placehold.co/80x80",
      unread: 1,
      verified: false,
    ),
    _ChatItem(
      name: "Group Proyek 4",
      lastMessage: "Checklist task minggu ini",
      time: "1:55 PM",
      avatarUrl: "https://placehold.co/80x80",
      unread: 0,
      verified: false,
    ),
  ];

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final maxContent = w > 420 ? 420.0 : w;
    final padH = (w - maxContent) / 2;

    final listData = (_segment == 0) ? _items : _groups;

    // ✅ PENTING: Karena Dashboard sudah punya Scaffold + bottom nav,
    // di sini kita return "body content" saja (tanpa Scaffold + bottomNavigationBar)
    return Container(
      color: BG,
      child: SafeArea(
        child: Column(
          children: [
            _TopBarNavy(
              title: "Chat (home page)",
              onGear: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Gear clicked")),
                );
              },
              onBell: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Notification clicked")),
                );
              },
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padH),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _ProfileCard(
                      name: "Hanyaka Narendra",
                      role: "Supervisor",
                      avatarUrl: "https://placehold.co/120x120",
                    ),
                    const SizedBox(height: 12),
                    _Segmented(
                      value: _segment,
                      onChanged: (v) => setState(() => _segment = v),
                    ),
                    const SizedBox(height: 12),
                    _SearchRow(
                      controller: _searchC,
                      onNewMessage: () {},
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: ListView.separated(
                        // ✅ jangan kasih bottom padding terlalu besar karena nav global sudah ada
                        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                        itemCount: listData.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final item = listData[i];

                          return _SwipeTile(
                            key: ValueKey("${item.name}-$i-${_segment}"),
                            item: item,
                            borderColor: item.highlighted ? BLUE_BADGE : BORDER,
                            onTap: () {},
                            onArchive: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Archived: ${item.name}")),
                              );
                            },
                            onDelete: () {
                              if (_segment == 0) {
                                setState(() => _items.removeAt(i));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Deleted: ${item.name}")),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Groups demo: delete disabled")),
                                );
                              }
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

// ===================== HEADER NAVY (MIRIP DASHBOARD) =====================

class _TopBarNavy extends StatelessWidget {
  final String title;
  final VoidCallback onGear;
  final VoidCallback onBell;

  const _TopBarNavy({
    required this.title,
    required this.onGear,
    required this.onBell,
  });

  static const Color NAVY = _ChatPageState.NAVY;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 768;

    return Container(
      height: isTablet ? 90 : 80,
      decoration: const BoxDecoration(color: NAVY),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
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
            onPressed: onBell,
            icon: const Icon(Icons.notifications_none_rounded),
            color: Colors.white,
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

// ===================== UI PARTS =====================

class _ProfileCard extends StatelessWidget {
  final String name;
  final String role;
  final String avatarUrl;

  const _ProfileCard({
    required this.name,
    required this.role,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
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
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(avatarUrl),
              backgroundColor: const Color(0xFFEFEFEF),
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
    const navy = _ChatPageState.NAVY;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.05, 0.10),
            end: Alignment(1.27, 1.27),
            colors: [navy, Color(0x3FEBD4F3)],
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onNewMessage;

  const _SearchRow({
    required this.controller,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: Row(
                children: const [
                  Icon(Icons.add, size: 16, color: _ChatPageState.PURPLE),
                  SizedBox(width: 4),
                  Text(
                    "New message",
                    style: TextStyle(
                      color: _ChatPageState.PURPLE,
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
  final VoidCallback onTap;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const _SwipeTile({
    super.key,
    required this.item,
    required this.borderColor,
    required this.onTap,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key!,
      direction: DismissDirection.horizontal,
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          onArchive();
          return false;
        } else {
          return true;
        }
      },
      onDismissed: (_) => onDelete(),
      background: _ActionBG(
        color: _ChatPageState.SOFT,
        icon: Icons.folder_open,
        alignLeft: true,
      ),
      secondaryBackground: _ActionBG(
        color: _ChatPageState.DELETE_BG,
        icon: Icons.delete_outline,
        alignLeft: false,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _ChatPageState.CARD,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0CB3B3B3),
                  blurRadius: 40,
                  offset: Offset(0, 16),
                )
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(item.avatarUrl),
                  backgroundColor: const Color(0xFFEFEFEF),
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
                          color: _ChatPageState.TEXT,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (item.verified)
                            const Icon(Icons.check, size: 14, color: Colors.black54),
                          if (item.verified) const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _ChatPageState.MUTED,
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
                          color: _ChatPageState.BLUE_BADGE,
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

// ===================== MODEL =====================

class _ChatItem {
  final String name;
  final String lastMessage;
  final String time;
  final String avatarUrl;
  final int unread;
  final bool verified;
  final bool highlighted;

  const _ChatItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatarUrl,
    required this.unread,
    required this.verified,
    this.highlighted = false,
  });
} 