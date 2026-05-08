import 'dart:io';
import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'tambah_tabungan_screen.dart';
import 'edit_tabungan_screen.dart';
import 'tabungan_manual_screen.dart';

// ============================================================
//  STATISTIK MENABUNG SCREEN - TABUNGANKU (Dark Mode Ready)
// ============================================================

class SavingGoal {
  final String title;
  final String? imageUrl;
  final String? localImagePath;
  final double targetAmount;
  final double collectedAmount;
  final int savingPerPeriod;
  final String rencana;
  final String createdDate;
  final String estimasiDate;
  final bool isCompleted;

  const SavingGoal({
    required this.title,
    this.imageUrl,
    this.localImagePath,
    required this.targetAmount,
    required this.collectedAmount,
    required this.savingPerPeriod,
    required this.rencana,
    required this.createdDate,
    required this.estimasiDate,
    this.isCompleted = false,
  });

  double get progressPercent => (collectedAmount / targetAmount).clamp(0.0, 1.0);
  double get remaining => targetAmount - collectedAmount;

  // ✅ copyWith — agar bisa update field tertentu tanpa buat ulang semua
  SavingGoal copyWith({
    String? title,
    String? imageUrl,
    String? localImagePath,
    double? targetAmount,
    double? collectedAmount,
    int? savingPerPeriod,
    String? rencana,
    String? createdDate,
    String? estimasiDate,
    bool? isCompleted,
    bool clearImageUrl = false,
    bool clearLocalPath = false,
  }) {
    return SavingGoal(
      title:           title          ?? this.title,
      imageUrl:        clearImageUrl  ? null : (imageUrl   ?? this.imageUrl),
      localImagePath:  clearLocalPath ? null : (localImagePath ?? this.localImagePath),
      targetAmount:    targetAmount   ?? this.targetAmount,
      collectedAmount: collectedAmount ?? this.collectedAmount,
      savingPerPeriod: savingPerPeriod ?? this.savingPerPeriod,
      rencana:         rencana        ?? this.rencana,
      createdDate:     createdDate    ?? this.createdDate,
      estimasiDate:    estimasiDate   ?? this.estimasiDate,
      isCompleted:     isCompleted    ?? this.isCompleted,
    );
  }
}

// ============================================================
//  WIDGET UTAMA
// ============================================================
class StatistikScreen extends StatefulWidget {
  const StatistikScreen({super.key});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<SavingGoal> _goals = [
    SavingGoal(
      title: 'Iphone 17 Pro max',
      imageUrl:
          'https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/iphone-16-pro-finish-select-202409-6-9inch-deserttitanium?wid=5120&hei=2880&fmt=p-jpg&qlt=80&.v=1725297160229',
      targetAmount: 19000000,
      collectedAmount: 5250000,
      savingPerPeriod: 500000,
      rencana: 'Mingguan',
      createdDate: '20 April 2026',
      estimasiDate: 'Januari 2027',
      isCompleted: false,
    ),
    SavingGoal(
      title: 'Laptop Gaming',
      imageUrl:
          'https://images.unsplash.com/photo-1525547719571-a2d4ac8945e2?w=400',
      targetAmount: 12000000,
      collectedAmount: 3500000,
      savingPerPeriod: 300000,
      rencana: 'Mingguan',
      createdDate: '1 Maret 2026',
      estimasiDate: 'Oktober 2026',
      isCompleted: false,
    ),
    SavingGoal(
      title: 'Iphone 17 Pro max',
      imageUrl:
          'https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/iphone-16-pro-finish-select-202409-6-9inch-deserttitanium?wid=5120&hei=2880&fmt=p-jpg&qlt=80&.v=1725297160229',
      targetAmount: 19000000,
      collectedAmount: 19000000,
      savingPerPeriod: 500000,
      rencana: 'Mingguan',
      createdDate: '20 April 2026',
      estimasiDate: 'Januari 2027',
      isCompleted: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── NAVIGASI TAMBAH ────────────────────────────────────────────
  Future<void> _bukaHalamanTambah() async {
    final SavingGoal? newGoal = await Navigator.of(context).push<SavingGoal>(
      MaterialPageRoute(builder: (_) => const TambahTabunganScreen()),
    );
    if (!mounted) return;
    if (newGoal != null) {
      setState(() => _goals.add(newGoal));
    }
  }

  // ── NAVIGASI EDIT ──────────────────────────────────────────────
  Future<void> _bukaHalamanEdit(SavingGoal goal) async {
    final int idx = _goals.indexOf(goal);
    if (idx == -1) return;

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => EditTabunganScreen(goal: goal, goalIndex: idx),
      ),
    );
    if (!mounted) return;
    if (result != null) {
      final SavingGoal updatedGoal = result['goal'] as SavingGoal;
      final int        goalIndex   = result['index'] as int;
      setState(() => _goals[goalIndex] = updatedGoal);
      _showSnackbar('Tabungan berhasil diperbarui!');
    }
  }

  // ── NAVIGASI MANUAL ────────────────────────────────────────────
  Future<void> _bukaHalamanManual() async {
    // Kirim hanya goals yang In Progress beserta index aslinya
    final List<MapEntry<int, SavingGoal>> activeEntries = [];
    for (int i = 0; i < _goals.length; i++) {
      if (!_goals[i].isCompleted) {
        activeEntries.add(MapEntry(i, _goals[i]));
      }
    }

    if (activeEntries.isEmpty) {
      _showSnackbar('Belum ada tabungan aktif!', isError: true);
      return;
    }

    final ManualResult? result =
        await Navigator.of(context).push<ManualResult>(
      MaterialPageRoute(
        builder: (_) => TabunganManualScreen(activeGoals: activeEntries),
      ),
    );
    if (!mounted) return;
    if (result != null) {
      setState(() {
        final SavingGoal g       = _goals[result.goalIndex];
        final double newCollected =
            (g.collectedAmount + result.deltaAmount).clamp(0, g.targetAmount);
        // Cek apakah sudah complete setelah update
        final bool nowComplete = newCollected >= g.targetAmount;

        _goals[result.goalIndex] = g.copyWith(
          collectedAmount: newCollected,
          isCompleted:     nowComplete,
        );
      });

      final bool isAdd = result.deltaAmount >= 0;
      _showSnackbar(
        isAdd
            ? 'Tabungan berhasil ditambahkan!'
            : 'Tabungan berhasil dikurangi!',
      );
    }
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? const Color(0xFFE53935) : const Color(0xFF2E7D32),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final List<SavingGoal> inProgress =
        _goals.where((g) => !g.isCompleted).toList();
    final List<SavingGoal> completed =
        _goals.where((g) => g.isCompleted).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF4CAF72),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF72),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Statistik Menabung',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGoalList(inProgress, isDark, isCompleted: false),
                _buildGoalList(completed, isDark, isCompleted: true),
              ],
            ),
          ),
          _buildBottomButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Colors.black87,
      indicatorWeight: 2.5,
      dividerColor: Colors.transparent,
      labelPadding: EdgeInsets.zero,
      tabs: [_buildTab('In progress', 0), _buildTab('Complete', 1)],
    );
  }

  Widget _buildTab(String label, int index) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        final bool selected = _tabController.index == index;
        return Tab(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.black87 : Colors.black45,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalList(List<SavingGoal> goals, bool isDark,
      {required bool isCompleted}) {
    if (goals.isEmpty) {
      return Center(
        child: Text(
          isCompleted
              ? 'Belum ada tabungan selesai'
              : 'Belum ada tabungan aktif',
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: goals.length,
      itemBuilder: (context, i) =>
          _buildGoalCard(goals[i], isDark, isCompleted, i),
    );
  }

  Widget _buildGoalCard(
      SavingGoal goal, bool isDark, bool isCompleted, int listIndex) {
    final Color cardBg   = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final Color textMain = isDark ? Colors.white : Colors.black87;
    final Color textSub  = isDark ? Colors.white60 : Colors.black54;
    final int pct        = (goal.progressPercent * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title + Edit/Check ──
            Row(
              children: [
                Expanded(
                  child: Text(goal.title,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textMain)),
                ),
                if (!isCompleted)
                  _buildEditButton(goal)
                else
                  const Icon(Icons.check, color: Color(0xFF4CAF72), size: 22),
              ],
            ),
            const SizedBox(height: 12),

            // ── Gambar ──
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildImage(goal),
            ),
            const SizedBox(height: 14),

            // ── Harga + Persen ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rp. ${_fmt(goal.targetAmount)}',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: textMain)),
                    const SizedBox(height: 2),
                    Text(
                        'Rp. ${_fmt(goal.savingPerPeriod.toDouble())}/${goal.rencana.toLowerCase()}',
                        style: TextStyle(fontSize: 11, color: textSub)),
                  ],
                ),
                Text('$pct%',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textSub)),
              ],
            ),
            const SizedBox(height: 10),

            // ── Progress bar ──
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: goal.progressPercent,
                backgroundColor:
                    isDark ? Colors.white12 : Colors.grey.shade200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF72)),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 12),

            Text('Dibuat: ${goal.createdDate}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textMain)),
            const SizedBox(height: 2),
            Text('Estimasi: ${goal.estimasiDate}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textMain)),

            // ── Dikumpulkan & Tersisa (In Progress only) ──
            if (!isCompleted) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAmountBadge(
                      'Dikumpulkan', goal.collectedAmount,
                      const Color(0xFF4CAF72), isDark),
                  _buildAmountBadge(
                      'Yang Tersisa', goal.remaining,
                      const Color(0xFFE53935), isDark),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImage(SavingGoal goal) {
    if (goal.localImagePath != null && goal.localImagePath!.isNotEmpty) {
      return Image.file(
        File(goal.localImagePath!),
        height: 130,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }
    if (goal.imageUrl != null && goal.imageUrl!.isNotEmpty) {
      return Image.network(
        goal.imageUrl!,
        height: 130,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 130,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
    );
  }

  Widget _buildEditButton(SavingGoal goal) {
    return GestureDetector(
      onTap: () => _bukaHalamanEdit(goal),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF72).withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF4CAF72), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.edit, size: 13, color: Color(0xFF4CAF72)),
            SizedBox(width: 4),
            Text('Edit',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF72))),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountBadge(
      String label, double amount, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : Colors.black54)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8)),
          child: Text('Rp. ${_fmt(amount)}',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(bool isDark) {
    return Container(
      color: const Color(0xFF4CAF72),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          // ✅ Tombol Manual → buka TabunganManualScreen
          Expanded(
              child: _buildBtn(
                  label: '+ Manual',
                  onTap: _bukaHalamanManual,
                  outlined: true)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildBtn(
                  label: '+ Tambah',
                  onTap: _bukaHalamanTambah,
                  outlined: false)),
        ],
      ),
    );
  }

  Widget _buildBtn(
      {required String label,
      required VoidCallback onTap,
      required bool outlined}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: outlined ? Border.all(color: Colors.white, width: 1.5) : null,
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: outlined ? Colors.white : const Color(0xFF4CAF72),
              )),
        ),
      ),
    );
  }

  String _fmt(double amount) {
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