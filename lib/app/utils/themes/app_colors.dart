import 'package:flutter/material.dart';
import 'k_colors.dart';

/// Semantic, context-aware colors.
/// Access via: `AppColors.of(context)` or `context.colors`
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    this.primary = KColors.primary,
    this.secondary = KColors.secondary,
    this.bg0 = KColors.bg0,
    this.bg1 = KColors.bg1,
    this.bg2 = KColors.bg2,
    this.error = KColors.error,
    this.success = KColors.success,
    this.warning = KColors.warning,
    this.white = KColors.white,
    this.textPrimary = KColors.white,
    this.textSecondary = const Color(0xFFAAAAAA),
    this.textMuted = const Color(0xFF555566),
    this.fieldColor = KColors.bg1,
    this.borderColor = const Color(0xFF252540),
    this.gradientStart = KColors.primary,
    this.gradientEnd = KColors.secondary,
  });

  final Color primary;
  final Color secondary;
  final Color bg0;
  final Color bg1;
  final Color bg2;
  final Color error;
  final Color success;
  final Color warning;
  final Color white;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color fieldColor;
  final Color borderColor;
  final Color gradientStart;
  final Color gradientEnd;

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? const AppColors();

  LinearGradient get primaryGradient => LinearGradient(
        colors: [gradientStart, gradientEnd],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  LinearGradient get primaryGradientDiagonal => LinearGradient(
        colors: [gradientStart, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  @override
  AppColors copyWith({
    Color? primary,
    Color? secondary,
    Color? bg0,
    Color? bg1,
    Color? bg2,
    Color? error,
    Color? success,
    Color? warning,
    Color? white,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? fieldColor,
    Color? borderColor,
    Color? gradientStart,
    Color? gradientEnd,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      bg0: bg0 ?? this.bg0,
      bg1: bg1 ?? this.bg1,
      bg2: bg2 ?? this.bg2,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      white: white ?? this.white,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      fieldColor: fieldColor ?? this.fieldColor,
      borderColor: borderColor ?? this.borderColor,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      bg0: Color.lerp(bg0, other.bg0, t)!,
      bg1: Color.lerp(bg1, other.bg1, t)!,
      bg2: Color.lerp(bg2, other.bg2, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      white: Color.lerp(white, other.white, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      fieldColor: Color.lerp(fieldColor, other.fieldColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
    );
  }
}
