import 'package:flutter/material.dart';

// ============================================================
//  TRANSACTION SCREEN - TABUNGANKU (Dark Mode Ready)
// ============================================================

class TransactionItem {
  final double amount;
  final String note;
  final String type;

  const TransactionItem({required this.amount, required this.note, required this.type});
}

final List<TransactionItem> dummyIncome = [
  TransactionItem(amount: 100000, note: 'thr sudah cair',                        type: 'income'),
  TransactionItem(amount: 10000,  note: 'dari sisa uang jajan',                  type: 'income'),
  TransactionItem(amount: 15000,  note: 'dapat dari pemberian uang lebih mama',  type: 'income'),
  TransactionItem(amount: 10000,  note: 'dari sisa uang jajan',                  type: 'income'),
  TransactionItem(amount: 20000,  note: 'dapat dari nenek',                      type: 'income'),
];

final List<TransactionItem> dummyExpense = [
  TransactionItem(amount: 10000,  note: 'buat beli jajan',                       type: 'expense'),
  TransactionItem(amount: 50000,  note: 'buat membeli perlengkapan tulis',        type: 'expense'),
  TransactionItem(amount: 15000,  note: 'buat membeli makanan',                  type: 'expense'),
  TransactionItem(amount: 10000,  note: 'buat foto copy',                        type: 'expense'),
  TransactionItem(amount: 20000,  note: 'buat beli gas',                         type: 'expense'),
];

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_tabController.index == 0 ? Icons.add : Icons.remove, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMotivationBanner(),
          const SizedBox(height: 16),
          _buildTabBar(isDark),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(items: dummyIncome,   type: 'income',  isDark: isDark),
                _buildTransactionList(items: dummyExpense,  type: 'expense', isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1A2333),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'NABUNG\nLEBIH\nPENTING\n',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                    color: Colors.white, height: 1.3, letterSpacing: 1.5),
              ),
              TextSpan(
                text: 'DARIPADA\nNONGKI',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                    color: Color(0xFFE53935), height: 1.3, letterSpacing: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF4CAF72),
        indicatorWeight: 2.5,
        labelPadding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        tabs: [
          _buildTab('Pemasukan', 0),
          _buildTab('Pengeluaran', 1),
        ],
        onTap: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final Color activeColor = index == 0 ? const Color(0xFF4CAF72) : const Color(0xFFE53935);
    return Tab(
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          final bool isDark = Theme.of(context).brightness == Brightness.dark;
          final bool selected = _tabController.index == index;
          return Text(label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected ? activeColor : (isDark ? Colors.white38 : Colors.black45),
              ));
        },
      ),
    );
  }

  Widget _buildTransactionList({
    required List<TransactionItem> items,
    required String type,
    required bool isDark,
  }) {
    final bool isIncome = type == 'income';
    final double total = items.fold(0, (sum, item) => sum + item.amount);
    final String totalLabel = isIncome ? 'Total Pemasukan' : 'Total Pengeluaran';
    final String totalFormatted = isIncome
        ? 'Rp. ${_formatCurrency(total)}'
        : 'Rp. -${_formatCurrency(total)}';
    final Color totalColor = isIncome ? const Color(0xFF4CAF72) : const Color(0xFFE53935);

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            itemCount: items.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: isDark ? Colors.white12 : const Color(0xFFEEEEEE),
            ),
            itemBuilder: (context, index) => _buildTransactionItem(items[index], isDark),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            children: [
              Divider(color: isDark ? Colors.white12 : Colors.black12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(totalLabel,
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      )),
                  Text(totalFormatted,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: totalColor)),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: Text('Show all',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.black45,
                        decoration: TextDecoration.underline,
                      )),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(TransactionItem item, bool isDark) {
    final bool isIncome = item.type == 'income';
    final Color iconColor = isIncome ? const Color(0xFF4CAF72) : const Color(0xFFE53935);
    final IconData iconData = isIncome ? Icons.check : Icons.remove;
    final String amountText = isIncome
        ? 'Rp. ${_formatCurrency(item.amount)}'
        : 'Rp. -${_formatCurrency(item.amount)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(iconData, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(amountText,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    )),
                const SizedBox(height: 2),
                Text(item.note,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black45,
                    )),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(Icons.more_vert,
                color: isDark ? Colors.white38 : Colors.black45, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final String raw = amount.toStringAsFixed(0);
    final StringBuffer result = StringBuffer();
    int count = 0;
    for (int i = raw.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result.write('.');
      result.write(raw[i]);
      count++;
    }
    return result.toString().split('').reversed.join('');
  }
}