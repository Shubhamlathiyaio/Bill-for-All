import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'todo_controller.dart';

/// Aggregates summary data from all active module controllers.
/// Each module contributes its own summary — the dashboard just reads it.
/// To add a new module's data: inject its controller here and expose getters.
@lazySingleton
class DashboardController extends GetxController {
  DashboardController(this._todo);

  final TodoController _todo;

  // ── Todo summary ────────────────────────────────────────────────────────
  int get totalTodos => _todo.todos.length;
  int get pendingTodos =>
      _todo.todos.where((t) => t.status == 'pending').length;
  int get completedTodos =>
      _todo.todos.where((t) => t.status == 'completed').length;

  /// The 3 most recently added todos (newest first).
  List get recentTodos => _todo.todos.reversed.take(3).toList();

  final isRefreshing = false.obs;

  Future<void> refresh() async {
    isRefreshing.value = true;
    await _todo.fetchTodos();
    isRefreshing.value = false;
  }
}
