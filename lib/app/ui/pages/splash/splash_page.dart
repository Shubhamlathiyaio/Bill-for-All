import 'package:flutter/material.dart';
import '../../../controllers/splash_controller.dart';
import '../../widgets/get_it_hook.dart';
import '../../widgets/system_ui_overlay.dart';
import '../../../utils/themes/k_colors.dart';
import '../../../utils/themes/app_styles.dart';
import '../../../utils/constants/app_strings.dart';

class SplashPage extends GetItHook<SplashController> {
  const SplashPage({super.key});

  @override
  bool get autoDispose => true;

  @override
  Widget build(BuildContext context) {
    return SplashSystemUiOverlayStyle(
      child: _SplashBody(controller: controller),
    );
  }
}

class _SplashBody extends StatefulWidget {
  const _SplashBody({required this.controller});
  final SplashController controller;

  @override
  State<_SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<_SplashBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.80, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _animController.forward();
    Future.delayed(const Duration(milliseconds: 2400),
        widget.controller.navigateAfterSplash);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final styles = AppStyles.of(context);

    return Scaffold(
      backgroundColor: KColors.bg0,
      body: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (_, __) => Opacity(
            opacity: _fadeAnim.value,
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [KColors.primary, KColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: KColors.primary.changeOpacity(0.45),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: KColors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(AppStrings.appName, style: styles.s36w700White),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.appTagline,
                    style: styles.s14w400Muted,
                  ),
                  const SizedBox(height: 64),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        KColors.white.changeOpacity(0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Extension for Color on non-context usage in splash
extension _ColorX on Color {
  Color changeOpacity(double o) => withValues(alpha: o);
}
