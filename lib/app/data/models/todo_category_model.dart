class TodoCategoryModel {
  final String id;
  final String userId;
  final String name;
  final String color;
  final String icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TodoCategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    this.color = '#6366F1',
    this.icon = 'folder',
    required this.createdAt,
    required this.updatedAt,
  });

  factory TodoCategoryModel.fromJson(Map<String, dynamic> json) {
    return TodoCategoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      color: json['color'] as String? ?? '#6366F1',
      icon: json['icon'] as String? ?? 'folder',
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
        'name': name,
        'color': color,
        'icon': icon,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  TodoCategoryModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoCategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
