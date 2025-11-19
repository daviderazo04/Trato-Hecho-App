import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your files
import 'screens/chatView/messages_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import 'screens/homeView/home_screen.dart';
import 'screens/searchView/search_screen.dart';

// Importamos tu nueva vista de usuario
import 'screens/usuarioView/usuarioView.dart';
import 'config/theme_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'screens/welcomeView/welcome_screen.dart';

void main() async {
  // 2. Ensure binding is initialized because we are using async code in main
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Check Shared Preferences
  final prefs = await SharedPreferences.getInstance();
  // Try to get the boolean. If it doesn't exist (first time), return false.
  final bool seenWelcome = prefs.getBool('seenWelcome') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      // 4. Pass the 'seenWelcome' flag to MyApp
      child: MyApp(startWithWelcome: !seenWelcome),
    ),
  );
}

class MyApp extends StatelessWidget {
  // 5. Accept the flag in the constructor
  final bool startWithWelcome;

  const MyApp({super.key, required this.startWithWelcome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TratoHecho',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Sora',
      ),
      debugShowCheckedModeBanner: false,
      // 6. Decide which screen to show first based on the flag
      home: startWithWelcome ? const WelcomeScreen() : const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  // Variable para guardar el índice de la pestaña seleccionada
  int _selectedIndex = 0;

  // Note: Ensure HomeFeedScreen is imported or defined

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
