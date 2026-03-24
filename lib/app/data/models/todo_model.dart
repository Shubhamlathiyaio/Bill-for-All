class TodoModel {
  final String id;
  final String title;
  final String? description;
  final String status; // 'pending' | 'in-progress' | 'completed'
  final DateTime? dueDate;
  final String? categoryId;
  final String userId;

  TodoModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.dueDate,
    this.categoryId,
    required this.userId,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'pending',
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
      categoryId: json['category_id'] as String?,
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'status': status,
      if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
      if (categoryId != null) 'category_id': categoryId,
      'user_id': userId,
    };
  }

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    DateTime? dueDate,
    String? categoryId,
    String? userId,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      categoryId: categoryId ?? this.categoryId,
      userId: userId ?? this.userId,
    );
  }
}
