import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importamos Provider
import '../../config/theme_provider.dart'; // Importamos tu ThemeProvider
import '../../config/appColors.dart';
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
  // ... (Tu lista chatData y lógica de filtrado se mantienen igual) ...
  final List<Map<String, dynamic>> chatData = [
    {
      "image":
          "https://img.vorecol.com/ia-images/1502/mazamitla-mariachi15.jpeg",
      "name": "Mariachi 'El Sol'",
      "message": "¡Mensaje nuevo!",
      "count": 2,
      "subtitle": "Gustavo",
      "rating": "4,6"
    },
    // ... (resto de datos) ...
     {
      "image":
          "https://boomerangfiesta.com/wp-content/uploads/2023/01/photo_2023-01-06_07-12-01-225x300.jpg",
      "name": "Payaso",
      "message": "¡Mensaje nuevo!",
      "count": 4,
      "subtitle": "Blinky",
      "rating": "4,2"
    },
    {
      "image":
          "https://d31gst00xgi6hm.cloudfront.net/0x500/ad-images/01hrf3e1j9mnxt2zbf4wb9w7ks/image-cf27d421f07bcb4a9dd1cc8080cc3461.png",
      "name": "Enanos",
      "message": "Enviado",
      "count": 0,
      "subtitle": "Equipo de 3",
      "rating": "4,9"
    },
    {
      "image":
          "https://showsparafiestas.org/wp-content/uploads/2012/05/salasa-778.jpg?w=564",
      "name": "Bailarines",
      "message": "Enviado",
      "count": 0, // 0 para no mostrar contador
      "subtitle": "Ballet Folklórico",
      "rating": "4,7"
    },
    {
      "image":
          "https://zubardubar.es/wp-content/uploads/2021/05/Alquila-un-bar-de-cocteleria-Bartender-para-fiesta-coctel.jpg",
      "name": "Bartender",
      "message": "¿Responder?",
      "count": 0, // 0 para no mostrar contador
      "subtitle": "Juan",
      "rating": "4,5"
    }
  ];

  List<Map<String, dynamic>> _filteredChatData = [];
  final _searchController = TextEditingController();

  void _notifyParentAboutUnreadStatus() {
    final bool hasUnread = chatData.any((chat) => (chat['count'] ?? 0) > 0);
    widget.onUnreadStatusChanged(hasUnread);
  }

  @override
  void initState() {
    super.initState();
    _filteredChatData = chatData;
    _searchController.addListener(_filterChats);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyParentAboutUnreadStatus();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterChats);
    _searchController.dispose();
    super.dispose();
  }

  void _filterChats() {
    final query = _searchController.text.toLowerCase();
    final List<Map<String, dynamic>> tempFilteredList;
    if (query.isEmpty) {
      tempFilteredList = chatData;
    } else {
      tempFilteredList = chatData.where((chat) {
        final chatName = chat['name'].toString().toLowerCase();
        return chatName.contains(query);
      }).toList();
    }
    setState(() {
      _filteredChatData = tempFilteredList;
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
    // Accedemos al estado global
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: _backgroundColor(isDarkMode), // Fondo dinámico
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título "Mensajes"
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Text(
                'Mensajes',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: _textColor(isDarkMode), // Texto dinámico
                ),
              ),
            ),

            // Barra de Búsqueda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                    color: _textColor(isDarkMode)), // Texto input dinámico
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  hintStyle: TextStyle(color: _subTextColor(isDarkMode)),
                  prefixIcon: Icon(Icons.search, color: _subTextColor(isDarkMode)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: _searchFieldColor(isDarkMode), // Fondo input dinámico
                ),
              ),
            ),

            const SizedBox(height: 16.0),

            // Lista de Mensajes
            Expanded(
              child: ListView.separated(
                itemCount: _filteredChatData.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: isDarkMode
                      ? AppColors.darkBorders
                      : const Color.fromARGB(255, 230, 230, 230), // Separador dinámico
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (context, index) {
                  final item = _filteredChatData[index];
                  final bool hasUnread = (item["message"] == "¡Mensaje nuevo!");
                  final bool hasBadge = (item["count"] > 0);

                  return ListTile(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            chatName: item["name"],
                            chatSubtitle: item["subtitle"] ?? "",
                            rating: item["rating"] ?? "N/A",
                          ),
                        ),
                      );

                      if (hasUnread || hasBadge) {
                        setState(() {
                          item["message"] = "Enviado";
                          item["count"] = 0;
                          _notifyParentAboutUnreadStatus();
                        });
                      }
                    },
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(item["image"]),
                      onBackgroundImageError: (exception, stackTrace) {},
                      backgroundColor: AppColors.lightGray,
                    ),
                    title: Text(
                      item["name"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _textColor(isDarkMode), // Título dinámico
                      ),
                    ),
                    subtitle: Text(
                      item["message"],
                      style: TextStyle(
                        color: hasUnread
                            ? (isDarkMode
                                ? Colors.white
                                : Colors.black) // Negrita si no leído
                            : _subTextColor(isDarkMode), // Gris si leído
                        fontWeight:
                            hasUnread ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: hasBadge
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: hasUnread
                                  ? AppColors.notificacion // Verde (se ve bien en dark)
                                  : (isDarkMode
                                      ? AppColors.darkButtons
                                      : AppColors.lightGray),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              item["count"].toString(),
                              style: TextStyle(
                                color: hasUnread
                                    ? AppColors.backgroundWhite
                                    : (isDarkMode
                                        ? Colors.white70
                                        : AppColors.gray),
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
          ],
        ),
      ),
    );
  }
}