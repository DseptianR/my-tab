import 'package:flutter/material.dart';
import 'theme_notifier.dart'; // ✅ Import dari file terpisah, bukan main.dart

// ============================================================
//  SETTINGS SCREEN - TABUNGANKU (Dark Mode Ready)
// ============================================================

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        final bool isDark = mode == ThemeMode.dark;
        const Color green = Color(0xFF4CAF72);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text('Settings'),
          ),
          body: Column(
            children: [

              // ── TEMA GELAP ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tema Gelap',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        )),
                    // Toggle switch bulan ↔ matahari
                    GestureDetector(
                      onTap: () {
                        themeNotifier.value =
                            isDark ? ThemeMode.light : ThemeMode.dark;
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 72,
                        height: 36,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isDark
                              ? green.withOpacity(0.25)
                              : Colors.grey.shade200,
                          border: Border.all(
                            color: isDark ? green : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Ikon bulan (kiri)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Icon(Icons.nightlight_round,
                                  size: 18,
                                  color: isDark ? green : Colors.grey.shade400),
                            ),
                            // Ikon matahari (kanan)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.wb_sunny,
                                  size: 18,
                                  color: !isDark ? Colors.orange : Colors.grey.shade600),
                            ),
                            // Bulatan indikator geser
                            AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              alignment: isDark
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? green : Colors.orange,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isDark ? green : Colors.orange)
                                          .withOpacity(0.4),
                                      blurRadius: 6,
                                    )
                                  ],
                                ),
                                child: Icon(
                                  isDark ? Icons.nightlight_round : Icons.wb_sunny,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, indent: 20, endIndent: 20,
                  color: isDark ? Colors.white12 : Colors.black12),

              // ── NOTIFIKASI ──────────────────────────────────
              _buildTile(context, 'Notifikasi', isDark, onTap: () {}),

              Divider(height: 1, indent: 20, endIndent: 20,
                  color: isDark ? Colors.white12 : Colors.black12),

              // ── PENGINGAT ALARM ─────────────────────────────
              _buildTile(context, 'Pengingat Alarm', isDark, onTap: () {}),

              const Spacer(),

              // ── COPYRIGHT ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  '@copyright 2026 my tab',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white30 : Colors.black38,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTile(BuildContext context, String title, bool isDark,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              )),
        ),
      ),
    );
  }
}