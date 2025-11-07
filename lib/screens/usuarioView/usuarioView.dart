import 'package:flutter/material.dart';
import '../../config/appColors.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../proveedorView/new_service_screen.dart';
import 'edit_profile_screen.dart';

class UsuarioView extends StatefulWidget {
  final bool showModeSwitch;

  const UsuarioView({
    Key? key,
    this.showModeSwitch = false,
  }) : super(key: key);

  @override
  _UsuarioViewState createState() => _UsuarioViewState();
}

class _UsuarioViewState extends State<UsuarioView> {
  int _selectedIndex = 3;
  final ScrollController _scrollController = ScrollController();

  // This variable now controls which UI is shown
  bool _isSupplierMode = false;
  String _selectedFontSize = '16 pt';

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
              crossAxisAlignment: CrossAxisAlignment.start, // Align titles left
              children: [
                const SizedBox(height: 10),

                // --- 1. Sección de Perfil (Avatar, Nombre y Estadísticas) ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: NetworkImage(
                        'https://www.jreventos.com.ar/uploads/servicio-imagen/big/af332f5af35068cd6a8935e65c7f0a5c.jpeg',
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pedro el Enano',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quito, Ecuador',
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

                // --- 2. (CONDITIONAL) Sección de Estadísticas ---
                // This will HIDE when in client mode
                if (_isSupplierMode)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn('10', 'Tratos'),
                          Container(
                            height: 50,
                            width: 1,
                            color: AppColors.border,
                          ),
                          _buildStatColumn('4', 'Reviews'),
                          Container(
                            height: 50,
                            width: 1,
                            color: AppColors.border,
                          ),
                          _buildStatColumn('4', 'Años en TratoHecho'),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                // --- 3. (CONDITIONAL) Modo Proveedor/Cliente Switch ---
                if (widget.showModeSwitch)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFEFEFF4),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // --- DYNAMIC LABEL ---
                          Text(
                            _isSupplierMode ? 'Modo Proveedor' : 'Modo Cliente',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Switch(
                            value: _isSupplierMode,
                            onChanged: (value) {
                              setState(() {
                                _isSupplierMode = value;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),

                // --- 4. "Tratos" Section (Shared) ---
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Tratos',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildOptionRow(
                  context,
                  icon: Icons.history,
                  text: 'Tratos Recientes',
                  onTap: () {},
                ),
                _buildOptionRow(
                  context,
                  icon: Icons.favorite_border,
                  text: 'Favoritos',
                  onTap: () {},
                ),
                // --- (CONDITIONAL) List Item ---
                if (_isSupplierMode)
                  _buildOptionRow(
                    context,
                    icon: Icons.publish, // Supplier icon
                    text: 'Publicar Servicios', // Supplier text
                    onTap: () {},
                  )
                else
                  _buildOptionRow(
                    context,
                    icon: Icons.check, // Customer icon
                    text: 'Prestar Servicios', // Customer text
                    onTap: () {
                      // Maybe this toggles them to supplier mode?
                      setState(() {
                        _isSupplierMode = true;
                      });
                    },
                  ),
                _buildOptionRow(
                  context,
                  icon: Icons.quiz_outlined,
                  text: 'Preguntas Frecuentes',
                  onTap: () {},
                ),

                // --- 5. (CONDITIONAL) Supplier-Only Sections ---
                // This entire block will HIDE when in client mode
                if (_isSupplierMode)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // --- "Mis Tratos" Section ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mis Tratos',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(Icons.arrow_back_ios,
                                    color: AppColors.primary, size: 20),
                                onPressed: () => _scroll(-scrollAmount),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(Icons.arrow_forward_ios,
                                    color: AppColors.primary, size: 20),
                                onPressed: () => _scroll(scrollAmount),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // --- Carrusel de Tarjetas ---
                      SizedBox(
                        height: 140,
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
                                serviceName: 'Enanos',
                              ),
                              SizedBox(width: 16),
                              _ServiceCard(
                                imageUrl:
                                    'https://ichef.bbci.co.uk/ace/ws/640/amz/worldservice/live/assets/images/2015/04/11/150411184332_reino4.jpg.webp',
                                serviceName: 'Bailarines',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // --- "Publicar un nuevo Trato" Button ---
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const NewServiceScreen()),
                          );
                        },
                        child: const Text(
                          'Publicar un nuevo Trato',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // --- Divider ---
                      Divider(
                        color: AppColors.border,
                        thickness: 1,
                      ),
                    ],
                  ),

                // --- 6. "Configuración" Section (Shared) ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Configuración',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(
                  children: [
                    _buildOptionRow(
                      context,
                      icon: Icons.person_outline,
                      text: 'Cuenta',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildOptionRow(
                      context,
                      icon: Icons.lock_outline,
                      text: 'Cambiar contraseña',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    // --- Tamaño de Texto ---
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.text_fields,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Tamaño de Texto',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedFontSize,
                                items: <String>[
                                  '12 pt',
                                  '14 pt',
                                  '16 pt',
                                  '18 pt'
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                          color: AppColors.textPrimary),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedFontSize = newValue!;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    _buildDivider(),
                    // --- Cerrar Sesión ---
                    _buildOptionRow(
                      context,
                      icon: Icons.logout,
                      text: 'Cerrar Sesion',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper para Divisor sutil ---
  Widget _buildDivider() {
    return Divider(
      color: AppColors.border,
      height: 1,
      indent: 20,
      endIndent: 20,
    );
  }

  // --- Helper para las columnas de estadísticas ---
  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // --- Helper para las filas de opciones ---
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
                color: AppColors.primary,
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
                color: AppColors.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Widget: _ServiceCard (Sin cambios) ---
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
      width: 140,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
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
                    color: AppColors.border,
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
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
