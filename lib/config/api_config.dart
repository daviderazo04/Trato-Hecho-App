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
      return 'http://10.0.2.2:8080/api';
    } else {
      return 'http://localhost:8080/api';
    }
  }

  static String get login => '$baseUrl/auth/login';
  static String get registro => '$baseUrl/auth/registro';
  static String get chat => '$baseUrl/chat';
  static String get servicios => '$baseUrl/servicios';
  static String get favoritosAgregar => '$baseUrl/favoritos/agregar';
  static String get favoritosEliminar => '$baseUrl/favoritos/eliminar';
  static String favoritosList(int userId) =>
      '$baseUrl/servicios/favoritos/$userId';
  static String servicioPorId(int id) => '$baseUrl/servicio/$id';
  static String get contratarServicio => '$baseUrl/contrataciones/contratar';
  static String historialContrataciones(int userId) =>
      '$baseUrl/contrataciones/historial/$userId';
  static String get calificarServicio => '$baseUrl/calificaciones/calificar';
  static String misServicios(int userId) => '$baseUrl/servicios/mis-servicios/$userId';
}
