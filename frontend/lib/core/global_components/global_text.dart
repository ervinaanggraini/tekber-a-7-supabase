import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GlobalText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign textAlign;
  final double lineHeight;
  final VoidCallback? onTap;
  final int? maxLines; // Ditambahkan
  final TextOverflow? overflow; // Ditambahkan

  const GlobalText({
    super.key,
    required this.text,
    this.fontSize = 20,
    this.fontWeight = FontWeight.bold,
    this.color = Colors.black,
    this.textAlign = TextAlign.center,
    this.lineHeight = 1.2,
    this.onTap,
    this.maxLines, // Ditambahkan
    this.overflow = TextOverflow.ellipsis, // Default overflow adalah elipsis
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines, // Diterapkan
      overflow: overflow, // Diterapkan
      style: GoogleFonts.poppins(
        fontSize: fontSize.sp,
        fontWeight: fontWeight,
        color: color,
        height: lineHeight,
        decoration: onTap != null ? TextDecoration.none : null,
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: textWidget);
    }
    return textWidget;
  }

  // 🔹 Varian Clickable
  factory GlobalText.clickable(
    String text, {
    Key? key,
    double fontSize = 16,
    Color color = Colors.blue,
    TextAlign textAlign = TextAlign.center,
    required VoidCallback onTap,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return GlobalText(
      key: key,
      text: text,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
      textAlign: textAlign,
      onTap: onTap,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory GlobalText.light(
    String text, {
    Key? key,
    double fontSize = 20,
    Color color = Colors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return GlobalText(
      key: key,
      text: text,
      fontSize: fontSize,
      fontWeight: FontWeight.w300,
      color: color,
      textAlign: textAlign,
      lineHeight: lineHeight,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory GlobalText.regular(
    String text, {
    Key? key,
    double fontSize = 20,
    Color color = Colors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return GlobalText(
      key: key,
      text: text,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color,
      textAlign: textAlign,
      lineHeight: lineHeight,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory GlobalText.medium(
    String text, {
    Key? key,
    double fontSize = 20,
    Color color = Colors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return GlobalText(
      key: key,
      text: text,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
      textAlign: textAlign,
      lineHeight: lineHeight,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory GlobalText.semiBold(
    String text, {
    Key? key,
    double fontSize = 20,
    Color color = Colors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return GlobalText(
      key: key,
      text: text,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      textAlign: textAlign,
      lineHeight: lineHeight,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory GlobalText.bold(
    String text, {
    Key? key,
    double fontSize = 20,
    Color color = Colors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return GlobalText(
      key: key,
      text: text,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
      textAlign: textAlign,
      lineHeight: lineHeight,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory GlobalText.extraBold(
    String text, {
    Key? key,
    double fontSize = 20,
    Color color = Colors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return GlobalText(
      key: key,
      text: text,
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: color,
      textAlign: textAlign,
      lineHeight: lineHeight,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
