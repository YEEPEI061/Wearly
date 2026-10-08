class ClothingItem {
  final String id;
  final String name;
  final String category;
  final String? subcategory;
  final String? brand;
  final String? color;
  final String? style;
  final String? material;
  final String? imagePath;
  final String? processedImagePath;
  final bool isFavorite;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? detectedCategory;
  final double? categoryConfidence;
  final String? detectedColor;
  final double? colorConfidence;
  final String? detectedStyle;
  final double? styleConfidence;
  final Map<String, dynamic>? styleScores;
  final Map<String, dynamic>? colorScores;
  final List<double>? visualEmbedding;
  final String? analysisVersion;

  ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    this.brand,
    this.color,
    this.style,
    this.material,
    this.imagePath,
    this.processedImagePath,
    this.isFavorite = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.detectedCategory,
    this.categoryConfidence,
    this.detectedColor,
    this.colorConfidence,
    this.detectedStyle,
    this.styleConfidence,
    this.styleScores,
    this.colorScores,
    this.visualEmbedding,
    this.analysisVersion,
  });

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Clothing',
      category: json['category']?.toString() ?? 'upper',

      subcategory: json['subcategory']?.toString(),
      brand: json['brand']?.toString(),
      color: json['color']?.toString(),
      style: json['style']?.toString(),
      material: json['material']?.toString(),

      imagePath: json['image_path']?.toString(),

      processedImagePath: json['processed_image_path']?.toString(),

      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,

      isActive: json['is_active'] == null
          ? true
          : json['is_active'] == true || json['is_active'] == 1,

      createdAt: _parseDate(json['created_at']),

      updatedAt: _parseDate(json['updated_at']),

      detectedCategory: json['detected_category']?.toString(),

      categoryConfidence: (json['category_confidence'] as num?)?.toDouble(),

      detectedColor: json['detected_color']?.toString(),

      colorConfidence: (json['color_confidence'] as num?)?.toDouble(),

      detectedStyle: json['detected_style']?.toString(),

      styleConfidence: (json['style_confidence'] as num?)?.toDouble(),

      analysisVersion: json['analysis_version']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'brand': brand,
      'color': color,
      'style': style,
      'material': material,
      'image_path': imagePath,
      'processed_image_path': processedImagePath,
      'is_favorite': isFavorite,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'detected_category': detectedCategory,
      'category_confidence': categoryConfidence,
      'detected_color': detectedColor,
      'color_confidence': colorConfidence,
      'detected_style': detectedStyle,
      'style_confidence': styleConfidence,
      'analysis_version': analysisVersion,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
