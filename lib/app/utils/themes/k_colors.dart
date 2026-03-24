// Raw color constants — NEVER use directly in widgets.
// Only referenced as defaults in AppColors.
import 'package:flutter/material.dart';

abstract class KColors {
  // Brand
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF3ECFCF);

  // Backgrounds
  static const Color bg0 = Color(0xFF0A0A0F);
  static const Color bg1 = Color(0xFF1A1A2E);
  static const Color bg2 = Color(0xFF16213E);

  // Status
  static const Color error = Color(0xFFFF5C5C);
  static const Color success = Color(0xFF3ECFCF);
  static const Color warning = Color(0xFFF39C12);

  // Neutrals
  static const Color white = Colors.white;
  static const Color transparent = Colors.transparent;

  // Onboarding nav bar
  static const Color onboarding = Color(0xFF0A0A0F);
}
