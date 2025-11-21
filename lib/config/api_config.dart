class ApiConfig {
  // Para Emulador Android usa 10.0.2.2
  // Para iOS o Web usa localhost
  // Para dispositivo físico usa tu IP local (ej: 192.168.1.X)
  static const String baseUrl = 'http://localhost:8080/api';

  // Endpoints específicos
  static const String login = '$baseUrl/auth/login';
  static const String chat = '$baseUrl/chat';
}
