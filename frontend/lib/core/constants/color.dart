import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF121212);
  static const Color primary = Color(0xFF28B498); // Alias for primaryAccent
  static const Color primaryAccent = Color(0xFF28B498);
  static const Color secondaryAccent = Color(0xFF2A2A2E);
  static const Color textLight = Colors.white;
  static const Color textSecondary = Color(0xFFB3B3B3); // Grey text
  static const Color textDark = Colors.black;
  static const Color inactiveIndicator = Color(0x4DFFFFFF);
  static const Color success = Color(0xFF4CAF50);

  // Warna baru yang ditambahkan
  static const Color danger = Color(
    0xFFD32F2F,
  ); // Merah tua untuk aksi bahaya seperti logout
  // Alternatif lain bisa:
  // static const Color danger = Color(0xFFE53935); // Sedikit lebih terang
  // static const Color danger = Colors.redAccent; // Menggunakan konstanta Flutter

  static const Color cardBackground = Color(0xFF1E1E1E);
}
