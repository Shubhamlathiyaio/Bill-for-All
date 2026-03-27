import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/todo_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/helpers/extensions.dart';
import '../../widgets/get_it_hook.dart';
import '../../widgets/system_ui_overlay.dart';

class TodoListPage extends GetItHook<TodoController> {
  const TodoListPage({super.key});

  @override
  bool get autoDispose => false;

  @override
  Widget build(BuildContext context) {
    return DarkSystemUiOverlayStyle(child: _Body(controller: controller));
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.controller});
  final TodoController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;

    return Scaffold(
      backgroundColor: colors.bg0,
      appBar: AppBar(
        title: Text('Tasks', style: styles.s14w500White.copyWith(fontSize: 18)),
        backgroundColor: colors.bg1,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: colors.textPrimary.changeOpacity(0.8)),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded,
                color: colors.textPrimary.changeOpacity(0.8)),
            onPressed: controller.fetchTodos,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter chips ─────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Obx(() => Row(
                  children: ['All', 'Pending', 'In-Progress', 'Completed']
                      .map((f) {
                    final sel = controller.currentFilter.value
                            .toLowerCase() ==
                        f.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(f,
                            style: sel
                                ? styles.s13w600Primary
                                : styles.s13w400Muted),
                        selected: sel,
                        onSelected: (_) => controller.setFilter(f),
                        backgroundColor: colors.bg1,
                        selectedColor:
                            colors.primary.changeOpacity(0.15),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: sel
                                ? colors.primary
                                : colors.textPrimary.changeOpacity(0.1),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
          ),

          // ── Task list ────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.todos.isEmpty) {
                return Center(
                    child: CircularProgressIndicator(
                        color: colors.primary));
              }

              final list = controller.filteredTodos;

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 56,
                          color:
                              colors.textPrimary.changeOpacity(0.15)),
                      const SizedBox(height: 16),
                      Text('No tasks found.',
                          style: styles.s14w400Muted),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final todo = list[i];
                  final cat = controller.categories
                          .firstWhereOrNull(
                              (c) => c.id == todo.categoryId)
                          ?.name ??
                      'General';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.bg1,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              colors.textPrimary.changeOpacity(0.05)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status toggle
                        GestureDetector(
                          onTap: () =>
                              controller.toggleStatus(todo),
                          child: Icon(
                            todo.status == 'completed'
                                ? Icons.check_circle_rounded
                                : todo.status == 'in-progress'
                                    ? Icons.play_circle_fill_rounded
                                    : Icons
                                        .radio_button_unchecked_rounded,
                            color: todo.status == 'completed'
                                ? colors.success
                                : todo.status == 'in-progress'
                                    ? colors.warning
                                    : colors.textPrimary
                                        .changeOpacity(0.3),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                todo.title,
                                style:
                                    styles.s14w500White.copyWith(
                                  decoration:
                                      todo.status == 'completed'
                                          ? TextDecoration
                                              .lineThrough
                                          : null,
                                  color:
                                      todo.status == 'completed'
                                          ? colors.textPrimary
                                              .changeOpacity(0.5)
                                          : colors.textPrimary,
                                  fontSize: 15,
                                ),
                              ),
                              if (todo.description != null &&
                                  todo.description!
                                      .trim()
                                      .isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(todo.description!,
                                    style: styles.s13w400Muted),
                              ],
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  // Category badge
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4),
                                    decoration: BoxDecoration(
                                      color: colors.textPrimary
                                          .changeOpacity(0.05),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      cat,
                                      style: styles.s14w400White
                                          .copyWith(
                                        color: colors.textPrimary
                                            .changeOpacity(0.6),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  // Due date
                                  if (todo.dueDate != null) ...[
                                    Icon(
                                        Icons
                                            .calendar_today_rounded,
                                        size: 12,
                                        color: colors.textPrimary
                                            .changeOpacity(0.4)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${todo.dueDate!.day}/${todo.dueDate!.month}',
                                      style: styles.s14w400White
                                          .copyWith(
                                        color: colors.textPrimary
                                            .changeOpacity(0.4),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Delete
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            icon: Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color:
                                    colors.error.changeOpacity(0.7)),
                            onPressed: () =>
                                controller.deleteTodo(todo.id),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        onPressed: () => Get.toNamed(AppRoutes.todoAddEdit),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
