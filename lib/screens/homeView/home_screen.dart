import 'package:flutter/material.dart';
// --- CAMBIO 1: Importamos la nueva pantalla de detalle ---
import 'service_detail_screen.dart';

class HomeFeedScreen extends StatelessWidget {
  HomeFeedScreen({super.key});

  final List<CategoryItemData> _categories = const [
    CategoryItemData(icon: Icons.celebration, label: 'Fiestas'),
    CategoryItemData(icon: Icons.music_note, label: 'Música'),
    CategoryItemData(icon: Icons.emoji_people, label: 'Baile'),
  ];

  // --- CAMBIO 2: Actualizamos la lista con los nuevos datos ---
  final List<ServiceCardData> _services = const [
    ServiceCardData(
      imageUrls: [
        'https://img.vorecol.com/ia-images/1502/mazamitla-mariachi15.jpeg',
        'https://img.vorecol.com/ia-images/1502/mariachi-familia.jpg',
        'https://img.vorecol.com/ia-images/1502/mariachi-noche.jpg',
      ],
      title: "Mariachi \"El Sol\"",
      providerName: 'Gustavo David', // Nombre actualizado
      rating: 4.6,
      category: 'Música', // Nuevo
      price: 15, // Nuevo
      description: // Nuevo
          '¡Dale vida y luz a tu evento con Mariachi \'El Sol\'! Somos un grupo de músicos profesionales dedicados a llevar la auténtica pasión y alegría de la música ranchera directamente a tu celebración.',
    ),
    ServiceCardData(
      imageUrls: [
        'https://boomerangfiesta.com/wp-content/uploads/2023/01/photo_2023-01-06_07-12-01-225x300.jpg',
        'https://boomerangfiesta.com/wp-content/uploads/2022/06/animacion-infantil-ecuador.jpg',
        'https://boomerangfiesta.com/wp-content/uploads/2022/07/animacion-pjs.jpg',
      ],
      title: 'Animadores Infantiles',
      providerName: 'Blinky',
      rating: 4.2,
      category: 'Fiestas', // Nuevo
      price: 10, // Nuevo
      description: // Nuevo
          'Diversión garantizada para los más pequeños. Ofrecemos juegos, pintacaritas, globoflexia y shows temáticos para hacer de su fiesta un día inolvidable.',
    ),
    ServiceCardData(
      imageUrls: [
        'https://showsparafiestas.org/wp-content/uploads/2012/05/salasa-778.jpg?w=564',
        'https://showsparafiestas.org/wp-content/uploads/2012/05/salsa-show.jpg',
        'https://showsparafiestas.org/wp-content/uploads/2012/05/ballet-folklorico.jpg',
      ],
      title: 'Bailarines Profesionales',
      providerName: 'Ballet Folklórico',
      rating: 4.7,
      category: 'Baile', // Nuevo
      price: 25, // Nuevo
      description: // Nuevo
          'Shows de salsa, bachata y folklore. Contamos con un elenco de bailarines de primer nivel para darle un toque de elegancia y sabor a tu evento.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color accentColor = const Color.fromRGBO(59, 96, 125, 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SearchField(),
              const SizedBox(height: 24),
              _CategoryHeader(
                categories: _categories,
                accentColor: accentColor,
              ),
              const SizedBox(height: 24),
              // --- CAMBIO 2: Envolvemos el Padding en un GestureDetector ---
              for (final service in _services)
                GestureDetector(
                  onTap: () {
                    // --- CAMBIO 3: Añadimos la navegación ---
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceDetailScreen(
                          // NOTA: Esto asume que ya actualizaste tu clase
                          // de datos (ahora pública 'ServiceCardData')
                          // con los campos que 'ServiceDetailScreen' necesita.
                          data: service,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _ServiceCard(
                      data: service,
                      accentColor: accentColor,
                      textTheme: theme.textTheme,
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

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.categories,
    required this.accentColor,
  });

  final List<CategoryItemData> categories;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ArrowButton(
          icon: Icons.arrow_back_ios_new,
          color: accentColor,
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: categories
                .map((item) => _CategoryItem(
                      data: item,
                      accentColor: accentColor,
                    ))
                .toList(),
          ),
        ),
        _ArrowButton(icon: Icons.arrow_forward_ios, color: accentColor),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 18,
        color: color,
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.data,
    required this.accentColor,
  });

  final CategoryItemData data;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          data.icon,
          color: accentColor,
          size: 36,
        ),
        const SizedBox(height: 8),
        Text(
          data.label,
          style: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatefulWidget {
  const _ServiceCard({
    required this.data,
    required this.accentColor,
    required this.textTheme,
  });

  final ServiceCardData data;
  final Color accentColor;
  final TextTheme textTheme;

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
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

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.data.imageUrls.isNotEmpty;
    final imageCount = hasImages ? widget.data.imageUrls.length : 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: imageCount,
                    onPageChanged: _handlePageChanged,
                    itemBuilder: (context, index) {
                      if (!hasImages) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.black38,
                          ),
                        );
                      }
                      return Image.network(
                        widget.data.imageUrls[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: _ImageArrow(
                        icon: Icons.arrow_back_ios_new,
                        background: Colors.black54,
                        iconColor: Colors.white,
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
                        background: Colors.black54,
                        iconColor: Colors.white,
                        onTap: _goNext,
                        enabled: _currentIndex < imageCount - 1,
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              widget.data.title,
              style: widget.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                Text(
                  // --- CAMBIO 5: Usamos el nuevo nombre del campo ---
                  widget.data.providerName,
                  style: widget.textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey[700]),
                ),
                const Spacer(),
                Text(
                  widget.data.rating.toStringAsFixed(1),
                  style: widget.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.star,
                  color: widget.accentColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageArrow extends StatelessWidget {
  const _ImageArrow({
    required this.icon,
    required this.background,
    required this.iconColor,
    this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackground =
        enabled ? background : background.withOpacity(0.35);
    final Color effectiveIconColor =
        enabled ? iconColor : iconColor.withOpacity(0.5);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.6,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: effectiveBackground,
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
            color: effectiveIconColor,
            size: 16,
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar servicios...',
        prefixIcon: const Icon(
          Icons.search,
          color: Color.fromARGB(255, 26, 188, 156),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}

// --- CAMBIO 6: Clases de datos ahora PÚBLICAS (sin '_') ---
// (Movidas al final del archivo para que 'home_screen.dart' las importe)

class CategoryItemData {
  const CategoryItemData({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class ServiceCardData {
  const ServiceCardData({
    required this.imageUrls,
    required this.title,
    required this.providerName,
    required this.rating,
    // --- CAMBIO 7: Nuevos campos añadidos ---
    required this.category,
    required this.price,
    required this.description,
  });

  final List<String> imageUrls;
  final String title;
  final String providerName; // Campo renombrado
  final double rating;
  final String category;
  final int price;
  final String description;
}

