import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // This is your global variable
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme(bool isOn) {
    _isDarkMode = isOn;
    // This tells the whole app to rebuild with the new color
    notifyListeners();
  }
}
