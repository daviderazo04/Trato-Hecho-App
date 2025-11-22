import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Para Emulador Android usa 10.0.2.2
  // Para iOS o Web usa localhost
  // Para dispositivo físico usa tu IP local (ej: 192.168.1.X)
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api';

  // Endpoints específicos
  static String get login => '$baseUrl/auth/login';
  static String get chat => '$baseUrl/chat';
}
