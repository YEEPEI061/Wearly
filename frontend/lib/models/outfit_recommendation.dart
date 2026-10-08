import 'package:frontend/models/clothing_item.dart';

class OutfitRecommendation {
  final String id;
  final String title;
  final List<ClothingItem> items;
  final double score;
  final String reason;
  final Map<String, dynamic>? scoreBreakdown;

  OutfitRecommendation({
    required this.id,
    required this.title,
    required this.items,
    required this.score,
    required this.reason,
    this.scoreBreakdown,
  });

  factory OutfitRecommendation.fromJson(
    Map<String, dynamic> json,
  ) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];

    return OutfitRecommendation(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'AI Outfit',
      items: itemsJson
          .map(
            (item) => ClothingItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason']?.toString() ?? '',
      scoreBreakdown: json['score_breakdown'] != null
          ? Map<String, dynamic>.from(
              json['score_breakdown'],
            )
          : null,
    );
  }
}