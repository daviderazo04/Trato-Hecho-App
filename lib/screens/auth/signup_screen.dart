import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../config/appColors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- Controllers ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _repeatPassController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // --- State Variables ---
  bool _isPasswordVisible = false;
  bool _isRepeatPasswordVisible = false;
  String? _selectedGender;

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
      body: Column(
        children: [
          // --- 1. CUSTOM HEADER ---
          _buildCustomHeader(context),

          // --- 2. FORM CONTENT ---
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    "Registrate aqui",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Full Name
                  _buildInput(
                    controller: _nameController,
                    hint: "Nombre Completo",
                    icon: Icons.person_outline,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 15),

                  // Email
                  _buildInput(
                    controller: _emailController,
                    hint: "Correo",
                    icon: Icons.email_outlined,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 15),

                  // Password
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

                  // Repeat Password
                  _buildInput(
                    controller: _repeatPassController,
                    hint: "Repetir Contraseña",
                    icon: Icons.lock_outline,
                    isDarkMode: isDarkMode,
                    isPassword: true,
                    isPasswordVisible: _isRepeatPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _isRepeatPasswordVisible = !_isRepeatPasswordVisible;
                      });
                    },
                  ),
                  const SizedBox(height: 15),

                  // Date of Birth
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

                  // Phone Number
                  _buildInput(
                    controller: _phoneController,
                    hint: "Numero de telefono",
                    icon: Icons.phone_outlined,
                    isDarkMode: isDarkMode,
                    inputType: TextInputType.phone,
                  ),
                  const SizedBox(height: 15),

                  // Gender Dropdown
                  _buildDropdown(isDarkMode),

                  const SizedBox(height: 30),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Registration Logic
                        // After success, likely log them in:
                        // themeProvider.login();
                        // Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side:
                              const BorderSide(color: Colors.white, width: 1.5),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Registrarse",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "¿Ya tienes una cuenta? ",
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Go back to Login
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
              value: 'm',
              child: Text('Masculino', style: TextStyle(color: textColor))),
          DropdownMenuItem(
              value: 'f',
              child: Text('Femenino', style: TextStyle(color: textColor))),
          DropdownMenuItem(
              value: 'o',
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
