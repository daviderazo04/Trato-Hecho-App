import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../config/appColors.dart';

// ----------------------------------------------------------------------
// CONFIGURACIÓN DE LA API (SIMULANDO OBTENCIÓN DE .ENV)
// ----------------------------------------------------------------------

// Usamos una constante estática para simular la configuración centralizada.
// Tu valor de .env es: API_BASE_URL=http://localhost:8080/api
// Adaptamos esto para que la clase de Dart pueda construir las URLs completas.
class ApiConfig {
  // Asegúrate de que esta URL sea accesible (ej. http://10.0.2.2:8080 para Android emulator)
  static const String BASE_API_URL = "http://10.0.2.2:8080/api";

  static const String CATEGORIES = "$BASE_API_URL/categorias";
  static const String SERVICES = "$BASE_API_URL/servicios";
}

// ----------------------------------------------------------------------
// MODELO DE DATOS
// ----------------------------------------------------------------------

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

  // SIMULACIÓN DE USER ID (DEBE VENIR DE UN PROVIDER REAL)
  final int _currentUserId = 1;

  // --- INITIALIZATION ---
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

  // ============================================================
  // LÓGICA DE API Y ESTADO
  // ============================================================

  // OBTENER CATEGORÍAS
  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.CATEGORIES));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _availableCategories.clear();
          _availableCategories
              .addAll(jsonList.map((json) => Category.fromJson(json)).toList());
          _isLoadingCategories = false;
          // Inicializa las categorías seleccionadas con un ejemplo si la lista está vacía
          if (_selectedCategoriesObjects.isEmpty &&
              _availableCategories.isNotEmpty) {
            _selectedCategoriesObjects.addAll(_availableCategories.take(3));
          }
        });
      } else {
        throw Exception("Failed to load categories: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching categories: $e");
      setState(() => _isLoadingCategories = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '❌ Error al cargar categorías: ${e.toString().split(':').last}'),
            backgroundColor: AppColors.error),
      );
    }
  }

  // PUBLICAR SERVICIO (MULTIPART REQUEST)
  Future<void> _createService() async {
    if (_isPublishing) return;

    // Validación básica
    final price = double.tryParse(_priceController.text) ?? 0.0;
    if (_titleController.text.isEmpty ||
        price <= 0 ||
        _selectedCategoriesObjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('⚠️ Complete título, precio y seleccione categorías.'),
            backgroundColor: AppColors.warning),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      // 1. Crear el DTO JSON
      final serviceDto = {
        "userId": _currentUserId,
        "nombre": _titleController.text,
        "descripcion": _descriptionController.text,
        "precio": price,
        "categoriasIds": _selectedCategoriesObjects.map((c) => c.id).toList(),
      };

      // 2. Crear el MultipartRequest
      var request =
          http.MultipartRequest('POST', Uri.parse(ApiConfig.SERVICES));

      // 3. Agregar el DTO JSON como campo 'servicio'
      request.fields['servicio'] = jsonEncode(serviceDto);

      // 4. Agregar archivos multimedia (Máx 3)
      for (var file in _selectedFiles.take(3)) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'files', // Clave requerida por la API
            file.path,
          ),
        );
      }

      // 5. Enviar la petición
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Servicio publicado con éxito'),
              backgroundColor: AppColors.success),
        );
        // Opcional: Navegar de regreso: Navigator.pop(context);
      } else {
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(
            "Error ${response.statusCode}: ${errorBody['message'] ?? response.reasonPhrase}");
      }
    } catch (e) {
      print("Error al publicar servicio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('❌ Error al publicar: ${e.toString().split(':').last}'),
            backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isPublishing = false);
    }
  }

  // SELECCIÓN DE ARCHIVOS MULTIMEDIA
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
        // Limitar a 3 archivos después de la selección
        if (_selectedFiles.length > 3) {
          _selectedFiles.removeRange(3, _selectedFiles.length);
        }
      });
    }
  }

  // GESTIÓN DE CATEGORÍAS EN ESTADO
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // -------------------
          // CONTENIDO PRINCIPAL (Centrado)
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
                      // Título principal (Centrado)
                      Text(
                        "Nuevo Servicio",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Información básica
                      _buildCenteredSectionTitle(
                        "Información básica",
                        "Describe tu servicio de forma clara para atraer más clientes",
                      ),

                      const SizedBox(height: 15),

                      _buildInput(
                        controller: _titleController,
                        hint: "Título del servicio",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 15),

                      _buildInput(
                        controller: _priceController,
                        hint: "Precio del servicio",
                        icon: Icons.attach_money,
                        inputType: TextInputType.number,
                      ),
                      const SizedBox(height: 15),

                      _buildDescriptionInput(
                        controller: _descriptionController,
                        hint: "Descripción del servicio",
                        maxLength: 500,
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 30),

                      // Clasificación
                      _buildCenteredSectionTitle(
                        "Clasifica tu servicio",
                        "Esto ayudará a tus clientes a ubicarte rápidamente",
                      ),

                      const SizedBox(height: 15),

                      _isLoadingCategories
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary))
                          : _buildCategoryChips(),

                      const SizedBox(height: 15),

                      _buildCategoryDropdownButton(),

                      const SizedBox(height: 30),

                      // Media
                      _buildCenteredSectionTitle(
                        "Muestra tu servicio",
                        "Los clientes confían más cuando pueden ver lo que ofreces",
                      ),

                      const SizedBox(height: 15),

                      _buildMediaUploadBox(),

                      const SizedBox(height: 10),
                      _buildSelectedFilesPreview(),

                      const SizedBox(height: 30),

                      // Botón Crear Servicio
                      _buildCreateServiceButton(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // -------------------
          // FLECHA DE REGRESO (Posicionada en el Stack)
          // -------------------
          Positioned(
            top: safeTop + 10,
            left: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black87,
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

  Widget _buildCenteredSectionTitle(String title, String subtitle) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style:
                TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      width: double.infinity,
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black54),
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
  }) {
    return Container(
      width: double.infinity,
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        maxLines: 5,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Icon(icon, color: Colors.black),
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          alignLabelWithHint: true,
          counterText: '${controller.text.length}/$maxLength caracteres',
          counterStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
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

  Widget _buildCategoryDropdownButton() {
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

  Widget _buildMediaUploadBox() {
    return GestureDetector(
      onTap: _pickFiles,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.file_upload_outlined,
                size: 60, color: Colors.black),
            const SizedBox(height: 10),
            Text(
              'Click para subir archivos\ndesde tu galería',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black.withOpacity(0.7)),
            ),
            const SizedBox(height: 5),
            Text(
              'Añade fotos o videos al servicio (${_selectedFiles.length}/3)',
              style:
                  TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 12),
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

  Widget _buildCreateServiceButton() {
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
