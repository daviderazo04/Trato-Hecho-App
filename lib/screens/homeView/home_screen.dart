import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

import 'service_detail_screen.dart';
import '../../config/api_config.dart';
import '../../config/appColors.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ServiceCardData> _services = [];
  List<ServiceCardData> _filteredServices = [];
  String? _selectedCategory;
  bool _isLoading = true;
  String? _error;

  final List<CategoryItemData> _categories = const [
    CategoryItemData(icon: Icons.celebration, label: 'Fiestas'),
    CategoryItemData(icon: Icons.music_note, label: 'Música'),
    CategoryItemData(icon: Icons.emoji_people, label: 'Baile'),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterServices);
    _fetchServices();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterServices);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/servicios'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> decoded =
            jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        final services = decoded
            .map((item) => ServiceCardData.fromJson(item as Map<String, dynamic>))
            .toList();

        if (!mounted) return;
        setState(() {
          _services = services;
        });
        _filterServices();
      } else {
        if (!mounted) return;
        setState(() {
          _error = 'Error ${response.statusCode} al cargar servicios';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar servicios: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = _services.where((service) {
        final serviceTitle = service.title.toLowerCase();
        final matchesSearch = serviceTitle.contains(query);
        final matchesCategory = _selectedCategory == null ||
            service.category.toLowerCase() == _selectedCategory!.toLowerCase();
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

    Widget content;
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchServices,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    } else {
      content = SingleChildScrollView(
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
            if (_filteredServices.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'No hay servicios disponibles',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                ),
              )
            else
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
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: content,
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
    final hasMedia = widget.data.imageUrls.isNotEmpty;
    final mediaCount = hasMedia ? widget.data.imageUrls.length : 1;

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
                    itemCount: mediaCount,
                    onPageChanged: _handlePageChanged,
                    itemBuilder: (context, index) {
                      if (!hasMedia) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.black38,
                          ),
                        );
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
                                aspectRatio:
                                    controller.value.isInitialized ? controller.value.aspectRatio : (4 / 3),
                                child: VideoPlayer(controller),
                              ),
                              GestureDetector(
                                onTap: () => _togglePlay(index),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
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
    this.id,
    required this.imageUrls,
    required this.title,
    required this.providerName,
    required this.rating,
    // --- CAMBIO 7: Nuevos campos añadidos ---
    required this.category,
    required this.price,
    required this.description,
  });

  final int? id;
  final List<String> imageUrls;
  final String title;
  final String providerName; // Campo renombrado
  final double rating;
  final String category;
  final double price;
  final String description;

  factory ServiceCardData.fromJson(Map<String, dynamic> json) {
    final List<String> images =
        (json['multimediaUrls'] as List<dynamic>?)
                ?.whereType<String>()
                .toList() ??
            [];
    final List<String> categories =
        (json['categorias'] as List<dynamic>?)
                ?.whereType<String>()
                .toList() ??
            [];

    return ServiceCardData(
      id: json['id'] as int?,
      imageUrls: images,
      title: json['nombre'] as String? ?? 'Servicio',
      providerName: json['usuarioNombre'] as String? ?? 'Proveedor',
      rating: (json['promedioCalificacion'] as num?)?.toDouble() ?? 0,
      category: _mapCategory(categories.isNotEmpty ? categories.first : 'Servicios'),
      price: (json['precio'] as num?)?.toDouble() ?? 0,
      description: json['descripcion'] as String? ?? '',
    );
  }

  static String _mapCategory(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('música') || lower.contains('musica')) {
      return 'Música';
    }
    if (lower.contains('fiesta')) {
      return 'Fiestas';
    }
    if (lower.contains('baile') || lower.contains('danza')) {
      return 'Baile';
    }
    return raw;
  }
}
