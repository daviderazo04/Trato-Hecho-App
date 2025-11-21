class InboxChat {
  final int conId;
  final String chatName;
  final String chatImage;
  final String lastMessage;
  final int unreadCount;
  final String subtitle;
  final double rating;

  InboxChat({
    required this.conId,
    required this.chatName,
    required this.chatImage,
    required this.lastMessage,
    required this.unreadCount,
    required this.subtitle,
    required this.rating,
  });

  factory InboxChat.fromJson(Map<String, dynamic> json) {
    return InboxChat(
      conId: json['conId'] ?? 0,
      chatName: json['chatName'] ?? 'Usuario',
      // Si viene nulo, ponemos una imagen por defecto
      chatImage: json['chatImage'] ?? 'https://i.pravatar.cc/150?u=${json['conId']}', 
      lastMessage: json['lastMessage'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
      subtitle: json['subtitle'] ?? 'Proveedor',
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }
}

class ChatMessage {
  final int msjId;
  final String contenido;
  final String fechaEnvio; // Podrías usar DateTime si prefieres parsear
  final int senderId;
  final String senderName;

  ChatMessage({
    required this.msjId,
    required this.contenido,
    required this.fechaEnvio,
    required this.senderId,
    required this.senderName,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      msjId: json['msjId'] ?? 0,
      contenido: json['contenido'] ?? '',
      fechaEnvio: json['fechaEnvio']?.toString() ?? '',
      senderId: json['senderId'] ?? 0,
      senderName: json['senderName'] ?? '',
    );
  }
}