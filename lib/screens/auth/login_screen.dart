import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../config/appColors.dart';
import '../usuarioView/usuarioView.dart';
import '../auth/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    // Background Logic
    final Color backgroundColor =
        isDarkMode ? AppColors.backgroundDark : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // --- 1. SCROLLABLE CONTENT ---
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP IMAGE (Party Illustration)
                  const SizedBox(height: 40),
                  Center(
                    child: Image.network(
                      'https://img.freepik.com/free-vector/hand-drawn-business-party-illustration_23-2149495494.jpg?w=1380&t=st=1709657000~exp=1709657600~hmac=6c5c0c9c9c9c9c9c9c9c9c9c9c9c9c9c',
                      height: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 220,
                          color: Colors.transparent,
                          child: const Icon(Icons.image,
                              size: 100, color: Colors.grey),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TITLE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "Hey,\nInicia Sesion ahora.",
                      style: TextStyle(
                        fontSize: 24, // Reduced from 28
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // INPUTS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // User Input
                        _buildInput(
                          controller: _userController,
                          hint: "Usuario",
                          icon: Icons.person_outline,
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 16),

                        // Password Input
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

                        const SizedBox(height: 16),

                        // Remember Me Checkbox
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.primary,
                                side: BorderSide(
                                  color: isDarkMode ? Colors.grey : Colors.grey,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _rememberMe = val ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Recordarme",
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              // --- LOGIN LOGIC ---
                              // 1. Set logged in state
                              themeProvider.login();

                              // 2. Navigate to Profile (Remove back history so they can't go back to login)
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                                side: isDarkMode
                                    ? const BorderSide(
                                        color: Colors.white, width: 1.5)
                                    : BorderSide.none,
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              "Iniciar Sesion",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // REGISTER LINK
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "¿No tienes una cuenta? ",
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[600],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigate to Register
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen()),
                                );
                              },
                              child: Text(
                                "Registrate",
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- SPACER REPLACEMENT ---
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ),

          // --- 2. BOTTOM DECORATION (Fixed on top of ScrollView) ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              // Allows touches to pass through transparent parts if needed
              child: SizedBox(
                height: 120,
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    // The Angled Strip
                    ClipPath(
                      clipper: BottomAngledClipper(),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        color: isDarkMode ? Colors.white : AppColors.primary,
                      ),
                    ),

                    // The Cake Image
                    Positioned(
                      left: 20,
                      bottom: 20,
                      child: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/2454/2454269.png',
                        height: 80,
                        fit: BoxFit.contain,
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

  // --- CUSTOM INPUT WIDGET ---
  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
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
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
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
}

class BottomAngledClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.4);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
