import 'package:supabase_flutter/supabase_flutter.dart';

class TodoService {
  TodoService._(this.supabase);
  final SupabaseClient supabase;

  static final TodoService _instance = TodoService._(Supabase.instance.client);

  factory TodoService() => _instance;

  // 🔹 Get All Todos
  Future<List<Map<String, dynamic>>> getTodos() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final response = await supabase.from('todos').select().eq('user_id', user.id).order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // 🔹 Add Todo
  Future<void> addTodo(String title) async {
    final user = supabase.auth.currentUser;
    if (user == null) return; 

    await supabase.from('todos').insert({'title': title, 'user_id': user.id});
  }
}
