import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  // 1. Add text scale variable (1.0 is normal size)
  double _textScaleFactor = 1.0;
  String _currentFontSizeLabel = '14 pt'; // To keep track of the dropdown value

  bool get isDarkMode => _isDarkMode;
  double get textScaleFactor => _textScaleFactor;
  String get currentFontSizeLabel => _currentFontSizeLabel;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDark);
  }

  // 2. Logic to change font size
  void setFontSize(String label) async {
    _currentFontSizeLabel = label;

    // Map the label to a scale factor
    switch (label) {
      case '12 pt':
        _textScaleFactor = 0.85; // Small
        break;
      case '14 pt':
        _textScaleFactor = 1.0; // Normal
        break;
      case '16 pt':
        _textScaleFactor = 1.15; // Large
        break;
      case '18 pt':
        _textScaleFactor = 1.30; // Extra Large
        break;
      default:
        _textScaleFactor = 1.0;
    }

    notifyListeners();

    // Optional: Save to preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('fontSizeLabel', label);
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;

    // Load saved font size
    String savedLabel = prefs.getString('fontSizeLabel') ?? '14 pt';
    setFontSize(savedLabel); // This will set the scale factor too

    notifyListeners();
  }
}
