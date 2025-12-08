import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trato_hecho_app/main.dart' show MainNavigator;
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Para obtener la URL base
import '../../config/appColors.dart';
import '../../config/theme_provider.dart';
// Asumo la existencia del UserProvider en la carpeta config
import '../../config/user_provider.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../auth/login_screen.dart';
import '../chatView/chat_detail_screen.dart';
import '../chatView/contratar_servicio_screen.dart';
import 'home_screen.dart' show ServiceCardData;

// --- CONFIGURACIÓN DE LA API ---
final String BASE_API_URL =
    dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api';
const String DELETE_SERVICE_ENDPOINT =
    "/servicios"; // Se complementará con el ID y query param

class ServiceDetailScreen extends StatefulWidget {
  final ServiceCardData data;
  final bool isFavorite;
  final Future<void> Function()? onFavoriteToggle;
  final bool showActions;

  const ServiceDetailScreen({
    super.key,
    required this.data,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.showActions = true,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, Future<void>> _initializeVideoFutures = {};
  late bool _isFavorite;
  final int _navbarIndex = 0;
  bool get _showActions => widget.showActions;
  bool _isDeleting = false; // Estado para el loading del botón de borrar

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _isFavorite = widget.isFavorite;
  }

  @override
  void dispose() {
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE BORRADO ---
  Future<void> _deleteService() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;
    final serviceId = widget.data.id;

    if (userId == null || serviceId == null || _isDeleting) return;

    final confirmed = await _showConfirmationDialog(context);
    if (!confirmed) return;

    setState(() => _isDeleting = true);

    try {
      final url = Uri.parse(
          '$BASE_API_URL$DELETE_SERVICE_ENDPOINT/$serviceId?userId=$userId');

      final response = await http.delete(url);

      if (response.statusCode == 200) {
        // Éxito: notificar y regresar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Servicio eliminado con éxito.'),
              backgroundColor: AppColors.success),
        );
        Navigator.pop(context); // Regresa a la vista anterior (UsuarioView)
      } else {
        throw Exception(
            'Fallo al eliminar servicio: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error al eliminar servicio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('❌ Error: ${e.toString().split(':').last}'),
            backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  // --- DIÁLOGO DE CONFIRMACIÓN ---
  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar Borrado'),
              content: const Text(
                  '¿Estás seguro de que deseas eliminar este servicio de forma permanente? Esta acción no se puede deshacer.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar',
                      style: TextStyle(color: AppColors.gray)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error),
                  child: const Text('Borrar',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _handlePageChanged(int index) {
    final prevController = _videoControllers[_currentIndex];
    prevController?.pause();
    setState(() {
      _currentIndex = index;
    });
  }

  // --- HELPERS DE COLOR ---
  Color _backgroundColor(bool isDark) =>
      isDark ? AppColors.backgroundDark : AppColors.backgroundWhite;

  Color _textColor(bool isDark) =>
      isDark ? AppColors.darkText : AppColors.borders;

  Color _subTextColor(bool isDark) =>
      isDark ? Colors.grey[400]! : AppColors.gray;

  bool _isVideo(String url) {
    final lower = url.toLowerCase();
    return _isHttpUrl(url) &&
        (lower.contains('.mp4') ||
            lower.contains('.mov') ||
            lower.contains('.webm') ||
            lower.contains('.mkv') ||
            lower.contains('.m3u8') ||
            lower.contains('video'));
  }

  bool _isHttpUrl(String url) =>
      url.startsWith('http://') || url.startsWith('https://');

  Future<void> _ensureVideoInitialized(int index, String url) {
    if (_initializeVideoFutures.containsKey(index)) {
      return _initializeVideoFutures[index]!;
    }
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _videoControllers[index] = controller;
    final initFuture = controller.initialize();
    controller.setLooping(true);
    _initializeVideoFutures[index] = initFuture;
    return initFuture;
  }

  void _togglePlay(int index) {
    final controller = _videoControllers[index];
    if (controller == null) return;
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  void _goPrevious() {
    if (_currentIndex == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _goNext() {
    if (_currentIndex >= widget.data.imageUrls.length - 1) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (widget.onFavoriteToggle != null) {
      await widget.onFavoriteToggle!();
    }
  }

  bool _redirectToLoginIfNeeded(
      UserProvider userProvider, ThemeProvider themeProvider,
      {VoidCallback? onAuthenticated}) {
    final bool isLoggedIn =
        userProvider.userId != null && themeProvider.isLoggedIn;
    if (!isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(onAuthenticated: onAuthenticated),
        ),
      );
    }
    return isLoggedIn;
  }

  void _openChat() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          receiverId: widget.data.providerId,
          serviceId: widget.data.id,
          chatName: widget.data.title,
          chatSubtitle: widget.data.providerName,
          rating: widget.data.rating.toStringAsFixed(1),
          serviceImage: widget.data.imageUrls.isNotEmpty
              ? widget.data.imageUrls.first
              : null,
        ),
      ),
    );
  }

  void _openHireFlow() {
    if (!mounted) return;
    final serviceId = widget.data.id;
    if (serviceId == null || serviceId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede contratar: falta el ID del servicio.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContratarServicioScreen(
          serviceId: serviceId,
          serviceName: widget.data.title,
          serviceImage: widget.data.imageUrls.isNotEmpty
              ? widget.data.imageUrls.first
              : null,
          fallbackPrice: widget.data.price,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    final Color contactButtonColor = AppColors.notificacion;
    final Color darkBlueColor = const Color.fromRGBO(7, 39, 64, 1);

    final bool hasRatings = true;
    final String ratingLabel = widget.data.rating.toStringAsFixed(1);
    final bool isOwner = userProvider.userId != null &&
        widget.data.providerId == userProvider.userId;
    final bool showClientActions = _showActions && !isOwner;
    final bool showProviderActions = !_showActions && isOwner;

    return Scaffold(
      backgroundColor: _backgroundColor(isDarkMode),
      appBar: AppBar(
        backgroundColor: _backgroundColor(isDarkMode),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDarkMode ? Colors.white : AppColors.borders),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Text(
                  ratingLabel,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : AppColors.borders,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasRatings) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.star,
                    color: AppColors.amber,
                    size: 20,
                  ),
                ],
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(context, isDarkMode, darkBlueColor),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.data.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.data.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _textColor(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.data.providerName,
                    style: TextStyle(
                      fontSize: 16,
                      color: _subTextColor(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _textColor(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.data.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[300] : AppColors.borders,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // --- ACCIONES DE CLIENTE (CONTACTAR / HACER TRATO) ---
                  if (showClientActions) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_redirectToLoginIfNeeded(
                              userProvider, themeProvider,
                              onAuthenticated: _openChat)) {
                            return;
                          }
                          _openChat();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDarkMode ? darkBlueColor : contactButtonColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: isDarkMode
                                ? const BorderSide(
                                    color: Colors.white, width: 1.5)
                                : BorderSide.none,
                          ),
                          elevation: isDarkMode ? 0 : 2,
                        ),
                        child: const Text(
                          'Contactar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_redirectToLoginIfNeeded(
                              userProvider, themeProvider,
                              onAuthenticated: _openHireFlow)) {
                            return;
                          }
                          _openHireFlow();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.notificacion,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: isDarkMode ? 0 : 2,
                        ),
                        child: const Text(
                          'Hacer un trato',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ] else if (showProviderActions) ...[
                    // --- ACCIÓN DE PROVEEDOR (BORRAR SERVICIO) ---
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isDeleting ? null : _deleteService,
                        icon: _isDeleting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.delete_forever,
                                color: Colors.white),
                        label: Text(
                          _isDeleting ? 'Borrando...' : 'Borrar este servicio',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: isDarkMode ? 0 : 2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _navbarIndex,
        hasUnreadMessages: false,
        onTap: (int index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainNavigator(initialIndex: index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageCarousel(
      BuildContext context, bool isDarkMode, Color darkBlueColor) {
    final hasMedia = widget.data.imageUrls.isNotEmpty;
    final mediaCount = hasMedia ? widget.data.imageUrls.length : 1;

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: PageView.builder(
            controller: _pageController,
            itemCount: mediaCount,
            onPageChanged: _handlePageChanged,
            itemBuilder: (context, index) {
              if (!hasMedia) {
                return Container(color: Colors.grey.shade200);
              }
              final url = widget.data.imageUrls[index];
              final isVideo = _isVideo(url);

              if (!isVideo) {
                return _buildImage(url);
              }

              return FutureBuilder(
                future: _ensureVideoInitialized(index, url),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      color: Colors.black,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(Icons.error_outline, color: Colors.white),
                      ),
                    );
                  }
                  final controller = _videoControllers[index]!;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: controller.value.isInitialized
                            ? controller.value.aspectRatio
                            : (16 / 10),
                        child: VideoPlayer(controller),
                      ),
                      GestureDetector(
                        onTap: () => _togglePlay(index),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Material(
            color: Colors.black45,
            shape: const CircleBorder(),
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.redAccent : Colors.white,
              ),
              onPressed: _toggleFavorite,
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Text(
              '\$ ${widget.data.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _ImageArrow(
                icon: Icons.arrow_back_ios_new,
                onTap: _goPrevious,
                enabled: _currentIndex > 0,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _ImageArrow(
                icon: Icons.arrow_forward_ios,
                onTap: _goNext,
                enabled: _currentIndex < mediaCount - 1,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: hasMedia
                ? List.generate(
                    mediaCount,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: index == _currentIndex ? 12 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index == _currentIndex
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )
                : const <Widget>[],
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String url) {
    const fallback = ServiceCardData.fallbackImage;

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          fallback,
          fit: BoxFit.cover,
        ),
      );
    }

    if (_isHttpUrl(url)) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          fallback,
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(
      fallback,
      fit: BoxFit.cover,
    );
  }
}

class _ImageArrow extends StatelessWidget {
  const _ImageArrow({
    required this.icon,
    this.onTap,
    this.enabled = true,
    this.background = Colors.black54,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;
  final Color background;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.6,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 16,
          ),
        ),
      ),
    );
  }
}
