import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart'; // Asegúrate de que este archivo existe

class UserProvider with ChangeNotifier {
  // --- AUTH DATA (From your API) ---
  int? _userId;
  String? _userName;
  String? _userRole;
  bool _isLoading = false;

  // --- SUPPLIER MODE (Added) ---
  bool _isSupplierMode = false;

  // --- GETTERS ---
  int? get userId => _userId;
  String? get userName => _userName;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;
  bool get isSupplierMode => _isSupplierMode;

  UserProvider() {
    loadUserFromPrefs();
  }

  // --- LOAD DATA (Merged) ---
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // Load User Data
    _userId = prefs.getInt('userId');
    _userName = prefs.getString('userName');
    _userRole = prefs.getString('userRole');

    // Load Supplier Mode
    _isSupplierMode = prefs.getBool('isSupplierMode') ?? false;

    notifyListeners();
  }

  // --- SUPPLIER MODE LOGIC (Added) ---
  void setSupplierMode(bool value) async {
    _isSupplierMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSupplierMode', value);
  }

  // --- LOGIN LOGIC (From your code) ---
  Future<Map<String, dynamic>> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombreUsuario': username,
          'contrasenia': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));
        // Check if 'usuario' exists, otherwise handle structure differences
        final usuarioJson = data['usuario'];

        _userId = usuarioJson['userId'];
        _userName = usuarioJson['userNombreCompleto'];
        _userRole = usuarioJson['userRol'];

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', _userId!);
        await prefs.setString('userName', _userName ?? '');
        await prefs.setString('userRole', _userRole ?? '');

        // IMPORTANT: Set 'isLoggedIn' for main.dart compatibility
        await prefs.setBool('isLoggedIn', true);

        _isLoading = false;
        notifyListeners();
        return {'success': true, 'message': 'Login exitoso'};
      } else {
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': 'Credenciales incorrectas'};
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // --- LOGOUT LOGIC (Merged) ---
  void logout() async {
    _userId = null;
    _userName = null;
    _userRole = null;
    _isSupplierMode = false; // Reset mode on logout

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userRole');
    await prefs.setBool('isSupplierMode', false);
    await prefs.setBool('isLoggedIn', false); // Update auth state

    notifyListeners();
  }
}
