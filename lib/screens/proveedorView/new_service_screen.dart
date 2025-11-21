import 'package:flutter/material.dart';
import '../../config/appColors.dart';

class NewServiceScreen extends StatefulWidget {
  const NewServiceScreen({super.key});

  @override
  State<NewServiceScreen> createState() => _NewServiceScreenState();
}

class _NewServiceScreenState extends State<NewServiceScreen> {
  static const Color _selectCategoryButtonColor = AppColors.primary;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _allCategories = [
    'Baile',
    'Música',
    'Fiestas',
    'Eventos',
    'Clases'
  ];
  final List<String> _selectedCategories = ['Baile', 'Música', 'Fiestas'];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addCategory(String category) {
    if (!_selectedCategories.contains(category)) {
      setState(() {
        _selectedCategories.add(category);
      });
    }
  }

  void _removeCategory(String category) {
    setState(() {
      _selectedCategories.remove(category);
    });
  }

  void _createService() {
    final selectedCategories = _selectedCategories;

    print('--- Nuevo Servicio Creado ---');
    print('Título: ${_titleController.text}');
    print('Categorías: $selectedCategories');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Servicio publicado con éxito'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // -------------------------
          // HEADER CENTRADO PERFECTO
          // -------------------------
          Padding(
            padding: EdgeInsets.only(
              top: safeTop + 10,
              left: 10,
              right: 10,
              bottom: 10,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black87,
                    size: 26,
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Text(
                      "Nuevo Servicio",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                // placeholder para balancear
                const SizedBox(width: 26),
              ],
            ),
          ),

          // -------------------------
          // CONTENIDO PRINCIPAL
          // -------------------------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // -------------------------
                  // INFORMACIÓN BÁSICA
                  // -------------------------
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
                    icon: Icons.description_outlined,
                  ),

                  const SizedBox(height: 30),

                  // -------------------------
                  // CLASIFICAR SERVICIO
                  // -------------------------
                  _buildCenteredSectionTitle(
                    "Clasifica tu servicio",
                    "Esto ayudará a tus clientes a ubicarte rápidamente",
                  ),

                  const SizedBox(height: 15),

                  _buildCategoryChips(),
                  const SizedBox(height: 15),
                  _buildCategoryDropdownButton(),

                  const SizedBox(height: 30),

                  // -------------------------
                  // MEDIA / ARCHIVOS
                  // -------------------------
                  _buildCenteredSectionTitle(
                    "Muestra tu servicio",
                    "Los clientes confían más cuando pueden ver lo que ofreces",
                  ),

                  const SizedBox(height: 15),

                  _buildMediaUploadBox(),

                  const SizedBox(height: 30),
                  _buildCreateServiceButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TÍTULOS CENTRADOS
  // ============================================================

  Widget _buildCenteredSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INPUTS
  // ============================================================

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
            padding: const EdgeInsets.only(bottom: 50),
            child: Icon(icon, color: Colors.black),
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          alignLabelWithHint: true,
          counterText: '${controller.text.length}/$maxLength caracteres',
          counterStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black54),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORÍAS (CHIPS)
  // ============================================================

  Widget _buildCategoryChips() {
    const Color selectedChipColor = Color(0xFF10B981);

    return Align(
      alignment: Alignment.center,
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: _selectedCategories.map((category) {
          return ChoiceChip(
            label: Text(category),
            selected: true,
            onSelected: (_) => _removeCategory(category),
            selectedColor: selectedChipColor,
            backgroundColor: selectedChipColor,
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

  // ============================================================
  // SELECTOR DROPDOWN
  // ============================================================

  Widget _buildCategoryDropdownButton() {
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
          items: _allCategories
              .where((c) => !_selectedCategories.contains(c))
              .map((category) {
            return DropdownMenuItem(
              value: category,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child:
                    Text(category, style: const TextStyle(color: Colors.white)),
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

  // ============================================================
  // MEDIA UPLOAD
  // ============================================================

  Widget _buildMediaUploadBox() {
    return GestureDetector(
      onTap: () {},
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
              'Añade fotos o videos al servicio',
              style:
                  TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOTÓN CREAR SERVICIO
  // ============================================================

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
        onPressed: _createService,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 3,
        ),
        child: const Text(
          "Crear servicio",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
