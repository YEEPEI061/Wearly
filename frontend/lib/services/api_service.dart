import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/clothing_item.dart';

class ApiService {
  // Physical Android phone:
  static const String baseUrl = 'http://192.168.1.58:8000';

  // Android emulator:
  // static const String baseUrl =
  //     'http://10.0.2.2:8000';

  // iOS simulator:
  // static const String baseUrl =
  //     'http://127.0.0.1:8000';

  // ========================================================
  // PROCESS CLOTHING
  // ========================================================

  static Future<ClothingItem> processClothing({
    required File image,
    required String category,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/process-clothing'),
    );

    request.fields['category'] = category;

    print('SENDING CATEGORY TO BACKEND: $category');

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final response = await request.send();

    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Backend error: $body');
    }

    final data = jsonDecode(body);

    return ClothingItem.fromJson(data);
  }

  // ========================================================
  // GET WARDROBE
  // ========================================================

  static Future<List<ClothingItem>> getWardrobe() async {
    final response = await http.get(Uri.parse('$baseUrl/wardrobe'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load wardrobe.');
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
      throw Exception('Failed to delete clothing.');
    }
  }

  // ========================================================
  // GENERATE OUTFIT
  // ========================================================

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

    headers: {
      'Content-Type': 'application/json',
    },

    body: jsonEncode({
      'outfit_key': outfitKey,
      'feedback': feedback,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Failed to save outfit feedback: ${response.body}',
    );
  }

  return jsonDecode(response.body);
}
}
