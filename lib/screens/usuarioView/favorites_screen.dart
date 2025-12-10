import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../config/appColors.dart';
import '../../config/user_provider.dart';
import '../../services/favorites_service.dart';
import '../homeView/home_screen.dart' show ServiceCardData;
import '../homeView/service_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isLoading = true;
  String? _error;
  List<ServiceCardData> _favorites = [];
  bool _updatingFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _error = 'Debes iniciar sesión para ver favoritos.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final favs = await _favoritesService.getFavorites(userId);
    if (!mounted) return;
    setState(() {
      _favorites = favs;
      _isLoading = false;
      _error = favs.isEmpty ? 'No tienes favoritos guardados.' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    // Background colors
    final Color backgroundColor =
        isDarkMode ? AppColors.backgroundDark : Colors.white;
    final Color decorationColor = isDarkMode
        ? Colors.white.withOpacity(0.05)
        : const Color(0xFFC5CAE9).withOpacity(0.5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // --- 1. BACKGROUND DECORATIONS ---
          Positioned(
            top: 100,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: decorationColor,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -40,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: decorationColor,
              ),
            ),
          ),

          // --- 2. MAIN CONTENT ---
          Column(
            children: [
              // --- Custom Header ---
              _buildCustomHeader(context),

              // --- Content Body ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // "Favoritos" Label Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          border: isDarkMode
                              ? Border.all(color: Colors.white, width: 1)
                              : null,
                        ),
                        child: const Text(
                          "Favoritos",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // List of Favorites
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              )
                            : _error != null
                                ? Center(
                                    child: Text(
                                      _error!,
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white70
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  )
                                : RefreshIndicator(
                                    onRefresh: _loadFavorites,
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: _favorites.length,
                                      itemBuilder: (context, index) {
                                        final item = _favorites[index];
                                        return _buildFavoriteCard(
                                          isDarkMode,
                                          data: item,
                                          onTap: () => _openDetail(item),
                                        );
                                      },
                                    ),
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.primary, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 20),
            const Text(
              'Favoritos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(
    bool isDarkMode, {
    required ServiceCardData data,
    required VoidCallback onTap,
  }) {
    final imageUrl =
        data.imageUrls.isNotEmpty ? data.imageUrls.first : ServiceCardData.fallbackImage;
    final rating =
        data.totalRatings > 0 ? data.rating.toStringAsFixed(1) : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12), // Reduced padding slightly
      height: 110, // Fixed height for consistency
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkButtons : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        // REQUIREMENT: White border in dark mode
        border: Border.all(
          color: isDarkMode ? Colors.white : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl,
                width: 80,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  width: 80,
                  color: Colors.grey[300],
                  child:
                      const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 2. Middle Text Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.description,
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.grey[300]
                          : AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // 3. Right Action Section (Heart + Rating)
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(
                  Icons.favorite,
                  color: AppColors.error, // Red heart
                  size: 28,
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetail(ServiceCardData data) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(
          data: data,
          isFavorite: data.esFavorito,
          onFavoriteToggle: () => _toggleFavoriteFromDetail(data),
        ),
      ),
    );
    if (mounted) {
      await _loadFavorites(); // refrescar listado al volver
    }
  }

  Future<void> _toggleFavoriteFromDetail(ServiceCardData data) async {
    if (_updatingFavorite) return;
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final serviceId = data.id;
    if (userId == null || serviceId == null) return;

    final bool target = !data.esFavorito;
    setState(() {
      _updatingFavorite = true;
      data.esFavorito = target;
    });

    bool success;
    if (target) {
      success = await _favoritesService.addFavorite(
          userId: userId, serviceId: serviceId);
    } else {
      success = await _favoritesService.removeFavorite(
          userId: userId, serviceId: serviceId);
    }

    if (!success && mounted) {
      setState(() {
        data.esFavorito = !target; // revertir local si falló
      });
    }

    if (mounted) {
      setState(() {
        _updatingFavorite = false;
      });
    }
  }
}
