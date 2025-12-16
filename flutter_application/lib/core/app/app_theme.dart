import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application/core/constants/font_sizes.dart';
import 'package:flutter_application/core/constants/spacings.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData getTheme(Brightness brightness) {
  final colorScheme = brightness == Brightness.light ? _lightColorScheme : _darkColorScheme;
  return _getTheme(colorScheme);
}

final _lightColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF47828F),
  brightness: Brightness.light,
);

final _darkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFFA7C8FF),
  brightness: Brightness.dark,
);

ThemeData _getTheme(ColorScheme colorScheme) {
  final textTheme = _getTextTheme(colorScheme);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.background,
      titleTextStyle: textTheme.titleLarge,
      iconTheme: IconThemeData(
        color: colorScheme.primary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.s16.r),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: Spacing.s16.h,
          horizontal: Spacing.s32.w,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.all(Spacing.s24.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(Spacing.s16.r),
        ),
      ),
    ),
  );
}

TextTheme _getTextTheme(ColorScheme colorScheme) {
  final textTheme = TextTheme(
      //Headline
      headlineLarge: TextStyle(
        fontSize: FontSize.s24.sp,
        fontWeight: FontWeight.w700,
        color: colorScheme.primary,
      ),
      headlineMedium: TextStyle(
        fontSize: FontSize.s18.sp,
        fontWeight: FontWeight.w700,
        color: colorScheme.onBackground,
      ),
      //Display
      displayLarge: TextStyle(
        fontSize: FontSize.s36.sp,
        fontWeight: FontWeight.w700,
        color: colorScheme.primary,
      ),
      displayMedium: TextStyle(
        fontSize: FontSize.s18.sp,
        fontWeight: FontWeight.w500,
      ),
      //Title
      titleLarge: TextStyle(
        fontSize: FontSize.s20.sp,
        fontWeight: FontWeight.w400,
        color: colorScheme.onBackground,
      ),
      titleMedium: TextStyle(
        fontSize: FontSize.s18.sp,
        fontWeight: FontWeight.w400,
        color: colorScheme.onBackground,
      ),
      //Body
      bodyMedium: TextStyle(
        fontSize: FontSize.s16.sp,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        fontSize: FontSize.s14.sp,
        fontWeight: FontWeight.w400,
        color: colorScheme.onBackground,
      ),
      //Label
      labelSmall: TextStyle(
        fontSize: FontSize.s10.sp,
        fontWeight: FontWeight.w400,
        color: colorScheme.primary,
      ));

  return GoogleFonts.rubikTextTheme(textTheme);
}
