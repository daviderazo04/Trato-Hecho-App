import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChanged(int index) {
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
                    // LÓGICA: Si es oscuro, fondo VERDE. Si es claro, azul suave.
                    backgroundColor: isDarkMode
                        ? contactButtonColor // Verde sólido
                        : accentColor.withOpacity(0.1),
                    labelStyle: TextStyle(
                      // LÓGICA: Si es oscuro, texto BLANCO. Si es claro, azul.
                      color: isDarkMode ? Colors.white : accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      // --- CAMBIO AQUÍ: Borde blanco en modo oscuro ---
                      side: BorderSide(
                        color: isDarkMode ? Colors.white : Colors.transparent,
                        width: 1.5, // Un borde sutil pero visible
                      ),
                      // -----------------------------------------------
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
    final hasImages = widget.data.imageUrls.isNotEmpty;
    final imageCount = hasImages ? widget.data.imageUrls.length : 1;

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: PageView.builder(
            controller: _pageController,
            itemCount: imageCount,
            onPageChanged: _handlePageChanged,
            itemBuilder: (context, index) {
              if (!hasImages) {
                return Container(color: Colors.grey.shade200);
              }
              return Image.network(
                widget.data.imageUrls[index],
                fit: BoxFit.cover,
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
              // Aquí usamos el color: Azul Oscuro nuevo o Azul Primario (según preferencia o tema)
              // Para ser consistentes con tu petición, usaré el azul oscuro nuevo en ambos modos
              // o solo en dark mode si prefieres. Aquí lo pongo fijo al darkBlueColor para que se vea como pides.
              color: darkBlueColor, 
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white, // Borde blanco
                width: 2.0,
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
              '\$ ${widget.data.price}',
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
                enabled: _currentIndex < imageCount - 1,
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
            children: hasImages
                ? List.generate(
                    imageCount,
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