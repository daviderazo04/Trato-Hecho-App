import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../../config/theme_provider.dart'; // Import ThemeProvider
import '../../config/user_provider.dart';
import '../../config/appColors.dart';

// --- CONFIGURACIÓN DE LA API ---
final String BASE_API_URL =
    dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080/api';
final String CATEGORIES_URL = "$BASE_API_URL/categorias";
final String SERVICES_URL = "$BASE_API_URL/servicios";

// --- MODELO PARA CATEGORÍAS ---
class Category {
  final int id;
  final String nombre;
  Category({required this.id, required this.nombre});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      nombre:
          json.containsKey('nombre') ? json['nombre'] as String : 'Sin Nombre',
    );
  }
}

// ----------------------------------------------------------------------
// WIDGET PRINCIPAL
// ----------------------------------------------------------------------

class NewServiceScreen extends StatefulWidget {
  const NewServiceScreen({super.key});

  @override
  State<NewServiceScreen> createState() => _NewServiceScreenState();
}

class _NewServiceScreenState extends State<NewServiceScreen> {
  // --- COLORES ---
  static const Color _selectCategoryButtonColor = AppColors.primary;
  static const Color _selectedChipBgColor = Color(0xFF10B981);

  // --- CONTROLADORES ---
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // --- ESTADO DE LÓGICA DE NEGOCIO ---
  final List<Category> _availableCategories = [];
  final List<Category> _selectedCategoriesObjects = [];
  final List<File> _selectedFiles = [];

  bool _isLoadingCategories = true;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _clearFormAndNavigateBack() {
    _titleController.clear();
    _priceController.clear();
    _descriptionController.clear();

    setState(() {
      _selectedCategoriesObjects.clear();
      _selectedFiles.clear();
    });

    Navigator.pop(context);
  }

  // ============================================================
  // LÓGICA DE API
  // ============================================================

  Future<void> _fetchCategories() async {
    if (BASE_API_URL.isEmpty) {
      setState(() => _isLoadingCategories = false);
      return;
    }

    try {
      final response = await http.get(Uri.parse(CATEGORIES_URL));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _availableCategories.clear();
          _availableCategories
              .addAll(jsonList.map((json) => Category.fromJson(json)).toList());
          _isLoadingCategories = false;
        });
      } else {
        throw Exception("Failed to load categories: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching categories: $e");
      setState(() => _isLoadingCategories = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ Error al cargar categorías.'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _createService() async {
    if (_isPublishing) return;

    final userId =
        Provider.of<UserProvider>(context, listen: false).userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('⚠️ Inicia sesión para publicar un servicio.'),
            backgroundColor: AppColors.warning),
      );
      return;
    }

    final price = double.tryParse(_priceController.text) ?? 0.0;

    if (_titleController.text.isEmpty ||
        price <= 0 ||
        _selectedCategoriesObjects.isEmpty) {
      String message;
      if (_titleController.text.isEmpty) {
        message = '⚠️ El título es obligatorio.';
      } else if (price <= 0) {
        message = '⚠️ El precio debe ser mayor a cero.';
      } else if (_selectedCategoriesObjects.isEmpty) {
        message = '⚠️ Debe seleccionar al menos una categoría.';
      } else {
        message = '⚠️ Complete todos los campos.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.warning),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final serviceDto = {
        "userId": userId,
        "nombre": _titleController.text,
        "descripcion": _descriptionController.text,
        "precio": price,
        "categoriasIds": _selectedCategoriesObjects.map((c) => c.id).toList(),
      };

      var request = http.MultipartRequest('POST', Uri.parse(SERVICES_URL));
      request.fields['servicio'] = jsonEncode(serviceDto);

      for (var file in _selectedFiles.take(3)) {
        request.files.add(
          await http.MultipartFile.fromPath('files', file.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('✅ Servicio publicado con éxito'),
                backgroundColor: AppColors.success),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'ℹ️ Tu servicio puede tardar unos minutos en aparecer en las búsquedas.'),
              backgroundColor: AppColors.gray,
              duration: Duration(seconds: 4),
            ),
          );
          _clearFormAndNavigateBack();
        }
      } else {
        throw Exception("Error ${response.statusCode}");
      }
    } catch (e) {
      print("Error al publicar servicio: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('❌ Error al publicar servicio'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  Future<void> _pickFiles() async {
    if (_selectedFiles.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('⚠️ Límite alcanzado: Máximo 3 archivos.'),
            backgroundColor: AppColors.warning),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
        imageQuality: 70, maxHeight: 1024, maxWidth: 1024);

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedFiles.addAll(pickedFiles.map((xfile) => File(xfile.path)));
        if (_selectedFiles.length > 3) {
          _selectedFiles.removeRange(3, _selectedFiles.length);
        }
      });
    }
  }

  void _addCategory(String categoryName) {
    try {
      final cat =
          _availableCategories.firstWhere((c) => c.nombre == categoryName);
      if (!_selectedCategoriesObjects.any((c) => c.id == cat.id)) {
        setState(() => _selectedCategoriesObjects.add(cat));
      }
    } catch (e) {
      print("Error: Categoría no encontrada.");
    }
  }

  void _removeCategory(Category category) {
    setState(() =>
        _selectedCategoriesObjects.removeWhere((c) => c.id == category.id));
  }

  // ============================================================
  // CONSTRUCCIÓN DE LA VISTA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final double safeTop = MediaQuery.of(context).padding.top;

    // --- ACCESS THEME ---
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    // Define Colors based on Mode
    final Color backgroundColor =
        isDarkMode ? AppColors.backgroundDark : Colors.white;
    final Color titleColor = isDarkMode ? Colors.white : Colors.black;
    final Color subtitleColor =
        isDarkMode ? Colors.grey[400]! : Colors.black.withOpacity(0.7);
    final Color iconColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // -------------------
          // CONTENIDO PRINCIPAL
          // -------------------
          Column(
            children: [
              SizedBox(height: safeTop + 50),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Título principal
                      Text(
                        "Nuevo Servicio",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Información básica
                      _buildCenteredSectionTitle(
                        "Información básica",
                        "Describe tu servicio de forma clara para atraer más clientes",
                        titleColor,
                        subtitleColor,
                      ),

                      const SizedBox(height: 15),

                      _buildInput(
                        controller: _titleController,
                        hint: "Título del servicio",
                        icon: Icons.person_outline,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 15),

                      _buildInput(
                        controller: _priceController,
                        hint: "Precio del servicio",
                        icon: Icons.attach_money,
                        inputType: TextInputType.number,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 15),

                      _buildDescriptionInput(
                        controller: _descriptionController,
                        hint: "Descripción del servicio",
                        maxLength: 500,
                        icon: Icons.person_outline,
                        isDarkMode: isDarkMode,
                      ),

                      const SizedBox(height: 30),

                      // Clasificación
                      _buildCenteredSectionTitle(
                        "Clasifica tu servicio",
                        "Esto ayudará a tus clientes a ubicarte rápidamente",
                        titleColor,
                        subtitleColor,
                      ),

                      const SizedBox(height: 15),

                      _isLoadingCategories
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary))
                          : _buildCategoryChips(isDarkMode),

                      const SizedBox(height: 15),

                      _buildCategoryDropdownButton(isDarkMode),

                      const SizedBox(height: 30),

                      // Media
                      _buildCenteredSectionTitle(
                        "Muestra tu servicio",
                        "Los clientes confían más cuando pueden ver lo que ofreces",
                        titleColor,
                        subtitleColor,
                      ),

                      const SizedBox(height: 15),

                      _buildMediaUploadBox(isDarkMode),

                      const SizedBox(height: 10),
                      _buildSelectedFilesPreview(),

                      const SizedBox(height: 30),

                      // Botón Crear Servicio
                      _buildCreateServiceButton(isDarkMode),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // -------------------
          // FLECHA DE REGRESO
          // -------------------
          Positioned(
            top: safeTop + 10,
            left: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back,
                color: iconColor,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WIDGETS AUXILIARES
  // ============================================================

  Widget _buildCenteredSectionTitle(
      String title, String subtitle, Color titleColor, Color subtitleColor) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w600, color: titleColor),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: subtitleColor),
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
    TextInputType inputType = TextInputType.text,
  }) {
    final Color fillColor = isDarkMode ? AppColors.darkButtons : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color iconColor = isDarkMode ? Colors.white70 : Colors.black;
    final Color borderColor = isDarkMode ? Colors.white24 : Colors.black54;
    final Color hintColor = isDarkMode ? Colors.white54 : Colors.black54;

    return SizedBox(
      width: double.infinity,
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: iconColor),
          filled: true,
          fillColor: fillColor,
          hintText: hint,
          hintStyle: TextStyle(color: hintColor),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionInput({
    required TextEditingController controller,
    required String hint,
    required int maxLength,
    required IconData icon,
    required bool isDarkMode,
  }) {
    final Color fillColor = isDarkMode ? AppColors.darkButtons : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color iconColor = isDarkMode ? Colors.white70 : Colors.black;
    final Color borderColor = isDarkMode ? Colors.white24 : Colors.black54;
    final Color hintColor = isDarkMode ? Colors.white54 : Colors.black54;
    final Color counterColor = isDarkMode ? Colors.white54 : Colors.grey;

    return SizedBox(
      width: double.infinity,
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        maxLines: 5,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Icon(icon, color: iconColor),
          ),
          filled: true,
          fillColor: fillColor,
          hintText: hint,
          hintStyle: TextStyle(color: hintColor),
          alignLabelWithHint: true,
          counterText: '${controller.text.length}/$maxLength caracteres',
          counterStyle: TextStyle(color: counterColor, fontSize: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(bool isDarkMode) {
    if (_selectedCategoriesObjects.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          "Ninguna categoría seleccionada.",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontStyle: FontStyle.italic),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        alignment: WrapAlignment.start,
        children: _selectedCategoriesObjects.map((category) {
          return ChoiceChip(
            label: Text(category.nombre),
            selected: true,
            onSelected: (_) => _removeCategory(category),
            selectedColor: _selectedChipBgColor,
            backgroundColor: _selectedChipBgColor,
            labelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide.none,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryDropdownButton(bool isDarkMode) {
    final selectedNames =
        _selectedCategoriesObjects.map((c) => c.nombre).toSet();

    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: _selectCategoryButtonColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: null,
          isExpanded: true,
          dropdownColor: AppColors.primary,
          hint: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              "Seleccionar categoría/s",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ),
          items: _availableCategories
              .where((c) => !selectedNames.contains(c.nombre))
              .map((category) {
            return DropdownMenuItem<String>(
              value: category.nombre,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(category.nombre,
                    style: const TextStyle(color: Colors.white)),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) _addCategory(value);
          },
        ),
      ),
    );
  }

  Widget _buildMediaUploadBox(bool isDarkMode) {
    final Color boxColor = isDarkMode ? AppColors.darkButtons : Colors.white;
    final Color borderColor = isDarkMode ? Colors.white24 : Colors.black26;
    final Color iconColor = isDarkMode ? Colors.white : Colors.black;
    final Color textColor =
        isDarkMode ? Colors.white70 : Colors.black.withOpacity(0.7);
    final Color subTextColor =
        isDarkMode ? Colors.white38 : Colors.black.withOpacity(0.5);

    return GestureDetector(
      onTap: _pickFiles,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: boxColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_upload_outlined, size: 60, color: iconColor),
            const SizedBox(height: 10),
            Text(
              'Click para subir archivos\ndesde tu galería',
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 5),
            Text(
              'Añade fotos o videos al servicio (${_selectedFiles.length}/3)',
              style: TextStyle(color: subTextColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFilesPreview() {
    if (_selectedFiles.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedFiles.length,
        itemBuilder: (context, index) {
          final file = _selectedFiles[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    file,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFiles.removeAt(index)),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreateServiceButton(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.8),
          width: 2,
        ),
      ),
      child: ElevatedButton(
        onPressed: _isPublishing ? null : _createService,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 3,
        ),
        child: _isPublishing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Text(
                "Crear servicio",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
