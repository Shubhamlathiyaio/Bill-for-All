import 'package:bill_for_all/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/module_selection_controller.dart';
import '../../../data/models/module_model.dart';
import '../../../utils/constants/app_strings.dart';
import '../../../utils/helpers/extensions.dart';
import '../../widgets/app_button.dart';
import '../../widgets/get_it_hook.dart';

class ModuleSelectionPage extends StatefulWidget {
  const ModuleSelectionPage({super.key});

  @override
  State<ModuleSelectionPage> createState() => _ModuleSelectionPageState();
}

class _ModuleSelectionPageState
    extends GetItHookState<ModuleSelectionController, ModuleSelectionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  bool get autoDispose => true;

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
                        padding: const .fromLTRB(24, 40, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const .all(10),
                              decoration: BoxDecoration(
                                  color: colors.primary.changeOpacity(0.12),
                                  borderRadius: .circular(12)),
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
                              final count = controller.selected.length;
                              if (count == 0) return const SizedBox.shrink();
                              return Padding(
                                padding: const .only(top: 12),
                                child: Text(AppStrings.modulesSelected(count),
                                    style: styles.s13w600Primary),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    // Module grid
                    SliverPadding(
                      padding:
                          const .symmetric(horizontal: 20, vertical: 8),
                      sliver: Obx(() {
                        // Loading
                        if (controller.isFetchingModules.value) {
                          return const SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                  padding: .all(40),
                                  child: CircularProgressIndicator()),
                            ),
                          );
                        }

                        // Error with retry
                        if (controller.error.value != null &&
                            controller.modules.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: const .symmetric(
                                  vertical: 40, horizontal: 16),
                              child: Column(
                                mainAxisSize: .min,
                                children: [
                                  Icon(Icons.cloud_off_rounded,
                                      size: 48,
                                      color:
                                          colors.textPrimary.changeOpacity(0.3)),
                                  const SizedBox(height: 16),
                                  Text(controller.error.value!,
                                      style: styles.s14w400Muted,
                                      textAlign: .center),
                                  const SizedBox(height: 20),
                                  TextButton.icon(
                                      onPressed: controller.retryFetch,
                                      icon: const Icon(Icons.refresh_rounded),
                                      label: const Text('Retry')),
                                ],
                              ),
                            ),
                          );
                        }

                        // Empty
                        if (controller.modules.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const .all(40),
                                child: Text('No modules available.',
                                    style: styles.s14w400Muted),
                              ),
                            ),
                          );
                        }

                        // Grid
                        return SliverGrid(
                          delegate: SliverChildBuilderDelegate((_, i) {
                            final mod = controller.modules[i];
                            return Obx(
                              () => _ModuleCard(
                                module: mod,
                                selected: controller.isSelected(mod.id),
                                iconData: _iconFor(mod.iconName),
                                onTap: () => controller.toggleModule(mod.id),
                              ),
                            );
                          }, childCount: controller.modules.length),
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
                padding: const .fromLTRB(20, 12, 20, 24),
                decoration: BoxDecoration(
                  color: colors.bg0,
                  border: Border(
                      top: BorderSide(
                          color: colors.textPrimary.changeOpacity(0.06))),
                ),
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    // Submit error — only show real errors, not loading status strings
                    Obx(() {
                      final err = controller.error.value;
                      // Hide during loading (status messages) or when modules aren't loaded yet
                      if (err == null ||
                          controller.modules.isEmpty ||
                          controller.isLoading.value) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        width: .infinity,
                        padding: const .all(12),
                        margin: const .only(bottom: 12),
                        decoration: BoxDecoration(
                          color: colors.error.changeOpacity(0.1),
                          borderRadius: .circular(10),
                          border: .all(
                              color: colors.error.changeOpacity(0.3)),
                        ),
                        child: Text(err,
                            style: styles.s13w400Error,
                            textAlign: .center),
                      );
                    }),
                    // Submit button
                    Obx(
                      () => AppButton(
                        title: AppStrings.setUpWorkspace,
                        isLoading: controller.isLoading.value,
                        enabled: controller.selected.isNotEmpty,
                        onPressed: controller.submit,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                        title: AppStrings.toDemo,
                        onPressed: () => Get.toNamed(AppRoutes.waiting)),
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
  const _ModuleCard(
      {required this.module,
      required this.selected,
      required this.iconData,
      required this.onTap});

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
      HexColor.fromHex(module.gradientEnd)
    ];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: .circular(16),
          color: selected ? Colors.transparent : colors.bg1,
          gradient: selected
              ? LinearGradient(
                  colors: [
                      gradientColors[0].changeOpacity(0.18),
                      gradientColors[1].changeOpacity(0.08)
                    ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)
              : null,
          border: .all(
              color: selected
                  ? gradientColors[0].changeOpacity(0.7)
                  : colors.textPrimary.changeOpacity(0.07),
              width: selected ? 1.5 : 1),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const .all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: .circular(10),
                      gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                    ),
                    child: Icon(iconData, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  Text(module.title,
                      style: styles.s14w700White.copyWith(
                          color: selected
                              ? colors.textPrimary
                              : colors.textPrimary.changeOpacity(0.85))),
                  const SizedBox(height: 3),
                  Text(module.subtitle,
                      style: styles.s11w400Muted,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
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
