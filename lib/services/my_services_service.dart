import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../screens/homeView/home_screen.dart' show ServiceCardData;

class MyServicesService {
  Future<List<ServiceCardData>> getMyServices(int userId) async {
    final url = Uri.parse(ApiConfig.misServicios(userId));
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
