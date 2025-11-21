import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../../config/theme_provider.dart';
// --- CAMBIO 1: Importamos UserProvider ---
import '../../config/user_provider.dart';
import '../../config/appColors.dart';
import 'edit_profile_screen.dart';
import '../../screens/welcomeView/welcome_screen.dart';
import '../usuarioView/recent_deals_screen.dart';
import '../usuarioView/favorites_screen.dart';

// --- SERVICE DUMMIES (Keep your imports) ---
class NewServiceScreen extends StatelessWidget {
  const NewServiceScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text("New Service")));
}

class UsuarioView extends StatefulWidget {
  const UsuarioView({Key? key}) : super(key: key);

  @override
  _UsuarioViewState createState() => _UsuarioViewState();
}

class _UsuarioViewState extends State<UsuarioView> {
  final ScrollController _scrollController = ScrollController();

  bool _isSupplierMode = false;
  String _selectedFontSize = '16 pt';

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

  // --- Helper to get dynamic colors based on Global Dark Mode ---
  Color _backgroundColor(bool isDark) =>
      isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

  Color _textColor(bool isDark) =>
      isDark ? AppColors.darkText : AppColors.textPrimary;

  Color _subTextColor(bool isDark) =>
      isDark ? Colors.grey[300]! : AppColors.textSecondary;

  Color _iconColor(bool isDark) => isDark ? Colors.white : AppColors.primary;

  Color _cardColor(bool isDark) =>
      isDark ? AppColors.darkButtons : const Color(0xFFF0F4F8);

  @override
  Widget build(BuildContext context) {
    const double scrollAmount = 156.0;

    // 1. ACCESS THE GLOBAL VARIABLES
    final themeProvider = Provider.of<ThemeProvider>(context);
    // --- CAMBIO 2: Obtenemos el UserProvider (listen: false porque solo ejecutamos funciones) ---
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    final bool isDarkMode = themeProvider.isDarkMode;
    final String currentFontSize = themeProvider.currentFontSizeLabel;

    return Scaffold(
      backgroundColor: _backgroundColor(isDarkMode),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // --- 1. HEADER: Avatar & Name ---
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color:
                                isDarkMode ? AppColors.primary : Colors.white,
                            width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 42,
                        backgroundImage: NetworkImage(
                          'https://www.jreventos.com.ar/uploads/servicio-imagen/big/af332f5af35068cd6a8935e65c7f0a5c.jpeg',
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pedro Salas',
                          style: TextStyle(
                            color: _textColor(isDarkMode),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quito, Ecuador',
                          style: TextStyle(
                            color: _subTextColor(isDarkMode),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // --- 2. MODE SWITCH ---
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: _cardColor(isDarkMode),
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(
                      color: isDarkMode
                          ? AppColors.darkBorders 
                          : Colors.transparent, 
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isSupplierMode ? 'Modo Proveedor' : 'Modo Cliente',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textColor(isDarkMode),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.9,
                        child: Switch(
                          value: _isSupplierMode,
                          onChanged: (value) {
                            setState(() {
                              _isSupplierMode = value;
                            });
                          },
                          activeColor: Colors.white,
                          activeTrackColor: AppColors.primary,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFFB0B0B0),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- 3. (CONDITIONAL) SUPPLIER STATS ---
                if (_isSupplierMode) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppColors.darkButtons : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isDarkMode
                              ? Colors.transparent
                              : AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('10', 'Tratos', isDarkMode),
                        Container(
                            height: 30, width: 1, color: AppColors.darkText),
                        _buildStatColumn('4', 'Reviews', isDarkMode),
                        Container(
                            height: 30, width: 1, color: AppColors.darkText),
                        _buildStatColumn('4', 'Años', isDarkMode),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // --- 4. LIST SECTION ---
                _buildSectionTitle('Tratos', isDarkMode),
                const SizedBox(height: 10),
                _buildMenuItem(
                  icon: Icons.access_time,
                  text: 'Tratos Recientes',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RecentDealsScreen()),
                    );
                  },
                  isDarkMode: isDarkMode,
                ),
                _buildMenuItem(
                  icon: Icons.favorite_border,
                  text: 'Favoritos',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FavoritesScreen()),
                    );
                  },
                  isDarkMode: isDarkMode,
                ),

                if (_isSupplierMode)
                  _buildMenuItem(
                    icon: Icons.publish,
                    text: 'Publicar Servicios',
                    onTap: () {},
                    isDarkMode: isDarkMode,
                  )
                else
                  _buildMenuItem(
                    icon: Icons.check,
                    text: 'Prestar Servicios',
                    onTap: () {
                      setState(() {
                        _isSupplierMode = true;
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),

                _buildMenuItem(
                  icon: Icons.help_outline,
                  text: 'Preguntas Frecuentes',
                  onTap: () {},
                  isDarkMode: isDarkMode,
                ),

                // --- 5. (CONDITIONAL) SUPPLIER DASHBOARD ---
                if (_isSupplierMode) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mis Tratos',
                        style: TextStyle(
                          color: _textColor(isDarkMode),
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
                                color: _textColor(isDarkMode), size: 18),
                            onPressed: () => _scroll(-scrollAmount),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(Icons.arrow_forward_ios,
                                color: _textColor(isDarkMode), size: 18),
                            onPressed: () => _scroll(scrollAmount),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: ListView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(bottom: 10),
                      children: const [
                        _ServiceCard(
                            imageUrl:
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcROP0F8frSy8dG_OEnlu6tcyS6LYBsXYC5h1g&s',
                            serviceName: 'Mariachis'),
                        SizedBox(width: 16),
                        _ServiceCard(
                            imageUrl:
                                'https://media.minutouno.com/p/4a0e318ddc071d2050e87fbc4adaec7f/adjuntos/150/imagenes/027/232/0027232808/610x0/smart/enano.png',
                            serviceName: 'Enanos'),
                        SizedBox(width: 16),
                        _ServiceCard(
                            imageUrl:
                                'https://ichef.bbci.co.uk/ace/ws/640/amz/worldservice/live/assets/images/2015/04/11/150411184332_reino4.jpg.webp',
                            serviceName: 'Bailarines'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(color: AppColors.border, thickness: 1, height: 40),
                ],

                const SizedBox(height: 20),

                // --- 6. CONFIGURATION SECTION ---
                _buildSectionTitle('Configuración', isDarkMode),
                const SizedBox(height: 10),
                _buildMenuItem(
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
                  isDarkMode: isDarkMode,
                ),
                _buildMenuItem(
                  icon: Icons.lock_outline,
                  text: 'Cambiar contraseña',
                  onTap: () {},
                  isDarkMode: isDarkMode,
                ),

                // --- GLOBAL DARK MODE SWITCH ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  child: Row(
                    children: [
                      Icon(Icons.nightlight_round,
                          color: _iconColor(isDarkMode), size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Modo Oscuro',
                          style: TextStyle(
                            color: _textColor(isDarkMode),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: isDarkMode,
                          onChanged: (val) {
                            themeProvider.toggleTheme(val);
                          },
                          activeColor: Colors.white,
                          activeTrackColor: AppColors.primary,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFFB0B0B0),
                        ),
                      ),
                    ],
                  ),
                ),

                // Text Size
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    children: [
                      Icon(Icons.text_fields,
                          color: _iconColor(isDarkMode), size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Tamaño de Texto',
                          style: TextStyle(
                            color: _textColor(isDarkMode),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: _cardColor(isDarkMode),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: currentFontSize,
                            icon: Icon(Icons.keyboard_arrow_down,
                                color: _textColor(isDarkMode)),
                            dropdownColor: isDarkMode
                                ? AppColors.backgroundDark
                                : Colors.white,
                            style: TextStyle(
                              color: _textColor(isDarkMode),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            items: ['12 pt', '14 pt', '16 pt', '18 pt']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                themeProvider.setFontSize(newValue);
                              }
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                // --- 7. LOGOUT SECTION ---
                _buildMenuItem(
                  icon: Icons.logout,
                  text: 'Cerrar Sesion',
                  onTap: () {
                    // --- CAMBIO 3: Limpiamos datos de AMBOS providers ---
                    themeProvider.logout(); // Limpia estado visual (isLoggedIn)
                    userProvider.logout(); // Limpia datos del usuario (userId = null)

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const WelcomeScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  showArrow: true,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: _textColor(isDarkMode),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool showArrow = true,
    required bool isDarkMode,
  }) {
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: _iconColor(isDarkMode), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: _textColor(isDarkMode),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
                size: 14,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String count, String label, bool isDarkMode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: TextStyle(
            color: _subTextColor(isDarkMode),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _subTextColor(isDarkMode),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// --- Service Card ---
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
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
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
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}