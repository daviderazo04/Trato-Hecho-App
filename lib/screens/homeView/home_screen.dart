import 'package:flutter/material.dart';
import 'service_detail_screen.dart';
import '../../config/appColors.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ServiceCardData> _filteredServices = [];
  String? _selectedCategory;

  final List<CategoryItemData> _categories = const [
    CategoryItemData(icon: Icons.celebration, label: 'Fiestas'),
    CategoryItemData(icon: Icons.music_note, label: 'Música'),
    CategoryItemData(icon: Icons.emoji_people, label: 'Baile'),
  ];

  final List<ServiceCardData> _services = const [
    ServiceCardData(
      imageUrls: [
        'https://img.vorecol.com/ia-images/1502/mazamitla-mariachi15.jpeg',
        'https://www.viajabonito.mx/wp-content/uploads/2021/07/canciones-de-mariachi-50.jpg',
        'https://estaticosgn-cdn.deia.eus/clip/02be8ee3-8a11-440e-b360-d7e34ab0f688_16-9-discover-aspect-ratio_default_0.jpg',
      ],
      title: "Mariachi \"El Sol\"",
      providerName: 'Gustavo David',
      rating: 4.6,
      category: 'Música',
      price: 15,
      description:
          '¡Dale vida y luz a tu evento con Mariachi \'El Sol\'! Somos un grupo de músicos profesionales dedicados a llevar la auténtica pasión y alegría de la música ranchera directamente a tu celebración.',
    ),
    ServiceCardData(
      imageUrls: [
        'https://diverticarts.com/wp-content/uploads/disneybotargas1.jpg',
        'https://res.cloudinary.com/kosmoapp/image/upload/v1661978302/services/images/wqwzrth2f0qclaex33zh.jpg',
        'https://miro.medium.com/0*WVoLwv7pmP4bQcFF.jpg',
      ],
      title: 'Botargueros Infantiles',
      providerName: 'Blinky',
      rating: 4.2,
      category: 'Fiestas',
      price: 10,
      description:
          'Diversión garantizada para los más pequeños. Ofrecemos juegos, pintacaritas, globoflexia y shows temáticos para hacer de su fiesta un día inolvidable.',
    ),
    ServiceCardData(
      imageUrls: [
        'https://dnwp63qf32y8i.cloudfront.net/423d13ab39b4f6e8365d9a12e925dc2df7f96cc6',
        'https://dnwp63qf32y8i.cloudfront.net/166253847d4029ef258157dc63cec55634f24cf5',
        'https://images.squarespace-cdn.com/content/v1/52b4c979e4b056e96533da8d/1387755905167-TLN167ICDNT07DV6HH30/_SAR0828.jpg',
      ],
      title: 'Bailarines Profesionales',
      providerName: 'Tap Dance Ecuador',
      rating: 4.7,
      category: 'Baile',
      price: 25,
      description:
          'Shows de baile - tap dance. Perfecto para sorprender a todos con un espectáculo único.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredServices = _services;
    _searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterServices);
    _searchController.dispose();
    super.dispose();
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = _services.where((service) {
        final serviceTitle = service.title.toLowerCase();
        final matchesSearch = serviceTitle.contains(query);
        final matchesCategory =
            _selectedCategory == null || service.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _selectCategory(String category) {
    setState(() {
      if (_selectedCategory == category) {
        // Si la categoría ya está seleccionada, la deseleccionamos
        _selectedCategory = null;
      } else {
        _selectedCategory = category;
      }
    });
    _filterServices();
  }

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
              _SearchField(controller: _searchController),
              const SizedBox(height: 24),
              _CategoryHeader(
                categories: _categories,
                accentColor: accentColor,
                selectedCategory: _selectedCategory,
                onCategorySelected: _selectCategory,
              ),
              const SizedBox(height: 24),
              for (final service in _filteredServices)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceDetailScreen(
                          data: service,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _ServiceCard(
                      data: service,
                      accentColor: AppColors.amber,
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
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<CategoryItemData> categories;
  final Color accentColor;
  final String? selectedCategory;
  final Function(String) onCategorySelected;

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
                      isSelected: item.label == selectedCategory,
                      onTap: () => onCategorySelected(item.label),
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
    required this.isSelected,
    required this.onTap,
  });

  final CategoryItemData data;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withOpacity(0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              color: accentColor,
              size: 36,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.label,
            style: TextStyle(
              color: accentColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
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
  const _SearchField({super.key, this.controller});

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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
