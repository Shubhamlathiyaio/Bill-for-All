import 'package:bill_for_all/app/data/services/todo_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/todo_controller.dart';
import '../../../data/models/todo_model.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/helpers/extensions.dart';
import '../../../utils/helpers/injectable/injectable.dart';
import '../../../utils/themes/app_colors.dart';
import '../../../utils/themes/app_styles.dart';
import '../../widgets/get_it_hook.dart';

/// Unified Todo page for the module.
/// Replaces the previous multi-tab (Dashboard/Tasks) approach for simplicity.
class TodoModulePage extends GetItHook<TodoController> {
  const TodoModulePage({super.key});

  @override
  bool get autoDispose => false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;

    return Scaffold(
      backgroundColor: colors.bg0,
      body: SafeArea(
        child: RefreshIndicator(
          color: colors.primary,
          backgroundColor: colors.bg1,
          onRefresh: () async {
            await TodoService().getTodos();
          }, //controller.fetchTodos,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [HexColor.fromHex('#6C63FF'), HexColor.fromHex('#9B59B6')],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('To-Do', style: styles.s24w700White),
                          Obx(() {
                            final total = controller.totalCount;
                            return Text('$total task${total == 1 ? '' : 's'} total', style: styles.s13w400Muted);
                          }),
                        ],
                      ),
                      const Spacer(),
                      Obx(
                        () => controller.isLoading.value
                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary))
                            : IconButton(
                                onPressed: controller.fetchTodos,
                                icon: Icon(Icons.refresh_rounded, color: colors.textPrimary.changeOpacity(0.5), size: 22),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Stats Row ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Obx(() {
                  final total = controller.totalCount;
                  final pending = controller.pendingCount;
                  final done = controller.doneCount;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _StatCard(label: 'Total', value: '$total', color: colors.primary, styles: styles),
                        const SizedBox(width: 10),
                        _StatCard(label: 'Pending', value: '$pending', color: colors.warning, styles: styles),
                        const SizedBox(width: 10),
                        _StatCard(label: 'Done', value: '$done', color: colors.success, styles: styles),
                      ],
                    ),
                  );
                }),
              ),

              // ── Filter Chips ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Obx(
                    () => Row(
                      children: ['All', 'Pending', 'In Progress', 'Done'].map((f) {
                        final sel = controller.currentFilter.value == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(f, style: sel ? styles.s13w600Primary : styles.s13w400Muted),
                            selected: sel,
                            onSelected: (_) => controller.setFilter(f),
                            backgroundColor: colors.bg1,
                            selectedColor: colors.primary.changeOpacity(0.15),
                            showCheckmark: false,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: sel ? colors.primary : colors.textPrimary.changeOpacity(0.1)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // ── Task List ─────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: Obx(() {
                  // Loading state
                  if (controller.isLoading.value && controller.todos.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final list = controller.filteredTodos;

                  // Empty state
                  if (list.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(colors: colors, styles: styles),
                    );
                  }

                  // The list
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((_, i) {
                      if (i == list.length) return const SizedBox(height: 80);
                      return _TodoRow(
                        todo: list[i],
                        colors: colors,
                        styles: styles,
                        onToggle: () => controller.toggleStatus(list[i]),
                        onDelete: () => controller.deleteTodo(list[i].id),
                      );
                    }, childCount: list.length + 1),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        onPressed: () => Get.toNamed(AppRoutes.todoAddEdit),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color, required this.styles});
  final String label;
  final String value;
  final Color color;
  final AppStyles styles;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.changeOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.changeOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: styles.s24w700White.copyWith(color: color, fontSize: 20)),
            const SizedBox(height: 3),
            Text(label, style: styles.s11w400Muted),
          ],
        ),
      ),
    );
  }
}

class _TodoRow extends StatelessWidget {
  const _TodoRow({required this.todo, required this.colors, required this.styles, required this.onToggle, required this.onDelete});

  final TodoModel todo;
  final AppColors colors;
  final AppStyles styles;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  Color? _parseCatColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = getIt<TodoController>();
    final cat = ctrl.categories.firstWhereOrNull((c) => c.id == todo.categoryId);
    final catColor = cat != null ? _parseCatColor(cat.color) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.textPrimary.changeOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status toggle
          GestureDetector(
            onTap: onToggle,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                todo.isDone
                    ? Icons.check_circle_rounded
                    : todo.isInProgress
                    ? Icons.play_circle_fill_rounded
                    : Icons.radio_button_unchecked_rounded,
                key: ValueKey(todo.status),
                size: 22,
                color: todo.isDone
                    ? colors.success
                    : todo.isInProgress
                    ? colors.warning
                    : colors.textPrimary.changeOpacity(0.3),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: styles.s14w500White.copyWith(
                    decoration: todo.isDone ? TextDecoration.lineThrough : null,
                    color: todo.isDone ? colors.textPrimary.changeOpacity(0.4) : colors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (todo.description != null && todo.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(todo.description!, style: styles.s13w400Muted.copyWith(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                if (todo.dueDate != null || cat != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (cat != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: (catColor ?? colors.primary).changeOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            cat.name,
                            style: styles.s13w400Muted.copyWith(fontSize: 10, fontWeight: FontWeight.w600, color: catColor ?? colors.primary),
                          ),
                        ),
                      if (todo.dueDate != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_outlined, size: 12, color: colors.textPrimary.changeOpacity(0.4)),
                            const SizedBox(width: 4),
                            Text(
                              '${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}',
                              style: styles.s13w400Muted.copyWith(fontSize: 10, color: colors.textPrimary.changeOpacity(0.4)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Delete
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              icon: Icon(Icons.delete_outline_rounded, size: 18, color: colors.error.changeOpacity(0.6)),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors, required this.styles});
  final AppColors colors;
  final AppStyles styles;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 56, color: colors.textPrimary.changeOpacity(0.15)),
          const SizedBox(height: 16),
          Text('No tasks here.', style: styles.s14w400Muted),
          const SizedBox(height: 6),
          Text('Tap + to add one.', style: styles.s13w400Muted),
        ],
      ),
    );
  }
}
