import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../config/user_provider.dart';
import '../../config/appColors.dart';
import '../../services/chat_service.dart';
import '../../models/chat_models.dart';

class ChatDetailScreen extends StatefulWidget {
  final int? conId;
  final int? receiverId;
  // --- 1. AGREGAMOS EL CAMPO AQUÍ ---
  final int? serviceId;
  // ----------------------------------
  final String chatName;
  final String chatSubtitle;
  final String rating;
  final String? serviceImage;

  const ChatDetailScreen({
    super.key,
    this.conId,
    this.receiverId,
    // --- 2. Y LO AGREGAMOS AL CONSTRUCTOR ---
    this.serviceId,
    // ----------------------------------------
    required this.chatName,
    required this.chatSubtitle,
    required this.rating,
    this.serviceImage,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final _textController = TextEditingController();
  final ScrollController _listController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  int? _currentConId;
  int? _currentServiceId;

  @override
  void initState() {
    super.initState();
    _currentConId = widget.conId;
    _currentServiceId = widget.serviceId;
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final myUserId = Provider.of<UserProvider>(context, listen: false).userId;
    if (myUserId == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Buscamos si existe chat para ESTE servicio específico
    if (_currentConId == null && widget.receiverId != null) {
      try {
        // Pasamos el serviceId a la búsqueda
        final existingId = await _chatService.checkConversation(
            myUserId, widget.receiverId!,
            serviceId: widget.serviceId);

        if (existingId != null) {
          _currentConId = existingId;
        }
      } catch (e) {
        print("Error buscando conversación: $e");
      }
    }

    if (_currentConId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final msgs = await _chatService.getHistory(_currentConId!, myUserId);
      if (mounted) {
        // Si no tenemos serviceId, tratamos de obtenerlo de los mensajes
        int? firstServiceId;
        for (final m in msgs) {
          if (m.serviceId != null && m.serviceId! > 0) {
            firstServiceId = m.serviceId;
            break;
          }
        }

        setState(() {
          _messages = msgs;
          _isLoading = false;
          _currentServiceId = _currentServiceId ?? firstServiceId;
        });
        _scrollToBottom();
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

    final String localId =
        'local_${DateTime.now().microsecondsSinceEpoch.toString()}';
    final pendingMessage = ChatMessage(
      msjId: -1,
      contenido: text,
      fechaEnvio: DateTime.now().toIso8601String(),
      senderId: myUserId,
      senderName: '',
      serviceId: _currentServiceId,
      isPending: true,
      isFailed: false,
      localId: localId,
    );

    setState(() {
      _messages.add(pendingMessage);
    });
    _scrollToBottom();
    _textController.clear();

    try {
      final newMessage = await _chatService.sendMessage(
        senderId: myUserId,
        receiverId: widget.receiverId,
        conId: _currentConId,
        serviceId:
            _currentServiceId, // Usamos el ID si lo tenemos
        content: text,
      );

      if (!mounted) return;

      if (newMessage != null) {
        setState(() {
          _replaceLocalMessage(localId, newMessage);
        });

        if (_currentConId == null && widget.receiverId != null) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;
          final newConId = await _chatService.checkConversation(
              myUserId, widget.receiverId!,
              serviceId: widget.serviceId);
          if (newConId != null) {
            if (!mounted) return;
            setState(() {
              _currentConId = newConId;
            });
          }
        }
      } else {
        setState(() {
          _markLocalFailed(localId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "No se pudo enviar el mensaje. Comprueba tu conexión.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      print("Error sending: $e");
      if (mounted) {
        setState(() {
          _markLocalFailed(localId);
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al enviar mensaje")),
      );
    }
  }

  void _replaceLocalMessage(String localId, ChatMessage newMessage) {
    final int index = _messages.indexWhere(
        (msg) => msg.localId != null && msg.localId == localId);
    final ChatMessage mergedMessage = ChatMessage(
      msjId: newMessage.msjId,
      contenido: newMessage.contenido,
      fechaEnvio: newMessage.fechaEnvio,
      senderId: newMessage.senderId,
      senderName: newMessage.senderName,
      serviceId: newMessage.serviceId ?? _currentServiceId,
      isPending: false,
      isFailed: false,
      localId: null,
    );

    if (index >= 0) {
      _messages[index] = mergedMessage;
    } else {
      _messages.add(mergedMessage);
    }
    _scrollToBottom();
  }

  void _markLocalFailed(String localId) {
    final int index = _messages.indexWhere(
        (msg) => msg.localId != null && msg.localId == localId);
    if (index >= 0) {
      final old = _messages[index];
      _messages[index] = ChatMessage(
        msjId: old.msjId,
        contenido: old.contenido,
        fechaEnvio: old.fechaEnvio,
        senderId: old.senderId,
        senderName: old.senderName,
        serviceId: old.serviceId,
        isPending: false,
        isFailed: true,
        localId: old.localId,
      );
    }
  }

  Future<void> _retryMessage(ChatMessage message) async {
    if (message.isPending) return;
    final myUserId = Provider.of<UserProvider>(context, listen: false).userId;
    if (myUserId == null) return;

    final String retryLocalId =
        message.localId ?? 'local_${DateTime.now().microsecondsSinceEpoch}';

    setState(() {
      final idx = _messages.indexOf(message);
      if (idx >= 0) {
        _messages[idx] = ChatMessage(
          msjId: message.msjId,
          contenido: message.contenido,
          fechaEnvio: DateTime.now().toIso8601String(),
          senderId: message.senderId,
          senderName: message.senderName,
          serviceId: message.serviceId,
          isPending: true,
          isFailed: false,
          localId: retryLocalId,
        );
      }
    });
    _scrollToBottom();

    try {
      final newMessage = await _chatService.sendMessage(
        senderId: myUserId,
        receiverId: widget.receiverId,
        conId: _currentConId,
        serviceId: _currentServiceId,
        content: message.contenido,
      );

      if (!mounted) return;

      if (newMessage != null) {
        setState(() {
          _replaceLocalMessage(retryLocalId, newMessage);
        });
      } else {
        setState(() {
          _markLocalFailed(retryLocalId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("No se pudo enviar el mensaje. Comprueba tu conexión."),
              backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      print("Error retrying: $e");
      if (mounted) {
        setState(() {
          _markLocalFailed(retryLocalId);
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No se pudo enviar el mensaje. Comprueba tu conexión.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_listController.hasClients) {
        _listController.animateTo(
          _listController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Helpers de color
  Color _backgroundColor(bool isDark) =>
      isDark ? AppColors.backgroundDark : Colors.white;
  Color _appBarColor(bool isDark) =>
      isDark ? AppColors.backgroundDark : Colors.white;
  Color _textColor(bool isDark) => isDark ? AppColors.darkText : Colors.black;
  Color _subTextColor(bool isDark) =>
      isDark ? Colors.grey[400]! : Colors.black54;
  Color _bubbleMeColor(bool isDark) => isDark
      ? const Color.fromRGBO(59, 96, 125, 1)
      : const Color.fromARGB(255, 173, 202, 226);
  Color _bubbleOtherColor(bool isDark) =>
      isDark ? AppColors.darkButtons : const Color.fromARGB(255, 0, 51, 102);
  Color _inputColor(bool isDark) =>
      isDark ? AppColors.darkButtons : Colors.white;

  @override
  void dispose() {
    _textController.dispose();
    _listController.dispose();
    super.dispose();
  }

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
        title: Row(
          children: [
            if (widget.serviceImage != null)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.serviceImage!),
                  radius: 20,
                ),
              ),
            // Allow the title area to take available space and wrap text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Auto-scrolling horizontal title to avoid overflow
                  _AutoScrollText(
                    text: widget.chatName,
                    style: TextStyle(
                      color: _textColor(isDarkMode),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    pauseDuration: const Duration(milliseconds: 900),
                  ),
                  Text(
                    widget.chatSubtitle,
                    style: TextStyle(
                      color: _subTextColor(isDarkMode),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _listController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final bool isMe = message.senderId == myUserId;
                      final bool isPending = message.isPending;
                      final bool isFailed = message.isFailed;
                      final Color statusColor =
                          isFailed ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black54);

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: isFailed
                                ? Colors.red.withOpacity(0.75)
                                : isPending
                                    ? _bubbleMeColor(isDarkMode)
                                        .withOpacity(0.7)
                                    : isMe
                                        ? _bubbleMeColor(isDarkMode)
                                        : _bubbleOtherColor(isDarkMode),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.contenido,
                                style: TextStyle(
                                  color: isFailed
                                      ? Colors.white
                                      : isMe
                                          ? (isDarkMode
                                              ? Colors.white
                                              : Colors.black87)
                                          : Colors.white,
                                ),
                              ),
                              if (isPending || isFailed) ...[
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: isMe
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      isFailed
                                          ? Icons.error_outline
                                          : Icons.schedule,
                                      size: 14,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isFailed
                                          ? 'No se pudo enviar'
                                          : 'Enviando...',
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (isFailed) ...[
                                      const SizedBox(width: 12),
                                      TextButton(
                                        onPressed: () => _retryMessage(message),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text(
                                          'Reenviar',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ],
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
                        color: isDarkMode
                            ? AppColors.darkBorders
                            : Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 0, 51, 102), width: 2.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  filled: true,
                  fillColor:
                      isDarkMode ? AppColors.backgroundDark : Colors.white,
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

// Auto-scrolling horizontal text widget (marquee-like) used for long titles
class _AutoScrollText extends StatefulWidget {
  const _AutoScrollText({
    required this.text,
    this.style,
    this.pauseDuration = const Duration(milliseconds: 800),
  });

  final String text;
  final TextStyle? style;
  final Duration pauseDuration;

  @override
  State<_AutoScrollText> createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<_AutoScrollText> {
  final ScrollController _scrollController = ScrollController();
  bool _shouldScroll = false;
  double _maxScroll = 0.0;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndStart());
  }

  @override
  void didUpdateWidget(covariant _AutoScrollText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      // restart check when text changes
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndStart());
    }
  }

  Future<void> _checkAndStart() async {
    if (!mounted) return;
    // allow layout to settle
    await Future.delayed(const Duration(milliseconds: 50));
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    setState(() {
      _maxScroll = max;
      _shouldScroll = max > 0.5;
    });
    if (_shouldScroll && !_running) {
      _running = true;
      _startLoop();
    }
  }

  Future<void> _startLoop() async {
    while (mounted && _shouldScroll) {
      try {
        // scroll to end
        final distance = _maxScroll;
        const double velocity = 40.0; // pixels per second
        final durationMillis =
            (distance / velocity * 1000).clamp(300, 20000).toInt();
        await _scrollController.animateTo(
          _maxScroll,
          duration: Duration(milliseconds: durationMillis),
          curve: Curves.linear,
        );

        await Future.delayed(widget.pauseDuration);

        // scroll back to start
        await _scrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: durationMillis),
          curve: Curves.linear,
        );

        await Future.delayed(widget.pauseDuration);
      } catch (_) {
        // animation cancelled or controller disposed
        break;
      }
    }
    _running = false;
  }

  @override
  void dispose() {
    _running = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (widget.style?.fontSize ??
              DefaultTextStyle.of(context).style.fontSize ??
              16) *
          1.3,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.text,
            style: widget.style,
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }
}
