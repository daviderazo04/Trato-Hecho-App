import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../config/theme_provider.dart';
import '../../config/appColors.dart';
import '../../config/api_config.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- Controllers ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _repeatPassController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // --- State Variables ---
  bool _isPasswordVisible = false;
  bool _isRepeatPasswordVisible = false;
  String? _selectedGender;
  bool _isSubmitting = false;
  bool _showOverlay = false;
  bool _overlaySuccess = false;
  String _overlayMessage = '';

  Future<void> _submit(BuildContext context) async {
    if (_isSubmitting) return;

    final String nombreCompleto = _nameController.text.trim();
    final String correo = _emailController.text.trim();
    final String username = _usernameController.text.trim();
    final String pass = _passController.text;
    final String repeatPass = _repeatPassController.text;
    final String fechaNac = _dateController.text.trim();
    final String telefono = _phoneController.text.trim();
    final String? genero = _selectedGender;

    if (nombreCompleto.isEmpty ||
        correo.isEmpty ||
        username.isEmpty ||
        pass.isEmpty ||
        repeatPass.isEmpty ||
        fechaNac.isEmpty ||
        telefono.isEmpty ||
        genero == null) {
      _showFeedback(
        success: false,
        message: 'Completa todos los campos para registrarte.',
      );
      return;
    }

    if (pass != repeatPass) {
      _showFeedback(
        success: false,
        message: 'Las contraseñas no coinciden.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final body = {
        "nombreCompleto": nombreCompleto,
        "correo": correo,
        "genero": genero,
        "fechaNacimiento": fechaNac,
        "telefono": telefono,
        "nombreUsuario": username,
        "contrasenia": pass,
      };

      final response = await http.post(
        Uri.parse(ApiConfig.registro),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showFeedback(
          success: true,
          message: 'Serás redirigido al login.',
        );
        await Future.delayed(const Duration(milliseconds: 2500));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } else {
        _showFeedback(
          success: false,
          message: 'Revisa tus datos e intenta nuevamente.',
        );
        await Future.delayed(const Duration(milliseconds: 1700));
      }
    } catch (e) {
      _showFeedback(
        success: false,
        message: 'Error de red: $e',
      );
      await Future.delayed(const Duration(milliseconds: 1700));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          if (!_overlaySuccess) {
            _showOverlay = false;
          }
        });
      }
    }
  }

  void _showFeedback({required bool success, required String message}) {
    setState(() {
      _overlaySuccess = success;
      _overlayMessage = message;
      _showOverlay = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    // Background Colors
    final Color backgroundColor =
        isDarkMode ? AppColors.backgroundDark : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              _buildCustomHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Registrate aqui",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 25),
                      _buildInput(
                        controller: _nameController,
                        hint: "Nombre Completo",
                        icon: Icons.person_outline,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 15),
                      _buildInput(
                        controller: _emailController,
                        hint: "Correo",
                        icon: Icons.email_outlined,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 15),
                      _buildInput(
                        controller: _usernameController,
                        hint: "Nombre de usuario",
                        icon: Icons.alternate_email,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 15),
                      _buildInput(
                        controller: _passController,
                        hint: "Contraseña",
                        icon: Icons.lock_outline,
                        isDarkMode: isDarkMode,
                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        onVisibilityToggle: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildInput(
                        controller: _repeatPassController,
                        hint: "Repetir Contraseña",
                        icon: Icons.lock_outline,
                        isDarkMode: isDarkMode,
                        isPassword: true,
                        isPasswordVisible: _isRepeatPasswordVisible,
                        onVisibilityToggle: () {
                          setState(() {
                            _isRepeatPasswordVisible =
                                !_isRepeatPasswordVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildInput(
                        controller: _dateController,
                        hint: "Fecha de nacimiento",
                        icon: Icons.calendar_today_outlined,
                        isDarkMode: isDarkMode,
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            String formattedDate =
                                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                            setState(() {
                              _dateController.text = formattedDate;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildInput(
                        controller: _phoneController,
                        hint: "Numero de telefono",
                        icon: Icons.phone_outlined,
                        isDarkMode: isDarkMode,
                        inputType: TextInputType.phone,
                      ),
                      const SizedBox(height: 15),
                      _buildDropdown(isDarkMode),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              _isSubmitting ? null : () => _submit(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: const BorderSide(
                                  color: Colors.white, width: 1.5),
                            ),
                            elevation: 5,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.3,
                                  ),
                                )
                              : const Text(
                                  "Registrarse",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "¿Ya tienes una cuenta? ",
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[300]
                                  : Colors.grey[600],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Inicia Sesion",
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_showOverlay)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: AnimatedOpacity(
                  opacity: _showOverlay ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Stack(
                    children: [
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: _overlaySuccess
                                ? Colors.green[600]
                                : Colors.red[600],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _overlaySuccess
                                      ? Icons.arrow_forward
                                      : Icons.close,
                                  color: _overlaySuccess
                                      ? Colors.green[600]
                                      : Colors.red[600],
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _overlaySuccess
                                    ? '¡Gracias por registrarte!'
                                    : 'No se pudo registrar',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _overlayMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 20),
          const Text(
            'Registro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    bool isPassword = false,
    bool isPasswordVisible = false,
    bool readOnly = false,
    VoidCallback? onTap,
    VoidCallback? onVisibilityToggle,
    TextInputType inputType = TextInputType.text,
  }) {
    // Dark Mode: Grey fill, White border. Light Mode: White fill, Black border.
    final Color fillColor = isDarkMode ? const Color(0xFF768088) : Colors.white;
    final Color borderColor = isDarkMode ? Colors.black54 : Colors.black;
    final Color iconColor = isDarkMode ? Colors.white : Colors.black;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color hintColor = isDarkMode ? Colors.white70 : Colors.grey;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: inputType,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          filled: true,
          fillColor: fillColor,
          hintText: hint,
          hintStyle: TextStyle(color: hintColor),
          prefixIcon: Icon(icon, color: iconColor),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: iconColor,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          // Borders
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(bool isDarkMode) {
    final Color fillColor = isDarkMode ? const Color(0xFF768088) : Colors.white;
    final Color borderColor = isDarkMode ? Colors.black54 : Colors.black;
    final Color iconColor = isDarkMode ? Colors.white : Colors.black;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color hintColor = isDarkMode ? Colors.white70 : Colors.grey;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        isExpanded: true,
        dropdownColor: fillColor,
        icon: Icon(Icons.keyboard_arrow_down, color: iconColor),
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          filled: true,
          fillColor: fillColor,
          hintText: "Genero",
          hintStyle: TextStyle(color: hintColor),
          prefixIcon: Icon(Icons.person_outline, color: iconColor),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor, width: 1.5),
          ),
        ),
        items: [
          DropdownMenuItem(
              value: 'Masculino',
              child: Text('Masculino', style: TextStyle(color: textColor))),
          DropdownMenuItem(
              value: 'Femenino',
              child: Text('Femenino', style: TextStyle(color: textColor))),
          DropdownMenuItem(
              value: 'Otro',
              child: Text('Otro', style: TextStyle(color: textColor))),
        ],
        onChanged: (value) {
          setState(() {
            _selectedGender = value;
          });
        },
      ),
    );
  }
}
