import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class ApiService {
  static const String _ipKey   = 'server_ip';
  static const String _portKey = 'server_port';
  static const int    _defaultPort = 3000;

  // ─── Server settings ─────────────────────────────────────────────────────────

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final ip   = prefs.getString(_ipKey) ?? '192.168.1.100';
    final port = prefs.getInt(_portKey)  ?? _defaultPort;
    return 'http://$ip:$port';
  }

  static Future<void> saveServerSettings(String ip, int port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ipKey, ip);
    await prefs.setInt(_portKey, port);
  }

  static Future<String> getSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ipKey) ?? '';
  }

  static Future<int> getSavedPort() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_portKey) ?? _defaultPort;
  }

  // ─── Test connection ──────────────────────────────────────────────────────────

  static Future<bool> testConnection() async {
    try {
      final base     = await getBaseUrl();
      final response = await http
          .get(Uri.parse('$base/api/todos?limit=1'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── GET todos ────────────────────────────────────────────────────────────────

  static Future<TodoListResponse> getTodos({
    String search    = '',
    String status    = 'all',
    String sortBy    = 'created_at',
    String sortOrder = 'DESC',
    int    page      = 1,
    int    limit     = 10,
  }) async {
    final base = await getBaseUrl();
    final uri  = Uri.parse('$base/api/todos').replace(queryParameters: {
      'search':    search,
      'status':    status,
      'sortBy':    sortBy,
      'sortOrder': sortOrder,
      'page':      page.toString(),
      'limit':     limit.toString(),
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return TodoListResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Server returned ${response.statusCode}');
  }

  // ─── CREATE todo ──────────────────────────────────────────────────────────────

  static Future<Todo> createTodo({
    required String title,
    String description = '',
    String priority    = 'medium',
  }) async {
    final base     = await getBaseUrl();
    final response = await http.post(
      Uri.parse('$base/api/todos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'description': description, 'priority': priority}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return Todo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to create todo: ${response.body}');
  }

  // ─── UPDATE todo ──────────────────────────────────────────────────────────────

  static Future<Todo> updateTodo(
    int id, {
    required String title,
    String description = '',
    String priority    = 'medium',
    String status      = 'pending',
  }) async {
    final base     = await getBaseUrl();
    final response = await http.put(
      Uri.parse('$base/api/todos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title':       title,
        'description': description,
        'priority':    priority,
        'status':      status,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return Todo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update todo: ${response.body}');
  }

  // ─── TOGGLE complete ──────────────────────────────────────────────────────────

  static Future<Todo> toggleTodo(int id) async {
    final base     = await getBaseUrl();
    final response = await http
        .patch(Uri.parse('$base/api/todos/$id/toggle'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return Todo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to toggle todo');
  }

  // ─── DELETE todo ──────────────────────────────────────────────────────────────

  static Future<void> deleteTodo(int id) async {
    final base = await getBaseUrl();
    await http
        .delete(Uri.parse('$base/api/todos/$id'))
        .timeout(const Duration(seconds: 10));
  }
}
