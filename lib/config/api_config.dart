import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    // Verificamos si dotenv está inicializado antes de acceder
    if (dotenv.isInitialized) {
      final envUrl = dotenv.env['API_URL'];
      if (envUrl != null && envUrl.isNotEmpty) {
        return envUrl;
      }
    }
    
    // Fallback seguro
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:9090/api'; 
    } else {
      return 'http://localhost:9090/api'; 
    }
  }
  
  static String get login => '$baseUrl/auth/login';
  static String get chat => '$baseUrl/chat';
  static String get servicios => '$baseUrl/servicios';
}