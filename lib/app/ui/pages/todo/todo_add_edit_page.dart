import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/todo_controller.dart';
import '../../../utils/helpers/extensions.dart';
import '../../../utils/helpers/injectable/injectable.dart';

/// Pure StatelessWidget — all state lives in [TodoController].
/// Call [TodoController.resetForm()] before pushing this route.
class TodoAddEditPage extends StatelessWidget {
  const TodoAddEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = getIt<TodoController>();
    final colors = context.colors;
    final styles = context.styles;

    return Scaffold(
      backgroundColor: colors.bg0,
      appBar: AppBar(
        title: Text('New Task', style: styles.s18w700White),
        backgroundColor: colors.bg0,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded,
              color: colors.textPrimary.changeOpacity(0.8)),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            // Obx so the Save button reacts to formIsSaving
            child: Obx(() {
              final saving = ctrl.formIsSaving.value;
              return TextButton(
                onPressed: saving ? null : ctrl.saveNewTodo,
                child: saving
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: colors.primary),
                      )
                    : Text('Save',
                        style: styles.s14w500White
                            .copyWith(color: colors.primary)),
              );
            }),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──────────────────────────────────────────────────────
            TextField(
              controller: ctrl.titleCtrl,
              style: styles.s16w600White,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'What needs to be done?',
                hintStyle: styles.s16w600White
                    .copyWith(color: colors.textPrimary.changeOpacity(0.3)),
                border: InputBorder.none,
              ),
            ),
            Divider(color: colors.textPrimary.changeOpacity(0.08)),

            // ── Description ────────────────────────────────────────────────
            TextField(
              controller: ctrl.descCtrl,
              style: styles.s14w400White,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Add a description...',
                hintStyle: styles.s14w400White
                    .copyWith(color: colors.textPrimary.changeOpacity(0.3)),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),

            // ── Due Date ───────────────────────────────────────────────────
            // Obx so the date label reacts to formDueDate
            Obx(() {
              final due = ctrl.formDueDate.value;
              return InkWell(
                onTap: () => ctrl.pickDueDate(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.bg1,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: colors.textPrimary.changeOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 20, color: colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          due == null
                              ? 'Set Due Date'
                              : '${due.day}/${due.month}/${due.year}',
                          style: styles.s14w500White.copyWith(
                            color: due == null
                                ? colors.textPrimary.changeOpacity(0.5)
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                      if (due != null)
                        GestureDetector(
                          onTap: () => ctrl.formDueDate.value = null,
                          child: Icon(Icons.close_rounded,
                              size: 20,
                              color: colors.textPrimary.changeOpacity(0.5)),
                        ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // ── Category ───────────────────────────────────────────────────
            Text(
              'Category',
              style: styles.s14w500White.copyWith(
                  color: colors.textPrimary.changeOpacity(0.7)),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (ctrl.isCategoriesLoading.value) {
                return Center(
                    child: CircularProgressIndicator(color: colors.primary));
              }
              if (ctrl.categories.isEmpty) {
                return Text('No categories yet.', style: styles.s13w400Muted);
              }
              final selectedId = ctrl.formCategoryId.value;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ctrl.categories.map((cat) {
                  final isSelected = selectedId == cat.id;
                  final catColor =
                      ctrl.parseHexColor(cat.color, colors.primary);
                  return GestureDetector(
                    onTap: () => ctrl.toggleFormCategory(cat.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? catColor.changeOpacity(0.2)
                            : colors.bg1,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? catColor
                              : colors.textPrimary.changeOpacity(0.05),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.label_rounded,
                            size: 16,
                            color: isSelected
                                ? catColor
                                : colors.textPrimary.changeOpacity(0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat.name,
                            style: styles.s14w500White.copyWith(
                              fontSize: 12,
                              color: isSelected
                                  ? catColor
                                  : colors.textPrimary.changeOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
