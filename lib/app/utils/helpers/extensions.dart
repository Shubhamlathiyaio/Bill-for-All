import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_styles.dart';

extension BuildContextX on BuildContext {
  AppColors get colors => AppColors.of(this);
  AppStyles get styles => AppStyles.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isKeyboardOpen => MediaQuery.of(this).viewInsets.bottom > 0;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

extension ColorX on Color {
  /// Use instead of deprecated withOpacity / withAlpha.
  Color changeOpacity(double opacity) => withValues(alpha: opacity);
}

extension StringX on String {
  bool get isValidEmail => RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(this);
  bool get isValidPhone => RegExp(r'^\+?[0-9]{7,15}$').hasMatch(this);
  String get toCapitalized => split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
