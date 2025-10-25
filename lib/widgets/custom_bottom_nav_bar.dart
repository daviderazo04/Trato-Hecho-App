import 'package:flutter/material.dart';

///
/// Este es nuestro Widget reutilizable para la barra de navegación.
///
class CustomBottomNavBar extends StatelessWidget {
  // Ahora acepta el índice actual y una función para manejar el "tap"
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 0,
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(59, 96, 125, 1),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: const Color.fromRGBO(59, 96, 125, 1),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Icono de Home
            IconButton(
              // CAMBIO: El icono cambia si está seleccionado
              icon: Icon(currentIndex == 0 ? Icons.home : Icons.home_outlined),
              color: const Color.fromARGB(255, 255, 255, 255),
              iconSize: 32.0,
              padding: EdgeInsets.zero,
              // CAMBIO: Llama a la función onTap con el índice 0
              onPressed: () => onTap(0),
            ),
            // Icono de Búsqueda
            IconButton(
              icon: Icon(currentIndex == 1
                  ? Icons.search
                  : Icons.search_outlined), // Asumiendo que 'search_outlined' existe o usa 'search'
              color: const Color.fromARGB(255, 255, 255, 255),
              iconSize: 32.0,
              padding: EdgeInsets.zero,
              onPressed: () => onTap(1),
            ),
            // Icono de Chat
            IconButton(
              icon: Icon(currentIndex == 2
                  ? Icons.chat_bubble
                  : Icons.chat_bubble_outline),
              color: const Color.fromARGB(255, 255, 255, 255),
              iconSize: 32.0,
              padding: EdgeInsets.zero,
              onPressed: () => onTap(2), // Este es el que nos importa
            ),
            // Icono de Perfil
            IconButton(
              icon: Icon(currentIndex == 3
                  ? Icons.person
                  : Icons.person_outline),
              color: const Color.fromARGB(255, 255, 255, 255),
              iconSize: 32.0,
              padding: EdgeInsets.zero,
              onPressed: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}
