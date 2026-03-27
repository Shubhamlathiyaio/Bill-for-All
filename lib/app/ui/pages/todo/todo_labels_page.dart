import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/todo_controller.dart';
import '../../../utils/helpers/extensions.dart';
import '../../widgets/get_it_hook.dart';
import '../../widgets/system_ui_overlay.dart';

class TodoLabelsPage extends GetItHook<TodoController> {
  const TodoLabelsPage({super.key});

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text('Labels', style: styles.s24w700White),
            ),
            Expanded(
              child: Obx(() {
                final cats = controller.categories;
                if (cats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.label_outline_rounded,
                            size: 56,
                            color: colors.textPrimary.changeOpacity(0.15)),
                        const SizedBox(height: 16),
                        Text('No labels yet.', style: styles.s14w400Muted),
                        const SizedBox(height: 8),
                        Text(
                          'Labels help you organise tasks.',
                          style: styles.s13w400Muted,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  itemCount: cats.length,
                  itemBuilder: (_, i) {
                    final cat = cats[i];
                    final count = controller.todos
                        .where((t) => t.categoryId == cat.id)
                        .length;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: colors.bg1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: colors.textPrimary.changeOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.primary.changeOpacity(0.12),
                            ),
                            child: Icon(Icons.label_rounded,
                                color: colors.primary, size: 18),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(cat.name,
                                style: styles.s14w500White),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors.primary.changeOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$count task${count == 1 ? '' : 's'}',
                              style: styles.s13w600Primary,
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        onPressed: () {
          // TODO: show add-label dialog
          Get.snackbar('Coming Soon', 'Add label feature coming soon.',
              snackPosition: SnackPosition.BOTTOM);
        },
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
