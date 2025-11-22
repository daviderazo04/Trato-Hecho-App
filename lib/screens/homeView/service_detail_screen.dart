import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trato_hecho_app/main.dart' show MainNavigator;
import 'package:video_player/video_player.dart';

import '../../config/appColors.dart';
import '../../config/theme_provider.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
// Importamos la pantalla de chat
import '../chatView/chat_detail_screen.dart';
// Importamos el modelo de datos que está en 'home_screen.dart'
import 'home_screen.dart' show ServiceCardData;

class ServiceDetailScreen extends StatefulWidget {
  final ServiceCardData data;
  final bool isFavorite;
  final Future<bool> Function(bool isFavorite)? onFavoriteToggle;

  const ServiceDetailScreen({
    super.key,
    required this.data,
    this.isFavorite = false,
    this.onFavoriteToggle,
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

  void _onNavTap(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MainNavigator(initialIndex: index),
      ),
      (route) => false,
    );
  }

  Future<void> _toggleFavorite() async {
    final bool target = !_isFavorite;
    setState(() {
      _isFavorite = target;
    });

    if (widget.onFavoriteToggle != null) {
      final success = await widget.onFavoriteToggle!(target);
      if (!success) {
        setState(() => _isFavorite = !target);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    final Color contactButtonColor = AppColors.notificacion;
    final Color darkBlueColor = const Color.fromRGBO(7, 39, 64, 1);
    final bool hasRatings = widget.data.hasRatings;
    final String ratingLabel = widget.data.ratingLabel;

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
            _buildImageCarousel(context, isDarkMode),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: Text(widget.data.category),
                    backgroundColor: AppColors.primary,
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
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
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: _backgroundColor(isDarkMode),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          receiverId: widget.data.providerId,
                          // --- CORRECCIÓN AQUÍ: INVERTIMOS LOS NOMBRES ---
                          chatName: widget.data.providerName, // Nombre: Jhon Tonsupa
                          chatSubtitle: widget.data.title,    // Subtítulo: Payaso Bombón
                          // ----------------------------------------------
                          rating: widget.data.ratingLabel,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDarkMode ? darkBlueColor : contactButtonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: isDarkMode
                          ? const BorderSide(color: Colors.white, width: 2.0)
                          : BorderSide.none,
                    ),
                    elevation: isDarkMode ? 0 : 2,
                  ),
                  child: const Text(
                    'Contactar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            CustomBottomNavBar(
              currentIndex: 0,
              onTap: _onNavTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(BuildContext context, bool isDarkMode) {
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
                      size: 48,
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
              onPressed: _toggleFavorite,
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.redAccent : Colors.white,
              ),
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
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 2.0),
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
                color: AppColors.backgroundWhite,
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
