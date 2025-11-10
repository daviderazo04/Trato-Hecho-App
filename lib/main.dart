import 'package:flutter/material.dart';
// Importamos los nuevos archivos que creamos
import 'screens/chatView/messages_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';

// Importamos las pantallas que creamos antes
import 'screens/homeView/home_screen.dart';
import 'screens/searchView/search_screen.dart';

// Importamos tu nueva vista de usuario
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
  int _selectedIndex = 0;

  // --- CAMBIO 1: Creamos una variable de estado para la notificación ---
  bool _hasUnreadMessages = false;

  // --- CAMBIO 2: Creamos la función que recibirá el aviso ---
  void _updateUnreadStatus(bool hasUnread) {
    // Usamos setState para guardar el valor y redibujar si es necesario
    // (Añadimos 'mounted' por seguridad)
    if (mounted) {
      setState(() {
        _hasUnreadMessages = hasUnread;
      });
    }
  }

  // --- CAMBIO 3: La lista de widgets ya NO puede ser 'static final' ---
  // Debe ser una variable de la clase para poder acceder a '_updateUnreadStatus'
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Inicializamos la lista aquí, pasando el callback a MessagesScreen
    _widgetOptions = <Widget>[
      HomeFeedScreen(), // Pantalla 0: Home
      const SearchScreen(), // Pantalla 1: Búsqueda
      MessagesScreen(
        // Pantalla 2: Mensajes
        // Le pasamos nuestra función de callback
        onUnreadStatusChanged: _updateUnreadStatus,
      ),
      const UsuarioView(), // Pantalla 3: Perfil
    ];
  }

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
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // --- CAMBIO 4: Pasamos el estado de "no leídos" a la barra ---
        hasUnreadMessages: _hasUnreadMessages,
      ),
    );
  }
}