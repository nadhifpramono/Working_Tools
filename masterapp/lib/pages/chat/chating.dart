import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isMe;

  const ChatMessage({
    required this.text,
    required this.isMe,
  });
}

class ChatingPage extends StatefulWidget {
  final String chatName;
  final String subtitle;
  final bool isGroup;
  final String avatarUrl;
  final List<ChatMessage> initialMessages;

  const ChatingPage({
    super.key,
    required this.chatName,
    required this.subtitle,
    required this.isGroup,
    required this.avatarUrl,
    required this.initialMessages,
  });

  @override
  State<ChatingPage> createState() => _ChatingPageState();
}

class _ChatingPageState extends State<ChatingPage> {
  static const Color navy = Color(0xFF101D6E);
  static const Color bg = Colors.white;
  static const Color bubble = Color(0xFFD9D9D9);
  static const Color bubbleBorder = Color(0xFF838383);

  final TextEditingController _messageC = TextEditingController();
  final ScrollController _scrollC = ScrollController();

  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List<ChatMessage>.from(widget.initialMessages);
  }

  @override
  void dispose() {
    _messageC.dispose();
    _scrollC.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageC.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isMe: true));
    });

    _messageC.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollC.hasClients) {
        _scrollC.animateTo(
          _scrollC.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final maxContent = w > 420 ? 420.0 : w;
    final padH = (w - maxContent) / 2;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 72,
              color: navy,
              padding: EdgeInsets.symmetric(horizontal: 12 + padH),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(16 + padH, 12, 16 + padH, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFEFEFEF),
                      backgroundImage: widget.avatarUrl.isNotEmpty
                          ? NetworkImage(widget.avatarUrl)
                          : null,
                      child: widget.avatarUrl.isEmpty
                          ? Icon(
                              widget.isGroup
                                  ? Icons.group_outlined
                                  : Icons.person_outline,
                              color: Colors.black87,
                              size: 26,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.chatName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.call, color: Colors.black),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Hari ini',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                controller: _scrollC,
                padding: EdgeInsets.fromLTRB(16 + padH, 6, 16 + padH, 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _Bubble(
                    text: msg.text,
                    isMe: msg.isMe,
                  );
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(6 + padH, 8, 6 + padH, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          const Icon(
                            Icons.emoji_emotions_outlined,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _messageC,
                              decoration: const InputDecoration(
                                hintText: 'Ketik pesan',
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _sendMessage,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: navy,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
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

class _Bubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const _Bubble({
    required this.text,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.68,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _ChatingPageState.bubble,
            border: Border.all(
              color: _ChatingPageState.bubbleBorder,
              width: 1,
            ),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isMe ? 20 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 20),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }
}