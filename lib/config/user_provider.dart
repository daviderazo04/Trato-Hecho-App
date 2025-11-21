import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Necesario para guardar sesión
import 'api_config.dart'; // Asegúrate de que este archivo existe

class UserProvider with ChangeNotifier {
  int? _userId;
  String? _userName;
  String? _userRole;
  bool _isLoading = false;

  int? get userId => _userId;
  String? get userName => _userName;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;

  // --- ESTA ES LA FUNCIÓN QUE TE FALTA ---
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');
    _userName = prefs.getString('userName');
    _userRole = prefs.getString('userRole');
    notifyListeners();
  }
  // ---------------------------------------

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
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final usuarioJson = data['usuario'];
        
        _userId = usuarioJson['userId'];
        _userName = usuarioJson['userNombreCompleto'];
        _userRole = usuarioJson['userRol'];

        // Guardamos en SharedPreferences al hacer login
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', _userId!);
        await prefs.setString('userName', _userName ?? '');
        await prefs.setString('userRole', _userRole ?? '');

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

  void logout() async {
    _userId = null;
    _userName = null;
    _userRole = null;
    
    // Borramos de SharedPreferences al salir
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userRole');
    
    notifyListeners();
  }
}