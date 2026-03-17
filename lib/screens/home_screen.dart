import 'dart:async';
import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/api_service.dart';
import 'add_edit_todo_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ─── State ──────────────────────────────────────────────────────────────────
  List<Todo>     _todos      = [];
  PaginationInfo? _pagination;
  bool           _loading    = false;
  String         _error      = '';

  // ─── Filters ────────────────────────────────────────────────────────────────
  final _searchCtrl = TextEditingController();
  String _filterStatus = 'all';
  String _sortBy       = 'created_at';
  String _sortOrder    = 'DESC';
  int    _currentPage  = 1;
  static const int _pageSize = 10;
  Timer? _searchDebounce;

  // ─── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // ─── Data ───────────────────────────────────────────────────────────────────
  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      setState(() => _currentPage = 1);
      _fetchTodos();
    });
  }

  Future<void> _fetchTodos() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final result = await ApiService.getTodos(
        search:    _searchCtrl.text.trim(),
        status:    _filterStatus,
        sortBy:    _sortBy,
        sortOrder: _sortOrder,
        page:      _currentPage,
        limit:     _pageSize,
      );
      setState(() {
        _todos      = result.todos;
        _pagination = result.pagination;
      });
    } catch (e) {
      setState(() => _error = 'Cannot connect to server.\nCheck Settings → verify IP address and that\nthe server is running on your PC.');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _resetAndFetch() {
    setState(() => _currentPage = 1);
    _fetchTodos();
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      appBar: AppBar(
        title: const Text('📋 My Todos', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _fetchTodos,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Server Settings',
            onPressed: () async {
              await Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              _fetchTodos();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterRow(),
          _buildSortBar(),
          const Divider(height: 1),
          Expanded(child: _buildBody()),
          if (_pagination != null && _pagination!.totalPages > 1) _buildPagination(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Todo'),
        onPressed: () async {
          final result = await Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AddEditTodoScreen()));
          if (result == true) _resetAndFetch();
        },
      ),
    );
  }

  // ─── Search bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search todos…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () { _searchCtrl.clear(); _resetAndFetch(); },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  // ─── Status filter chips ─────────────────────────────────────────────────────
  Widget _buildFilterRow() {
    final filters = [
      ('All',       'all',       Icons.list_alt),
      ('Pending',   'pending',   Icons.hourglass_empty),
      ('Completed', 'completed', Icons.check_circle_outline),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: filters.map((f) {
          final selected = _filterStatus == f.$2;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: Icon(f.$3, size: 16),
              label: Text(f.$1),
              selected: selected,
              onSelected: (_) {
                setState(() { _filterStatus = f.$2; _currentPage = 1; });
                _fetchTodos();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Sort bar ────────────────────────────────────────────────────────────────
  Widget _buildSortBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 8, 4),
      child: Row(
        children: [
          const Text('Sort by:', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _sortBy,
            isDense: true,
            underline: const SizedBox(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
            items: const [
              DropdownMenuItem(value: 'created_at', child: Text('Date Created')),
              DropdownMenuItem(value: 'updated_at', child: Text('Last Updated')),
              DropdownMenuItem(value: 'priority',   child: Text('Priority')),
              DropdownMenuItem(value: 'title',      child: Text('Title (A-Z)')),
            ],
            onChanged: (val) {
              setState(() { _sortBy = val!; _currentPage = 1; });
              _fetchTodos();
            },
          ),
          IconButton(
            icon: Icon(
              _sortOrder == 'DESC' ? Icons.arrow_downward : Icons.arrow_upward,
              size: 18,
            ),
            tooltip: _sortOrder == 'DESC' ? 'Descending' : 'Ascending',
            onPressed: () {
              setState(() { _sortOrder = _sortOrder == 'DESC' ? 'ASC' : 'DESC'; _currentPage = 1; });
              _fetchTodos();
            },
          ),
          const Spacer(),
          if (_pagination != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '${_pagination!.total} item${_pagination!.total == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Body ────────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, height: 1.5)),
              const SizedBox(height: 20),
              FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: _fetchTodos,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
                onPressed: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  _fetchTodos();
                },
              ),
            ],
          ),
        ),
      );
    }

    if (_todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('No todos found', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              _searchCtrl.text.isNotEmpty ? 'Try a different search term' : 'Tap + to add your first todo',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchTodos,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 80),
        itemCount: _todos.length,
        itemBuilder: (ctx, i) => _buildTodoCard(_todos[i]),
      ),
    );
  }

  // ─── Todo card ───────────────────────────────────────────────────────────────
  Widget _buildTodoCard(Todo todo) {
    final colors = {
      'high':   (Colors.red, Colors.red.shade50),
      'medium': (Colors.orange, Colors.orange.shade50),
      'low':    (Colors.green, Colors.green.shade50),
    };
    final (chipColor, chipBg) = colors[todo.priority] ?? (Colors.grey, Colors.grey.shade50);
    final isCompleted = todo.isCompleted;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted
              ? Colors.green.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showOptionsSheet(todo),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: isCompleted,
                  shape: const CircleBorder(),
                  onChanged: (_) async {
                    await ApiService.toggleTodo(todo.id);
                    _fetchTodos();
                  },
                ),
              ),
              const SizedBox(width: 4),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      todo.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? Colors.grey : null,
                      ),
                    ),
                    if (todo.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        todo.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Priority badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: chipColor.withOpacity(0.4)),
                      ),
                      child: Text(
                        todo.priority.toUpperCase(),
                        style: TextStyle(fontSize: 10, color: chipColor, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              // More button
              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                onPressed: () => _showOptionsSheet(todo),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Options bottom sheet ────────────────────────────────────────────────────
  void _showOptionsSheet(Todo todo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(todo.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => AddEditTodoScreen(todo: todo)));
                if (result == true) _fetchTodos();
              },
            ),
            ListTile(
              leading: Icon(
                todo.isCompleted ? Icons.replay_outlined : Icons.check_circle_outline,
                color: Colors.green,
              ),
              title: Text(todo.isCompleted ? 'Mark as Pending' : 'Mark as Complete'),
              onTap: () async {
                Navigator.pop(context);
                await ApiService.toggleTodo(todo.id);
                _fetchTodos();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Todo'),
                    content: Text('Delete "${todo.title}"? This cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ApiService.deleteTodo(todo.id);
                  _fetchTodos();
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─── Pagination ──────────────────────────────────────────────────────────────
  Widget _buildPagination() {
    final p = _pagination!;
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: _currentPage > 1
                ? () { setState(() => _currentPage = 1); _fetchTodos(); }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 1
                ? () { setState(() => _currentPage--); _fetchTodos(); }
                : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Page ${p.page} of ${p.totalPages}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < p.totalPages
                ? () { setState(() => _currentPage++); _fetchTodos(); }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: _currentPage < p.totalPages
                ? () { setState(() => _currentPage = p.totalPages); _fetchTodos(); }
                : null,
          ),
        ],
      ),
    );
  }
}
