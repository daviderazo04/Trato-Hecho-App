import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your screens and widgets
import 'screens/chatView/messages_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import 'screens/homeView/home_screen.dart';
import 'screens/searchView/search_screen.dart';
import 'screens/usuarioView/usuarioView.dart';
import 'config/theme_provider.dart';
import 'screens/welcomeView/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load ALL preferences here, before the app starts
  final prefs = await SharedPreferences.getInstance();

  final bool seenWelcome = prefs.getBool('seenWelcome') ?? false;
  final bool isDark = prefs.getBool('isDarkMode') ?? false;
  final String fontSizeLabel = prefs.getString('fontSizeLabel') ?? '14 pt';

  // 2. Load the Auth State from storage
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    ChangeNotifierProvider(
      // 3. Pass all loaded values to the Provider
      create: (_) => ThemeProvider(
        isDark: isDark,
        fontSizeLabel: fontSizeLabel,
        isLoggedIn: isLoggedIn,
      ),
      child: MyApp(startWithWelcome: !seenWelcome),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool startWithWelcome;

  const MyApp({super.key, required this.startWithWelcome});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'TratoHecho',
      theme: ThemeData(
        // Match system bars to theme
        brightness:
            themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.blue,
        // Global background color
        scaffoldBackgroundColor:
            themeProvider.isDarkMode ? const Color(0xFF213748) : Colors.white,
        fontFamily: 'Sora',
      ),
      debugShowCheckedModeBanner: false,

      // Apply Font Size Globally
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

// --- MAIN NAVIGATOR ---
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
