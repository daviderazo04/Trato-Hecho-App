import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chat_models.dart';

class ChatService {
  
  // 1. Obtener Inbox
  Future<List<InboxChat>> getInbox(int userId) async {
    final url = Uri.parse('${ApiConfig.chat}/inbox/$userId');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((dynamic item) => InboxChat.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar inbox: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // 2. Obtener Historial
  Future<List<ChatMessage>> getHistory(int conId, int userId) async {
    final url = Uri.parse('${ApiConfig.chat}/history/$conId?userId=$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((dynamic item) => ChatMessage.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar historial');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // 3. Enviar Mensaje
  Future<ChatMessage?> sendMessage({
    required int senderId,
    int? receiverId, // Puede ser nulo si ya tenemos conId
    int? conId,      // Puede ser nulo si es chat nuevo
    required String content,
  }) async {
    final url = Uri.parse('${ApiConfig.chat}/send');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'senderId': senderId,
          'receiverId': receiverId,
          'conId': conId,
          'contenido': content,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return ChatMessage.fromJson(body);
      } else {
        print('Error al enviar: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error de conexión al enviar: $e');
      return null;
    }
  }
}