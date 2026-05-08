import 'package:flutter/material.dart';

// ============================================================
//  GLOBAL THEME NOTIFIER - TABUNGANKU
//  Dipisah agar tidak circular import
// ============================================================
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);