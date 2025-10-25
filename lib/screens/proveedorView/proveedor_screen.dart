import 'package:flutter/material.dart';
import 'new_service_screen.dart'; // Importamos la pantalla que creamos

class HomeContentScreen extends StatelessWidget {
  const HomeContentScreen({super.key});

  // Color primario de tu app (lo tomo de tu NavBar)
  static const Color primaryColor = Color.fromRGBO(59, 96, 125, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Inicio',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor, // Color de fondo del botón
            foregroundColor: Colors.white, // Color del texto
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), // Bordes redondeados
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            // Esta es la acción: navegar a la pantalla de Nuevo Servicio
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NewServiceScreen(),
              ),
            );
          },
          child: const Text('Añadir Servicio'),
        ),
      ),
    );
  }
}
