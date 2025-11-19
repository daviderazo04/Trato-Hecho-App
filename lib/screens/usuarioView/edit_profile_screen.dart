import 'dart:io'; // 1. Import needed for File
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../config/appColors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // --- CONTROLADORES ---
  late TextEditingController _nombreCompletoController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _usuarioController;
  late TextEditingController _fechaController;
  String? _generoValue;

  // 2. Variable to hold the new selected image locally
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nombreCompletoController = TextEditingController(text: "Pedro Salas");
    _correoController = TextEditingController(text: "pedro.salas@mail.com");
    _telefonoController = TextEditingController(text: "0991234567");
    _usuarioController = TextEditingController(text: "@pedritoS81");
    _fechaController = TextEditingController(text: "1990-01-01");
  }

  @override
  void dispose() {
    _nombreCompletoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _usuarioController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;
    final Color backgroundColor =
        isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight;
    final Color textColor = isDarkMode ? Colors.white : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // --- 1. CUSTOM HEADER (Updated Padding) ---
          _buildCustomHeader(context, textColor),

          // --- 2. SCROLLABLE CONTENT ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // --- Profile Section (Interactive) ---
                  _buildProfileSection(context, isDarkMode, textColor),

                  const SizedBox(height: 30),

                  // --- FORM SECTION ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cuenta",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildInput(
                          controller: _nombreCompletoController,
                          hint: 'Nombre Completo',
                          icon: Icons.person_outline,
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 15),
                        _buildInput(
                          controller: _correoController,
                          hint: 'Correo',
                          icon: Icons.email_outlined,
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 15),
                        _buildDropdown(isDarkMode),
                        const SizedBox(height: 15),
                        _buildInput(
                          controller: _fechaController,
                          hint: 'Fecha de nac.',
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
                                _fechaController.text = formattedDate;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        _buildInput(
                          controller: _telefonoController,
                          hint: 'Numero de telefono',
                          icon: Icons.phone_outlined,
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 15),
                        _buildInput(
                          controller: _usuarioController,
                          hint: 'Nombre de Usuario',
                          icon: Icons.account_circle_outlined,
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  "Guardar Cambios",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            TextButton(
                              onPressed: () =>
                                  _showDeleteConfirmationDialog(context),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.error,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                      color: AppColors.error.withOpacity(0.3)),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 20),
                                  SizedBox(width: 4),
                                  Text("Eliminar"),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildCustomHeader(BuildContext context, Color textColor) {
    return Container(
      width: double.infinity,
      // 3. UPDATED PADDING HERE
      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        // Added SafeArea here to ensure it doesn't overlap with status bar on top 15
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.primary, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 20),
            const Text(
              'Cuenta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Updated Profile Section with Clickable Pencil
  Widget _buildProfileSection(
      BuildContext context, bool isDarkMode, Color textColor) {
    // Logic to determine which image to show
    ImageProvider? imageProvider;
    if (_selectedImage != null) {
      imageProvider = FileImage(_selectedImage!);
    } else {
      imageProvider = const NetworkImage(
          'https://www.jreventos.com.ar/uploads/servicio-imagen/big/af332f5af35068cd6a8935e65c7f0a5c.jpeg');
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            // The Image
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode ? AppColors.primary : Colors.grey.shade300,
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                backgroundImage: imageProvider,
              ),
            ),

            // The Pencil Icon (Now Clickable)
            GestureDetector(
              onTap: () {
                _showImagePickerOptions(context, isDarkMode);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Pedro Salas',
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Quito, Ecuador',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // --- 5. NEW IMAGE PICKER MODAL ---
// --- 5. NEW IMAGE PICKER MODAL (FIXED OVERFLOW) ---
  void _showImagePickerOptions(BuildContext context, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? AppColors.backgroundDark : Colors.white,
      isScrollControlled: true, // Allows the modal to adjust size better
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          // Added SafeArea to avoid bottom nav overlaps
          child: Padding(
            padding: const EdgeInsets.all(20),
            // REMOVED: height: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min, // IMPORTANT: Wrap content height
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Handle Bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "Foto de Perfil",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // Current Image Preview
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : const NetworkImage(
                              'https://www.jreventos.com.ar/uploads/servicio-imagen/big/af332f5af35068cd6a8935e65c7f0a5c.jpeg')
                          as ImageProvider,
                ),

                const SizedBox(height: 30),

                // Options Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageOption(
                        icon: Icons.camera_alt_outlined,
                        label: "Cámara",
                        isDarkMode: isDarkMode,
                        onTap: () {
                          // TODO: Implement Camera
                          Navigator.pop(context);
                        }),
                    _buildImageOption(
                        icon: Icons.photo_library_outlined,
                        label: "Galería",
                        isDarkMode: isDarkMode,
                        onTap: () {
                          // TODO: Implement Gallery
                          Navigator.pop(context);
                        }),
                  ],
                ),
                const SizedBox(height: 10), // Extra bottom padding
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageOption(
      {required IconData icon,
      required String label,
      required bool isDarkMode,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
              borderRadius: BorderRadius.circular(50),
              color: isDarkMode ? AppColors.darkButtons : Colors.grey[50],
            ),
            child: Icon(icon, color: AppColors.primary, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.grey[800],
                  fontWeight: FontWeight.w500))
        ],
      ),
    );
  }

  // ... (Rest of methods: _showDeleteConfirmationDialog, _buildInput, _buildDropdown remain unchanged) ...

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("¿Eliminar cuenta?"),
          content: const Text(
            "¿Seguro que quieres eliminar tu cuenta? Una vez lo hagas no puedes recuperarla y perderás todos tus datos.",
            style: TextStyle(fontSize: 14),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child:
                  const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text("Eliminar",
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    final Color fillColor = isDarkMode ? AppColors.darkButtons : Colors.white;
    final Color iconColor = isDarkMode ? Colors.white70 : Colors.grey[600]!;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color borderColor = isDarkMode ? Colors.white : Colors.grey.shade400;

    return Container(
      decoration: BoxDecoration(
          boxShadow: isDarkMode
              ? []
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2))
                ]),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.grey[600]),
          prefixIcon: Icon(icon, color: iconColor),
          filled: true,
          fillColor: fillColor,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2)),
        ),
      ),
    );
  }

  Widget _buildDropdown(bool isDarkMode) {
    final Color fillColor = isDarkMode ? AppColors.darkButtons : Colors.white;
    final Color iconColor = isDarkMode ? Colors.white70 : Colors.grey[600]!;
    final Color borderColor = isDarkMode ? Colors.white : Colors.grey.shade400;
    final Color dropdownTextColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      decoration: BoxDecoration(
          boxShadow: isDarkMode
              ? []
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2))
                ]),
      child: DropdownButtonFormField<String>(
        value: _generoValue,
        isExpanded: true,
        dropdownColor: isDarkMode ? AppColors.darkButtons : Colors.white,
        icon: Icon(Icons.keyboard_arrow_down, color: iconColor),
        style: TextStyle(color: dropdownTextColor),
        decoration: InputDecoration(
          labelText: 'Genero',
          labelStyle: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.grey[600]),
          prefixIcon: Icon(Icons.wc, color: iconColor),
          filled: true,
          fillColor: fillColor,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor)),
        ),
        items: [
          DropdownMenuItem(
              value: 'm',
              child: Text('Masculino',
                  style: TextStyle(color: dropdownTextColor))),
          DropdownMenuItem(
              value: 'f',
              child:
                  Text('Femenino', style: TextStyle(color: dropdownTextColor))),
          DropdownMenuItem(
              value: 'o',
              child: Text('Otro', style: TextStyle(color: dropdownTextColor))),
        ],
        onChanged: (value) {
          setState(() {
            _generoValue = value;
          });
        },
      ),
    );
  }
}
