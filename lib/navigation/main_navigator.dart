import 'package:flutter/material.dart';

import '../screens/chatView/messages_screen.dart';
import '../screens/homeView/home_screen.dart';
import '../screens/searchView/search_screen.dart';
import '../screens/usuarioView/usuarioView.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  late int _selectedIndex;
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
    _selectedIndex = widget.initialIndex;
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
