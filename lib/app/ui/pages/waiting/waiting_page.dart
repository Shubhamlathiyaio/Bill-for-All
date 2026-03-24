import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/waiting_controller.dart';
import '../../../utils/constants/app_strings.dart';
import '../../../utils/helpers/extensions.dart';
import '../../widgets/get_it_hook.dart';
import '../../widgets/system_ui_overlay.dart';

class WaitingPage extends GetItHook<WaitingController> {
  const WaitingPage({super.key});

  @override
  bool get autoDispose => true;

  @override
  Widget build(BuildContext context) {
    return OnboardingSystemUiOverlayStyle(child: _WaitingBody(controller: controller));
  }
}

class _WaitingBody extends StatefulWidget {
  const _WaitingBody({required this.controller});
  final WaitingController controller;

  @override
  State<_WaitingBody> createState() => _WaitingBodyState();
}

class _WaitingBodyState extends State<_WaitingBody> with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _dotsCtrl;
  late Animation<int> _dotsAnim;

  WaitingController get ctrl => widget.controller;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.90, end: 1.08).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _dotsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

    _dotsAnim = StepTween(begin: 0, end: 3).animate(_dotsCtrl);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;

    return Scaffold(
      backgroundColor: colors.bg0,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Illustration
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [colors.primary.changeOpacity(0.18), Colors.transparent]),
                        ),
                      ),
                      Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary.changeOpacity(0.08),
                          border: Border.all(color: colors.primary.changeOpacity(0.22), width: 1.5),
                        ),
                      ),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: colors.primaryGradientDiagonal,
                          boxShadow: [BoxShadow(color: colors.primary.changeOpacity(0.45), blurRadius: 28, spreadRadius: 2)],
                        ),
                        child: const Icon(Icons.hourglass_top_rounded, color: Colors.white, size: 34),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // Content
                Text(AppStrings.settingUpWorkspace, textAlign: TextAlign.center, style: styles.s28w700White),
                const SizedBox(height: 14),
                Text(
                  AppStrings.settingUpSub,
                  textAlign: TextAlign.center,
                  style: styles.s15w400White.copyWith(color: colors.textPrimary.changeOpacity(0.45), height: 1.6),
                ),
                const SizedBox(height: 20),
                // Animated dots badge
                AnimatedBuilder(
                  animation: _dotsAnim,
                  builder: (_, __) {
                    final dots = '.' * (_dotsAnim.value + 1);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.primary.changeOpacity(0.12),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: colors.primary.changeOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: colors.primary),
                          ),
                          const SizedBox(width: 8),
                          Text('${AppStrings.provisioning}$dots', style: styles.s13w600Primary),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                // Steps list
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.bg1,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.white.changeOpacity(0.06)),
                  ),
                  child: Column(
                    children: List.generate(_steps.length, (i) {
                      final step = _steps[i];
                      final isLast = i == _steps.length - 1;
                      return Column(
                        children: [
                          Row(
                            children: [
                              Icon(step.icon, color: step.done ? colors.success : colors.white.changeOpacity(0.2), size: 20),
                              const SizedBox(width: 12),
                              Text(
                                step.label,
                                style: styles.s14w400White.copyWith(
                                  color: step.done ? colors.textPrimary.changeOpacity(0.85) : colors.textPrimary.changeOpacity(0.35),
                                  fontWeight: step.done ? FontWeight.w500 : FontWeight.w400,
                                ),
                              ),
                              const Spacer(),
                              if (!step.done && i == 2)
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 1.8, valueColor: AlwaysStoppedAnimation(colors.primary)),
                                ),
                            ],
                          ),
                          if (!isLast)
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
                              child: Row(children: [Container(width: 1, height: 16, color: colors.white.changeOpacity(0.1))]),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
                const Spacer(flex: 3),
                // Footer
                Text(
                  AppStrings.workspaceNotification,
                  textAlign: TextAlign.center,
                  style: styles.s13w400Muted.copyWith(color: colors.textPrimary.changeOpacity(0.3), height: 1.6),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => TextButton.icon(
                    onPressed: ctrl.isChecking.value ? null : ctrl.checkWorkspace,
                    icon: ctrl.isChecking.value
                        ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(colors.primary)))
                        : Icon(Icons.refresh_rounded, color: colors.primary, size: 16),
                    label: Text(ctrl.isChecking.value ? AppStrings.checking : AppStrings.checkNow, style: styles.s14w500White.copyWith(color: colors.primary)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: ctrl.reselectModules,
                  child: Text('Reselect Modules', style: styles.s14w500White.copyWith(color: colors.white.changeOpacity(0.5))),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _steps = [
  _Step(icon: Icons.check_circle_rounded, label: AppStrings.accountCreated, done: true),
  _Step(icon: Icons.check_circle_rounded, label: AppStrings.modulesSelectedStep, done: true),
  _Step(icon: Icons.radio_button_unchecked_rounded, label: AppStrings.workspaceProvisioning, done: false),
  _Step(icon: Icons.radio_button_unchecked_rounded, label: AppStrings.credentialsDelivered, done: false),
];

class _Step {
  const _Step({required this.icon, required this.label, required this.done});
  final IconData icon;
  final String label;
  final bool done;
}
