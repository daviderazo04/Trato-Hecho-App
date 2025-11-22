import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../screens/homeView/home_screen.dart' show ServiceCardData;

class FavoritesService {
  Future<bool> addFavorite({
    required int userId,
    required int serviceId,
  }) async {
    final url = Uri.parse(ApiConfig.favoritosAgregar);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'servicioId': serviceId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFavorite({
    required int userId,
    required int serviceId,
  }) async {
    final url = Uri.parse(ApiConfig.favoritosEliminar);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'servicioId': serviceId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<ServiceCardData>> getFavorites(int userId) async {
    final url = Uri.parse(ApiConfig.favoritosList(userId));
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> decoded =
            jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(ServiceCardData.fromJson)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
