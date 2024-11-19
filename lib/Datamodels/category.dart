class Category {
  int? categoryId;
  String name;

  Category({this.categoryId, required this.name});

  // Convert Category to Map (for SQL insertion)
  Map<String, dynamic> toMap() {
    return {
      'category_id': categoryId,
      'name': name,
    };
  }

  // Convert Map to Category (for SQL selection)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      categoryId: map['category_id'],
      name: map['name'],
    );
  }
}
