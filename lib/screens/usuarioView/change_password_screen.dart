import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../config/appColors.dart';
import '../../config/theme_provider.dart';
import '../../config/user_provider.dart';
import '../../config/api_config.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isSubmitting = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit(UserProvider userProvider) async {
    if (!_formKey.currentState!.validate()) return;
    final userId = userProvider.userId;
    final username = userProvider.userUsername;
    if (userId == null || username == null || username.isEmpty) {
      setState(() {
        _error = 'Inicia sesión nuevamente antes de cambiar la contraseña.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final currentPassword = _currentController.text.trim();

    // 1) Validar contraseña actual contra el endpoint de login
    final isValidCurrent =
        await _validateCurrentPassword(username, currentPassword);
    if (!isValidCurrent) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _error = 'La contraseña actual es incorrecta.';
        });
      }
      return;
    }

    // 2) Enviar nueva contraseña al endpoint de usuario (form-data con key "usuario")
    final payload = {
      'nombreCompleto': userProvider.userName ?? '',
      'correo': userProvider.userEmail ?? '',
      'genero': (userProvider.userGender ?? '').toUpperCase(),
      'fechaNacimiento': userProvider.userBirthdate ?? '',
      'telefono': userProvider.userPhone ?? '',
      'nombreUsuario': username,
      'contrasenia': _newController.text.trim(),
    };

    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse(ApiConfig.usuario(userId)),
      );
      request.fields['usuario'] = jsonEncode(payload);

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña actualizada.')),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _error =
              'Error al actualizar (código ${streamed.statusCode})${body.isNotEmpty ? ': $body' : ''}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = 'Error de red: $e';
      });
    }
  }

  Future<bool> _validateCurrentPassword(
      String username, String currentPassword) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombreUsuario': username,
          'contrasenia': currentPassword,
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actualiza tu contraseña para mayor seguridad.',
                style: TextStyle(color: textColor, fontSize: 16),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _buildPasswordField(
                controller: _currentController,
                label: 'Contraseña actual',
                isDarkMode: isDarkMode,
                obscure: !_showCurrent,
                onToggle: () =>
                    setState(() => _showCurrent = !_showCurrent),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Ingresa tu contraseña actual' : null,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _newController,
                label: 'Nueva contraseña',
                isDarkMode: isDarkMode,
                obscure: !_showNew,
                onToggle: () => setState(() => _showNew = !_showNew),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Ingresa una nueva contraseña';
                  if (val.length < 6) return 'Debe tener al menos 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _confirmController,
                label: 'Confirmar contraseña',
                isDarkMode: isDarkMode,
                obscure: !_showConfirm,
                onToggle: () =>
                    setState(() => _showConfirm = !_showConfirm),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Confirma tu nueva contraseña';
                  if (val != _newController.text) return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submit(userProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Guardar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isDarkMode,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    final fillColor = isDarkMode ? AppColors.darkButtons : Colors.white;
    final borderColor =
        isDarkMode ? Colors.white.withOpacity(0.4) : Colors.grey.shade400;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
        filled: true,
        fillColor: fillColor,
        prefixIcon: Icon(Icons.lock_outline,
            color: isDarkMode ? Colors.white : AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: isDarkMode ? Colors.white70 : Colors.grey[700],
          ),
          onPressed: onToggle,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
