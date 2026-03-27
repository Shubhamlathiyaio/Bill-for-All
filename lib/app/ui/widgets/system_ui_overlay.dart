import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/themes/k_colors.dart';

/// Standard pages (light/dark on white bg)
class DarkSystemUiOverlayStyle extends StatelessWidget {
  const DarkSystemUiOverlayStyle({super.key, required this.child});
  final Widget child;

  static const SystemUiOverlayStyle style = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: KColors.bg1,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  @override
  Widget build(BuildContext context) =>
      AnnotatedRegion<SystemUiOverlayStyle>(value: style, child: child);
}

/// Splash page only
class SplashSystemUiOverlayStyle extends StatelessWidget {
  const SplashSystemUiOverlayStyle({super.key, required this.child});
  final Widget child;

  static const SystemUiOverlayStyle style = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: KColors.bg0,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  );

  @override
  Widget build(BuildContext context) =>
      AnnotatedRegion<SystemUiOverlayStyle>(value: style, child: child);
}

/// Pages with dark/colored background
class OnboardingSystemUiOverlayStyle extends StatelessWidget {
  const OnboardingSystemUiOverlayStyle({super.key, required this.child});
  final Widget child;

  static const SystemUiOverlayStyle style = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: KColors.onboarding,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) =>
      AnnotatedRegion<SystemUiOverlayStyle>(value: style, child: child);
}
