import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // Import for JSON
import 'package:http/http.dart' as http; // Import for API calls
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/theme_provider.dart';
import '../../config/user_provider.dart';
import '../../config/appColors.dart';
import '../../config/api_config.dart';
import 'edit_profile_screen.dart';
import '../../screens/welcomeView/welcome_screen.dart';
import '../usuarioView/recent_deals_screen.dart';
import '../usuarioView/favorites_screen.dart';
import '../proveedorView/new_service_screen.dart';
import 'faq_screen.dart';
import 'change_password_screen.dart';
import '../../services/my_services_service.dart';
import '../homeView/home_screen.dart' show ServiceCardData;
import '../homeView/service_detail_screen.dart';

class UsuarioView extends StatefulWidget {
  const UsuarioView({Key? key}) : super(key: key);

  @override
  _UsuarioViewState createState() => _UsuarioViewState();
}

class _UsuarioViewState extends State<UsuarioView> {
  final ScrollController _scrollController = ScrollController();
  final MyServicesService _myServicesService = MyServicesService();
  bool _isLoadingMyServices = false;
  String? _myServicesError;
  List<ServiceCardData> _myServices = [];

  // --- ESTADÍSTICAS DEL PROVEEDOR (New Variables) ---
  int _totalContrataciones = 0;
  int _totalCalificaciones = 0;
  double _promedioGeneral = 0.0;
  bool _isLoadingStats = false;
  Timer? _reviewTimer;
  bool _isReviewPolling = false;
  Map<int, _ReviewSnapshot> _reviewSnapshot = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreSupplierMode();
    });
  }

  @override
  void dispose() {
    _reviewTimer?.cancel();
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

  void _openMyService(ServiceCardData data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailScreen(
          data: data,
          isFavorite: data.esFavorito,
          showActions: false,
        ),
      ),
    );
  }

  Future<void> _restoreSupplierMode() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final savedMode = prefs.getBool('isSupplierMode') ?? false;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.isSupplierMode != savedMode) {
      userProvider.setSupplierMode(savedMode);
    }

    if (savedMode) {
      _loadMyServices();
      _fetchSupplierStats();
      _startReviewPolling();
    } else {
      _stopReviewPolling();
    }
  }

  // --- API 1: CARGAR SERVICIOS ---
  Future<void> _loadMyServices() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) {
      setState(() {
        _isLoadingMyServices = false;
        _myServicesError = 'Inicia sesión para ver tus servicios.';
      });
      return;
    }
    setState(() {
      _isLoadingMyServices = true;
      _myServicesError = null;
    });
    final list = await _myServicesService.getMyServices(userId);
    if (!mounted) return;
    setState(() {
      _myServices = list;
      _isLoadingMyServices = false;
      _myServicesError =
          list.isEmpty ? 'No tienes servicios publicados.' : null;
    });
    _updateReviewSnapshot(list);
  }

  // --- API 2: CARGAR ESTADÍSTICAS (New Function) ---
  Future<void> _fetchSupplierStats() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) return;

    setState(() {
      _isLoadingStats = true;
    });

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/estadisticas/$userId');
      // final url = envUrl + Uri.parse('http://localhost:8080/api/estadisticas/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _totalContrataciones = data['totalContrataciones'] ?? 0;
            _totalCalificaciones = data['totalCalificaciones'] ?? 0;
            // Ensure it's treated as a double
            _promedioGeneral = (data['promedioGeneral'] ?? 0).toDouble();
            _isLoadingStats = false;
          });
        }
      } else {
        print("Error cargando estadísticas: ${response.statusCode}");
        if (mounted) setState(() => _isLoadingStats = false);
      }
    } catch (e) {
      print("Error fetch stats: $e");
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  void _startReviewPolling() {
    _reviewTimer?.cancel();
    _reviewTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _checkForNewReviews();
    });
  }

  void _stopReviewPolling() {
    _reviewTimer?.cancel();
    _reviewTimer = null;
    _reviewSnapshot = {};
  }

  Future<void> _checkForNewReviews() async {
    if (_isReviewPolling) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isSupplierMode) return;
    final userId = userProvider.userId;
    if (userId == null) return;
    _isReviewPolling = true;

    try {
      final services = await _myServicesService.getMyServices(userId);
      if (!mounted) return;

      _updateReviewSnapshot(services, checkForChanges: true);
      setState(() {
        _myServices = services;
        _myServicesError =
            services.isEmpty ? 'No tienes servicios publicados.' : null;
      });
    } catch (e) {
      print('Error revisando nuevas reviews: $e');
    } finally {
      _isReviewPolling = false;
    }
  }

  void _updateReviewSnapshot(List<ServiceCardData> services,
      {bool checkForChanges = false}) {
    bool notified = false;
    final Map<int, _ReviewSnapshot> next = {};

    for (final service in services) {
      final id = service.id;
      if (id == null) continue;

      final prev = _reviewSnapshot[id];
      if (checkForChanges &&
          !notified &&
          prev != null &&
          service.totalRatings > prev.totalRatings) {
        final double? newScore = _calculateNewReviewScore(
          currentTotal: service.totalRatings,
          currentAverage: service.rating,
          previousTotal: prev.totalRatings,
          previousAverage: prev.average,
        );
        _showReviewSnack(service.title, newScore);
        notified = true;
      }

      next[id] = _ReviewSnapshot(
        totalRatings: service.totalRatings,
        average: service.rating,
        serviceName: service.title,
      );
    }

    _reviewSnapshot = next;
  }

  double? _calculateNewReviewScore({
    required int currentTotal,
    required double currentAverage,
    required int previousTotal,
    required double previousAverage,
  }) {
    final int delta = currentTotal - previousTotal;
    if (delta <= 0) return null;
    final double diff =
        (currentAverage * currentTotal) - (previousAverage * previousTotal);
    if (diff.isNaN || diff.isInfinite) return null;
    final double score = diff / delta;
    if (score.isNaN || score.isInfinite) return null;
    return score.clamp(0.0, 5.0);
  }

  void _showReviewSnack(String serviceName, double? stars) {
    final String ratingText =
        stars != null ? '${stars.toStringAsFixed(1)} estrellas' : 'una nueva review';
    final snack = SnackBar(
      content: Text(
          'Enhorabuena, alguien dejo una review de $ratingText en el servicio "$serviceName".'),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snack);
    }
  }

  // --- Helper Colors ---
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

    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final bool isDarkMode = themeProvider.isDarkMode;
    final String currentFontSize = themeProvider.currentFontSizeLabel;
    final bool isSupplierMode = userProvider.isSupplierMode;

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

                // --- 1. HEADER ---
                Row(
                  children: [
                    _ProfileAvatar(
                      imageUrl:
                          userProvider.cacheBustedPhotoUrl ?? userProvider.userPhotoUrl,
                      cachedPhotoBytes: userProvider.userPhotoCache,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProvider.userName ?? 'Usuario',
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
                        isSupplierMode ? 'Modo Proveedor' : 'Modo Cliente',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textColor(isDarkMode),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.9,
                        child: Switch(
                          value: isSupplierMode,
                          onChanged: (value) {
                            userProvider.setSupplierMode(value);
                            if (value) {
                              _loadMyServices();
                              _fetchSupplierStats(); // Fetch stats when enabling
                              _startReviewPolling();
                            } else {
                              _stopReviewPolling();
                            }
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

                // --- 3. SUPPLIER STATS (Connected to API) ---
                if (isSupplierMode) ...[
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
                    child: _isLoadingStats
                        ? Center(
                            child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary),
                          ))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // 1. Tratos (Contrataciones)
                              _buildStatColumn('$_totalContrataciones',
                                  'Tratos', isDarkMode),
                              Container(
                                  height: 30,
                                  width: 1,
                                  color: AppColors.darkText),

                              // 2. Reviews (Calificaciones)
                              _buildStatColumn('$_totalCalificaciones',
                                  'Reviews', isDarkMode),
                              Container(
                                  height: 30,
                                  width: 1,
                                  color: AppColors.darkText),

                              // 3. Rating (Promedio) - Replaces "Años"
                              _buildStatColumn(
                                  _promedioGeneral.toStringAsFixed(1),
                                  'Rating',
                                  isDarkMode),
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

                if (!isSupplierMode)
                  _buildMenuItem(
                    icon: Icons.check,
                    text: 'Prestar Servicios',
                    onTap: () {
                      userProvider.setSupplierMode(true);
                      _loadMyServices();
                      _fetchSupplierStats();
                      _startReviewPolling();
                    },
                    isDarkMode: isDarkMode,
                  ),

                _buildMenuItem(
                  icon: Icons.help_outline,
                  text: 'Preguntas Frecuentes',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FaqScreen(),
                      ),
                    );
                  },
                  isDarkMode: isDarkMode,
                ),

                // --- 5. SUPPLIER DASHBOARD ---
                if (isSupplierMode) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mis Servicios',
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
                    child: _isLoadingMyServices
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : _myServicesError != null
                            ? Center(
                                child: Text(
                                  _myServicesError!,
                                  style: TextStyle(
                                    color: _textColor(isDarkMode),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                controller: _scrollController,
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(bottom: 10),
                                itemCount: _myServices.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  final item = _myServices[index];
                                  final imageUrl = item.imageUrls.isNotEmpty
                                      ? item.imageUrls.first
                                      : ServiceCardData.fallbackImage;
                                  return _ServiceCard(
                                    imageUrl: imageUrl,
                                    serviceName: item.title,
                                    onTap: () => _openMyService(item),
                                  );
                                },
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
                  text: 'Editar Perfil',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
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

                // --- FONT SIZE SELECTOR ---
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

                // --- LOGOUT BUTTON ---
                _buildMenuItem(
                  icon: Icons.lock_reset,
                  text: 'Cambiar Contraseña',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                  showArrow: true,
                  isDarkMode: isDarkMode,
                ),
                _buildMenuItem(
                  icon: Icons.logout,
                  text: 'Cerrar Sesion',
                  onTap: () {
                    themeProvider.logout();
                    userProvider.logout();

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

// --- Profile Avatar ---
class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final Uint8List? cachedPhotoBytes;
  final bool isDarkMode;

  const _ProfileAvatar({
    Key? key,
    required this.imageUrl,
    required this.cachedPhotoBytes,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ImageProvider? photoProvider;
    if (cachedPhotoBytes != null && cachedPhotoBytes!.isNotEmpty) {
      photoProvider = MemoryImage(cachedPhotoBytes!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      photoProvider = NetworkImage(imageUrl!);
    }
    final hasImage = photoProvider != null;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: isDarkMode ? AppColors.primary : Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 42,
        backgroundColor: AppColors.backgroundLight,
        backgroundImage: photoProvider,
        child: hasImage
            ? null
            : Icon(
                Icons.person,
                size: 40,
                color: isDarkMode ? Colors.white : AppColors.textSecondary,
              ),
      ),
    );
  }
}

// --- Service Card ---
class _ServiceCard extends StatelessWidget {
  final String imageUrl;
  final String serviceName;
  final VoidCallback? onTap;

  const _ServiceCard({
    Key? key,
    required this.imageUrl,
    required this.serviceName,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}

class _ReviewSnapshot {
  _ReviewSnapshot({
    required this.totalRatings,
    required this.average,
    required this.serviceName,
  });

  final int totalRatings;
  final double average;
  final String serviceName;
}
