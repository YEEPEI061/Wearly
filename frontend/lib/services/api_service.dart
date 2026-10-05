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

  // Android emulator
  // static const String baseUrl = 'http://10.0.2.2:8000';

  // iOS simulator
  // static const String baseUrl = 'http://127.0.0.1:8000';

  // ========================================================
  // IMAGE CONTENT TYPE
  // ========================================================

  static MediaType _getImageContentType(String path) {
    final extension = path.split('.').last.toLowerCase();

    switch (extension) {
      case 'png':
        return MediaType('image', 'png');

      case 'webp':
        return MediaType('image', 'webp');

      case 'gif':
        return MediaType('image', 'gif');

      case 'heic':
      case 'heif':
        return MediaType('image', 'heic');

      case 'jpg':
      case 'jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }

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

    if (response.statusCode != 200) {
      throw Exception('Failed to load wardrobe: ${response.body}');
    }

    final data = jsonDecode(response.body);

    final List items = data['items'] ?? [];

    return items.map((item) => ClothingItem.fromJson(item)).toList();
  }

  // ========================================================
  // DELETE CLOTHING
  // ========================================================

  static Future<void> deleteClothing(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/wardrobe/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete clothing: ${response.body}');
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
  // OUTFIT FEEDBACK
  // ========================================================

  static Future<Map<String, dynamic>> sendOutfitFeedback({
    required List<String> outfitKey,
    required String feedback,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/outfit-feedback'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'outfit_key': outfitKey, 'feedback': feedback}),
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
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to save clothing: ${response.body}');
    }

    final data = jsonDecode(response.body);

    return ClothingItem.fromJson(data['item']);
  }
}
