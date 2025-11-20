import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode;
  double _textScaleFactor = 1.0;
  String _currentFontSizeLabel;
  // 1. New Variable for Auth State
  bool _isLoggedIn;

  bool get isDarkMode => _isDarkMode;
  double get textScaleFactor => _textScaleFactor;
  String get currentFontSizeLabel => _currentFontSizeLabel;
  bool get isLoggedIn => _isLoggedIn;

  // Constructor now requires initial values for auth too
  ThemeProvider({
    required bool isDark,
    required String fontSizeLabel,
    required bool isLoggedIn, // <--- Add this
  })  : _isDarkMode = isDark,
        _currentFontSizeLabel = fontSizeLabel,
        _isLoggedIn = isLoggedIn {
    _applyFontSize(fontSizeLabel);
  }

  void toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDark);
  }

  void setFontSize(String label) async {
    _applyFontSize(label);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('fontSizeLabel', label);
  }

  // 2. Login Method
  void login() async {
    _isLoggedIn = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
  }

  // 3. Logout Method
  void logout() async {
    _isLoggedIn = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
  }

  void _applyFontSize(String label) {
    _currentFontSizeLabel = label;
    switch (label) {
      case '12 pt':
        _textScaleFactor = 0.85;
        break;
      case '14 pt':
        _textScaleFactor = 1.0;
        break;
      case '16 pt':
        _textScaleFactor = 1.15;
        break;
      case '18 pt':
        _textScaleFactor = 1.30;
        break;
      default:
        _textScaleFactor = 1.0;
    }
  }
}
