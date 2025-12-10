import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../config/user_provider.dart'; // Para obtener mi ID
import '../../config/appColors.dart';
import '../../services/chat_service.dart'; // Importamos el servicio
import '../../models/chat_models.dart';    // Importamos los modelos
import 'chat_detail_screen.dart';

class MessagesScreen extends StatefulWidget {
  final Function(bool) onUnreadStatusChanged;

  const MessagesScreen({
    super.key,
    required this.onUnreadStatusChanged,
  });

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ChatService _chatService = ChatService();
  final _searchController = TextEditingController();
  Timer? _autoRefreshTimer;
  
  List<InboxChat> _allChats = [];      // Lista original de la API
  List<InboxChat> _filteredChats = []; // Lista filtrada para mostrar
  bool _isLoading = true;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterChats);
    // Cargamos los chats al iniciar
    _loadChats();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Carga los datos del API
  Future<void> _loadChats({bool silent = false}) async {
    if (_isFetching) return; // evitamos peticiones duplicadas si el timer coincide
    _isFetching = true;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final myUserId = userProvider.userId;

    if (myUserId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _allChats = [];
          _filteredChats = [];
        });
      }
      _isFetching = false;
      return;
    }

    try {
      final chats = await _chatService.getInbox(myUserId);
      
      if (mounted) {
        setState(() {
          _allChats = chats;
          _filteredChats = _applySearchFilter();
          _isLoading = false;
        });
        
        // Notificar al padre si hay mensajes sin leer
        _checkUnreadStatus();
      }
    } catch (e) {
      print("Error cargando inbox: $e");
      if (mounted && !silent) setState(() => _isLoading = false);
    } finally {
      _isFetching = false;
    }
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadChats(silent: true);
    });
  }

  void _checkUnreadStatus() {
    final hasUnread = _allChats.any((chat) => chat.unreadCount > 0);
    widget.onUnreadStatusChanged(hasUnread);
  }

  List<InboxChat> _applySearchFilter() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _allChats;
    return _allChats.where((chat) {
      return chat.chatName.toLowerCase().contains(query);
    }).toList();
  }

  void _filterChats() {
    setState(() {
      _filteredChats = _applySearchFilter();
    });
  }

  // --- HELPERS PARA MODO OSCURO ---
  Color _backgroundColor(bool isDark) =>
      isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color _textColor(bool isDark) =>
      isDark ? AppColors.darkText : AppColors.textPrimary;
  Color _subTextColor(bool isDark) =>
      isDark ? Colors.grey[400]! : AppColors.textSecondary;
  Color _searchFieldColor(bool isDark) =>
      isDark ? AppColors.darkButtons : AppColors.lightGray;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: _backgroundColor(isDarkMode),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Text(
                'Mensajes',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: _textColor(isDarkMode),
                ),
              ),
            ),

            // Buscador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: _textColor(isDarkMode)),
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  hintStyle: TextStyle(color: _subTextColor(isDarkMode)),
                  prefixIcon: Icon(Icons.search, color: _subTextColor(isDarkMode)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: _searchFieldColor(isDarkMode),
                ),
              ),
            ),

            const SizedBox(height: 16.0),

            // Lista
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.primary))
                  : RefreshIndicator(
                      onRefresh: () => _loadChats(silent: true),
                      child: _filteredChats.isEmpty
                          ? Center(
                              child: Text(
                                "No tienes mensajes aún",
                                style: TextStyle(color: _subTextColor(isDarkMode)),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _filteredChats.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                thickness: 1,
                                color: isDarkMode
                                    ? AppColors.darkBorders
                                    : const Color.fromARGB(255, 230, 230, 230),
                                indent: 16,
                                endIndent: 16,
                              ),
                              itemBuilder: (context, index) {
                                final item = _filteredChats[index];
                                final bool hasUnread = item.unreadCount > 0;

                                return ListTile(
                                  onTap: () async {
                                    // Navegamos al detalle
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatDetailScreen(
                                          conId: item.conId, // Pasamos el ID real
                                          chatName: item.chatName,
                                          chatSubtitle: item.subtitle,
                                          rating: item.rating.toStringAsFixed(1),
                                          serviceId: item.serviceId,
                                        ),
                                      ),
                                    );
                                    // Al volver, recargamos la lista para limpiar notificaciones
                                    _loadChats(silent: true);
                                  },
                                  leading: CircleAvatar(
                                    radius: 28,
                                    backgroundImage: NetworkImage(item.chatImage),
                                    onBackgroundImageError: (_, __) {},
                                    backgroundColor: AppColors.lightGray,
                                  ),
                                  title: Text(
                                    item.chatName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _textColor(isDarkMode),
                                    ),
                                  ),
                                  subtitle: Text(
                                    item.lastMessage,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: hasUnread
                                          ? (isDarkMode ? Colors.white : Colors.black)
                                          : _subTextColor(isDarkMode),
                                      fontWeight: hasUnread
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  trailing: hasUnread
                                      ? Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.notificacion,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            item.unreadCount.toString(),
                                            style: TextStyle(
                                              color: AppColors.backgroundWhite,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        )
                                      : null,
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
