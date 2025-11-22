import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

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
}
