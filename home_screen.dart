import 'package:flutter/material.dart';
import 'transaction_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'statistik_screen.dart'; // ✅ Import StatistikScreen

// ============================================================
//  HOME SCREEN - TABUNGANKU (Dark Mode Ready)
// ============================================================

class Transaction {
  final String title;
  final String subtitle;
  final double amount;
  final String date;
  final String type;

  const Transaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
  });
}

final List<Transaction> dummyTransactions = [
  Transaction(title: 'Beli Hp',     subtitle: 'AMBARIP',         amount: -5000000, date: '4 April 2026', type: 'expense'),
  Transaction(title: 'Makanan',     subtitle: 'AMBAKANG',         amount: -25000,   date: '4 April 2026', type: 'expense'),
  Transaction(title: 'Top Up Dana', subtitle: 'AMBA STORE',       amount: -300000,  date: '4 April 2026', type: 'expense'),
  Transaction(title: 'Thr',         subtitle: 'Dikasih keluarga', amount: 450000,   date: '1 April 2026', type: 'income'),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;

    if (index == 1) {
      // Transaksi
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const TransactionScreen()))
          .then((_) => setState(() => _selectedIndex = 0));
    } else if (index == 2) {
      // ✅ Statistik Menabung
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const StatistikScreen()))
          .then((_) => setState(() => _selectedIndex = 0));
    } else if (index == 3) {
      // Settings
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const SettingsScreen()))
          .then((_) => setState(() => _selectedIndex = 0));
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Map<String, List<Transaction>> groupedTransactions = {};
    for (var t in dummyTransactions) {
      groupedTransactions.putIfAbsent(t.date, () => []).add(t);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  ...groupedTransactions.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateLabel(entry.key, isDark),
                        const SizedBox(height: 8),
                        ...entry.value.map((t) => _buildTransactionItem(t, isDark)),
                        const SizedBox(height: 8),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.45,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20, right: 20, bottom: 32,
      ),
      color: const Color(0xFF4CAF72),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined, color: Colors.black87, size: 26),
              ),
              IconButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
                icon: const Icon(Icons.account_circle_outlined, color: Colors.black87, size: 26),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('TABUNGANKU',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                              letterSpacing: 2.0, color: Color(0xFF212121))),
                      SizedBox(height: 4),
                      Text('TABUNGAN DIGITAL',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500,
                              letterSpacing: 3.5, color: Color(0xFF424242))),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    width: 1.5, height: 44,
                    color: const Color(0xFF2D2D2D),
                  ),
                  const Icon(Icons.account_balance_wallet_rounded,
                      size: 46, color: Color(0xFF2D2D2D)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDateLabel(String date, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(date,
          style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          )),
    );
  }

  Widget _buildTransactionItem(Transaction t, bool isDark) {
    final bool isExpense = t.type == 'expense';
    final Color amountColor = isExpense ? const Color(0xFFE53935) : const Color(0xFF43A047);
    final String formattedAmount = _formatCurrency(t.amount.abs());
    final String amountText = isExpense ? '-$formattedAmount' : '+$formattedAmount';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          isExpense ? _buildExpenseIcon() : _buildIncomeIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 2),
                Text(t.subtitle,
                    style: TextStyle(fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.black45,
                        letterSpacing: 0.5)),
              ],
            ),
          ),
          Text(amountText,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: amountColor)),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onNavTap,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined),          activeIcon: Icon(Icons.home),            label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.compare_arrows_outlined),activeIcon: Icon(Icons.compare_arrows),  label: 'Transaksi'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined),     activeIcon: Icon(Icons.bar_chart),       label: 'Statistik'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined),      activeIcon: Icon(Icons.settings),        label: 'Pengaturan'),
      ],
    );
  }

  Widget _buildExpenseIcon() {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE53935), width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.remove, color: Color(0xFFE53935), size: 20),
    );
  }

  Widget _buildIncomeIcon() {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF43A047), width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.add, color: Color(0xFF43A047), size: 20),
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