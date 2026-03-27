import 'dart:convert';
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

  final todos = <TodoModel>[].obs;
  final categories = <TodoCategoryModel>[].obs;
  final isLoading = false.obs;
  final currentFilter = 'All'.obs;

  /// Returns the tenant Supabase client (module-specific project).
  /// Falls back to the main client if tenant is not yet initialised.
  SupabaseClient get _db {
    final tenant = getIt<TenantService>().client;
    return tenant ?? Supabase.instance.client;
  }

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    fetchTodos();
  }

  void _loadFromCache() {
    final cached = _storage.read<String>(_kTodos);
    if (cached != null) {
      final List decoded = jsonDecode(cached);
      todos.value = decoded.map((e) => TodoModel.fromJson(e)).toList();
    }
  }

  Future<void> _saveToCache() async {
    final encoded = jsonEncode(todos.map((e) => e.toJson()).toList());
    await _storage.write(_kTodos, encoded);
  }

  Future<void> fetchTodos() async {
    try {
      isLoading.value = true;
      // Use main auth to get the current user id, but query on tenant db.
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response =
          await _db.from('todos').select().eq('user_id', user.id);

      todos.value =
          (response as List).map((e) => TodoModel.fromJson(e)).toList();
      await _saveToCache();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch todos',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  List<TodoModel> get filteredTodos {
    var list = todos.toList();
    if (currentFilter.value != 'All') {
      list = list
          .where((t) => t.status == currentFilter.value.toLowerCase())
          .toList();
    }
    list.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return list;
  }

  void setFilter(String filter) => currentFilter.value = filter;

  Future<void> toggleStatus(TodoModel todo) async {
    String nextStatus;
    if (todo.status == 'pending') {
      nextStatus = 'in-progress';
    } else if (todo.status == 'in-progress') {
      nextStatus = 'completed';
    } else {
      nextStatus = 'pending';
    }

    final updated = todo.copyWith(status: nextStatus);
    final index = todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      todos[index] = updated;
      todos.refresh();
      _saveToCache();
    }

    try {
      await _db
          .from('todos')
          .update({'status': nextStatus}).eq('id', todo.id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteTodo(String id) async {
    todos.removeWhere((t) => t.id == id);
    _saveToCache();

    try {
      await _db.from('todos').delete().eq('id', id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete todo',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
