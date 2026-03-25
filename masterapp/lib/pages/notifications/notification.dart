import 'package:flutter/material.dart';

import '../dashboard/dashboard.dart';
import '../chat/chat.dart';
import '../profile/profile.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  static const Color navy = Color(0xFF101D6E);
  static const Color bg = Color(0xFFF3F9FF);
  static const Color textGrey = Color(0xFF5E5E5E);
  static const Color softGrey = Color(0xFFDADADA);
  static const Color borderGrey = Color(0xFFE5E7EB);
  static const Color orange = Color(0xFFFF7A45);
  static const Color blueLine = Color(0xFF2F6BFF);

  int _selectedTab = 1;
  final int _bottomIndex = 0;

  final List<String> _tabs = const [
    "Semua",
    "Deadline",
    "Tugas",
    "Meeting",
    "Update",
  ];

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }

  void _goToChat() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ChatPage()),
    );
  }

  void _goToProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    );
  }

  void _goToFileManager() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const FileManagerPlaceholderPage()),
    );
  }

  void _openSimpleDetail(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimpleDetailPage(title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsToday = _getTodayItems();
    final itemsYesterday = _getYesterdayItems();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                children: [
                  _SectionHeader(
                    title: "HARI INI",
                    countText: "${itemsToday.length} notif",
                  ),
                  const SizedBox(height: 10),

                  ...itemsToday.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: item,
                    ),
                  ),

                  const SizedBox(height: 8),

                  _SectionHeader(
                    title: "KEMARIN",
                    countText: "${itemsYesterday.length} notif",
                  ),
                  const SizedBox(height: 10),

                  ...itemsYesterday.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: item,
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

  List<Widget> _getTodayItems() {
    final all = [
      NotificationCard(
        title: "Task baru ditugaskan",
        description:
            "Andi menugaskan “ Integrasi API Payment Gateway ” ke kamu di Project E - Commerce App.",
        time: "08:38",
        date: "28 Feb 2026",
        showCalendar: true,
        onTap: () => _openSimpleDetail("Task baru ditugaskan"),
      ),
      MeetingNotificationCard(
        title: "Meeting dimulai 30 menit lagi",
        description:
            "Sprint review Q1 2026 - Google Meet pukul 10:00 WIB bersama 5 peserta.",
        time: "09:30",
        onTap: () => _openSimpleDetail("Meeting dimulai 30 menit lagi"),
        onJoin: () => _openSimpleDetail("Gabung Meeting"),
        onAgenda: () => _openSimpleDetail("Agenda Meeting"),
      ),
    ];

    switch (_selectedTab) {
      case 0:
        return all;
      case 1:
        return [];
      case 2:
        return [all[0]];
      case 3:
        return [all[1]];
      case 4:
        return [];
      default:
        return all;
    }
  }

  List<Widget> _getYesterdayItems() {
    final deadlineCard = NotificationCard(
      title: "Deadline terlewati",
      description:
          "Task “ Riset Kompetitor ” telah melewati deadline kemarin, hubungi Project Manager.",
      time: "17:00",
      leftLineColor: orange,
      onTap: () => _openSimpleDetail("Deadline terlewati"),
    );

    final verifiedCard = NotificationCard(
      title: "Task diverifikasi",
      description:
          "Project Manager memverifikasi task “ Wireframe Dashboard ” yang kamu kerjakan. Bagus !",
      time: "14:20",
      leftLineColor: orange,
      onTap: () => _openSimpleDetail("Task diverifikasi"),
    );

    switch (_selectedTab) {
      case 0:
        return [deadlineCard, verifiedCard];
      case 1:
        return [deadlineCard];
      case 2:
        return [verifiedCard];
      case 3:
        return [];
      case 4:
        return [];
      default:
        return [deadlineCard, verifiedCard];
    }
  }

  Widget _buildHeader() {
    return Container(
      color: navy,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: SizedBox(
        height: 72,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 4),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Notifikasi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "2 belum terbaca",
                    style: TextStyle(
                      color: Color(0xFFBFC4DA),
                      fontSize: 10,
                      fontFamily: 'Urbanist',
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

  Widget _buildTabs() {
    return Container(
      color: navy,
      padding: const EdgeInsets.only(bottom: 6),
      child: SizedBox(
        height: 30,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final active = _selectedTab == index;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.5),
                child: Material(
                  color: active ? bg : navy,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTab = index;
                      });
                    },
                    child: Center(
                      child: Text(
                        _tabs[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: active ? Colors.black : Colors.white,
                          fontSize: 12,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class SectionLine extends StatelessWidget {
  final String title;
  final String countText;

  const SectionLine({
    super.key,
    required this.title,
    required this.countText,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionHeader(
      title: title,
      countText: countText,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String countText;

  const _SectionHeader({
    required this.title,
    required this.countText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xCC5E5E5E),
            fontSize: 10,
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color(0x4D000000),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          countText,
          style: const TextStyle(
            color: Color(0xCC5E5E5E),
            fontSize: 10,
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final String? date;
  final bool showCalendar;
  final Color? leftLineColor;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    this.date,
    this.showCalendar = false,
    this.leftLineColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (leftLineColor != null)
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: leftLineColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Color(0xFF5E5E5E),
                          fontSize: 12,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF5E5E5E),
                      fontSize: 12,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  if (date != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (showCalendar)
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.calendar_today_outlined,
                              size: 15,
                              color: Color(0xFF5E5E5E),
                            ),
                          ),
                        Text(
                          date!,
                          style: const TextStyle(
                            color: Color(0xFF5E5E5E),
                            fontSize: 12,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: card,
      ),
    );
  }
}

class MeetingNotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  final VoidCallback onAgenda;

  const MeetingNotificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    required this.onTap,
    required this.onJoin,
    required this.onAgenda,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF2F6BFF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Color(0xFF5E5E5E),
                          fontSize: 12,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF5E5E5E),
                      fontSize: 12,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(
                    height: 1,
                    color: Color(0x4D000000),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: onJoin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF101D6E),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text(
                              "Gabung Sekarang",
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: onAgenda,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDADADA),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text(
                              "Lihat Agenda",
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: card,
      ),
    );
  }
}

class SimpleDetailPage extends StatelessWidget {
  final String title;

  const SimpleDetailPage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101D6E),
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class FileManagerPlaceholderPage extends StatelessWidget {
  const FileManagerPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101D6E),
        foregroundColor: Colors.white,
        title: const Text("File Manager"),
      ),
      body: const Center(
        child: Text(
          "File Manager",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}