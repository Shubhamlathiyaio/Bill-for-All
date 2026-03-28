import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../controllers/main_shell_controller.dart';
import '../../../data/models/todo_model.dart';
import '../../../utils/helpers/extensions.dart';
import '../../../utils/helpers/injectable/injectable.dart';
import '../../../utils/themes/app_colors.dart';
import '../../../utils/themes/app_styles.dart';
import '../../widgets/get_it_hook.dart';
import '../../widgets/system_ui_overlay.dart';

class DashboardPage extends GetItHook<DashboardController> {
  const DashboardPage({super.key});

  @override
  bool get autoDispose => false;

  @override
  Widget build(BuildContext context) {
    return DarkSystemUiOverlayStyle(child: _Body(controller: controller));
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.controller});
  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;
    final shell = getIt<MainShellController>();

    return Scaffold(
      backgroundColor: colors.bg0,
      body: SafeArea(
        child: RefreshIndicator(
          color: colors.primary,
          backgroundColor: colors.bg1,
          onRefresh: controller.refreshData,
          child: CustomScrollView(
            slivers: [
              // ── Header ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dashboard', style: styles.s28w700White),
                            const SizedBox(height: 4),
                            Obx(() {
                              final count = shell.activeModuleIds.length;
                              return Text(
                                '$count module${count == 1 ? '' : 's'} active',
                                style: styles.s13w400Muted,
                              );
                            }),
                          ],
                        ),
                      ),
                      Obx(() => controller.isRefreshing.value
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: colors.primary),
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),
              ),

              // ── Module sections ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Obx(() {
                  final ids = shell.activeModuleIds;
                  if (ids.isEmpty) {
                    return _NoModulesBanner(colors: colors, styles: styles);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ids.contains('todo'))
                        _TodoSummarySection(
                          controller: controller,
                          colors: colors,
                          styles: styles,
                        ),
                      const SizedBox(height: 24),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── No modules banner ────────────────────────────────────────────────────────

class _NoModulesBanner extends StatelessWidget {
  const _NoModulesBanner({required this.colors, required this.styles});
  final AppColors colors;
  final AppStyles styles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.primary.changeOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.primary.changeOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(Icons.widgets_outlined,
                size: 48, color: colors.primary.changeOpacity(0.4)),
            const SizedBox(height: 12),
            Text('No modules selected',
                style: styles.s16w600White, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              'Go to Profile → Switch Modules to add modules.',
              style: styles.s13w400Muted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Todo summary section ─────────────────────────────────────────────────────

class _TodoSummarySection extends StatelessWidget {
  const _TodoSummarySection({
    required this.controller,
    required this.colors,
    required this.styles,
  });
  final DashboardController controller;
  final AppColors colors;
  final AppStyles styles;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = controller.totalTodos;
      final pending = controller.pendingTodos;
      final done = controller.completedTodos;
      final recent = controller.recentTodos.cast<TodoModel>();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        HexColor.fromHex('#6C63FF'),
                        HexColor.fromHex('#9B59B6'),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.check_circle_outline_rounded,
                      color: Colors.white, size: 17),
                ),
                const SizedBox(width: 10),
                Text('To-Do', style: styles.s16w600White),
              ],
            ),
            const SizedBox(height: 14),

            // Stats row
            Row(
              children: [
                _StatCard(
                    label: 'Total',
                    value: '$total',
                    color: colors.primary,
                    styles: styles),
                const SizedBox(width: 10),
                _StatCard(
                    label: 'Pending',
                    value: '$pending',
                    color: colors.warning,
                    styles: styles),
                const SizedBox(width: 10),
                _StatCard(
                    label: 'Done',
                    value: '$done',
                    color: colors.success,
                    styles: styles),
              ],
            ),

            // Recent tasks
            if (recent.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Recent Tasks', style: styles.s14w500White),
              const SizedBox(height: 10),
              ...recent.map((todo) =>
                  _RecentTodoRow(todo: todo, colors: colors, styles: styles)),
            ],
          ],
        ),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.styles,
  });
  final String label;
  final String value;
  final Color color;
  final AppStyles styles;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.changeOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.changeOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: styles.s24w700White.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(label, style: styles.s11w400Muted),
          ],
        ),
      ),
    );
  }
}

class _RecentTodoRow extends StatelessWidget {
  const _RecentTodoRow(
      {required this.todo, required this.colors, required this.styles});
  final TodoModel todo;
  final AppColors colors;
  final AppStyles styles;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.bg1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.textPrimary.changeOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(
            todo.isDone
                ? Icons.check_circle_rounded
                : todo.isInProgress
                    ? Icons.play_circle_fill_rounded
                    : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: todo.isDone
                ? colors.success
                : todo.isInProgress
                    ? colors.warning
                    : colors.textPrimary.changeOpacity(0.3),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              todo.title,
              style: styles.s14w400White.copyWith(
                fontSize: 13,
                decoration: todo.isDone ? TextDecoration.lineThrough : null,
                color: todo.isDone
                    ? colors.textPrimary.changeOpacity(0.4)
                    : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
