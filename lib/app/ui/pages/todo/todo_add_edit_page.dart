import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../controllers/todo_controller.dart';
import '../../../data/services/tenant_service.dart';
import '../../../utils/helpers/extensions.dart';
import '../../../utils/helpers/injectable/injectable.dart';

class TodoAddEditPage extends StatefulWidget {
  const TodoAddEditPage({super.key});

  @override
  State<TodoAddEditPage> createState() => _TodoAddEditPageState();
}

class _TodoAddEditPageState extends State<TodoAddEditPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSaving = false;

  /// Tenant client for the todo module's own Supabase project.
  /// Falls back to main client when not yet initialised.
  SupabaseClient get _db {
    final tenant = getIt<TenantService>().client;
    return tenant ?? Supabase.instance.client;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      // Auth lives on the main project; data lives on the tenant project.
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      await _db.from('todos').insert({
        'title': title,
        'description': _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        'status': 'pending',
        'user_id': user.id,
      });
      await GetIt.instance<TodoController>().fetchTodos();
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to create task: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: colors.primary),
                  )
                : Text('Save',
                    style: styles.s14w500White
                        .copyWith(color: colors.primary)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: styles.s16w600White,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Task title',
                hintStyle: styles.s16w600White
                    .copyWith(color: colors.textPrimary.changeOpacity(0.3)),
                border: InputBorder.none,
              ),
            ),
            Divider(color: colors.textPrimary.changeOpacity(0.08)),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              style: styles.s14w400White,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Description (optional)',
                hintStyle: styles.s14w400Muted,
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
