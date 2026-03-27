import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/profile_controller.dart';
import '../../../utils/helpers/extensions.dart';
import '../../../utils/themes/app_colors.dart';
import '../../../utils/themes/app_styles.dart';
import '../../widgets/get_it_hook.dart';
import '../../widgets/system_ui_overlay.dart';

class ProfilePage extends GetItHook<ProfileController> {
  const ProfilePage({super.key});

  @override
  bool get autoDispose => false;

  @override
  Widget build(BuildContext context) {
    return DarkSystemUiOverlayStyle(child: _Body(controller: controller));
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.controller});
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;

    return Scaffold(
      backgroundColor: colors.bg0,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: styles.s28w700White),
              const SizedBox(height: 24),

              // ── User card ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.bg1,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: colors.textPrimary.changeOpacity(0.07)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: colors.primaryGradientDiagonal,
                      ),
                      child: Center(
                        child: Text(
                          controller.userName.isNotEmpty
                              ? controller.userName[0].toUpperCase()
                              : 'U',
                          style:
                              styles.s24w700White.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(controller.userName, style: styles.s16w600White),
                          const SizedBox(height: 3),
                          Text(controller.userEmail,
                              style: styles.s13w400Muted),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Active modules ─────────────────────────────────────────
              _SectionLabel(label: 'Active Modules', colors: colors, styles: styles),
              const SizedBox(height: 10),
              Obx(() {
                final ids = controller.activeModuleIds;
                if (ids.isEmpty) {
                  return _InfoTile(
                    icon: Icons.info_outline_rounded,
                    label: 'No modules selected',
                    sublabel: 'Tap below to select modules',
                    colors: colors,
                    styles: styles,
                  );
                }
                return Column(
                  children: ids
                      .map((id) =>
                          _ModuleChip(id: id, colors: colors, styles: styles))
                      .toList(),
                );
              }),
              const SizedBox(height: 8),
              _ActionTile(
                icon: Icons.swap_horiz_rounded,
                label: 'Switch / Add Modules',
                iconColor: colors.primary,
                colors: colors,
                styles: styles,
                onTap: controller.switchModules,
              ),

              const SizedBox(height: 24),

              // ── Settings ───────────────────────────────────────────────
              _SectionLabel(label: 'Settings', colors: colors, styles: styles),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.language_rounded,
                label: 'Language',
                sublabel: 'Change app language',
                colors: colors,
                styles: styles,
                onTap: () => Get.toNamed('/language'),
              ),
              const SizedBox(height: 6),
              _ActionTile(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                sublabel: 'Coming soon',
                colors: colors,
                styles: styles,
                onTap: () => Get.snackbar(
                  'Coming Soon',
                  'Notification settings coming soon.',
                  snackPosition: SnackPosition.BOTTOM,
                ),
              ),

              const SizedBox(height: 24),

              // ── Account ────────────────────────────────────────────────
              _SectionLabel(label: 'Account', colors: colors, styles: styles),
              const SizedBox(height: 10),
              Obx(() => _ActionTile(
                    icon: Icons.logout_rounded,
                    label: controller.isSigningOut.value
                        ? 'Signing out…'
                        : 'Sign Out',
                    iconColor: colors.error,
                    labelColor: colors.error,
                    colors: colors,
                    styles: styles,
                    onTap: controller.isSigningOut.value
                        ? null
                        : controller.signOut,
                  )),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable sub-widgets ─────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(
      {required this.label, required this.colors, required this.styles});
  final String label;
  final AppColors colors;
  final AppStyles styles;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: styles.s13w600Primary.copyWith(
        letterSpacing: 1.1,
        color: colors.textPrimary.changeOpacity(0.45),
        fontSize: 11,
      ),
    );
  }
}

class _ModuleChip extends StatelessWidget {
  const _ModuleChip(
      {required this.id, required this.colors, required this.styles});
  final String id;
  final AppColors colors;
  final AppStyles styles;

  IconData _icon(String id) {
    switch (id.toLowerCase()) {
      case 'todo':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.widgets_outlined;
    }
  }

  String _label(String id) {
    switch (id.toLowerCase()) {
      case 'todo':
        return 'To-Do';
      default:
        return id.toCapitalized;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.primary.changeOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.primary.changeOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(_icon(id), color: colors.primary, size: 18),
          const SizedBox(width: 10),
          Text(_label(id), style: styles.s14w500White),
          const Spacer(),
          Icon(Icons.check_rounded, color: colors.success, size: 16),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    this.sublabel,
    required this.colors,
    required this.styles,
  });
  final IconData icon;
  final String label;
  final String? sublabel;
  final AppColors colors;
  final AppStyles styles;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: colors.bg1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.textPrimary.changeOpacity(0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.textPrimary.changeOpacity(0.4), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: styles.s14w400White),
              if (sublabel != null) Text(sublabel!, style: styles.s11w400Muted),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    this.sublabel,
    this.iconColor,
    this.labelColor,
    required this.colors,
    required this.styles,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String? sublabel;
  final Color? iconColor;
  final Color? labelColor;
  final AppColors colors;
  final AppStyles styles;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: colors.bg1,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.textPrimary.changeOpacity(0.06)),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: iconColor ?? colors.textPrimary.changeOpacity(0.55),
                size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: styles.s14w500White
                          .copyWith(color: labelColor)),
                  if (sublabel != null)
                    Text(sublabel!, style: styles.s11w400Muted),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: colors.textPrimary.changeOpacity(0.25), size: 20),
          ],
        ),
      ),
    );
  }
}
