import 'package:flutter/material.dart';
import '../../config/appColors.dart';

///
/// Este es nuestro Widget reutilizable para la barra de navegación.
///
class CustomBottomNavBar extends StatelessWidget {
  // Ahora acepta el índice actual y una función para manejar el "tap"
  final int currentIndex;
  final Function(int) onTap;

  // --- CAMBIO 1: Añadimos la nueva propiedad ---
  final bool hasUnreadMessages;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    // --- CAMBIO 2: La aceptamos en el constructor ---
    this.hasUnreadMessages = false, // Valor por defecto
  });

  @override
  Widget build(BuildContext context) {
    // Color para el icono activo
    const Color activeColor = Color.fromARGB(255, 255, 255, 255);
    // Color para el icono inactivo (un poco opaco)
    const Color inactiveColor = Color.fromARGB(150, 255, 255, 255);

    return BottomAppBar(
      color: Colors.white,
      elevation: 0,
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: AppColors.primary,
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
            // --- Icono de Home (Índice 0) ---
            IconButton(
              icon: Icon(currentIndex == 0 ? Icons.home : Icons.home_outlined),
              // --- CAMBIO 3: Lógica de color activo/inactivo ---
              color: currentIndex == 0 ? activeColor : inactiveColor,
              iconSize: 32.0,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(), // Asegura centrado
              onPressed: () => onTap(0),
            ),

            // --- Icono de Búsqueda (Índice 1) ---
            IconButton(
              icon: Icon(
                  currentIndex == 1 ? Icons.search : Icons.search_outlined),
              color: currentIndex == 1 ? activeColor : inactiveColor,
              iconSize: 32.0,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => onTap(1),
            ),

            // --- CAMBIO 4: Icono de Chat (Índice 2) ---
            // Envolvemos el IconButton en un Stack
            Stack(
              clipBehavior: Clip.none, // Permite que la burbuja se salga
              children: [
                IconButton(
                  icon: Icon(currentIndex == 2
                      ? Icons.chat_bubble
                      : Icons.chat_bubble_outline),
                  color: currentIndex == 2 ? activeColor : inactiveColor,
                  iconSize: 32.0,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => onTap(2),
                ),
                // --- CAMBIO 5: Esta es la burbuja de notificación ---
                if (hasUnreadMessages) // Solo se muestra si es true
                  Positioned(
                    top: 0, // Ajusta la posición vertical
                    right: 5, // Ajusta la posición horizontal
                    child: Container(
                      width: 15, // Tamaño de la burbuja
                      height: 15,
                      decoration: BoxDecoration(
                        // El color verde de tus chats
                        color: AppColors.notificacion,
                        shape: BoxShape.circle,
                        // Borde opcional para que resalte sobre la barra
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // --- Icono de Perfil (Índice 3) ---
            IconButton(
              icon:
                  Icon(currentIndex == 3 ? Icons.person : Icons.person_outline),
              color: currentIndex == 3 ? activeColor : inactiveColor,
              iconSize: 32.0,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}