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
  String? _userPhotoUrl;
  String? _userEmail;
  String? _userPhone;
  String? _userUsername;
  String? _userBirthdate;
  String? _userGender;
  bool _isLoading = false;

  // --- SUPPLIER MODE (Added) ---
  bool _isSupplierMode = false;

  // --- GETTERS ---
  int? get userId => _userId;
  String? get userName => _userName;
  String? get userRole => _userRole;
  String? get userPhotoUrl => _userPhotoUrl;
  String? get userEmail => _userEmail;
  String? get userPhone => _userPhone;
  String? get userUsername => _userUsername;
  String? get userBirthdate => _userBirthdate;
  String? get userGender => _userGender;
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
    _userPhotoUrl = prefs.getString('userPhotoUrl');
    _userEmail = prefs.getString('userEmail');
    _userPhone = prefs.getString('userPhone');
    _userUsername = prefs.getString('userUsername');
    _userBirthdate = prefs.getString('userBirthdate');
    _userGender = prefs.getString('userGender');

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
        final usuarioJson = data['usuario'] ?? data;

        _userId = usuarioJson['userId'] ?? usuarioJson['id'];
        _userName =
            usuarioJson['userNombreCompleto'] ?? usuarioJson['nombreCompleto'];
        _userRole = usuarioJson['userRol'] ?? usuarioJson['rol'];
        _userPhotoUrl = usuarioJson['userFotoPerfil'] ?? usuarioJson['foto'];
        _userEmail = usuarioJson['userCorreo'] ?? usuarioJson['correo'];
        _userPhone = usuarioJson['userTelefono'] ?? usuarioJson['telefono'];
        _userUsername =
            usuarioJson['userNombreUsuario'] ?? usuarioJson['nombreUsuario'];
        _userBirthdate = usuarioJson['userFechaNacimiento'] ??
            usuarioJson['fechaNacimiento'];
        _userGender = usuarioJson['userGenero'] ?? usuarioJson['genero'];

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', _userId!);
        await prefs.setString('userName', _userName ?? '');
        await prefs.setString('userRole', _userRole ?? '');
        if (_userPhotoUrl != null) {
          await prefs.setString('userPhotoUrl', _userPhotoUrl!);
        } else {
          await prefs.remove('userPhotoUrl');
        }
        if (_userEmail != null) {
          await prefs.setString('userEmail', _userEmail!);
        } else {
          await prefs.remove('userEmail');
        }
        if (_userPhone != null) {
          await prefs.setString('userPhone', _userPhone!);
        } else {
          await prefs.remove('userPhone');
        }
        if (_userUsername != null) {
          await prefs.setString('userUsername', _userUsername!);
        } else {
          await prefs.remove('userUsername');
        }
        if (_userBirthdate != null) {
          await prefs.setString('userBirthdate', _userBirthdate!);
        } else {
          await prefs.remove('userBirthdate');
        }
        if (_userGender != null) {
          await prefs.setString('userGender', _userGender!);
        } else {
          await prefs.remove('userGender');
        }

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

  Future<void> updateUserData({
    String? nombreCompleto,
    String? correo,
    String? telefono,
    String? nombreUsuario,
    String? fechaNacimiento,
    String? genero,
  }) async {
    _userName = nombreCompleto ?? _userName;
    _userEmail = correo ?? _userEmail;
    _userPhone = telefono ?? _userPhone;
    _userUsername = nombreUsuario ?? _userUsername;
    _userBirthdate = fechaNacimiento ?? _userBirthdate;
    _userGender = genero ?? _userGender;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (_userName != null) {
      await prefs.setString('userName', _userName!);
    } else {
      await prefs.remove('userName');
    }
    if (_userEmail != null) {
      await prefs.setString('userEmail', _userEmail!);
    } else {
      await prefs.remove('userEmail');
    }
    if (_userPhone != null) {
      await prefs.setString('userPhone', _userPhone!);
    } else {
      await prefs.remove('userPhone');
    }
    if (_userUsername != null) {
      await prefs.setString('userUsername', _userUsername!);
    } else {
      await prefs.remove('userUsername');
    }
    if (_userBirthdate != null) {
      await prefs.setString('userBirthdate', _userBirthdate!);
    } else {
      await prefs.remove('userBirthdate');
    }
    if (_userGender != null) {
      await prefs.setString('userGender', _userGender!);
    } else {
      await prefs.remove('userGender');
    }
  }

  // --- LOGOUT LOGIC (Merged) ---
  void logout() async {
    _userId = null;
    _userName = null;
    _userRole = null;
    _userPhotoUrl = null;
    _userEmail = null;
    _userPhone = null;
    _userUsername = null;
    _userBirthdate = null;
    _userGender = null;
    _isSupplierMode = false; // Reset mode on logout

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userRole');
    await prefs.remove('userPhotoUrl');
    await prefs.remove('userEmail');
    await prefs.remove('userPhone');
    await prefs.remove('userUsername');
    await prefs.remove('userBirthdate');
    await prefs.remove('userGender');
    await prefs.setBool('isSupplierMode', false);
    await prefs.setBool('isLoggedIn', false); // Update auth state

    notifyListeners();
  }

  // --- REFRESH USER DATA FROM API ---
  Future<void> refreshUserFromApi() async {
    final id = _userId;
    if (id == null) return;
    try {
      final response = await http.get(Uri.parse(ApiConfig.usuario(id)));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));
        final usuarioJson = data['usuario'] ?? data;

        _userId = usuarioJson['userId'] ?? usuarioJson['id'] ?? _userId;
        _userName =
            usuarioJson['userNombreCompleto'] ?? usuarioJson['nombreCompleto'];
        _userRole = usuarioJson['userRol'] ?? usuarioJson['rol'] ?? _userRole;
        _userPhotoUrl =
            usuarioJson['userFotoPerfil'] ?? usuarioJson['foto'] ?? _userPhotoUrl;
        _userEmail = usuarioJson['userCorreo'] ?? usuarioJson['correo'];
        _userPhone = usuarioJson['userTelefono'] ?? usuarioJson['telefono'];
        _userUsername =
            usuarioJson['userNombreUsuario'] ?? usuarioJson['nombreUsuario'];
        _userBirthdate = usuarioJson['userFechaNacimiento'] ??
            usuarioJson['fechaNacimiento'];
        _userGender = usuarioJson['userGenero'] ?? usuarioJson['genero'];

        final prefs = await SharedPreferences.getInstance();
        if (_userId != null) await prefs.setInt('userId', _userId!);
        if (_userName != null) {
          await prefs.setString('userName', _userName!);
        }
        if (_userRole != null) {
          await prefs.setString('userRole', _userRole!);
        }
        if (_userPhotoUrl != null) {
          await prefs.setString('userPhotoUrl', _userPhotoUrl!);
        } else {
          await prefs.remove('userPhotoUrl');
        }
        if (_userEmail != null) {
          await prefs.setString('userEmail', _userEmail!);
        } else {
          await prefs.remove('userEmail');
        }
        if (_userPhone != null) {
          await prefs.setString('userPhone', _userPhone!);
        } else {
          await prefs.remove('userPhone');
        }
        if (_userUsername != null) {
          await prefs.setString('userUsername', _userUsername!);
        } else {
          await prefs.remove('userUsername');
        }
        if (_userBirthdate != null) {
          await prefs.setString('userBirthdate', _userBirthdate!);
        } else {
          await prefs.remove('userBirthdate');
        }
        if (_userGender != null) {
          await prefs.setString('userGender', _userGender!);
        } else {
          await prefs.remove('userGender');
        }

        notifyListeners();
      }
    } catch (_) {
      // Silently ignore; UI will keep previous data
    }
  }
}
