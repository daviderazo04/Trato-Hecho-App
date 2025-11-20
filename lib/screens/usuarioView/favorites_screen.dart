import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../config/appColors.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

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
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            _buildFavoriteCard(
                              isDarkMode,
                              title: "Mariachi 'El Sol'",
                              description:
                                  "¡Dale vida y luz a tu evento con Mariachi 'El Sol'! Somos un grupo...",
                              rating: "4.8",
                              imageUrl:
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcROP0F8frSy8dG_OEnlu6tcyS6LYBsXYC5h1g&s',
                            ),
                            _buildFavoriteCard(
                              isDarkMode,
                              title: "Banquetes Delicia",
                              description:
                                  "Servicio de catering profesional para bodas y eventos corporativos...",
                              rating: "4.9",
                              imageUrl:
                                  'https://media.minutouno.com/p/4a0e318ddc071d2050e87fbc4adaec7f/adjuntos/150/imagenes/027/232/0027232808/610x0/smart/enano.png',
                            ),
                            _buildFavoriteCard(
                              isDarkMode,
                              title: "DJ Nightlife",
                              description:
                                  "La mejor música y luces para tu fiesta. Experiencia garantizada...",
                              rating: "4.5",
                              imageUrl:
                                  'https://ichef.bbci.co.uk/ace/ws/640/amz/worldservice/live/assets/images/2015/04/11/150411184332_reino4.jpg.webp',
                            ),
                          ],
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
    required String title,
    required String description,
    required String rating,
    required String imageUrl,
  }) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Image (Optional - added for visual appeal based on typical favorite lists)
          // If you don't want images, remove this ClipRRect block.
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
                  title,
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
                  description,
                  style: TextStyle(
                    color:
                        isDarkMode ? Colors.grey[300] : AppColors.textSecondary,
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
              // Heart Icon
              const Icon(
                Icons.favorite,
                color: AppColors.error, // Red heart
                size: 28,
              ),

              // Rating Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }
}
