import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/clothing_item.dart';

class ApiService {
  // ========================================================
  // BACKEND URL
  // ========================================================

  // Physical Android phone
  static const String baseUrl = 'http://192.168.1.58:8000';

  // College
  // static const String baseUrl = 'http://172.18.52.160:8000';

  // ========================================================
  // PROCESS CLOTHING
  // ========================================================

  static Future<ClothingItem> processClothing({
    required File image,
    required String selectedCategory,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/process-clothing'),
    );

    print('========================================');
    print('SENDING CLOTHING TO BACKEND');
    print('IMAGE: ${image.path}');
    print('========================================');

    request.fields['selected_category'] = selectedCategory;

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final response = await request.send();

    final body = await response.stream.bytesToString();

    print('BACKEND STATUS: ${response.statusCode}');

    print('BACKEND RESPONSE: $body');

    if (response.statusCode != 200) {
      throw Exception('Backend error: $body');
    }

    final data = jsonDecode(body);

    print('PROCESS CLOTHING RESPONSE: $data');
    print('ITEM FROM RESPONSE: ${data['item']}');

    return ClothingItem.fromJson(data['item']);
  }

  // ========================================================
  // DETECT CLOTHING CATEGORY
  // ========================================================

  static Future<String> detectClothingCategory({required File image}) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/detect-category'),
    );

    print('========================================');
    print('DETECTING CLOTHING CATEGORY');
    print('IMAGE: ${image.path}');
    print('========================================');

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final response = await request.send();

    final body = await response.stream.bytesToString();

    print('CATEGORY STATUS: ${response.statusCode}');
    print('CATEGORY RESPONSE: $body');

    if (response.statusCode != 200) {
      throw Exception('Category detection error: $body');
    }

    final data = jsonDecode(body);

    print('DETECTED CATEGORY: ${data['category']}');

    return data['category'] as String;
  }

  // ========================================================
  // GET WARDROBE
  // ========================================================

  static Future<List<ClothingItem>> getWardrobe() async {
    final response = await http.get(Uri.parse('$baseUrl/wardrobe'));

    print('WARDROBE STATUS: ${response.statusCode}');
    print('WARDROBE RESPONSE: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Unable to load wardrobe: ${response.body}');
    }

    final data = jsonDecode(response.body);

    final List<dynamic> items = data['items'] ?? [];

    return items
        .map((item) => ClothingItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ========================================================
  // DELETE / REMOVE CLOTHING ITEM
  // ========================================================

  static Future<void> deleteClothingItem({required String id}) async {
    final response = await http.delete(Uri.parse('$baseUrl/wardrobe/$id'));

    print('DELETE CLOTHING STATUS: ${response.statusCode}');
    print('DELETE CLOTHING RESPONSE: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to remove clothing item: ${response.body}');
    }
  }

  // ========================================================
  // GENERATE FIRST OUTFIT
  // ========================================================

  static Future<Map<String, dynamic>> generateOutfit() async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate-outfit'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return jsonDecode(response.body);
  }

  // ========================================================
  // GENERATE ANOTHER OUTFIT
  // ========================================================

  static Future<Map<String, dynamic>> generateAnotherOutfit({
    required List<List<String>> excludedOutfits,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate-outfit/another'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'excluded_outfits': excludedOutfits}),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return jsonDecode(response.body);
  }

  // ========================================================
  // GENERATE RECORD OUTFIT PREVIEW
  // ========================================================

  static Future<String> generateRecordOutfitPreview({
    required List<String> itemIds,
  }) async {
    if (itemIds.isEmpty) {
      throw Exception('No clothing items selected.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/record-outfit-preview'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'item_ids': itemIds}),
    );

    print('RECORD OUTFIT PREVIEW STATUS: ${response.statusCode}');
    print('RECORD OUTFIT PREVIEW RESPONSE: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to generate outfit preview: ${response.body}');
    }

    final data = jsonDecode(response.body);

    final imageUrl = data['image_url']?.toString();

    if (imageUrl == null || imageUrl.isEmpty) {
      throw Exception('Backend did not return an outfit preview image.');
    }

    return imageUrl;
  }

  // ========================================================
  // OUTFIT FEEDBACK
  // ========================================================

  static Future<Map<String, dynamic>> sendOutfitFeedback({
    required String outfitId,
    required String feedback,
  }) async {
    if (outfitId.isEmpty) {
      throw Exception('Outfit ID is missing.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/outfit/$outfitId/feedback'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'feedback': feedback}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save outfit feedback: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  // ========================================================
  // SAVE CLOTHING ITEM
  // ========================================================

  static Future<ClothingItem> saveClothingItem({
    required ClothingItem item,
    required String name,
    required String brand,
    required String category,
    required String color,
    required String style,
    required String material,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/wardrobe'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'category': category,
        'subcategory': item.subcategory ?? 'unknown',
        'brand': brand,
        'color': color,
        'style': style,
        'material': material,
        'image_path': item.imagePath,
        'processed_image_path': item.processedImagePath,

        // AI analysis
        'ai_analysis': {
          'category': item.detectedCategory,
          'category_confidence': item.categoryConfidence,
          'color': item.detectedColor,
          'color_confidence': item.colorConfidence,
          'style': item.detectedStyle,
          'style_confidence': item.styleConfidence,
          'analysis_version': item.analysisVersion,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to save clothing: ${response.body}');
    }

    final data = jsonDecode(response.body);

    return ClothingItem.fromJson(data['item']);
  }

  // ========================================================
  // UPDATE CLOTHING ITEM
  // ========================================================

  static Future<void> updateClothingItem({
    required String id,
    required String name,
    required String brand,
    required String category,
    required String color,
    required String style,
    required String material,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/wardrobe/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'brand': brand,
        'category': category,
        'color': color,
        'style': style,
        'material': material,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update clothing item: ${response.body}');
    }
  }

  static Future<void> saveOutfitHistory({
    required List<String> itemIds,
    required DateTime wornDate,
    required String notes,
  }) async {
    if (itemIds.isEmpty) {
      throw Exception('Please select at least one clothing item.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/outfit-history'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'item_ids': itemIds,
        'worn_date':
            '${wornDate.year.toString().padLeft(4, '0')}-'
            '${wornDate.month.toString().padLeft(2, '0')}-'
            '${wornDate.day.toString().padLeft(2, '0')}',
        'notes': notes,
      }),
    );

    print('SAVE OUTFIT HISTORY STATUS: ${response.statusCode}');
    print('SAVE OUTFIT HISTORY RESPONSE: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to save outfit history: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getOutfitHistory({
    required int year,
    required int month,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/outfit-history'
        '?year=$year'
        '&month=$month',
      ),
    );

    print('GET OUTFIT HISTORY STATUS: ${response.statusCode}');
    print('GET OUTFIT HISTORY RESPONSE: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to load outfit history: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
