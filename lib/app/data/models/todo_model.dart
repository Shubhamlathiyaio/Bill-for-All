class TodoModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String status; // 'pending', 'in-progress', 'done'
  final DateTime? dueDate;
  final String? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TodoModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.status = 'pending',
    this.dueDate,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isDone => status == 'done';
  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in-progress';

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'pending',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      categoryId: json['category_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        if (description != null) 'description': description,
        'status': status,
        if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
        if (categoryId != null) 'category_id': categoryId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  TodoModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? status,
    DateTime? dueDate,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
