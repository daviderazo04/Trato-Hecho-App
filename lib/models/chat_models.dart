class InboxChat {
  final int conId;
  final String chatName;
  final String chatImage;
  final String lastMessage;
  final int unreadCount;
  final String subtitle;
  final double rating;
  final int? serviceId;

  InboxChat({
    required this.conId,
    required this.chatName,
    required this.chatImage,
    required this.lastMessage,
    required this.unreadCount,
    required this.subtitle,
    required this.rating,
    this.serviceId,
  });

  factory InboxChat.fromJson(Map<String, dynamic> json) {
    final serRaw = json['serId'] ?? json['serviceId'] ?? json['servicioId'];
    final serId = serRaw is num && serRaw > 0 ? serRaw.toInt() : null;

    return InboxChat(
      conId: json['conId'] ?? 0,
      chatName: json['chatName'] ?? 'Usuario',
      // Si viene nulo, ponemos una imagen por defecto
      chatImage: json['chatImage'] ?? 'https://i.pravatar.cc/150?u=${json['conId']}', 
      lastMessage: json['lastMessage'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
      subtitle: json['subtitle'] ?? 'Proveedor',
      rating: (json['rating'] ?? 0.0).toDouble(),
      serviceId: serId,
    );
  }
}

class ChatMessage {
  final int msjId;
  final String contenido;
  final String fechaEnvio; // Podrías usar DateTime si prefieres parsear
  final int senderId;
  final String senderName;
  final int? serviceId;
  final bool isPending;
  final bool isFailed;
  final String? localId;

  ChatMessage({
    required this.msjId,
    required this.contenido,
    required this.fechaEnvio,
    required this.senderId,
    required this.senderName,
    this.serviceId,
    this.isPending = false,
    this.isFailed = false,
    this.localId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final serRaw = json['serId'] ?? json['serviceId'] ?? json['servicioId'];
    final serId = serRaw is num && serRaw > 0 ? serRaw.toInt() : null;

    return ChatMessage(
      msjId: json['msjId'] ?? 0,
      contenido: json['contenido'] ?? '',
      fechaEnvio: json['fechaEnvio']?.toString() ?? '',
      senderId: json['senderId'] ?? 0,
      senderName: json['senderName'] ?? '',
      serviceId: serId,
      isPending: false,
      isFailed: false,
      localId: null,
    );
  }
}
