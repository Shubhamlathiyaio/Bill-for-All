import 'dart:developer';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/todo_category_model.dart';
import '../models/todo_model.dart';
import '../services/tenant_service.dart';
import '../../utils/helpers/injectable/injectable.dart';

@lazySingleton
class TodoRepository {
  /// Returns the module's own Supabase client, falling back to main if not set.
  SupabaseClient get _db =>
      getIt<TenantService>().getClient('todo') ?? Supabase.instance.client;

  Future<List<TodoCategoryModel>> fetchCategories(String userId) async {
    try {
      log('--- TodoRepository: fetchCategories hitting ${_db.rest.url}');
      final response = await _db
          .from('todo_categories')
          .select()
          .eq('user_id', userId)
          .order('name');

      return (response as List)
          .map((e) => TodoCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('--- TodoRepository: fetchCategories failed (possibly table missing): $e');
      return [];
    }
  }

  Future<List<TodoModel>> fetchTodos(String userId) async {
    log('--- TodoRepository: fetchTodos hitting ${_db.rest.url}');
    final response = await _db
        .from('todos')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => TodoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> addTodo(Map<String, dynamic> data) async {
    log('--- TodoRepository: addTodo hitting ${_db.rest.url}');
    final response = await _db
        .from('todos')
        .insert(data)
        .select()
        .single();
    
    return response;
  }

  Future<void> updateTodoStatus(String id, String newStatus) async {
    await _db.from('todos').update({'status': newStatus}).eq('id', id);
  }

  Future<void> deleteTodo(String id) async {
    await _db.from('todos').delete().eq('id', id);
  }
}
