import 'package:flutter/material.dart';

// ============================================================
//  NOTIFICATION SCREEN - TABUNGANKU (Dark Mode Ready)
//
//  Notifikasi muncul otomatis dari:
//  1. addManualNotification()    → saat user tambah/kurang di TabunganManualScreen
//  2. addGoalNotification()      → saat user tambah tabungan baru di StatistikScreen
//  3. addCompletedNotification() → saat tabungan selesai / 100%
//  4. addDailyReminder()         → pengingat harian progress tabungan
// ============================================================

// ── TIPE NOTIFIKASI ──────────────────────────────────────────
enum NotifType {
  manual,    // Tambah / kurang tabungan manual
  newGoal,   // Tabungan baru ditambahkan
  completed, // Tabungan selesai 100%
  reminder,  // Pengingat harian
  security,  // Keamanan / sistem
}

// ── MODEL NOTIFIKASI ─────────────────────────────────────────
class AppNotification {
  final String   title;
  final String   body;
  final NotifType type;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });
}

// ── GLOBAL NOTIFIER ──────────────────────────────────────────
final ValueNotifier<List<AppNotification>> globalNotifications =
    ValueNotifier<List<AppNotification>>([
  AppNotification(
    title: 'Pengingat Tabungan',
    body: 'Jangan lupa menabung hari ini. Sedikit demi sedikit, lama lama jadi bukit',
    type: NotifType.reminder,
    createdAt: DateTime.now(),
  ),
  AppNotification(
    title: 'Verifikasi Akun',
    body: 'Akun Anda telah berhasil diverifikasi.',
    type: NotifType.security,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    isRead: true,
  ),
  AppNotification(
    title: 'Pembaruan Aplikasi',
    body: 'Versi terbaru (v2.1.0) sudah tersedia. Ketuk untuk memperbarui.',
    type: NotifType.security,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    isRead: true,
  ),
  AppNotification(
    title: 'Keamanan',
    body: 'Login baru terdeteksi di perangkat iPhone 16 Pro Max.',
    type: NotifType.security,
    createdAt: DateTime.now().subtract(const Duration(days: 6)),
    isRead: true,
  ),
  AppNotification(
    title: 'Pengingat Jadwal',
    body: 'Jangan lupa untuk menabung yaa',
    type: NotifType.reminder,
    createdAt: DateTime.now().subtract(const Duration(days: 6)),
    isRead: true,
  ),
]);

// ── FUNGSI TAMBAH NOTIFIKASI ──────────────────────────────────

void _pushNotif(AppNotification notif) {
  globalNotifications.value = [notif, ...globalNotifications.value];
}

/// Dipanggil dari TabunganManualScreen saat user klik Save
void addManualNotification({
  required String unitNama,
  required double nominal,
  required bool   isTambah,
  required String catatan,
  required double progressPersen,
}) {
  _pushNotif(AppNotification(
    title: isTambah ? 'Tabungan Bertambah 💰' : 'Tabungan Berkurang 📤',
    body:
        '$unitNama ${isTambah ? 'ditambahkan' : 'dikurangi'} sebesar Rp.${_fmtCurrency(nominal)}.\n'
        'Catatan: $catatan\n'
        'Progress: ${progressPersen.toStringAsFixed(1)}%',
    type: NotifType.manual,
    createdAt: DateTime.now(),
  ));
}

/// Dipanggil dari StatistikScreen saat user menambah goal baru
void addGoalNotification({
  required String namaGoal,
  required double target,
}) {
  _pushNotif(AppNotification(
    title: 'Tabungan Baru Ditambahkan 🎯',
    body:
        'Tabungan "$namaGoal" berhasil dibuat.\n'
        'Target: Rp.${_fmtCurrency(target)}. Semangat menabung!',
    type: NotifType.newGoal,
    createdAt: DateTime.now(),
  ));
}

/// Dipanggil dari StatistikScreen saat collectedAmount >= targetAmount
void addCompletedNotification({
  required String namaGoal,
  required double total,
}) {
  _pushNotif(AppNotification(
    title: 'Tabungan Selesai! 🎉',
    body:
        'Selamat! Tabungan "$namaGoal" telah tercapai.\n'
        'Total terkumpul: Rp.${_fmtCurrency(total)}. Luar biasa!',
    type: NotifType.completed,
    createdAt: DateTime.now(),
  ));
}

/// Dipanggil secara periodik atau dari StatistikScreen
void addDailyReminder({
  required String namaGoal,
  required double progressPersen,
  required double sisaAmount,
}) {
  _pushNotif(AppNotification(
    title: 'Pengingat Tabungan Harian 📅',
    body:
        '"$namaGoal" sudah ${progressPersen.toStringAsFixed(1)}% tercapai.\n'
        'Sisa yang perlu ditabung: Rp.${_fmtCurrency(sisaAmount)}. Yuk semangat!',
    type: NotifType.reminder,
    createdAt: DateTime.now(),
  ));
}

String _fmtCurrency(double amount) {
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

// ── SCREEN ────────────────────────────────────────────────────
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Notifikasi'),
        actions: [
          ValueListenableBuilder<List<AppNotification>>(
            valueListenable: globalNotifications,
            builder: (context, notifs, _) {
              final hasUnread = notifs.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  for (final n in globalNotifications.value) {
                    n.isRead = true;
                  }
                  globalNotifications.value =
                      List.from(globalNotifications.value);
                },
                child: const Text(
                  'Baca Semua',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4CAF72),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<AppNotification>>(
        valueListenable: globalNotifications,
        builder: (context, notifs, _) {
          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 56,
                      color: isDark ? Colors.white24 : Colors.black26),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada notifikasi',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            );
          }

          final Map<String, List<AppNotification>> grouped =
              _groupByTime(notifs);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              for (final entry in grouped.entries) ...[
                _buildSectionHeader(entry.key, isDark),
                const SizedBox(height: 6),
                ...entry.value.map((notif) => _buildNotifCard(
                      context:   context,
                      notif:     notif,
                      isDark:    isDark,
                      onTap: () {
                        // Tandai sebagai sudah dibaca
                        notif.isRead = true;
                        globalNotifications.value =
                            List.from(globalNotifications.value);
                      },
                      onDismiss: () {
                        // Hapus notifikasi dengan swipe
                        globalNotifications.value = globalNotifications.value
                            .where((n) => n != notif)
                            .toList();
                      },
                    )),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  // ── SECTION HEADER ────────────────────────────────────────────
  Widget _buildSectionHeader(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }

  // ── KARTU NOTIFIKASI ──────────────────────────────────────────
  Widget _buildNotifCard({
    required BuildContext      context,
    required AppNotification   notif,
    required bool              isDark,
    required VoidCallback      onTap,
    required VoidCallback      onDismiss,
  }) {
    final Color cardColor = isDark
        ? (notif.isRead ? const Color(0xFF1E1E1E) : const Color(0xFF2A2A2A))
        : (notif.isRead ? Colors.white : const Color(0xFFF0FBF3));

    final Color borderColor = notif.isRead
        ? Colors.transparent
        : const Color(0xFF4CAF72).withOpacity(0.4);

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(14),
        ),
        child:
            const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      onDismissed: (_) => onDismiss(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 10),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black26
                    : Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── IKON ──────────────────────────────────────────
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _notifIconBg(notif.type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _notifIcon(notif.type),
                  color: _notifIconColor(notif.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // ── KONTEN ────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notif.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF72),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.body,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(notif.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white30 : Colors.black38,
                      ),
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

  // ── HELPERS ───────────────────────────────────────────────────
  IconData _notifIcon(NotifType type) {
    switch (type) {
      case NotifType.manual:
        return Icons.account_balance_wallet_outlined;
      case NotifType.newGoal:
        return Icons.flag_outlined;
      case NotifType.completed:
        return Icons.emoji_events_outlined;
      case NotifType.reminder:
        return Icons.notifications_outlined;
      case NotifType.security:
        return Icons.shield_outlined;
    }
  }

  Color _notifIconColor(NotifType type) {
    switch (type) {
      case NotifType.manual:
        return const Color(0xFF4CAF72);
      case NotifType.newGoal:
        return const Color(0xFF1565C0);
      case NotifType.completed:
        return const Color(0xFFF57F17);
      case NotifType.reminder:
        return const Color(0xFF4CAF72);
      case NotifType.security:
        return const Color(0xFF6A1B9A);
    }
  }

  Color _notifIconBg(NotifType type) {
    switch (type) {
      case NotifType.manual:
        return const Color(0xFFE8F5E9);
      case NotifType.newGoal:
        return const Color(0xFFE3F2FD);
      case NotifType.completed:
        return const Color(0xFFFFF8E1);
      case NotifType.reminder:
        return const Color(0xFFE8F5E9);
      case NotifType.security:
        return const Color(0xFFF3E5F5);
    }
  }

  String _formatTime(DateTime dt) {
    final now  = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1)  return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24)   return '${diff.inHours} jam lalu';
    if (diff.inDays == 1)    return 'Kemarin';
    if (diff.inDays < 7)     return '${diff.inDays} hari lalu';

    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${bulan[dt.month]} ${dt.year}';
  }

  Map<String, List<AppNotification>> _groupByTime(
      List<AppNotification> notifs) {
    final now       = DateTime.now();
    final today     = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo   = today.subtract(const Duration(days: 7));

    final Map<String, List<AppNotification>> result = {};

    for (final n in notifs) {
      final d = DateTime(
          n.createdAt.year, n.createdAt.month, n.createdAt.day);
      String group;
      if (d == today)              group = 'Hari ini';
      else if (d == yesterday)     group = 'Kemarin';
      else if (d.isAfter(weekAgo)) group = 'Minggu Ini';
      else                         group = 'Lebih Lama';
      result.putIfAbsent(group, () => []).add(n);
    }

    const order = ['Hari ini', 'Kemarin', 'Minggu Ini', 'Lebih Lama'];
    final sorted = <String, List<AppNotification>>{};
    for (final key in order) {
      if (result.containsKey(key)) sorted[key] = result[key]!;
    }
    return sorted;
  }
}