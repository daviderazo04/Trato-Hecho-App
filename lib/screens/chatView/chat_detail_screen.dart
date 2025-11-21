import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../config/user_provider.dart';
import '../../config/appColors.dart';
import '../../services/chat_service.dart';
import '../../models/chat_models.dart';

class ChatDetailScreen extends StatefulWidget {
  final int? conId;       // ID de Conversación (Si viene del Inbox)
  final int? receiverId;  // ID del otro usuario (Si viene de "Contactar")
  final String chatName;
  final String chatSubtitle;
  final String rating;

  const ChatDetailScreen({
    super.key,
    this.conId,
    this.receiverId,
    required this.chatName,
    required this.chatSubtitle,
    required this.rating,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final _textController = TextEditingController();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  int? _currentConId; // Para guardar el ID si se crea uno nuevo

  @override
  void initState() {
    super.initState();
    _currentConId = widget.conId;
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final myUserId = Provider.of<UserProvider>(context, listen: false).userId;
    if (_currentConId == null || myUserId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final msgs = await _chatService.getHistory(_currentConId!, myUserId);
      if (mounted) {
        setState(() {
          _messages = msgs;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error history: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSendPressed() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final myUserId = Provider.of<UserProvider>(context, listen: false).userId;
    if (myUserId == null) return;

    // Limpiamos input para efecto inmediato
    _textController.clear();

    try {
      // Enviamos al backend
      final newMessage = await _chatService.sendMessage(
        senderId: myUserId,
        receiverId: widget.receiverId, // Puede ser null si ya tenemos conId
        conId: _currentConId,          // Puede ser null si es nuevo
        content: text,
      );

      if (newMessage != null && mounted) {
        setState(() {
          _messages.add(newMessage);
          // Si era un chat nuevo, la API probablemente creó la sala, 
          // pero para simplificar aquí solo añadimos el mensaje localmente.
          // En una app real, la respuesta debería incluir el nuevo conId.
        });
      }
    } catch (e) {
      print("Error sending: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al enviar mensaje")),
      );
    }
  }

  // ... (Helpers de color iguales que antes) ...
  Color _backgroundColor(bool isDark) => isDark ? AppColors.backgroundDark : Colors.white;
  Color _appBarColor(bool isDark) => isDark ? AppColors.backgroundDark : Colors.white;
  Color _textColor(bool isDark) => isDark ? AppColors.darkText : Colors.black;
  Color _subTextColor(bool isDark) => isDark ? Colors.grey[400]! : Colors.black54;
  Color _bubbleMeColor(bool isDark) => isDark ? const Color.fromRGBO(59, 96, 125, 1) : const Color.fromARGB(255, 173, 202, 226);
  Color _bubbleOtherColor(bool isDark) => isDark ? AppColors.darkButtons : const Color.fromARGB(255, 0, 51, 102);
  Color _inputColor(bool isDark) => isDark ? AppColors.darkButtons : Colors.white;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;
    final int myUserId = userProvider.userId ?? 0;

    return Scaffold(
      backgroundColor: _backgroundColor(isDarkMode),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _appBarColor(isDarkMode),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textColor(isDarkMode)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chatName,
              style: TextStyle(
                color: _textColor(isDarkMode),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              widget.chatSubtitle,
              style: TextStyle(
                color: _subTextColor(isDarkMode),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Text(
                  widget.rating,
                  style: TextStyle(
                    color: _textColor(isDarkMode),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.star, color: Colors.amber, size: 20),
              ],
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: isDarkMode ? AppColors.darkBorders : Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      // Comparamos IDs reales
                      final bool isMe = message.senderId == myUserId;
                      
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: isMe ? _bubbleMeColor(isDarkMode) : _bubbleOtherColor(isDarkMode),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message.contenido,
                            style: TextStyle(
                              color: isMe
                                  ? (isDarkMode ? Colors.white : Colors.black87)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _buildTextInputArea(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildTextInputArea(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: _inputColor(isDarkMode),
        border: Border(
          top: BorderSide(
              color: isDarkMode ? AppColors.darkBorders : Colors.grey[300]!,
              width: 1.0),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                style: TextStyle(color: _textColor(isDarkMode)),
                decoration: InputDecoration(
                  hintText: 'Escribe tu mensaje...',
                  hintStyle: TextStyle(color: _subTextColor(isDarkMode)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(
                        color: isDarkMode ? AppColors.darkBorders : Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 0, 51, 102), width: 2.0),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.backgroundDark : Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send_outlined,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  size: 28),
              onPressed: _handleSendPressed,
            ),
          ],
        ),
      ),
    );
  }
}