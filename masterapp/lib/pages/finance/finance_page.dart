import 'package:flutter/material.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  static const Color NAVY = Color(0xFF101D6E);
  static const Color BG = Color(0xFFF2F9FF);
  static const Color CARD = Colors.white;
  static const Color MUTED = Color(0xFF6B7280);
  static const Color BORDER = Color(0xFFDCECFF);

  DateTimeRange? _range;

  final List<_Txn> _txns = [
    _Txn(
      id: 't1',
      date: DateTime(2026, 3, 25),
      title: 'Material - Cat',
      category: 'Expense',
      amount: -450000,
      method: 'Transfer',
    ),
    _Txn(
      id: 't2',
      date: DateTime(2026, 3, 24),
      title: 'Pembayaran Client',
      category: 'Income',
      amount: 2500000,
      method: 'Cash',
    ),
    _Txn(
      id: 't3',
      date: DateTime(2026, 3, 19),
      title: 'Transport',
      category: 'Expense',
      amount: -120000,
      method: 'Cash',
    ),
    _Txn(
      id: 't4',
      date: DateTime(2026, 2, 25),
      title: 'DP Proyek Renovasi',
      category: 'Income',
      amount: 1500000,
      method: 'Transfer',
    ),
  ];

  final List<_Invoice> _invoices = [
    _Invoice(
      id: 'INV-2026-001',
      customer: 'PT Contoh Abadi',
      issuedAt: DateTime(2026, 3, 20),
      dueAt: DateTime(2026, 3, 30),
      total: 2500000,
      status: _InvoiceStatus.unpaid,
      items: const [
        _InvoiceLine(desc: 'Jasa Renovasi', qty: 1, price: 2000000),
        _InvoiceLine(desc: 'Material', qty: 1, price: 500000),
      ],
    ),
    _Invoice(
      id: 'INV-2026-002',
      customer: 'CV Sample',
      issuedAt: DateTime(2026, 2, 15),
      dueAt: DateTime(2026, 2, 28),
      total: 1500000,
      status: _InvoiceStatus.paid,
      items: const [
        _InvoiceLine(desc: 'DP Proyek', qty: 1, price: 1500000),
      ],
    ),
  ];

  List<_Txn> _filteredTxns() {
    if (_range == null) return _txns;
    final start = DateTime(_range!.start.year, _range!.start.month, _range!.start.day);
    final end = DateTime(_range!.end.year, _range!.end.month, _range!.end.day, 23, 59, 59, 999);
    return _txns
        .where((t) => !t.date.isBefore(start) && !t.date.isAfter(end))
        .toList(growable: false);
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dd = d.day.toString().padLeft(2, '0');
    return '$dd ${months[d.month - 1]} ${d.year}';
  }

  String _fmtMoney(int amount) {
    final abs = amount.abs();
    final s = abs.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      buf.write(s[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buf.write('.');
    }
    final prefix = amount < 0 ? '-Rp ' : 'Rp ';
    return '$prefix$buf';
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final initial = _range ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month, now.day),
        );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: initial,
      helpText: 'Pilih rentang tanggal transaksi',
    );
    if (picked == null) return;
    setState(() => _range = picked);
  }

  void _clearRange() => setState(() => _range = null);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: BG,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(
                title: 'Finance',
                onBack: () {
                  final nav = Navigator.of(context, rootNavigator: true);
                  if (nav.canPop()) {
                    nav.pop();
                    return;
                  }
                  nav.pushReplacementNamed('/dashboard');
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                child: TabBar(
                  indicatorColor: NAVY,
                  labelColor: NAVY,
                  unselectedLabelColor: MUTED,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w900),
                  tabs: const [
                    Tab(text: 'Transactions'),
                    Tab(text: 'Invoice'),
                    Tab(text: 'Reports'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _TransactionsTab(
                      navy: NAVY,
                      muted: MUTED,
                      border: BORDER,
                      range: _range,
                      fmtDate: _fmtDate,
                      fmtMoney: _fmtMoney,
                      items: _filteredTxns(),
                      onPickRange: _pickRange,
                      onClearRange: _clearRange,
                    ),
                    _InvoiceTab(
                      navy: NAVY,
                      muted: MUTED,
                      border: BORDER,
                      fmtDate: _fmtDate,
                      fmtMoney: _fmtMoney,
                      invoices: _invoices,
                      onMarkPaid: (id) {
                        setState(() {
                          final i = _invoices.indexWhere((e) => e.id == id);
                          if (i < 0) return;
                          _invoices[i] = _invoices[i].copyWith(status: _InvoiceStatus.paid);
                        });
                      },
                    ),
                    _ReportsTab(
                      navy: NAVY,
                      muted: MUTED,
                      border: BORDER,
                      fmtMoney: _fmtMoney,
                      range: _range,
                      fmtDate: _fmtDate,
                      txns: _filteredTxns(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: _FinancePageState.NAVY,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsTab extends StatelessWidget {
  final Color navy;
  final Color muted;
  final Color border;
  final DateTimeRange? range;
  final String Function(DateTime) fmtDate;
  final String Function(int) fmtMoney;
  final List<_Txn> items;
  final VoidCallback onPickRange;
  final VoidCallback onClearRange;

  const _TransactionsTab({
    required this.navy,
    required this.muted,
    required this.border,
    required this.range,
    required this.fmtDate,
    required this.fmtMoney,
    required this.items,
    required this.onPickRange,
    required this.onClearRange,
  });

  @override
  Widget build(BuildContext context) {
    final rangeLabel = range == null
        ? 'All time'
        : '${fmtDate(range!.start)} - ${fmtDate(range!.end)}';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickRange,
                  icon: const Icon(Icons.date_range_rounded, size: 18),
                  label: Text(
                    rangeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                tooltip: 'Clear date filter',
                onPressed: range == null ? null : onClearRange,
                icon: const Icon(Icons.clear_rounded),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada transaksi pada rentang ini.',
                    style: TextStyle(color: muted, fontWeight: FontWeight.w700),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final t = items[i];
                    final isIncome = t.amount >= 0;
                    final amountColor = isIncome ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _FinancePageState.CARD,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: amountColor.withOpacity(0.12),
                            child: Icon(
                              isIncome ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                              color: amountColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${fmtDate(t.date)} - ${t.method}',
                                  style: TextStyle(color: muted, fontWeight: FontWeight.w700, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            fmtMoney(t.amount),
                            style: TextStyle(fontWeight: FontWeight.w900, color: amountColor),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _InvoiceTab extends StatelessWidget {
  final Color navy;
  final Color muted;
  final Color border;
  final String Function(DateTime) fmtDate;
  final String Function(int) fmtMoney;
  final List<_Invoice> invoices;
  final ValueChanged<String> onMarkPaid;

  const _InvoiceTab({
    required this.navy,
    required this.muted,
    required this.border,
    required this.fmtDate,
    required this.fmtMoney,
    required this.invoices,
    required this.onMarkPaid,
  });

  Color _statusColor(_InvoiceStatus s) {
    switch (s) {
      case _InvoiceStatus.paid:
        return const Color(0xFF16A34A);
      case _InvoiceStatus.unpaid:
        return const Color(0xFFF59E0B);
      case _InvoiceStatus.overdue:
        return const Color(0xFFDC2626);
    }
  }

  String _statusLabel(_InvoiceStatus s) {
    switch (s) {
      case _InvoiceStatus.paid:
        return 'PAID';
      case _InvoiceStatus.unpaid:
        return 'UNPAID';
      case _InvoiceStatus.overdue:
        return 'OVERDUE';
    }
  }

  void _openInvoice(BuildContext context, _Invoice inv) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        final statusColor = _statusColor(inv.status);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        inv.id,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: statusColor.withOpacity(0.35)),
                      ),
                      child: Text(
                        _statusLabel(inv.status),
                        style: TextStyle(fontWeight: FontWeight.w900, color: statusColor, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  inv.customer,
                  style: TextStyle(color: muted, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text('Issued: ${fmtDate(inv.issuedAt)}', style: TextStyle(color: muted)),
                    ),
                    Expanded(
                      child: Text('Due: ${fmtDate(inv.dueAt)}', style: TextStyle(color: muted)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                ...inv.items.map(
                  (l) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.desc,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text('${l.qty} x ${fmtMoney(l.price)}', style: TextStyle(color: muted)),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(
                      child: Text('Total', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                    Text(fmtMoney(inv.total), style: const TextStyle(fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: navy),
                        onPressed: inv.status == _InvoiceStatus.paid
                            ? null
                            : () {
                                onMarkPaid(inv.id);
                                Navigator.pop(context);
                              },
                        child: const Text('Mark Paid'),
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

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return Center(
        child: Text(
          'Belum ada invoice.',
          style: TextStyle(color: muted, fontWeight: FontWeight.w700),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: invoices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final inv = invoices[i];
        final statusColor = _statusColor(inv.status);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _openInvoice(context, inv),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _FinancePageState.CARD,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: statusColor.withOpacity(0.12),
                    child: Icon(Icons.receipt_long_rounded, color: statusColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(inv.id, style: const TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        Text(inv.customer, style: TextStyle(color: muted, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          'Due ${fmtDate(inv.dueAt)}',
                          style: TextStyle(color: muted.withOpacity(0.85), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(fmtMoney(inv.total), style: const TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(
                        _statusLabel(inv.status),
                        style: TextStyle(fontWeight: FontWeight.w900, color: statusColor, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReportsTab extends StatelessWidget {
  final Color navy;
  final Color muted;
  final Color border;
  final String Function(int) fmtMoney;
  final DateTimeRange? range;
  final String Function(DateTime) fmtDate;
  final List<_Txn> txns;

  const _ReportsTab({
    required this.navy,
    required this.muted,
    required this.border,
    required this.fmtMoney,
    required this.range,
    required this.fmtDate,
    required this.txns,
  });

  @override
  Widget build(BuildContext context) {
    var income = 0;
    var expense = 0;
    for (final t in txns) {
      if (t.amount >= 0) {
        income += t.amount;
      } else {
        expense += t.amount.abs();
      }
    }
    final net = income - expense;

    final label = range == null ? 'All time' : '${fmtDate(range!.start)} - ${fmtDate(range!.end)}';

    Widget card(String title, String value, {Color? valueColor}) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _FinancePageState.CARD,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: muted, fontWeight: FontWeight.w800, fontSize: 12)),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _FinancePageState.CARD,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: navy.withOpacity(0.10),
                child: Icon(Icons.analytics_rounded, color: navy),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Report: $label',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            card('Income', fmtMoney(income), valueColor: const Color(0xFF16A34A)),
            const SizedBox(width: 10),
            card('Expense', fmtMoney(-expense), valueColor: const Color(0xFFDC2626)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            card('Net', fmtMoney(net), valueColor: net >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
            const SizedBox(width: 10),
            card('Count', '${txns.length} txns'),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _FinancePageState.CARD,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notes', style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(
                'Tab Reports ini masih template. Kalau kamu sudah tahu format report yang kamu mau (per proyek, per kategori, atau per bulan), bilang ya, nanti aku sesuaikan.',
                style: TextStyle(color: muted, fontWeight: FontWeight.w700, height: 1.25),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

@immutable
class _Txn {
  final String id;
  final DateTime date;
  final String title;
  final String category;
  final int amount; // positive income, negative expense
  final String method;

  const _Txn({
    required this.id,
    required this.date,
    required this.title,
    required this.category,
    required this.amount,
    required this.method,
  });
}

enum _InvoiceStatus { paid, unpaid, overdue }

@immutable
class _InvoiceLine {
  final String desc;
  final int qty;
  final int price;

  const _InvoiceLine({required this.desc, required this.qty, required this.price});
}

@immutable
class _Invoice {
  final String id;
  final String customer;
  final DateTime issuedAt;
  final DateTime dueAt;
  final int total;
  final _InvoiceStatus status;
  final List<_InvoiceLine> items;

  const _Invoice({
    required this.id,
    required this.customer,
    required this.issuedAt,
    required this.dueAt,
    required this.total,
    required this.status,
    required this.items,
  });

  _Invoice copyWith({_InvoiceStatus? status}) {
    return _Invoice(
      id: id,
      customer: customer,
      issuedAt: issuedAt,
      dueAt: dueAt,
      total: total,
      status: status ?? this.status,
      items: items,
    );
  }
}


