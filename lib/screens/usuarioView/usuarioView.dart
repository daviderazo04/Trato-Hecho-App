import 'package:flutter/material.dart';
import '../../config/appColors.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../proveedorView/new_service_screen.dart';
import 'edit_profile_screen.dart';

class UsuarioView extends StatefulWidget {
  const UsuarioView({Key? key}) : super(key: key);

  @override
  _UsuarioViewState createState() => _UsuarioViewState();
}

class _UsuarioViewState extends State<UsuarioView> {
  int _selectedIndex = 3;
  final ScrollController _scrollController = ScrollController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scroll(double offset) {
    _scrollController.animateTo(
      _scrollController.offset + offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    const double scrollAmount = 156.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- 1. Ícono de Configuración ---
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: AppColors.textPrimary, // Color de texto principal
                      size: 28.0,
                    ),
                    onPressed: () {
                      // TODO: Implementar navegación a pantalla de configuración
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // --- Sección de Perfil (Avatar, Nombre y Estadísticas) ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Avatar de Usuario con Insignia ---
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 40, // Reducido el radio del avatar
                          backgroundColor: Colors.grey[200],
                          backgroundImage: NetworkImage(
                            'https://www.jreventos.com.ar/uploads/servicio-imagen/big/af332f5af35068cd6a8935e65c7f0a5c.jpeg', // Nueva URL para el avatar
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.secondary, // Color de la insignia
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.verified_user, // Ícono de verificación
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
                          // Nombre Público y Botón de Editar
                          Row(
                            children: [
                              Text(
                                'Pedro Enano', // Nombre
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EditProfileScreen(),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.edit,
                                  color: AppColors.textSecondary,
                                  size: 22.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Ubicación
                          Text(
                            'Quito, Ecuador', // Ubicación de ejemplo
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Sección de Estadísticas (Tratos, Reviews, Años) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('10', 'Tratos'),
                    Container(
                      height: 50,
                      width: 1,
                      color: AppColors.border,
                    ), // Divisor vertical
                    _buildStatColumn('4', 'Reviews'),
                    Container(
                      height: 50,
                      width: 1,
                      color: AppColors.border,
                    ), // Divisor vertical
                    _buildStatColumn('4', 'Años en TratoHecho'),
                  ],
                ),

                const SizedBox(height: 24),

                // --- 5. Divisor ---
                Divider(
                  color: AppColors.border,
                  thickness: 1,
                ),

                const SizedBox(height: 24), // Espacio después del divisor

                // --- SECCIÓN "Mis Servicios" ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // --- Título y botón de Añadir juntos ---
                      Row(
                        children: [
                          Text(
                            'Mis Servicios',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8), // Espacio
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(Icons.add,
                                color: AppColors.textPrimary, size: 28),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NewServiceScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      // --- Flechas de navegación juntas ---
                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(Icons.arrow_back_ios,
                                color: AppColors.textPrimary, size: 20),
                            onPressed: () {
                              _scroll(-scrollAmount);
                            },
                          ),
                          const SizedBox(width: 8), // Espacio
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(Icons.arrow_forward_ios,
                                color: AppColors.textPrimary, size: 20),
                            onPressed: () {
                              _scroll(scrollAmount);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // --- Carrusel de Tarjetas de Servicio ---
                SizedBox(
                  height: 140, // Altura fija para el carrusel
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    thickness: 3.0,
                    radius: const Radius.circular(2.0),
                    child: ListView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(bottom: 20),
                      children: const [
                        _ServiceCard(
                          imageUrl:
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcROP0F8frSy8dG_OEnlu6tcyS6LYBsXYC5h1g&s',
                          serviceName: 'Mariachis',
                        ),
                        SizedBox(width: 16),
                        _ServiceCard(
                          imageUrl:
                              'https://media.minutouno.com/p/4a0e318ddc071d2050e87fbc4adaec7f/adjuntos/150/imagenes/027/232/0027232808/610x0/smart/enano.png',
                          serviceName: 'Músicos',
                        ),
                        SizedBox(width: 16),
                        _ServiceCard(
                          imageUrl:
                              'https://ichef.bbci.co.uk/ace/ws/640/amz/worldservice/live/assets/images/2015/04/11/150411184332_reino4.jpg.webp',
                          serviceName: 'Bailarines',
                        ),
                        SizedBox(width: 16),
                        _ServiceCard(
                          imageUrl:
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS5_JhkW8fYH8C-VyTLWBvft64oA1K1gy5giw&s',
                          serviceName: 'Payasos',
                        ),
                        SizedBox(width: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24), // Espacio antes de las opciones

                // --- 6. Divisor ---
                Divider(
                  color: AppColors.border,
                  thickness: 1,
                ),

                // --- 7. SECCIÓN DE OPCIONES (NUEVO) ---
                Column(
                  children: [
                    _buildOptionRow(
                      context,
                      icon: Icons.lock_outline,
                      text: 'Cambiar contraseña',
                      onTap: () {
                        // TODO: Navegar a Cambiar Contraseña
                      },
                    ),
                    Divider(
                      color: AppColors.border,
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                    ), // Divisor más sutil
                    _buildOptionRow(
                      context,
                      icon: Icons.help_outline,
                      text: 'Ayuda & Soporte',
                      onTap: () {
                        // TODO: Navegar a Ayuda y Soporte
                      },
                    ),
                    Divider(
                      color: AppColors.border,
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                    _buildOptionRow(
                      context,
                      icon: Icons.logout,
                      text: 'Cerrar Sesion',
                      onTap: () {
                        // TODO: Implementar lógica de Cerrar Sesión
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24), // Espacio al final
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget Helper para las columnas de estadísticas ---
  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Para que la columna se ajuste
      children: [
        Text(
          count,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18, // Tamaño de fuente más grande para el número
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center, // Centrar texto si es muy largo
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // --- NUEVO Widget Helper para las filas de opciones ---
  Widget _buildOptionRow(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.textPrimary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Widget: _ServiceCard (Componente de Tarjeta de Servicio) ---
class _ServiceCard extends StatelessWidget {
  final String imageUrl;
  final String serviceName;

  const _ServiceCard({
    Key? key,
    required this.imageUrl,
    required this.serviceName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140, // Ancho fijo para cada tarjeta
      decoration: BoxDecoration(
        color: AppColors.secondary, // Fondo de la tarjeta (azul pizarra)
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // Sombra suave
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Column(
          children: [
            Expanded(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors
                        .border, // Color de fondo si la imagen no carga
                    child: Center(
                      child: Icon(Icons.broken_image,
                          color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
              child: Text(
                serviceName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white, // Texto blanco sobre el color primario
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w600, // Ajustado a w600 para mejor legibilidad
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
