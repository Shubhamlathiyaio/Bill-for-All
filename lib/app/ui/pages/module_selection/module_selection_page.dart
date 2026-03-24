import 'package:bill_for_all/app/utils/helpers/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/module_selection_controller.dart';
import '../../widgets/get_it_hook.dart';
import '../../widgets/system_ui_overlay.dart';
import '../../widgets/app_button.dart';
import '../../../utils/constants/app_strings.dart';

class ModuleSelectionPage extends GetItHook<ModuleSelectionController> {
  const ModuleSelectionPage({super.key});

  @override
  bool get autoDispose => true;

  @override
  Widget build(BuildContext context) {
    return OnboardingSystemUiOverlayStyle(
      child: _ModuleBody(controller: controller),
    );
  }
}

// One-time animated shell
class _ModuleBody extends StatefulWidget {
  const _ModuleBody({required this.controller});
  final ModuleSelectionController controller;

  @override
  State<_ModuleBody> createState() => _ModuleBodyState();
}

class _ModuleBodyState extends State<_ModuleBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const _modules = [
    _Module(id: 'crm', title: 'CRM', subtitle: 'Manage customers & pipelines', icon: Icons.people_alt_outlined, gradient: [Color(0xFF6C63FF), Color(0xFF9B59B6)]),
    _Module(id: 'inventory', title: 'Inventory', subtitle: 'Track products & stock levels', icon: Icons.inventory_2_outlined, gradient: [Color(0xFF3ECFCF), Color(0xFF2980B9)]),
    _Module(id: 'invoicing', title: 'Invoicing', subtitle: 'Create and send invoices', icon: Icons.receipt_long_outlined, gradient: [Color(0xFFFF6B6B), Color(0xFFFF8E53)]),
    _Module(id: 'hr', title: 'HR & Payroll', subtitle: 'Employee management & payroll', icon: Icons.badge_outlined, gradient: [Color(0xFF2ECC71), Color(0xFF1ABC9C)]),
    _Module(id: 'projects', title: 'Projects', subtitle: 'Tasks, boards & milestones', icon: Icons.dashboard_outlined, gradient: [Color(0xFFF39C12), Color(0xFFE67E22)]),
    _Module(id: 'analytics', title: 'Analytics', subtitle: 'Reports, charts & insights', icon: Icons.bar_chart_rounded, gradient: [Color(0xFF6C63FF), Color(0xFF3ECFCF)]),
    _Module(id: 'support', title: 'Support Desk', subtitle: 'Tickets & customer support', icon: Icons.headset_mic_outlined, gradient: [Color(0xFFEC407A), Color(0xFFAB47BC)]),
    _Module(id: 'accounting', title: 'Accounting', subtitle: 'Books, ledgers & tax', icon: Icons.account_balance_outlined, gradient: [Color(0xFF26A69A), Color(0xFF00BCD4)]),
  ];

  ModuleSelectionController get ctrl => widget.controller;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_animController);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
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
                            Text(AppStrings.pickModules, style: styles.s28w700White),
                            const SizedBox(height: 8),
                            Text(AppStrings.pickModulesSub, style: styles.s14w400Muted),
                            Obx(() {
                              final count = ctrl.selected.length;
                              if (count == 0) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  AppStrings.modulesSelected(count),
                                  style: styles.s13w600Primary,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            final mod = _modules[i];
                            return Obx(() => _ModuleCard(
                                  module: mod,
                                  selected: ctrl.isSelected(mod.id),
                                  onTap: () => ctrl.toggleModule(mod.id),
                                ));
                          },
                          childCount: _modules.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.15,
                        ),
                      ),
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
                    top: BorderSide(color: colors.white.changeOpacity(0.06)),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() {
                      final err = ctrl.error.value;
                      if (err == null) return const SizedBox.shrink();
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: colors.error.changeOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colors.error.changeOpacity(0.3)),
                        ),
                        child: Text(err,
                            style: styles.s13w400Error,
                            textAlign: TextAlign.center),
                      );
                    }),
                    Obx(() => AppButton(
                          title: AppStrings.setUpWorkspace,
                          isLoading: ctrl.isLoading.value,
                          enabled: ctrl.selected.isNotEmpty,
                          onPressed: ctrl.submit,
                        )),
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

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module, required this.selected, required this.onTap});
  final _Module module;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;

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
                    module.gradient[0].changeOpacity(0.18),
                    module.gradient[1].changeOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: Border.all(
            color: selected
                ? module.gradient[0].changeOpacity(0.7)
                : colors.white.changeOpacity(0.07),
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
                        colors: module.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(module.icon, color: Colors.white, size: 20),
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
                  Text(module.subtitle, style: styles.s11w400Muted, maxLines: 2, overflow: TextOverflow.ellipsis),
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
                    gradient: LinearGradient(colors: module.gradient),
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Module {
  const _Module({required this.id, required this.title, required this.subtitle, required this.icon, required this.gradient});
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
}
