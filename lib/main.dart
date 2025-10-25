import 'package:flutter/material.dart';
// Importamos los nuevos archivos que creamos
import 'screens/chatView/messages_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';

// --- CAMBIO 1: Importamos las pantallas que creamos antes ---
import 'screens/homeView/home_screen.dart';
import 'screens/proveedorView/proveedor_screen.dart';

// No olvides importar tu AppTheme si lo vas a usar.
// import 'config/AppTheme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TratoHecho',
      // theme: AppTheme.lightTheme,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Sora',
      ),
      debugShowCheckedModeBanner: false,
      home:
          const HomeScreen(), // HomeScreen ahora es nuestro controlador principal
    );
  }
}

// CAMBIO: Convertimos HomeScreen a StatefulWidget para manejar el estado
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variable para guardar el índice de la pestaña seleccionada
  int _selectedIndex = 0; // <-- 0 = Home, 1 = Lupa, 2 = Mensajes, 3 = Perfil

  // Lista de las pantallas (Widgets) que queremos mostrar
  static final List<Widget> _widgetOptions = <Widget>[
    // Pantalla 0: Home principal
    HomeFeedScreen(),
    // Pantalla 1: Búsqueda (por ahora un placeholder)
    Center(
      child: Text(
        'Página de Búsqueda',
        style: TextStyle(fontSize: 24),
      ),
    ),
    // Pantalla 2: Mensajes (nuestra nueva pantalla)
    MessagesScreen(),

    // --- CAMBIO 2: La pestaña de Perfil (índice 3) ahora muestra tu pantalla ---
    HomeContentScreen(),
  ];

  // Función que actualiza el estado cuando se presiona una pestaña
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ya no hay AppBar aquí, cada pantalla puede tener la suya si la necesita

      // CAMBIO: El body ahora es la pantalla seleccionada de nuestra lista
      body: _widgetOptions.elementAt(_selectedIndex),

      // CAMBIO: Usamos nuestro widget CustomBottomNavBar y le pasamos el estado
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// YA NO NECESITAMOS la clase CustomBottomNavBar aquí,
// porque la hemos movido a su propio archivo (lib/widgets/custom_bottom_nav_bar.dart).
