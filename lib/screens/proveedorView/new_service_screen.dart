import 'package:flutter/material.dart';

class NewServiceScreen extends StatefulWidget {
  const NewServiceScreen({super.key});

  @override
  State<NewServiceScreen> createState() => _NewServiceScreenState();
}

class _NewServiceScreenState extends State<NewServiceScreen> {
  // Controladores para los campos de texto
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Valor seleccionado para el Dropdown
  String _selectedCategory = 'Categoría 1';
  final List<String> _categories = [
    'Categoría 1',
    'Categoría 2',
    'Categoría 3',
    'Servicios de Fiesta',
    'Música y Entretenimiento',
  ];

  // Color primario extraído de tu CustomBottomNavBar
  static const Color primaryColor = Color.fromRGBO(59, 96, 125, 1);
  // Color de fondo para inputs, extraído de tu MessagesScreen
  static final Color inputFillColor = Colors.grey[200]!;
  // Radio de borde estándar
  static final BorderRadius inputBorderRadius = BorderRadius.circular(12.0);

  @override
  void dispose() {
    // Es buena práctica limpiar los controladores
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Función placeholder para la lógica de subir imágenes
  void _pickImages() {
    // Aquí iría la lógica para abrir la galería de imágenes
    // Por ejemplo, usando el paquete image_picker
    print('Abriendo galería...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Fondo blanco y elevación 0 para un look limpio
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        // Título alineado con el estilo de la imagen
        title: const Text(
          'Nuevo Servicio',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        // Icono de "atrás" para volver (buena UX)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TÍTULO DEL SERVICIO ---
              _buildSectionTitle('Título del servicio'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _titleController,
                hintText: 'Ej. Mariachi para fiestas',
              ),
              const SizedBox(height: 24),

              // --- CATEGORÍA ---
              _buildSectionTitle('Selecciona una categoría'),
              const SizedBox(height: 8),
              _buildCategoryDropdown(),
              const SizedBox(height: 24),

              // --- PRECIO ---
              _buildSectionTitle('Precio del servicio'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _priceController,
                hintText: '\$0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.attach_money,
              ),
              const SizedBox(height: 24),

              // --- DESCRIPCIÓN ---
              _buildSectionTitle('Descripción del servicio'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _descriptionController,
                hintText: 'Describe tu servicio en detalle...',
                maxLines: 5,
                maxLength: 500, // Esto añade el contador automáticamente
              ),
              const SizedBox(height: 24),

              // --- SUBIR FOTOS/VIDEOS ---
              _buildSectionTitle('Añade fotos o videos al servicio'),
              const SizedBox(height: 8),
              _buildImageUploader(),
              const SizedBox(height: 32),

              // --- BOTÓN DE PUBLICAR (UX Esencial) ---
              _buildSubmitButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget helper para los títulos de sección
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  /// Widget helper genérico para los campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    IconData? prefixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: inputFillColor,
        filled: true,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.grey[600])
            : null,
        // Borde estándar (sin línea)
        border: OutlineInputBorder(
          borderRadius: inputBorderRadius,
          borderSide: BorderSide.none,
        ),
        // Borde cuando está enfocado (usa el color primario)
        focusedBorder: OutlineInputBorder(
          borderRadius: inputBorderRadius,
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
        // Ajustamos el padding para que el contador (si existe) quede bien
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  /// Widget helper para el dropdown de categorías
  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: inputBorderRadius,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCategory = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  /// Widget helper para el área de subir archivos
  Widget _buildImageUploader() {
    // Usamos InkWell para hacerlo "clicable"
    return InkWell(
      onTap: _pickImages,
      borderRadius: inputBorderRadius, // Para que el "ripple" sea redondeado
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: inputFillColor,
          borderRadius: inputBorderRadius,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.upload_file_outlined, // Un icono más moderno
              size: 48,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 12),
            Text(
              'Click para subir archivos',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'desde tu galería',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget helper para el botón de enviar
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // Usamos los colores de tu NavBar para consistencia
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: inputBorderRadius,
          ),
          elevation: 2, // Sombra sutil
        ),
        onPressed: () {
          // Aquí iría la lógica para guardar el servicio
          final title = _titleController.text;
          final price = _priceController.text;
          final description = _descriptionController.text;
          final category = _selectedCategory;

          print('--- Nuevo Servicio Creado ---');
          print('Título: $title');
          print('Precio: $price');
          print('Categoría: $category');
          print('Descripción: $description');

          // Opcional: Mostrar un SnackBar de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Servicio publicado con éxito'),
              backgroundColor:
                  Color.fromARGB(255, 26, 188, 156), // Verde de tus chats
            ),
          );

          // Opcional: Regresar a la pantalla anterior
          // Navigator.of(context).pop();
        },
        child: const Text(
          'Publicar Servicio',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
