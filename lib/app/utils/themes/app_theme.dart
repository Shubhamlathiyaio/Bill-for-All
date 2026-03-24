import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_styles.dart';
import 'k_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        extensions: [
          const AppColors(),
          AppStyles(),
        ],
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: KColors.bg0,
        fontFamily: 'Poppins',
        colorScheme: const ColorScheme.dark(
          primary: KColors.primary,
          secondary: KColors.secondary,
          error: KColors.error,
          surface: KColors.bg1,
        ),
      );
}
