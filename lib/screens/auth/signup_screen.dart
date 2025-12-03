import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para filtrar input numérico
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../config/theme_provider.dart';
import '../../config/appColors.dart';
import '../../config/api_config.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onAuthenticated;

  const RegisterScreen({Key? key, this.onAuthenticated}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- Key para el formulario ---
  final _formKey = GlobalKey<FormState>();

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

  // Variable para controlar cuándo mostrar errores
  // Inicialmente desactivado para no molestar al usuario
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  // Variable para habilitar/deshabilitar el botón (opcional, pero útil)
  // Aunque con la lógica de _autoValidateMode, podemos dejar el botón siempre habilitado
  // y que al presionar se validen y muestren los errores.

  // Validar edad (Mínimo 18 años)
  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu fecha de nacimiento';
    }
    try {
      final DateTime birthDate = DateTime.parse(value);
      final DateTime today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      if (age < 18) {
        return 'Debes ser mayor de 18 años';
      }
    } catch (e) {
      return 'Fecha inválida';
    }
    return null;
  }

  // Validar teléfono (Empieza con 09 y tiene 10 dígitos)
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu teléfono';
    }
    if (value.length != 10) {
      return 'El teléfono debe tener 10 dígitos';
    }
    if (!value.startsWith('09')) {
      return 'El teléfono debe empezar con 09';
    }
    return null;
  }

  // Validar contraseñas
  String? _validatePass(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa una contraseña';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  String? _validateRepeatPass(String? value) {
    if (value == null || value.isEmpty) {
      return 'Repite la contraseña';
    }
    if (value != _passController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Future<void> _submit(BuildContext context) async {
    if (_isSubmitting) return;

    // 1. Activamos la validación visual al presionar el botón
    setState(() {
      _autoValidateMode = AutovalidateMode.onUserInteraction;
    });

    // 2. Validamos el formulario completo
    if (!_formKey.currentState!.validate()) {
      // Si falla, no hacemos nada más (los errores rojos aparecerán ahora)
      return;
    }

    if (_selectedGender == null) {
      _showFeedback(
        success: false,
        message: 'Selecciona un género.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final body = {
        "nombreCompleto": _nameController.text.trim(),
        "correo": _emailController.text.trim(),
        "genero": _selectedGender,
        "fechaNacimiento": _dateController.text.trim(),
        "telefono": _phoneController.text.trim(),
        "nombreUsuario": _usernameController.text.trim(),
        "contrasenia": _passController.text,
      };

      // Usamos replaceAll por si acaso, o directo ApiConfig.registro si existiera
      // Asumimos ApiConfig.login existe y transformamos la URL
      final url = Uri.parse(ApiConfig.login.replaceAll('login', 'registro'));
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showFeedback(
          success: true,
          message: '¡Registro exitoso! Redirigiendo...',
        );
        await Future.delayed(const Duration(milliseconds: 2000));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    LoginScreen(onAuthenticated: widget.onAuthenticated)),
          );
        }
      } else {
        _showFeedback(
          success: false,
          message: 'Error en el registro. Verifica tus datos o usuario ya existe.',
        );
        await Future.delayed(const Duration(milliseconds: 1700));
      }
    } catch (e) {
      _showFeedback(
        success: false,
        message: 'Error de conexión: $e',
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
                  child: Form(
                    key: _formKey,
                    // CAMBIO CLAVE: Usamos la variable de estado para controlar cuándo validar
                    autovalidateMode: _autoValidateMode,
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
                          validator: (val) => (val == null || val.isEmpty) ? 'Campo obligatorio' : null,
                        ),
                        const SizedBox(height: 15),
                        
                        _buildInput(
                          controller: _emailController,
                          hint: "Correo",
                          icon: Icons.email_outlined,
                          isDarkMode: isDarkMode,
                          inputType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Campo obligatorio';

                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(val)) {
                              return 'Correo inválido. Ejemplo: usuario@mail.com';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        
                        _buildInput(
                          controller: _usernameController,
                          hint: "Nombre de usuario",
                          icon: Icons.alternate_email,
                          isDarkMode: isDarkMode,
                          validator: (val) => (val == null || val.isEmpty) ? 'Campo obligatorio' : null,
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
                          validator: _validatePass,
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
                          validator: _validateRepeatPass,
                        ),
                        const SizedBox(height: 15),
                        
                        _buildInput(
                          controller: _dateController,
                          hint: "Fecha de nacimiento",
                          icon: Icons.calendar_today_outlined,
                          isDarkMode: isDarkMode,
                          readOnly: true,
                          validator: _validateDate,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Sugerir 18 años atrás
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
                          inputType: TextInputType.number,
                          // Limitamos a 10 dígitos
                          inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                          ],
                          validator: _validatePhone,
                        ),
                        const SizedBox(height: 15),
                        
                        _buildDropdown(isDarkMode),
                        const SizedBox(height: 30),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            // CAMBIO: El botón siempre está habilitado (visual) para que al presionar
                            // se dispare la validación y se muestren los errores rojos.
                            // Solo se deshabilita si ya se está enviando (_isSubmitting)
                            onPressed: _isSubmitting ? null : () => _submit(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
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
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                    ),
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
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
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
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: inputType,
        style: TextStyle(color: textColor),
        validator: validator,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          filled: true,
          fillColor: fillColor,
          hintText: hint,
          hintStyle: TextStyle(color: hintColor),
          prefixIcon: Icon(icon, color: iconColor),
          errorStyle: const TextStyle(
             color: Colors.redAccent,
             fontWeight: FontWeight.bold,
          ),
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(10),
             borderSide: const BorderSide(color: Colors.red, width: 2),
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
          // Añadimos estilos de error también al dropdown
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(10),
             borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          errorStyle: const TextStyle(
             color: Colors.redAccent,
             fontWeight: FontWeight.bold,
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
          // Si ya se activó la validación, re-validamos el campo al cambiar
          if (_autoValidateMode == AutovalidateMode.onUserInteraction) {
            _formKey.currentState?.validate();
          }
        },
        validator: (value) => value == null ? 'Selecciona un género' : null,
      ),
    );
  }
}
