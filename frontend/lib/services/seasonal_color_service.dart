import 'package:frontend/services/api_service.dart';

class SeasonalColorService {
  static Future<Map<String, dynamic>?> getSavedAnalysis() async {
    return await ApiService.getSeasonalColor();
  }
}
