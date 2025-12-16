import 'package:flutter/material.dart';

class AppColors {
  // Solid colors
  static const Color f4e8da = Color(0xFFF4E8DA);
  static const Color ac9780 = Color(0xFFAC9780);
  static const Color c838a60 = Color(0xFF838A60);
  static const Color ba9659 = Color(0xFFBA9659);
  static const Color b93160 = Color(0xFFB93160);
  static const Color ffb4c2 = Color(0xFFFFB4C2);
  static const Color eed180 = Color(0xFFEED180);
  static const Color fff89c = Color(0xFFFFF89C);

  // Gradient utama (Linier)
  static const Gradient linier = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFB4C2), // pink
      Color(0xFFEED180), // yellow
    ],
  );
}
