import 'package:flutter/material.dart';
import 'k_colors.dart';

/// Poppins font wrapper. Never instantiate TextStyle directly in widgets.
class Poppins extends TextStyle {
  const Poppins({
    super.fontSize,
    super.color,
    super.fontWeight,
    super.letterSpacing,
    super.height,
    super.decoration,
  }) : super(fontFamily: 'Poppins');
}

/// Typography ThemeExtension.
/// Access via: `AppStyles.of(context)` or `context.styles`
@immutable
class AppStyles extends ThemeExtension<AppStyles> {
  AppStyles({
    Color textColor = KColors.white,
    Color mutedColor = const Color(0xFFAAAAAA),
    Color primaryColor = KColors.primary,
    Color errorColor = KColors.error,
  })  : s11w400Muted = Poppins(fontSize: 11, fontWeight: FontWeight.w400, color: mutedColor, height: 1.3),
        s12w400Muted = Poppins(fontSize: 12, fontWeight: FontWeight.w400, color: mutedColor),
        s13w400Muted = Poppins(fontSize: 13, fontWeight: FontWeight.w400, color: mutedColor, height: 1.4),
        s13w500Primary = Poppins(fontSize: 13, fontWeight: FontWeight.w500, color: primaryColor),
        s13w600Primary = Poppins(fontSize: 13, fontWeight: FontWeight.w600, color: primaryColor),
        s14w400Muted = Poppins(fontSize: 14, fontWeight: FontWeight.w400, color: mutedColor, height: 1.5),
        s14w400White = Poppins(fontSize: 14, fontWeight: FontWeight.w400, color: textColor),
        s14w500White = Poppins(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
        s14w700White = Poppins(fontSize: 14, fontWeight: FontWeight.w700, color: textColor),
        s15w400White = Poppins(fontSize: 15, fontWeight: FontWeight.w400, color: textColor),
        s15w600White = Poppins(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
        s16w600White = Poppins(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
        s18w700White = Poppins(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
        s24w700White = Poppins(fontSize: 24, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.4),
        s28w700White = Poppins(fontSize: 28, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.4, height: 1.25),
        s30w700White = Poppins(fontSize: 30, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.4, height: 1.2),
        s36w700White = Poppins(fontSize: 36, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.5),
        s13w400Error = Poppins(fontSize: 13, fontWeight: FontWeight.w400, color: errorColor, height: 1.4);

  final TextStyle s11w400Muted;
  final TextStyle s12w400Muted;
  final TextStyle s13w400Muted;
  final TextStyle s13w500Primary;
  final TextStyle s13w600Primary;
  final TextStyle s14w400Muted;
  final TextStyle s14w400White;
  final TextStyle s14w500White;
  final TextStyle s14w700White;
  final TextStyle s15w400White;
  final TextStyle s15w600White;
  final TextStyle s16w600White;
  final TextStyle s18w700White;
  final TextStyle s24w700White;
  final TextStyle s28w700White;
  final TextStyle s30w700White;
  final TextStyle s36w700White;
  final TextStyle s13w400Error;

  static AppStyles of(BuildContext context) =>
      Theme.of(context).extension<AppStyles>() ?? AppStyles();

  @override
  AppStyles copyWith() => this;

  @override
  AppStyles lerp(AppStyles? other, double t) => this;
}
