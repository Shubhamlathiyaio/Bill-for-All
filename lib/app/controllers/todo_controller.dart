import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/todo_model.dart';
import '../data/models/todo_category_model.dart';
import '../data/services/tenant_service.dart';
import '../utils/helpers/injectable/injectable.dart';

@lazySingleton
class TodoController extends GetxController {
  TodoController(this._storage);

  final GetStorage _storage;
  static const _kTodos = 'cached_todos';
  static const _kCategories = 'cached_categories';

  final todos = <TodoModel>[].obs;
  final categories = <TodoCategoryModel>[].obs;
  final isLoading = false.obs;
  final isCategoriesLoading = false.obs;

  // ── Form state (used by TodoAddEditPage) ─────────────────────────────────

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final formIsSaving = false.obs;
  final formDueDate = Rxn<DateTime>();
  final formCategoryId = Rxn<String>();

  /// Reset the add/edit form before opening the page.
  void resetForm() {
    titleCtrl.clear();
    descCtrl.clear();
    formIsSaving.value = false;
    formDueDate.value = null;
    formCategoryId.value = null;
  }

  /// Select or deselect a category chip.
  void toggleFormCategory(String id) {
    formCategoryId.value = formCategoryId.value == id ? null : id;
  }

  /// Save a new task using the current form state.
  Future<void> saveNewTodo() async {
    final title = titleCtrl.text.trim();
    if (title.isEmpty) return;
    formIsSaving.value = true;
    try {
      await addTodo(
        title,
        description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        categoryId: formCategoryId.value,
        dueDate: formDueDate.value,
      );
      Get.back();
    } catch (_) {
      // Error snackbar already shown inside addTodo.
    } finally {
      formIsSaving.value = false;
    }
  }

  /// Open the system date picker and store the result reactively.
  Future<void> pickDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: formDueDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).colorScheme.primary,
            onPrimary: Colors.white,
            surface: Theme.of(context).cardColor,
            onSurface: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) formDueDate.value = picked;
  }

  /// Parse a hex color string, returning [fallback] on error.
  Color parseHexColor(String hex, Color fallback) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  /// Filter: 'All' | 'Pending' | 'In Progress' | 'Done'
  final currentFilter = 'All'.obs;

  /// Returns the module's own Supabase client, falling back to main if not set.
  SupabaseClient get _db =>
      getIt<TenantService>().getClient('todo') ?? Supabase.instance.client;

  // ── Computed counts ──────────────────────────────────────────────────────

  int get totalCount => todos.length;
  int get pendingCount => todos.where((t) => t.isPending).length;
  int get inProgressCount => todos.where((t) => t.isInProgress).length;
  int get doneCount => todos.where((t) => t.isDone).length;

  List<TodoModel> get filteredTodos {
    final list = todos.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    switch (currentFilter.value) {
      case 'Pending':
        return list.where((t) => t.isPending).toList();
      case 'In Progress':
        return list.where((t) => t.isInProgress).toList();
      case 'Done':
        return list.where((t) => t.isDone).toList();
      default:
        return list;
    }
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    fetchCategories();
    fetchTodos();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }


  // ── Cache ────────────────────────────────────────────────────────────────

  void _loadFromCache() {
    final rawTodos = _storage.read<String>(_kTodos);
    if (rawTodos != null) {
      try {
        final list = jsonDecode(rawTodos) as List;
        todos.value =
            list.map((e) => TodoModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    final rawCats = _storage.read<String>(_kCategories);
    if (rawCats != null) {
      try {
        final list = jsonDecode(rawCats) as List;
        categories.value = list
            .map((e) => TodoCategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
  }

  Future<void> _saveTodosToCache() async {
    await _storage.write(
        _kTodos, jsonEncode(todos.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveCategoriesToCache() async {
    await _storage.write(
        _kCategories, jsonEncode(categories.map((e) => e.toJson()).toList()));
  }

  // ── Remote ───────────────────────────────────────────────────────────────

  Future<void> fetchCategories() async {
    isCategoriesLoading.value = true;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await _db
          .from('todo_categories')
          .select()
          .eq('user_id', user.id)
          .order('name');

      categories.value = response
          .map((e) => TodoCategoryModel.fromJson(e))
          .toList();
      await _saveCategoriesToCache();
    } catch (_) {
      // Background fetch — silent fail
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> fetchTodos() async {
    isLoading.value = true;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await _db
          .from('todos')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      todos.value = response.map((e) => TodoModel.fromJson(e)).toList();
      await _saveTodosToCache();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tasks',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTodo(
    String title, {
    String? description,
    String? categoryId,
    DateTime? dueDate,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _db
          .from('todos')
          .insert({
            'title': title.trim(),
            if (description != null && description.trim().isNotEmpty)
              'description': description.trim(),
            if (categoryId != null) 'category_id': categoryId,
            if (dueDate != null) 'due_date': dueDate.toIso8601String(),
            'status': 'pending',
            'user_id': user.id,
          })
          .select()
          .single();

      todos.insert(0, TodoModel.fromJson(response));
      await _saveTodosToCache();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add task: $e',
          snackPosition: SnackPosition.BOTTOM);
      rethrow;
    }
  }

  Future<void> updateStatus(TodoModel todo, String newStatus) async {
    final index = todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      todos[index] = todo.copyWith(status: newStatus);
      todos.refresh();
      _saveTodosToCache();
    }
    try {
      await _db.from('todos').update({'status': newStatus}).eq('id', todo.id);
    } catch (_) {
      // Revert on failure
      if (index != -1) {
        todos[index] = todo;
        todos.refresh();
        _saveTodosToCache();
      }
      Get.snackbar('Error', 'Failed to update task',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteTodo(String id) async {
    final removed = todos.firstWhereOrNull((t) => t.id == id);
    todos.removeWhere((t) => t.id == id);
    await _saveTodosToCache();
    try {
      await _db.from('todos').delete().eq('id', id);
    } catch (_) {
      if (removed != null) {
        todos.insert(0, removed);
        await _saveTodosToCache();
      }
      Get.snackbar('Error', 'Failed to delete task',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void setFilter(String filter) => currentFilter.value = filter;

  /// Cycle status: pending → in-progress → done → pending
  Future<void> toggleStatus(TodoModel todo) async {
    final next = todo.isPending
        ? 'in-progress'
        : todo.isInProgress
            ? 'done'
            : 'pending';
    await updateStatus(todo, next);
  }
}
