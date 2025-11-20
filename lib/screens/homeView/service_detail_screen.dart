import 'package:flutter/material.dart';
// Importamos el modelo de datos que está en 'home_screen.dart'
import 'home_screen.dart' show ServiceCardData;
// --- CAMBIO 1: Importamos la pantalla de chat ---
// (Asumiendo que está en 'lib/screens/chatView/chat_detail_screen.dart')
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color accentColor = AppColors.primary;
    final Color contactButtonColor = AppColors.notificacion;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      // --- APPBAR PERSONALIZADA ---
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.borders),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Text(
                  widget.data.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.borders,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
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
            _buildImageCarousel(context),

            // --- CONTENIDO DEBAJO DEL CARRUSEL ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CATEGORÍA ---
                  Chip(
                    label: Text(widget.data.category),
                    backgroundColor: accentColor.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: AppColors.transparent),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- TÍTULO ---
                  Text(
                    widget.data.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.borders,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // --- PROVEEDOR ---
                  Text(
                    widget.data.providerName,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: AppColors.gray),
                  ),
                  const SizedBox(height: 24),

                  // --- DESCRIPCIÓN ---
                  Text(
                    'Descripción',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.data.description,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: AppColors.borders, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Espacio para el botón de contacto
          ],
        ),
      ),
      // --- BOTÓN DE CONTACTAR ---
      bottomNavigationBar: Container(
        color: AppColors.backgroundWhite,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        // Usamos SafeArea para evitar la barra inferior del sistema
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              // --- CAMBIO 2: Lógica de navegación ---
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                    // Mapeamos los datos del servicio a la pantalla de chat
                    chatName: widget.data.title,
                    chatSubtitle: widget.data.providerName,
                    rating: widget.data.rating.toStringAsFixed(1),
                  ),
                ),
              );
              // --- FIN DEL CAMBIO ---
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: contactButtonColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Contactar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.backgroundWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET PARA EL CARRUSEL DE IMÁGENES ---
  Widget _buildImageCarousel(BuildContext context) {
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
                return Container(color: Colors.grey.shade200); // Placeholder
              }
              return Image.network(
                widget.data.imageUrls[index],
                fit: BoxFit.cover,
              );
            },
          ),
        ),

        // --- PRECIO ---
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white, // Color del contorno
                width: 2.0,          // Grosor del contorno
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

        // --- FLECHAS DE NAVEGACIÓN (Izquierda) ---
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
        // --- FLECHAS DE NAVEGACIÓN (Derecha) ---
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
            color: AppColors.borders,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.backgroundWhite,
            size: 16,
          ),
        ),
      ),
    );
  }
}

