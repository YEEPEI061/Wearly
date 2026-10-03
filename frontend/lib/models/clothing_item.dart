class ClothingItem {
  final String id;
  final String name;
  final String category;
  final String color;
  final String imageUrl;

  ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.imageUrl,
  });

  factory ClothingItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ClothingItem(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Clothing',
      category: json['category'] ?? 'upper',
      color: json['color'] ?? 'unknown',
      imageUrl: json['image_url'] ?? '',
    );
  }
}