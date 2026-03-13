import 'package:flutter/material.dart';

class NegoChatPopup extends StatefulWidget {
  final String title;
  final String subtitle;
  final int initialPrice;
  final int offeredPrice;

  const NegoChatPopup({
    super.key,
    required this.title,
    required this.subtitle,
    required this.initialPrice,
    required this.offeredPrice,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int initialPrice,
    required int offeredPrice,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: NegoChatPopup(
          title: title,
          subtitle: subtitle,
          initialPrice: initialPrice,
          offeredPrice: offeredPrice,
        ),
      ),
    );
  }

  @override
  State<NegoChatPopup> createState() => _NegoChatPopupState();
}

class _NegoChatPopupState extends State<NegoChatPopup> {
  static const Color navy = Color(0xFF101D6E);
  static const Color primary = Color(0xFF101D6E);
  static const Color bg = Color(0xFFF4F8FF);
  static const Color card = Colors.white;
  static const Color border = Color(0xFFDCE6F8);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color navySoft = Color(0xFF1A2F7A);
  static const Color navyBox = Color(0xFF243C96);

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late int currentOffer;
  late String currentStatus;

  final List<_ChatItem> messages = [];

  @override
  void initState() {
    super.initState();
    currentOffer = widget.offeredPrice;
    currentStatus = 'Menunggu';

    messages.addAll([
      _ChatItem(
        text: 'Halo kak, saya tertarik dengan penawaran ini.',
        isMe: false,
        time: '09:10',
      ),
      _ChatItem(
        text:
            'Baik kak, untuk ${widget.title} harga awalnya Rp ${_formatCurrency(widget.initialPrice)}.',
        isMe: true,
        time: '09:11',
      ),
      _ChatItem(
        text:
            'Saya ajukan penawaran Rp ${_formatCurrency(widget.offeredPrice)} ya kak.',
        isMe: false,
        time: '09:12',
      ),
    ]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatCurrency(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    int counter = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      counter++;
      if (counter == 3 && i != 0) {
        buffer.write('.');
        counter = 0;
      }
    }

    return buffer.toString().split('').reversed.join();
  }

  String _currentTime() {
    final now = TimeOfDay.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(
        _ChatItem(
          text: text,
          isMe: true,
          time: _currentTime(),
        ),
      );
      _messageController.clear();
    });

    _scrollToBottom();
  }

  void _sendCounterOffer() {
    setState(() {
      currentOffer -= 5000;
      if (currentOffer < 1000) currentOffer = 1000;
      currentStatus = 'Counter';

      messages.add(
        _ChatItem(
          text:
              'Saya ajukan counter di harga Rp ${_formatCurrency(currentOffer)} ya kak.',
          isMe: true,
          time: _currentTime(),
          statusLabel: 'Counter',
          statusColor: navy,
        ),
      );
    });

    _scrollToBottom();
  }

  void _acceptOffer() {
    setState(() {
      currentStatus = 'Diterima';

      messages.add(
        _ChatItem(
          text:
              'Penawaran disetujui. Deal di harga Rp ${_formatCurrency(currentOffer)}.',
          isMe: true,
          time: _currentTime(),
          statusLabel: 'Diterima',
          statusColor: success,
        ),
      );
    });

    _scrollToBottom();
  }

  void _rejectOffer() {
    setState(() {
      currentStatus = 'Ditolak';

      messages.add(
        _ChatItem(
          text: 'Maaf kak, penawaran belum bisa kami terima.',
          isMe: true,
          time: _currentTime(),
          statusLabel: 'Ditolak',
          statusColor: danger,
        ),
      );
    });

    _scrollToBottom();
  }

  Color _statusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'diterima':
        return success;
      case 'ditolak':
        return danger;
      case 'counter':
        return navy;
      default:
        return warning;
    }
  }

  Color _statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'diterima':
        return const Color(0xFFEAF8EE);
      case 'ditolak':
        return const Color(0xFFFFE9E9);
      case 'counter':
        return const Color(0xFFE8EEFF);
      default:
        return const Color(0xFFFFF4D8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;

    return Container(
      constraints: const BoxConstraints(
        maxWidth: 430,
        maxHeight: 720,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x25000000),
            blurRadius: 25,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          _buildProductInfo(),
          _buildOfferSummary(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: border),
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return _buildChatBubble(messages[index], isSmall);
                },
              ),
            ),
          ),
          _buildActionButtons(),
          _buildInputArea(),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: const BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.handshake_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Negosiasi Harga',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Diskusikan harga dengan pembeli',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(99),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferSummary() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [navySoft, navy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryBox(
              'Jenis',
              widget.title,
              valueColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _summaryBox(
              'Harga Awal',
              'Rp ${_formatCurrency(widget.initialPrice)}',
              valueColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _summaryBox(
              'Penawaran',
              'Rp ${_formatCurrency(currentOffer)}',
              valueColor: const Color(0xFFFFD6D6),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _summaryStatusBox(
              'Status',
              currentStatus,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryBox(
    String label,
    String value, {
    required Color valueColor,
  }) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: navyBox,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Text(
                value,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryStatusBox(String label, String status) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: navyBox,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _statusBgColor(status),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _statusTextColor(status),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(_ChatItem item, bool isSmall) {
    final align =
        item.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor =
        item.isMe ? const Color(0xFFE8EEFF) : const Color(0xFFF5F5F7);

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(item.isMe ? 18 : 6),
      bottomRight: Radius.circular(item.isMe ? 6 : 18),
    );

    return Column(
      crossAxisAlignment: align,
      children: [
        const SizedBox(height: 8),
        Container(
          constraints: BoxConstraints(
            maxWidth: isSmall ? 240 : 280,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: radius,
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment:
                item.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                item.text,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.statusLabel != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: item.statusColor!.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.statusLabel!,
                        style: TextStyle(
                          color: item.statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    item.time,
                    style: const TextStyle(
                      color: textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(
              label: 'Tolak',
              icon: Icons.close_rounded,
              bgColor: const Color(0xFFFFE9E9),
              textColor: danger,
              onTap: _rejectOffer,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _actionButton(
              label: 'Counter',
              icon: Icons.currency_exchange_rounded,
              bgColor: const Color(0xFFE8EEFF),
              textColor: primary,
              onTap: _sendCounterOffer,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _actionButton(
              label: 'Terima',
              icon: Icons.check_rounded,
              bgColor: const Color(0xFFEAF8EE),
              textColor: success,
              onTap: _acceptOffer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border),
              ),
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tulis pesan negosiasi...',
                  hintStyle: TextStyle(
                    color: textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: primary,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: _sendMessage,
              borderRadius: BorderRadius.circular(18),
              child: const SizedBox(
                width: 52,
                height: 52,
                child: Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatItem {
  final String text;
  final bool isMe;
  final String time;
  final String? statusLabel;
  final Color? statusColor;

  _ChatItem({
    required this.text,
    required this.isMe,
    required this.time,
    this.statusLabel,
    this.statusColor,
  });
}