class Todo {
  final int id;
  final String title;
  final String description;
  final String status;   // 'pending' | 'completed'
  final String priority; // 'low' | 'medium' | 'high'
  final String createdAt;
  final String updatedAt;

  const Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id:          json['id'] as int,
        title:       json['title'] as String,
        description: json['description'] as String? ?? '',
        status:      json['status'] as String? ?? 'pending',
        priority:    json['priority'] as String? ?? 'medium',
        createdAt:   json['created_at'] as String? ?? '',
        updatedAt:   json['updated_at'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'title':       title,
        'description': description,
        'status':      status,
        'priority':    priority,
      };

  bool get isCompleted => status == 'completed';
}

class TodoListResponse {
  final List<Todo> todos;
  final PaginationInfo pagination;

  const TodoListResponse({required this.todos, required this.pagination});

  factory TodoListResponse.fromJson(Map<String, dynamic> json) =>
      TodoListResponse(
        todos:      (json['todos'] as List).map((t) => Todo.fromJson(t as Map<String, dynamic>)).toList(),
        pagination: PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>),
      );
}

class PaginationInfo {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginationInfo({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) => PaginationInfo(
        total:      json['total'] as int,
        page:       json['page'] as int,
        limit:      json['limit'] as int,
        totalPages: json['totalPages'] as int,
      );
}
