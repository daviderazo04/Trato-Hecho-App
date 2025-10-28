import 'package:flutter/material.dart';
import '../../config/appColors.dart';

// Esta es una nueva pantalla (StatefulWidget)
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // --- 1. CONTROLADORES PARA EL FORMULARIO ---
  late TextEditingController _nombreCompletoController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _usuarioController;
  late TextEditingController _fechaController;
  String? _generoValue;

  @override
  void initState() {
    super.initState();
    // Inicializamos los controllers con los datos del usuario
    // (Aquí podríamos cargar datos de un servicio, por ahora son de ejemplo)
    _nombreCompletoController = TextEditingController(text: "Pedro Enano");
    _correoController = TextEditingController(text: "pedro.enano@mail.com");
    _telefonoController = TextEditingController(text: "0991234567");
    _usuarioController = TextEditingController(text: "@el_enanito_69");
    _fechaController = TextEditingController(text: "1990-01-01");
  }

  @override
  void dispose() {
    // Limpiamos los controllers
    _nombreCompletoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _usuarioController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            // --- 2. Este es el contenido del antiguo _buildEditForm ---
            child: Column(
              children: [
                // --- Cabecera del Formulario (Atrás y Título) ---
                Row(
                  children: [
                    IconButton(
                      icon:
                          Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      onPressed: () {
                        // --- CAMBIO: Regresar a la pantalla anterior ---
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Editar Perfil',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Cabecera de Perfil (Avatar, Nombre, Stats) ---
                _buildProfileHeader(context,
                    isEditing: true), // Header en modo edición
                const SizedBox(height: 20),
                _buildStatsRow(context), // Fila de estadísticas (se mantiene)

                const SizedBox(height: 24),
                Divider(color: AppColors.border, thickness: 1),
                const SizedBox(height: 24),

                // --- Formulario ---
                _buildTextFormField(
                  controller: _nombreCompletoController,
                  labelText: 'Nombre Completo',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _correoController,
                  labelText: 'Correo',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                // --- Fila de Género y Fecha ---
                Row(
                  children: [
                    // Género
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _generoValue,
                        decoration: InputDecoration(
                          labelText: 'Genero', // AÑADIDO
                          labelStyle: TextStyle(
                              color: AppColors.textSecondary), // AÑADIDO
                          // hint: Text('Genero', // ELIMINADO
                          //     style: TextStyle(color: AppColors.textSecondary)),
                          prefixIcon:
                              Icon(Icons.wc, color: AppColors.textSecondary),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: AppColors.border)),
                          filled: true,
                          fillColor: AppColors.backgroundLight,
                        ),
                        items: [
                          DropdownMenuItem(
                              value: 'm', child: Text('Masculino')),
                          DropdownMenuItem(value: 'f', child: Text('Femenino')),
                          DropdownMenuItem(value: 'o', child: Text('Otro')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _generoValue = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Fecha de Nacimiento
                    Expanded(
                      child: _buildTextFormField(
                        controller: _fechaController,
                        labelText: 'Fecha de nacimeinto',
                        icon: Icons.calendar_today_outlined,
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            // Formateamos la fecha
                            String formattedDate =
                                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                            setState(() {
                              _fechaController.text = formattedDate;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _telefonoController,
                  labelText: 'Numero de telefono',
                  icon: Icons.phone_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _usuarioController,
                  labelText: 'Nombre de Usuario',
                  icon: Icons.account_circle_outlined,
                ),
                const SizedBox(height: 24),
                // --- Botón Guardar ---
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Guardar cambios en la base de datos
                    Navigator.pop(context); // Regresar a la vista de perfil
                  },
                  child: Text('Guardar Cambios'),
                ),
                const SizedBox(height: 16),
                // --- Botón Eliminar Cuenta ---
                ElevatedButton.icon(
                  icon: Icon(Icons.delete_outline, color: Colors.white),
                  label: Text('Eliminar Cuenta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Mostrar diálogo de confirmación para eliminar cuenta
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 3. WIDGETS HELPER COPIADOS DE USUARIOVIEW ---

  // --- HELPER: Cabecera de Perfil (Avatar, Nombre) ---
  Widget _buildProfileHeader(BuildContext context, {required bool isEditing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --- Avatar con Insignia (Verificado o Editar) ---
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              backgroundImage: NetworkImage(
                  'https://www.jreventos.com.ar/uploads/servicio-imagen/big/af332f5af35068cd6a8935e65c7f0a5c.jpeg'),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  // Cambia el color de la insignia basado en el modo
                  color: isEditing ? AppColors.secondary : AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  // Cambia el ícono basado en el modo
                  isEditing ? Icons.edit : Icons.verified_user,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        // --- Información del Usuario (Nombre y Ubicación) ---
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Pedro Enano',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  // Oculta el botón de editar si ya estamos en modo edición
                  if (!isEditing)
                    GestureDetector(
                      onTap: () {
                        // (En esta pantalla, el botón de editar de la cabecera no es necesario)
                      },
                      child: Icon(Icons.edit,
                          color: AppColors.textSecondary, size: 22.0),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Quito, Ecuador',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- HELPER: Fila de Estadísticas ---
  Widget _buildStatsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatColumn('10', 'Tratos'),
        Container(height: 50, width: 1, color: AppColors.border),
        _buildStatColumn('4', 'Reviews'),
        Container(height: 50, width: 1, color: AppColors.border),
        _buildStatColumn('4', 'Años en TratoHecho'),
      ],
    );
  }

// --- HELPER: Columna de Estadísticas ---
  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  // --- HELPER: Campo de Texto del Formulario ---
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: AppColors.secondary, width: 2)),
        filled: true,
        fillColor: AppColors.backgroundLight,
      ),
    );
  }
}
