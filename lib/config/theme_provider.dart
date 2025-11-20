import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode;
  double _textScaleFactor = 1.0;
  String _currentFontSizeLabel;

  bool get isDarkMode => _isDarkMode;
  double get textScaleFactor => _textScaleFactor;
  String get currentFontSizeLabel => _currentFontSizeLabel;

  // Constructor now requires initial values
  ThemeProvider({required bool isDark, required String fontSizeLabel})
      : _isDarkMode = isDark,
        _currentFontSizeLabel = fontSizeLabel {
    // Apply the font size logic immediately upon creation
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

  // Helper to just calculate the scale (separated from saving logic)
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
