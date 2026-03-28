import 'package:bill_for_all/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/module_selection_controller.dart';
import '../../../data/models/module_model.dart';
import '../../../utils/constants/app_strings.dart';
import '../../../utils/helpers/extensions.dart';
import '../../widgets/app_button.dart';
import '../../widgets/get_it_hook.dart';
import '../../widgets/system_ui_overlay.dart';

class ModuleSelectionPage extends GetItHook<ModuleSelectionController> {
  const ModuleSelectionPage({super.key});

  @override
  bool get autoDispose => true;

  @override
  Widget build(BuildContext context) {
    return OnboardingSystemUiOverlayStyle(
        child: _ModuleBody(controller: controller));
  }
}

class _ModuleBody extends StatefulWidget {
  const _ModuleBody({required this.controller});
  final ModuleSelectionController controller;

  @override
  State<_ModuleBody> createState() => _ModuleBodyState();
}

class _ModuleBodyState extends State<_ModuleBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  ModuleSelectionController get ctrl => widget.controller;

  IconData _iconFor(String name) {
    switch (name) {
      case 'check_circle_outline':
        return Icons.check_circle_outline_rounded;
      case 'people_alt_outlined':
        return Icons.people_alt_outlined;
      case 'inventory_2_outlined':
        return Icons.inventory_2_outlined;
      case 'receipt_long_outlined':
        return Icons.receipt_long_outlined;
      case 'badge_outlined':
        return Icons.badge_outlined;
      case 'dashboard_outlined':
        return Icons.dashboard_outlined;
      case 'bar_chart_rounded':
        return Icons.bar_chart_rounded;
      case 'headset_mic_outlined':
        return Icons.headset_mic_outlined;
      case 'account_balance_outlined':
        return Icons.account_balance_outlined;
      default:
        return Icons.widgets_outlined;
    }
  }

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_animCtrl);
    _animCtrl.forward(); 
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;

    return Scaffold(
      backgroundColor: colors.bg0,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colors.primary.changeOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.widgets_outlined,
                                  color: colors.primary, size: 26),
                            ),
                            const SizedBox(height: 20),
                            Text(AppStrings.pickModules,
                                style: styles.s28w700White),
                            const SizedBox(height: 8),
                            Text(AppStrings.pickModulesSub,
                                style: styles.s14w400Muted),
                            Obx(() {
                              final count = ctrl.selected.length;
                              if (count == 0) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                    AppStrings.modulesSelected(count),
                                    style: styles.s13w600Primary),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    // Module grid
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      sliver: Obx(() {
                        // Loading
                        if (ctrl.isFetchingModules.value) {
                          return const SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          );
                        }

                        // Error with retry
                        if (ctrl.error.value != null && ctrl.modules.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 40, horizontal: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.cloud_off_rounded,
                                      size: 48,
                                      color:
                                          colors.textPrimary.changeOpacity(0.3)),
                                  const SizedBox(height: 16),
                                  Text(
                                    ctrl.error.value!,
                                    style: styles.s14w400Muted,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  TextButton.icon(
                                    onPressed: ctrl.retryFetch,
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Empty
                        if (ctrl.modules.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Text('No modules available.',
                                    style: styles.s14w400Muted),
                              ),
                            ),
                          );
                        }

                        // Grid
                        return SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) {
                              final mod = ctrl.modules[i];
                              return Obx(
                                () => _ModuleCard(
                                  module: mod,
                                  selected: ctrl.isSelected(mod.id),
                                  iconData: _iconFor(mod.iconName),
                                  onTap: () => ctrl.toggleModule(mod.id),
                                ),
                              );
                            },
                            childCount: ctrl.modules.length,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.15,
                          ),
                        );
                      }),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],
                ),
              ),

              // Bottom bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: BoxDecoration(
                  color: colors.bg0,
                  border: Border(
                      top: BorderSide(
                          color: colors.textPrimary.changeOpacity(0.06))),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Submit error — only show real errors, not loading status strings
                    Obx(() {
                      final err = ctrl.error.value;
                      // Hide during loading (status messages) or when modules aren't loaded yet
                      if (err == null || ctrl.modules.isEmpty || ctrl.isLoading.value) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: colors.error.changeOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: colors.error.changeOpacity(0.3)),
                        ),
                        child: Text(err,
                            style: styles.s13w400Error,
                            textAlign: TextAlign.center),
                      );
                    }),
                    // Submit button
                    Obx(
                      () => AppButton(
                        title: AppStrings.setUpWorkspace,
                        isLoading: ctrl.isLoading.value,
                        enabled: ctrl.selected.isNotEmpty,
                        onPressed: ctrl.submit,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      title: AppStrings.toDemo,
                      onPressed: () => Get.toNamed(AppRoutes.waiting),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Module card

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.selected,
    required this.iconData,
    required this.onTap,
  });

  final ModuleModel module;
  final bool selected;
  final IconData iconData;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;

    final gradientColors = [
      HexColor.fromHex(module.gradientStart),
      HexColor.fromHex(module.gradientEnd),
    ];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected ? Colors.transparent : colors.bg1,
          gradient: selected
              ? LinearGradient(
                  colors: [
                    gradientColors[0].changeOpacity(0.18),
                    gradientColors[1].changeOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: Border.all(
            color: selected
                ? gradientColors[0].changeOpacity(0.7)
                : colors.textPrimary.changeOpacity(0.07),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(iconData, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    module.title,
                    style: styles.s14w700White.copyWith(
                      color: selected
                          ? colors.textPrimary
                          : colors.textPrimary.changeOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    module.subtitle,
                    style: styles.s11w400Muted,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (selected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: gradientColors),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
