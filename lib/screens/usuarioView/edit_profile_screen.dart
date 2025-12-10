import 'dart:convert';
import 'dart:io'; // 1. Import needed for File
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../config/theme_provider.dart';
import '../../config/appColors.dart';
import '../../config/user_provider.dart';
import '../../config/api_config.dart';

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
  bool _prefilledFromUser = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreCompletoController = TextEditingController();
    _correoController = TextEditingController();
    _telefonoController = TextEditingController();
    _usuarioController = TextEditingController();
    _fechaController = TextEditingController();
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prefillFromUser(Provider.of<UserProvider>(context));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
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
                  _buildProfileSection(
                    context,
                    isDarkMode,
                    textColor,
                    userProvider,
                  ),

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
                          keyboardType: TextInputType.emailAddress,
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
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          maxLength: 10,
                        ),
                        const SizedBox(height: 15),
                        _buildInput(
                          controller: _usuarioController,
                          hint: 'Nombre de Usuario',
                          icon: Icons.account_circle_outlined,
                          isDarkMode: isDarkMode,
                          maxLength: 30,
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSaving
                                    ? null
                                    : () => _saveProfile(userProvider),
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
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
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
  void _prefillFromUser(UserProvider userProvider) {
    if (_prefilledFromUser) return;

    final hasData = userProvider.userId != null ||
        userProvider.userName != null ||
        userProvider.userEmail != null ||
        userProvider.userPhone != null ||
        userProvider.userUsername != null ||
        userProvider.userBirthdate != null ||
        userProvider.userGender != null;

    if (!hasData) return;

    _nombreCompletoController.text =
        userProvider.userName ?? _nombreCompletoController.text;
    _correoController.text =
        userProvider.userEmail ?? _correoController.text;
    _telefonoController.text =
        userProvider.userPhone ?? _telefonoController.text;
    _usuarioController.text =
        userProvider.userUsername ?? _usuarioController.text;
    _fechaController.text =
        userProvider.userBirthdate ?? _fechaController.text;
    _generoValue =
        _normalizeGender(userProvider.userGender) ?? _generoValue;

    _prefilledFromUser = true;
  }

  Future<void> _saveProfile(UserProvider userProvider) async {
    final userId = userProvider.userId;
    if (userId == null) {
      _showMessage('Inicia sesión para actualizar tu perfil.', isError: true);
      return;
    }

    // --- Validaciones ---
    final email = _correoController.text.trim();
    if (email.isNotEmpty && !_isValidEmail(email)) {
      _showMessage('Ingresa un correo válido (debe contener @ y terminar en .com).',
          isError: true);
      return;
    }

    final phone = _telefonoController.text.trim();
    if (phone.isNotEmpty && !_isValidPhone(phone)) {
      _showMessage('Ingresa un número de teléfono de 10 dígitos.', isError: true);
      return;
    }

    final username = _usuarioController.text.trim();
    if (username.isNotEmpty && username.length > 30) {
      _showMessage('El nombre de usuario debe tener máximo 30 caracteres.', isError: true);
      return;
    }

    final birthText = _fechaController.text.trim();
    if (birthText.isNotEmpty) {
      final birthDate = _parseDate(birthText);
      if (birthDate == null) {
        _showMessage('Ingresa una fecha de nacimiento válida (AAAA-MM-DD).',
            isError: true);
        return;
      }
      if (birthDate.isAfter(DateTime.now())) {
        _showMessage('La fecha de nacimiento no puede ser futura.', isError: true);
        return;
      }
      final eighteenYearsAgo = DateTime(
        DateTime.now().year - 18,
        DateTime.now().month,
        DateTime.now().day,
      );
      if (birthDate.isAfter(eighteenYearsAgo)) {
        _showMessage('Debes ser mayor de 18 años.', isError: true);
        return;
      }
    }

    final String genero = (_generoValue ?? '').toUpperCase();
    final Map<String, String> body = {};
    void addField(String key, String value) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) body[key] = trimmed;
    }

    addField('nombreCompleto', _nombreCompletoController.text);
    addField('correo', _correoController.text);
    addField('fechaNacimiento', _fechaController.text);
    addField('telefono', _telefonoController.text);
    addField('nombreUsuario', _usuarioController.text);
    if (genero.isNotEmpty) body['genero'] = genero;
    if (body.isEmpty) {
      _showMessage('Ingresa datos para actualizar.', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final uri = Uri.parse(ApiConfig.usuario(userId));
      final request = http.MultipartRequest('PUT', uri);
      request.headers['Accept'] = 'application/json';
      request.fields['usuario'] = jsonEncode(body);

      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto', _selectedImage!.path),
        );
      }

      final streamed = await request.send();
      final respBody = await streamed.stream.bytesToString();

      if (!mounted) return;
      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        final newPhotoBytes =
            _selectedImage != null ? await _selectedImage!.readAsBytes() : null;
        await userProvider.updateUserData(
          nombreCompleto: body['nombreCompleto'],
          correo: body['correo'],
          telefono: body['telefono'],
          nombreUsuario: body['nombreUsuario'],
          fechaNacimiento: body['fechaNacimiento'],
          genero: body['genero'],
        );
        await userProvider.refreshUserFromApi();
        if (newPhotoBytes != null) {
          await userProvider.setUserPhotoCache(newPhotoBytes);
        }
        if (mounted) {
          setState(() {
            // Clear local selection after successful upload so avatar uses refreshed URL
            _selectedImage = null;
          });
        }
        _showMessage('Perfil actualizado correctamente.');
        Navigator.pop(context);
      } else {
        final errorDetail =
            respBody.isNotEmpty ? ': $respBody' : '';
        _showMessage(
          'Error al actualizar (código ${streamed.statusCode})$errorDetail',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Error de conexión: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
      ),
    );
  }

  String? _normalizeGender(String? raw) {
    if (raw == null) return null;
    final value = raw.toLowerCase();
    if (value.startsWith('m')) return 'm';
    if (value.startsWith('f')) return 'f';
    if (value.startsWith('o')) return 'o';
    return raw;
  }

  bool _isValidEmail(String email) {
    final lower = email.toLowerCase();
    return lower.contains('@') && lower.contains('.com');
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  DateTime? _parseDate(String raw) {
    try {
      final parts = raw.split('-');
      if (parts.length != 3) return null;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (picked == null) return;
      setState(() {
        _selectedImage = File(picked.path);
      });
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showMessage('No se pudo seleccionar la imagen: $e', isError: true);
    }
  }

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
      BuildContext context,
      bool isDarkMode,
      Color textColor,
      UserProvider userProvider) {
    // Logic to determine which image to show
    ImageProvider? imageProvider;
    if (_selectedImage != null) {
      imageProvider = FileImage(_selectedImage!);
    } else if (userProvider.userPhotoCache != null &&
        userProvider.userPhotoCache!.isNotEmpty) {
      imageProvider = MemoryImage(userProvider.userPhotoCache!);
    } else if (userProvider.userPhotoUrl != null &&
        userProvider.userPhotoUrl!.isNotEmpty) {
      imageProvider = NetworkImage(userProvider.userPhotoUrl!);
    }

    final displayName = userProvider.userName?.isNotEmpty == true
        ? userProvider.userName!
        : 'Usuario';
    final rawUsername = userProvider.userUsername;
    final displaySubtitle = userProvider.userEmail ??
        ((rawUsername != null && rawUsername.isNotEmpty)
            ? (rawUsername.startsWith('@') ? rawUsername : '@$rawUsername')
            : 'Quito, Ecuador');

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
                child: imageProvider == null
                    ? Icon(
                        Icons.person,
                        size: 48,
                        color:
                            isDarkMode ? Colors.white70 : AppColors.textPrimary,
                      )
                    : null,
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
          displayName,
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          displaySubtitle,
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final ImageProvider? oldImage =
        (userProvider.userPhotoCache != null && userProvider.userPhotoCache!.isNotEmpty)
            ? MemoryImage(userProvider.userPhotoCache!)
            : (userProvider.userPhotoUrl?.isNotEmpty == true
                ? NetworkImage(userProvider.userPhotoUrl!)
                : null);
    final ImageProvider? newImage =
        _selectedImage != null ? FileImage(_selectedImage!) : null;

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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                        Column(
                          children: [
                            Text(
                              "Foto anterior",
                              style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                            const SizedBox(height: 10),
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey,
                              backgroundImage: oldImage,
                              child: oldImage == null
                                  ? Icon(
                                      Icons.person,
                                      color: isDarkMode ? Colors.white : Colors.black54,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                    Column(
                      children: [
                        Text(
                          "Foto nueva",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: newImage,
                          child: newImage == null
                              ? Icon(
                                  Icons.add_a_photo_outlined,
                                  color: isDarkMode ? Colors.white : Colors.black54,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ],
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
                        onTap: () => _pickImage(ImageSource.camera)),
                    _buildImageOption(
                        icon: Icons.photo_library_outlined,
                        label: "Galería",
                        isDarkMode: isDarkMode,
                        onTap: () => _pickImage(ImageSource.gallery)),
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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
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
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
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
          counterText: '',
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
