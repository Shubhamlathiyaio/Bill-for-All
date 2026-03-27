import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_styles.dart';
import 'k_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
    extensions: [const AppColors(), AppStyles()],
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: KColors.lightBg0,
    fontFamily: 'Poppins',
    // Explicit hint/icon colors for light mode
    hintColor: const Color(0xFF9999AA),
    iconTheme: const IconThemeData(color: KColors.black),
    primaryIconTheme: const IconThemeData(color: KColors.black),
    colorScheme: const ColorScheme.light(
      primary: KColors.primary,
      secondary: KColors.secondary,
      error: KColors.error,
      surface: KColors.lightBg1,
      onPrimary: KColors.white,
      onSecondary: KColors.white,
      onSurface: KColors.black,
      onSurfaceVariant: Color(0xFF555566),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: KColors.lightBg0,
      foregroundColor: KColors.black,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: KColors.black),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    cardTheme: const CardThemeData(color: KColors.lightBg1, elevation: 1, surfaceTintColor: Colors.transparent),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: KColors.lightBg2,
      hintStyle: const TextStyle(color: Color(0xFF9999AA)),
      prefixIconColor: const Color(0xFF9999AA),
      suffixIconColor: const Color(0xFF9999AA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDDDEE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDDDEE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: KColors.primary, width: 1.5),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFDDDDEE)),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: KColors.black),
      displayMedium: TextStyle(color: KColors.black),
      displaySmall: TextStyle(color: KColors.black),
      headlineLarge: TextStyle(color: KColors.black),
      headlineMedium: TextStyle(color: KColors.black),
      headlineSmall: TextStyle(color: KColors.black),
      titleLarge: TextStyle(color: KColors.black),
      titleMedium: TextStyle(color: KColors.black),
      titleSmall: TextStyle(color: KColors.black),
      bodyLarge: TextStyle(color: KColors.black),
      bodyMedium: TextStyle(color: KColors.black),
      bodySmall: TextStyle(color: Color(0xFF555566)),
      labelLarge: TextStyle(color: KColors.black),
      labelMedium: TextStyle(color: Color(0xFF555566)),
      labelSmall: TextStyle(color: Color(0xFF9999AA)),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    extensions: [
      const AppColors(
        bg0: KColors.bg0,
        bg1: KColors.bg1,
        bg2: KColors.bg2,
        textPrimary: KColors.white,
        textSecondary: Color(0xFFAAAAAA),
        textMuted: Color(0xFF555566),
        fieldColor: KColors.bg1,
        borderColor: Color(0xFF252540),
      ),
      AppStyles.dark(),
    ],
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: KColors.bg0,
    fontFamily: 'Poppins',
    hintColor: const Color(0xFF555566),
    iconTheme: const IconThemeData(color: KColors.white),
    primaryIconTheme: const IconThemeData(color: KColors.white),
    colorScheme: const ColorScheme.dark(
      primary: KColors.primary,
      secondary: KColors.secondary,
      error: KColors.error,
      surface: KColors.bg1,
      onSurface: KColors.white,
      onSurfaceVariant: Color(0xFFAAAAAA),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: KColors.bg0,
      foregroundColor: KColors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: KColors.white),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    cardTheme: const CardThemeData(color: KColors.bg1, elevation: 0, surfaceTintColor: Colors.transparent),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: KColors.bg1,
      hintStyle: const TextStyle(color: Color(0xFF555566)),
      prefixIconColor: const Color(0xFF555566),
      suffixIconColor: const Color(0xFF555566),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF252540)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF252540)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: KColors.primary, width: 1.5),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF252540)),
  );
}
