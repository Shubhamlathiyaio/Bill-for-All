class TodoCategoryModel {
  final String id;
  final String name;
  final String userId;

  TodoCategoryModel({
    required this.id,
    required this.name,
    required this.userId,
  });

  factory TodoCategoryModel.fromJson(Map<String, dynamic> json) {
    return TodoCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
    };
  }
}
