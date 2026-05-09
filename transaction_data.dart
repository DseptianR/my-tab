import 'package:flutter/material.dart';

// ============================================================
//  SHARED TRANSACTION DATA - TABUNGANKU
//  Global state yang dipakai HomeScreen & TransactionScreen
// ============================================================

class AppTransaction {
  final String title;    // Nama unit / judul transaksi
  final String subtitle; // Catatan deskripsi
  final double amount;   // Positif = pemasukan, Negatif = pengeluaran
  final String date;     // Tanggal dalam format "1 Januari 2026"
  final String type;     // 'income' atau 'expense'

  const AppTransaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
  });
}

/// Menghasilkan tanggal hari ini dalam format Indonesia
String formatTodayDate() {
  final now = DateTime.now();
  const months = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${now.day} ${months[now.month]} ${now.year}';
}

/// Global list transaksi yang didengarkan oleh HomeScreen & TransactionScreen
final ValueNotifier<List<AppTransaction>> globalTransactions =
    ValueNotifier<List<AppTransaction>>(const [
  AppTransaction(
    title: 'Beli Hp',
    subtitle: 'AMBARIP',
    amount: -5000000,
    date: '4 April 2026',
    type: 'expense',
  ),
  AppTransaction(
    title: 'Makanan',
    subtitle: 'AMBAKANG',
    amount: -25000,
    date: '4 April 2026',
    type: 'expense',
  ),
  AppTransaction(
    title: 'Top Up Dana',
    subtitle: 'AMBA STORE',
    amount: -300000,
    date: '4 April 2026',
    type: 'expense',
  ),
  AppTransaction(
    title: 'Thr',
    subtitle: 'Dikasih keluarga',
    amount: 450000,
    date: '1 April 2026',
    type: 'income',
  ),
]);

/// Tambah transaksi baru ke paling atas daftar (terbaru tampil duluan)
void addTransaction(AppTransaction t) {
  globalTransactions.value = [t, ...globalTransactions.value];
}