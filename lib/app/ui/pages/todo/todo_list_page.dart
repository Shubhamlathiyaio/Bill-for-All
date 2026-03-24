import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/todo_controller.dart';
import '../../../utils/helpers/extensions.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller should be registered in GetX bindings, or we can use Get.put
    final controller = Get.put(TodoController(Get.find()));
    final colors = context.colors;
    final styles = context.styles;

    return Scaffold(
      backgroundColor: colors.bg0,
      appBar: AppBar(
        title: Text('Tasks', style: styles.s14w500White.copyWith(fontSize: 18)),
        backgroundColor: colors.bg1,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.sort_rounded, color: colors.white.changeOpacity(0.8)),
            onPressed: () {
              // Toggles are handled inherently by the getter based on data
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Obx(() => Row(
              children: ['All', 'Pending', 'In-Progress', 'Completed'].map((filter) {
                final isSelected = controller.currentFilter.value.toLowerCase() == filter.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      filter, 
                      style: isSelected ? styles.s13w600Primary : styles.s13w400Muted
                    ),
                    selected: isSelected,
                    onSelected: (val) {
                      controller.setFilter(filter);
                    },
                    backgroundColor: colors.bg1,
                    selectedColor: colors.primary.changeOpacity(0.15),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? colors.primary : colors.white.changeOpacity(0.1),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
          ),
          
          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.todos.isEmpty) {
                return Center(child: CircularProgressIndicator(color: colors.primary));
              }
              
              final list = controller.filteredTodos;
              if (list.isEmpty) {
                return Center(
                  child: Text('No tasks found.', style: styles.s14w400Muted),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final todo = list[index];
                  final cat = controller.categories.firstWhereOrNull((c) => c.id == todo.categoryId)?.name ?? 'General';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.bg1,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.white.changeOpacity(0.05)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status toggle
                        GestureDetector(
                          onTap: () => controller.toggleStatus(todo),
                          child: Icon(
                            todo.status == 'completed' ? Icons.check_circle_rounded 
                              : todo.status == 'in-progress' ? Icons.play_circle_fill_rounded 
                              : Icons.radio_button_unchecked_rounded,
                            color: todo.status == 'completed' ? colors.success
                              : todo.status == 'in-progress' ? colors.warning
                              : colors.white.changeOpacity(0.3),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(todo.title, style: styles.s14w500White.copyWith(
                                decoration: todo.status == 'completed' ? TextDecoration.lineThrough : null,
                                color: todo.status == 'completed' ? colors.textPrimary.changeOpacity(0.5) : colors.textPrimary,
                                fontSize: 15,
                              )),
                              if (todo.description != null && todo.description!.trim().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(todo.description!, style: styles.s13w400Muted),
                              ],
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  // Category badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: colors.white.changeOpacity(0.05),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(cat, style: styles.s14w400White.copyWith(
                                      color: colors.textPrimary.changeOpacity(0.6),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    )),
                                  ),
                                  const Spacer(),
                                  // Due date
                                  if (todo.dueDate != null) ...[
                                    Icon(Icons.calendar_today_rounded, size: 12, color: colors.white.changeOpacity(0.4)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${todo.dueDate!.day}/${todo.dueDate!.month}',
                                      style: styles.s14w400White.copyWith(
                                        color: colors.textPrimary.changeOpacity(0.4),
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
                        // Delete Button
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            icon: Icon(Icons.delete_outline_rounded, size: 20, color: colors.error.changeOpacity(0.7)),
                            onPressed: () => controller.deleteTodo(todo.id),
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
        onPressed: () {
          Get.toNamed('/todo-add-edit');
        },
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
