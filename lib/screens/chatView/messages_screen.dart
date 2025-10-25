import 'package:flutter/material.dart';
// --- IMPORTAMOS LA PANTALLA DE CHAT ---
import 'chat_detail_screen.dart';

// --- CAMBIO 1: Convertido a StatefulWidget ---
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  // --- CAMBIO 2: Movemos la lista al State y quitamos 'final' y 'const' ---
  // Esto nos permite modificar la lista.
  List<Map<String, dynamic>> chatData = [
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
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none, // Sin borde
                ),
                filled: true, // Con fondo relleno
                fillColor: Colors.grey[200], // Color de fondo gris claro
              ),
            ),
          ),

          // Espacio para que la lista crezca
          const SizedBox(height: 16.0),

          // --- INICIO DE LA LISTA DE MENSAJES ---
          Expanded(
            child: ListView.separated(
              itemCount: chatData.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 1,
                color: Color.fromARGB(255, 230, 230, 230),
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                // Ahora usamos la lista del state
                final item = chatData[index];
                final bool hasUnread = (item["message"] == "¡Mensaje nuevo!");
                final bool hasBadge = (item["count"] > 0);

                // Usamos ListTile, es perfecto para esta estructura
                return ListTile(
                  // --- CAMBIO 3: Hacemos el onTap 'async' ---
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
                      // Usamos setState para redibujar la pantalla con los datos nuevos
                      setState(() {
                        // Cambiamos los datos en nuestra lista
                        chatData[index]["message"] =
                            "Enviado"; // O "Visto", como prefieras
                        chatData[index]["count"] = 0;
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
                    backgroundColor: Colors.grey[200], // Fondo si no carga
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
                      color: hasUnread ? Colors.black : Colors.grey[600],
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
                                ? const Color.fromARGB(255, 26, 188, 156)
                                : Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            item["count"].toString(),
                            style: TextStyle(
                              color:
                                  hasUnread ? Colors.white : Colors.grey[700],
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
