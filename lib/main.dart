import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/chatView/messages_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import 'screens/homeView/home_screen.dart';
import 'screens/searchView/search_screen.dart';
import 'screens/usuarioView/usuarioView.dart';
import 'config/theme_provider.dart';
import 'config/user_provider.dart'; 
import 'screens/welcomeView/welcome_screen.dart';
import 'screens/auth/login_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  final prefs = await SharedPreferences.getInstance();
  final bool seenWelcome = prefs.getBool('seenWelcome') ?? false;
  final bool isDark = prefs.getBool('isDarkMode') ?? false;
  final String fontSizeLabel = prefs.getString('fontSizeLabel') ?? '14 pt';
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(
            isDark: isDark,
            fontSizeLabel: fontSizeLabel,
            isLoggedIn: isLoggedIn,
          ),
        ),
        // CAMBIO: Inicializamos y cargamos las preferencias del usuario
        ChangeNotifierProvider(
          create: (_) => UserProvider()..loadUserFromPrefs(),
        ),
      ],
      child: MyApp(startWithWelcome: !seenWelcome),
    ),
  );
}

// ... (El resto de tu clase MyApp y MainNavigator se queda IGUAL) ...
class MyApp extends StatelessWidget {
  final bool startWithWelcome;

  const MyApp({super.key, required this.startWithWelcome});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'TratoHecho',
      theme: ThemeData(
        brightness:
            themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor:
            themeProvider.isDarkMode ? const Color(0xFF213748) : Colors.white,
        fontFamily: 'Sora',
      ),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(themeProvider.textScaleFactor),
          ),
          child: child!,
        );
      },
      home: startWithWelcome ? const WelcomeScreen() : const MainNavigator(),
    );
  }
}

// ... (MainNavigator se mantiene igual) ...
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;
  bool _hasUnreadMessages = false;

  void _updateUnreadStatus(bool hasUnread) {
    if (mounted) {
      setState(() {
        _hasUnreadMessages = hasUnread;
      });
    }
  }

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomeFeedScreen(),
      const SearchScreen(),
      MessagesScreen(
        onUnreadStatusChanged: _updateUnreadStatus,
      ),
      const UsuarioView(),
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
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        hasUnreadMessages: _hasUnreadMessages,
      ),
    );
  }
}
