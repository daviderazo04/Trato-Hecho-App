import 'package:flutter/material.dart';

// --- CAMBIO 1: Convertido a StatefulWidget ---
class ChatDetailScreen extends StatefulWidget {
  final String chatName;
  final String chatSubtitle;
  final String rating;

  const ChatDetailScreen({
    super.key,
    required this.chatName,
    required this.chatSubtitle,
    required this.rating,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  // --- CAMBIO 2: Creamos el controlador de texto ---
  final _textController = TextEditingController();

  // --- DATOS QUEMADOS PARA LOS MENSAJES DE CHAT ---
  // --- CAMBIO 3: La lista ya no es 'final' para poder añadir mensajes ---
  List<Map<String, String>> messages = [
    {
      "sender": "me",
      "text": "¡Buenas tardes! ¿Están disponibles para el sábado?"
    },
    {"sender": "other", "text": "Hola, ¡claro que sí! ¿A qué hora sería?"},
    {
      "sender": "me",
      "text": "Sería a las 8 PM. ¿Cuál es el costo por 2 horas?"
    },
    {
      "sender": "other",
      "text": "Para 2 horas serían \$X. Incluye equipo de sonido."
    },
    {"sender": "me", "text": "Perfecto, ¡reservado!"},
  ];
  // --- FIN DE DATOS QUEMADOS ---

  @override
  void dispose() {
    // Limpiamos el controlador cuando el widget se destruye
    _textController.dispose();
    super.dispose();
  }

  // --- CAMBIO 4: Creamos la función para manejar el envío ---
  void _handleSendPressed() {
    final text = _textController.text;
    // Si el texto no está vacío
    if (text.trim().isNotEmpty) {
      // Usamos setState para notificar a Flutter que el estado cambió
      setState(() {
        // Añadimos el nuevo mensaje a la lista
        messages.add({
          "sender": "me", // Los mensajes nuevos siempre son "me"
          "text": text,
        });
      });
      // Limpiamos el campo de texto
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // --- APPBAR PERSONALIZADA ---
      appBar: AppBar(
        // ... (el resto del AppBar no cambia)
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () =>
              Navigator.pop(context), // Regresa a la pantalla anterior
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // Usamos 'widget.' para acceder a las propiedades del StatefulWidget
              widget.chatName,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              widget.chatSubtitle,
              style: const TextStyle(
                color: Colors.black54,
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
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
              ],
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      // --- CUERPO DEL CHAT ---
      body: Column(
        children: [
          // 1. Lista de mensajes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              // La longitud ahora es dinámica
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final bool isMe = message["sender"] == "me";
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color.fromARGB(
                              255, 173, 202, 226) // Azul claro
                          : const Color.fromARGB(
                              255, 0, 51, 102), // Azul oscuro
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message["text"]!,
                      style: TextStyle(
                        color: isMe ? Colors.black87 : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 2. Campo de texto para escribir
          _buildTextInputArea(),
        ],
      ),
    );
  }

  // --- WIDGET PARA EL CAMPO DE TEXTO INFERIOR ---
  Widget _buildTextInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                // --- CAMBIO 5: Asignamos el controlador ---
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Escribe tu mensaje...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 0, 51, 102), width: 2.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.send_outlined,
                color: Colors.grey[600],
                size: 28,
              ),
              // --- CAMBIO 6: Asignamos la función de envío ---
              onPressed: _handleSendPressed,
            ),
          ],
        ),
      ),
    );
  }
}
