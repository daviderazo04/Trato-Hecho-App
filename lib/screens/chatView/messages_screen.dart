import 'package:flutter/material.dart';
// --- IMPORTAMOS LA PANTALLA DE CHAT ---
import 'chat_detail_screen.dart';
import '../../config/appColors.dart';

// --- CAMBIO 1: Añadimos un callback al constructor ---
class MessagesScreen extends StatefulWidget {
  // Esta función será llamada cada vez que el estado de "no leídos" cambie
  final Function(bool) onUnreadStatusChanged;

  const MessagesScreen({
    super.key,
    required this.onUnreadStatusChanged, // Hacemos que sea requerido
  });

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  // Esta es nuestra lista "Maestra"
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
  // --- FIN DE DATOS QUEMADOS ---

  // Esta lista contendrá los chats que coinciden con la búsqueda
  List<Map<String, dynamic>> _filteredChatData = [];
  // Controlador para el campo de texto
  final _searchController = TextEditingController();

  // --- CAMBIO 2: Creamos una función para notificar al padre ---
  void _notifyParentAboutUnreadStatus() {
    // Verificamos si algún chat en la lista original tiene un contador > 0
    final bool hasUnread =
        chatData.any((chat) => (chat['count'] ?? 0) > 0);
    // Llamamos a la función callback que nos pasó el MainNavigator
    widget.onUnreadStatusChanged(hasUnread);
  }

  @override
  void initState() {
    super.initState();
    // Al inicio, la lista filtrada es igual a la lista completa
    _filteredChatData = chatData;
    // Añadimos un "escuchador" al controlador
    _searchController.addListener(_filterChats);

    // --- CAMBIO 3: Notificamos el estado inicial al arrancar ---
    // (Usamos un frame de retraso para asegurar que el widget padre esté listo)
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

  // --- Función de Filtrado ---
  void _filterChats() {
    // Obtenemos el texto de búsqueda (en minúsculas)
    final query = _searchController.text.toLowerCase();

    // Creamos una nueva lista temporal
    final List<Map<String, dynamic>> tempFilteredList;

    if (query.isEmpty) {
      // Si la búsqueda está vacía, mostramos todos los chats
      tempFilteredList = chatData;
    } else {
      // Si hay texto, filtramos la lista maestra
      tempFilteredList = chatData.where((chat) {
        // Obtenemos el nombre del chat (en minúsculas)
        final chatName = chat['name'].toString().toLowerCase();
        // Devolvemos 'true' si el nombre contiene el texto de búsqueda
        return chatName.contains(query);
      }).toList(); // Convertimos el resultado a una Lista
    }

    // Actualizamos el estado para redibujar la UI con la lista filtrada
    setState(() {
      _filteredChatData = tempFilteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un SafeArea para evitar que el contenido se solape con la barra de estado
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título "Mensajes"
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Text(
              'Mensajes',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Barra de Búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none, // Sin borde
                ),
                filled: true, // Con fondo relleno
                fillColor: AppColors.lightGray, // Color de fondo gris claro
              ),
            ),
          ),

          // Espacio para que la lista crezca
          const SizedBox(height: 16.0),

          // --- INICIO DE LA LISTA DE MENSAJES ---
          Expanded(
            child: ListView.separated(
              itemCount: _filteredChatData.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 1,
                color: Color.fromARGB(255, 230, 230, 230),
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                // Obtenemos el item de la lista FILTRADA
                final item = _filteredChatData[index];

                final bool hasUnread = (item["message"] == "¡Mensaje nuevo!");
                final bool hasBadge = (item["count"] > 0);

                // Usamos ListTile, es perfecto para esta estructura
                return ListTile(
                  onTap: () async {
                    // Navegamos a la pantalla de detalle y ESPERAMOS a que regrese
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

                    // --- CAMBIO 4: Cuando el usuario regresa, actualizamos el estado ---
                    // Verificamos si este item tenía mensajes nuevos
                    if (hasUnread || hasBadge) {
                      setState(() {
                        // Modificamos el item. Esto funciona porque
                        // _filteredChatData y chatData apuntan a los mismos Mapas.
                        item["message"] = "Enviado";
                        item["count"] = 0;

                        // Notificamos al padre que el estado de "no leídos" pudo haber cambiado
                        _notifyParentAboutUnreadStatus();
                      });
                    }
                  },
                  // 'leading' es el widget a la izquierda (el avatar)
                  leading: CircleAvatar(
                    radius: 28, // Tamaño del círculo
                    backgroundImage: NetworkImage(item["image"]),
                    onBackgroundImageError: (exception, stackTrace) {
                      print(
                          'Error al cargar la imagen ${item["name"]}: $exception');
                    },
                    backgroundColor: AppColors.lightGray, // Fondo si no carga
                  ),

                  // 'title' es el texto principal
                  title: Text(
                    item["name"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // 'subtitle' es el texto secundario
                  subtitle: Text(
                    item["message"],
                    style: TextStyle(
                      color: hasUnread ? AppColors.borders : AppColors.gray,
                      fontWeight:
                          hasUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),

                  // 'trailing' es el widget a la derecha (el contador)
                  trailing: hasBadge
                      ? Container(
                          padding: const EdgeInsets.all(
                              8), // Relleno dentro del círculo
                          decoration: BoxDecoration(
                            color: hasUnread
                                ? AppColors.notificacion
                                : AppColors.lightGray,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            item["count"].toString(),
                            style: TextStyle(
                              color:
                                  hasUnread ? AppColors.backgroundWhite : AppColors.gray,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : null, // Si count es 0, no mostramos nada
                );
              },
            ),
          ),
          // --- FIN DE LA LISTA DE MENSAJES ---
        ],
      ),
    );
  }
}