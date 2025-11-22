import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:video_player/video_player.dart';
// Importamos el modelo de datos que está en 'home_screen.dart'
import 'home_screen.dart' show ServiceCardData;
// Importamos la pantalla de chat
import '../chatView/chat_detail_screen.dart';
import '../../config/theme_provider.dart';
import '../../config/appColors.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceCardData data;

  const ServiceDetailScreen({super.key, required this.data});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, Future<void>> _initializeVideoFutures = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
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
    return lower.contains('.mp4') ||
        lower.contains('.mov') ||
        lower.contains('.webm') ||
        lower.contains('.mkv') ||
        lower.contains('.m3u8') ||
        lower.contains('video');
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Accedemos al estado global
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    // Colores base
    final Color accentColor = AppColors.primary;
    final Color contactButtonColor = AppColors.notificacion; // El verde
    
    // --- NUEVO COLOR SOLICITADO ---
    // Un azul mucho más oscuro para el botón y precio en modo oscuro
    final Color darkBlueColor = const Color.fromRGBO(7, 39, 64, 1);

    return Scaffold(
      backgroundColor: _backgroundColor(isDarkMode),
      // --- APPBAR PERSONALIZADA ---
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
                  widget.data.rating.toStringAsFixed(1),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : AppColors.borders,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.star,
                  color: AppColors.amber,
                  size: 20,
                ),
              ],
            ),
          )
        ],
      ),
      // --- CUERPO DE LA PANTALLA ---
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CARRUSEL DE IMÁGENES ---
            // Pasamos el nuevo color oscuro al carrusel
            _buildImageCarousel(context, isDarkMode, darkBlueColor),

            // --- CONTENIDO DEBAJO DEL CARRUSEL ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CATEGORÍA (El Chip Verde) ---
                  Chip(
                    label: Text(widget.data.category),
                    backgroundColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide.none,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- TÍTULO ---
                  Text(
                    widget.data.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _textColor(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // --- PROVEEDOR ---
                  Text(
                    widget.data.providerName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: _subTextColor(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- DESCRIPCIÓN ---
                  Text(
                    'Descripción',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _textColor(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.data.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDarkMode ? Colors.grey[300] : AppColors.borders,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Espacio extra al final
          ],
        ),
      ),
      // --- BOTÓN DE CONTACTAR ---
      bottomNavigationBar: Container(
        color: _backgroundColor(isDarkMode),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                    chatName: widget.data.title,
                    chatSubtitle: widget.data.providerName,
                    rating: widget.data.rating.toStringAsFixed(1),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              // LÓGICA DEL BOTÓN:
              // Oscuro: Fondo AZUL OSCURO NUEVO con BORDE BLANCO
              // Claro: Fondo VERDE sólido sin borde
              backgroundColor: isDarkMode
                  ? darkBlueColor // El nuevo azul oscuro
                  : contactButtonColor, // Verde
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: isDarkMode
                    ? const BorderSide(color: Colors.white, width: 2.0) // Borde Blanco
                    : BorderSide.none,
              ),
              elevation: isDarkMode ? 0 : 2,
            ),
            child: const Text(
              'Contactar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Texto siempre blanco
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET PARA EL CARRUSEL DE IMÁGENES ---
  Widget _buildImageCarousel(BuildContext context, bool isDarkMode, Color darkBlueColor) {
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
                return Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.black38,
                    ),
                  ),
                );
              }
              return FutureBuilder(
                future: _ensureVideoInitialized(index, url),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.white,
                        ),
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
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 38,
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

        // --- PRECIO (Con borde blanco siempre) ---
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white, // Borde blanco
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '\$ ${widget.data.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.backgroundWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // --- FLECHAS DE NAVEGACIÓN ---
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

        // --- INDICADORES DE PÁGINA ---
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
                            ? AppColors.backgroundWhite
                            : AppColors.backgroundWhite.withOpacity(0.5),
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
}

// --- WIDGET INTERNO PARA LAS FLECHAS DEL CARRUSEL ---
class _ImageArrow extends StatelessWidget {
  const _ImageArrow({
    required this.icon,
    this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.3,
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }
}
