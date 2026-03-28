import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'todo_controller.dart';

/// Aggregates summary data from all active module controllers.
/// To add a new module's data: inject its controller and expose getters.
@lazySingleton
class DashboardController extends GetxController {
  DashboardController(this._todo);

  final TodoController _todo;

  // ── Todo summary ─────────────────────────────────────────────────────────
  int get totalTodos => _todo.totalCount;
  int get pendingTodos => _todo.pendingCount;
  int get completedTodos => _todo.doneCount;

  /// The 3 most recently added todos (newest first).
  List<dynamic> get recentTodos => _todo.todos.take(3).toList();

  final isRefreshing = false.obs;

  /// Pull fresh data from all active module controllers.
  Future<void> refreshData() async {
    isRefreshing.value = true;
    await _todo.fetchTodos();
    isRefreshing.value = false;
  }
}
