import 'package:flutter/material.dart';
// Importamos los nuevos archivos que creamos
import 'screens/chatView/messages_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';

// Importamos las pantallas que creamos antes
import 'screens/homeView/home_screen.dart';
import 'screens/searchView/search_screen.dart';

// --- CAMBIO 1: Importamos tu nueva vista de usuario ---
import 'screens/usuarioView/usuarioView.dart';

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
      home: const MainNavigator(), // Renombrado de HomeScreen para claridad
    );
  }
}

// Renombrado de HomeScreen a MainNavigator para que sea más claro
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  // Variable para guardar el índice de la pestaña seleccionada
  int _selectedIndex = 0; // <-- 0 = Home, 1 = Lupa, 2 = Mensajes, 3 = Perfil

  // Lista de las pantallas (Widgets) que queremos mostrar
  static final List<Widget> _widgetOptions = <Widget>[
    // Pantalla 0: Home principal
    HomeFeedScreen(), // Asumiendo que esta es tu vista principal de "home"
    // Pantalla 1: Búsqueda (por ahora un placeholder)
    const SearchScreen(),
    // Pantalla 2: Mensajes (nuestra nueva pantalla)
    MessagesScreen(),

    // --- CAMBIO 2: La pestaña de Perfil (índice 3) ahora muestra tu pantalla ---
    const UsuarioView(),
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

      // El body ahora es la pantalla seleccionada de nuestra lista
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),

      // Usamos nuestro widget CustomBottomNavBar y le pasamos el estado
      // Asumiendo que tu custom_bottom_nav_bar usa 'currentIndex' y 'onTap'
      // Si usa 'selectedIndex' y 'onItemTapped', cambia los nombres aquí.
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// YA NO NECESITAMOS la clase CustomBottomNavBar aquí,
// porque la hemos movido a su propio archivo (lib/widgets/custom_bottom_nav_bar.dart).

// NOTA: Tu 'HomeFeedScreen' (o como se llame tu pantalla de home)
// y 'HomeContentScreen' deben estar definidos en sus respectivos archivos.
// Aquí asumí que 'HomeFeedScreen' es la pantalla de índice 0.
