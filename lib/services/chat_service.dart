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
        print('Error API Inbox: ${response.body}');
        return []; 
      }
    } catch (e) {
      print('Excepción en getInbox: $e');
      return []; 
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
        print('Error API History: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Excepción en getHistory: $e');
      return [];
    }
  }

  // 3. Verificar si existe conversación
  Future<int?> checkConversation(int senderId, int receiverId, {int? serviceId}) async {
    String urlStr = '${ApiConfig.chat}/check/$receiverId?senderId=$senderId';
    if (serviceId != null) {
      urlStr += '&serId=$serviceId';
    }
    
    final url = Uri.parse(urlStr);
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body.trim() == 'null') return null;
        return int.tryParse(response.body);
      }
      return null;
    } catch (e) {
      print("Error checking conversation: $e");
      return null;
    }
  }

  // 4. Enviar Mensaje
  Future<ChatMessage?> sendMessage({
    required int senderId,
    int? receiverId, 
    int? conId,      
    int? serviceId,
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
          'serId': serviceId,
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

  // --- 5. NUEVO: Obtener estado global de no leídos ---
  Future<bool> getUnreadStatus(int userId) async {
    final url = Uri.parse('${ApiConfig.chat}/unread-status/$userId');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['hasUnread'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking unread status: $e');
      return false;
    }
  }
}