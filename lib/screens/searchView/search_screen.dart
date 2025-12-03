import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../config/api_config.dart';
import '../../config/appColors.dart';
import '../../config/user_provider.dart';
import '../../config/theme_provider.dart';
import '../../services/favorites_service.dart';
import '../../services/my_services_service.dart';
import '../../services/services_cache.dart';
import '../homeView/home_screen.dart' show ServiceCardData;
import '../homeView/service_detail_screen.dart';

// Fixed categories list (use these instead of deriving from services)
const List<String> _fixedCategories = [
  'Música Tradicional y Mariachis',
  'Animación Infantil y Payasos',
  'Catering y Comida',
  'Música Moderna y DJs',
  'Fotografía y Video',
  'Decoración y Ambientación',
  'Mobiliario y Logística',
  'Entretenimiento Variado',
  'Servicios Adicionales',
  'Juegos e Inflables',
];

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  final MyServicesService _myServicesService = MyServicesService();
  final ServicesCache _servicesCache = ServicesCache();

  List<ServiceCardData> _services = [];
  List<ServiceCardData> _filtered = [];
  Set<String> _selectedCategories = {};
  List<String> _availableCategories = List.from(_fixedCategories);
  final Set<int> _favoriteServiceIds = {};
  final FavoritesService _favoritesService = FavoritesService();

  double _minPrice = 0;
  double _maxPrice = 1000;
  RangeValues _priceRange = const RangeValues(0, 1000);

  bool _onlyWithMedia = false;
  bool _hideUnrated = false;
  String _sortOption = 'relevance';

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_applyFilters);
    _fetchServices();
  }

  @override
  void dispose() {
    _queryController
      ..removeListener(_applyFilters)
      ..dispose();
    super.dispose();
  }

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;

    // Serve cached data first to speed up screen render
    final cachedRaw = await _servicesCache.loadRaw(userId);
    final cachedServices =
        cachedRaw.map((item) => ServiceCardData.fromJson(item)).toList();
    if (mounted && cachedServices.isNotEmpty) {
      setState(() {
        _services = cachedServices;
        _favoriteServiceIds
          ..clear()
          ..addAll(
            cachedServices
                .where((s) => s.id != null && s.esFavorito)
                .map((s) => s.id!)
                .toSet(),
          );
        _minPrice = 0;
        _maxPrice = 1000;
        _priceRange = const RangeValues(0, 1000);
        _isLoading = false;
      });
      _applyFilters();
    }

    try {
      String urlString = ApiConfig.servicios;
      if (userId != null) {
        urlString += '?userId=$userId';
      }

      final url = Uri.parse(urlString);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> decoded =
            jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;

        List<ServiceCardData> services = decoded
            .map((item) =>
                ServiceCardData.fromJson(item as Map<String, dynamic>))
            .toList();

        // Merge own services to avoid backend filters hiding them.
        if (userId != null) {
          final ownServices = await _myServicesService.getMyServices(userId);
          services = _mergeServices(services, ownServices);
        }

        setState(() {
          _services = services;
          // populate favorite ids from the loaded services (API returns `esFavorito`)
          _favoriteServiceIds.clear();
          for (final s in services) {
            if (s.id != null && s.esFavorito) {
              _favoriteServiceIds.add(s.id!);
            }
          }
          // keep `_availableCategories` as the fixed list defined above
          _minPrice = 0;
          _maxPrice = 1000;
          _priceRange = const RangeValues(0, 1000);
        });
        _applyFilters();

        await _servicesCache
            .saveRaw(services.map((s) => s.toJson()).toList(), userId);
      } else {
        setState(() {
          if (_services.isEmpty) {
            _error =
                'No se pudieron cargar los servicios (${response.statusCode})';
          }
        });
      }
    } catch (e) {
      setState(() {
        if (_services.isEmpty) {
          _error = 'Error de conexión. Inténtalo de nuevo.';
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<ServiceCardData> _mergeServices(
      List<ServiceCardData> base, List<ServiceCardData> extra) {
    final List<ServiceCardData> withoutId = [];
    final Map<int, ServiceCardData> byId = {};

    void add(ServiceCardData s) {
      final id = s.id;
      if (id == null) {
        withoutId.add(s);
      } else {
        byId.putIfAbsent(id, () => s);
      }
    }

    for (final s in base) {
      add(s);
    }
    for (final s in extra) {
      add(s);
    }

    return [...withoutId, ...byId.values];
  }

  void _applyFilters() {
    final query = _queryController.text.toLowerCase();

    List<ServiceCardData> temp = _services.where((service) {
      final matchesText = query.isEmpty ||
          service.title.toLowerCase().contains(query) ||
          service.providerName.toLowerCase().contains(query) ||
          service.categories.any((c) => c.toLowerCase().contains(query));

      final matchesCategory = _selectedCategories.isEmpty ||
          service.categories.any((c) => _selectedCategories.contains(c));

      final matchesPrice = service.price >= _priceRange.start &&
          service.price <= _priceRange.end;

      final matchesMedia = !_onlyWithMedia || service.imageUrls.isNotEmpty;
      final matchesRating = !_hideUnrated || service.hasRatings;

      return matchesText &&
          matchesCategory &&
          matchesPrice &&
          matchesMedia &&
          matchesRating;
    }).toList();

    temp.sort((a, b) {
      switch (_sortOption) {
        case 'rating':
          return b.rating.compareTo(a.rating);
        case 'price_low':
          return a.price.compareTo(b.price);
        case 'price_high':
          return b.price.compareTo(a.price);
        case 'recent':
          return (b.id ?? 0).compareTo(a.id ?? 0);
        default:
          return 0;
      }
    });

    setState(() => _filtered = temp);
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
    _applyFilters();
  }

  void _resetFilters() {
    setState(() {
      _selectedCategories.clear();
      _onlyWithMedia = false;
      _hideUnrated = false;
      _sortOption = 'relevance';
      _priceRange = RangeValues(_minPrice, _maxPrice);
      _queryController.clear();
    });
    _applyFilters();
  }

  Future<bool> _toggleFavorite(ServiceCardData service, BuildContext context,
      {bool? desiredState}) async {
    final serviceId = service.id;
    if (serviceId == null) return false;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debes iniciar sesión para guardar favoritos')),
      );
      return false;
    }

    final isFav = _favoriteServiceIds.contains(serviceId);
    final target = desiredState ?? !isFav;
    if (target == isFav) return true;

    if (target) {
      setState(() => _favoriteServiceIds.add(serviceId));
      final success = await _favoritesService.addFavorite(
          userId: userId, serviceId: serviceId);
      if (!success) {
        setState(() => _favoriteServiceIds.remove(serviceId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo agregar a favoritos')),
        );
      }
      return success;
    } else {
      setState(() => _favoriteServiceIds.remove(serviceId));
      // also notify backend
      final success = await _favoritesService.removeFavorite(
          userId: userId, serviceId: serviceId);
      if (!success) {
        // rollback locally if server failed
        setState(() => _favoriteServiceIds.add(serviceId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo quitar de favoritos')),
        );
      }
      return success;
    }
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Busca servicios',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Encuentra por nombre, categoría o proveedor.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: 'Ej: mariachi, fotografía, David...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.accent, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkButtons : const Color(0xFFF7FBFF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: (isDark ? AppColors.darkBorders : AppColors.primary)
                  .withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: AppColors.accent),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Filtros inteligentes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _resetFilters,
                  icon: Icon(
                    Icons.refresh,
                    size: 18,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                  label: Text(
                    'Limpiar',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    side: BorderSide(
                      color: isDark ? Colors.white : AppColors.primary,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCategories(isDark),
            const SizedBox(height: 12),
            _buildPriceSlider(_priceRange, isDark),
            const SizedBox(height: 12),
            _buildToggles(),
            const SizedBox(height: 12),
            _buildSortSelector(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(bool isDark) {
    if (_availableCategories.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FilterLabel('Categorías', isDark: isDark),
        const SizedBox(height: 8),
        // Mostrar categorías en una columna vertical, una por una
        ...(_availableCategories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: ChoiceChip(
                label: Text(
                  category,
                  style: TextStyle(
                    color: _selectedCategories.contains(category)
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                selected: _selectedCategories.contains(category),
                onSelected: (_) => _toggleCategory(category),
                selectedColor: AppColors.secondary.withOpacity(0.18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _selectedCategories.contains(category)
                        ? AppColors.secondary
                        : AppColors.border,
                  ),
                ),
                backgroundColor: Colors.white,
              ),
            ),
          );
        }).toList()),
      ],
    );
  }

  Widget _buildPriceSlider(RangeValues range, bool isDark) {
    final bool hasRange = _maxPrice - _minPrice > 0.1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FilterLabel('Precio', isDark: isDark),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _PriceTag(label: 'Mín', value: range.start, isDark: isDark),
            _PriceTag(label: 'Máx', value: range.end, isDark: isDark),
          ],
        ),
        RangeSlider(
          values: range,
          min: _minPrice,
          max: _maxPrice <= _minPrice ? _minPrice + 1 : _maxPrice,
          divisions: hasRange ? 20 : null,
          activeColor: AppColors.secondary,
          inactiveColor: AppColors.border,
          labels: RangeLabels(
            '\$${range.start.toStringAsFixed(0)}',
            '\$${range.end.toStringAsFixed(0)}',
          ),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
            _applyFilters();
          },
        ),
      ],
    );
  }

  Widget _buildToggles() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('Solo con fotos/video'),
          selected: _onlyWithMedia,
          onSelected: (value) {
            setState(() => _onlyWithMedia = value);
            _applyFilters();
          },
          selectedColor: AppColors.secondary.withOpacity(0.18),
          labelStyle: TextStyle(
            color: _onlyWithMedia ? AppColors.primary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _onlyWithMedia ? AppColors.secondary : AppColors.border,
            ),
          ),
        ),
        FilterChip(
          label: const Text('Ocultar sin calificaciones'),
          selected: _hideUnrated,
          onSelected: (value) {
            setState(() => _hideUnrated = value);
            _applyFilters();
          },
          selectedColor: AppColors.secondary.withOpacity(0.18),
          labelStyle: TextStyle(
            color: _hideUnrated ? AppColors.primary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _hideUnrated ? AppColors.secondary : AppColors.border,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FilterLabel('Ordenar por', isDark: isDark),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _sortOption,
          isDense: false,
          isExpanded: true,
          itemHeight: 52,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkButtons : Colors.white,
          ),
          items: [
            DropdownMenuItem(
              value: 'relevance',
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white10
                      : AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Relevancia',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            DropdownMenuItem(value: 'rating', child: Text('Mejor calificados')),
            DropdownMenuItem(value: 'price_low', child: Text('Menor precio')),
            DropdownMenuItem(value: 'price_high', child: Text('Mayor precio')),
            DropdownMenuItem(value: 'recent', child: Text('Más recientes')),
          ],
          selectedItemBuilder: (context) {
            return [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Relevancia',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Mejor calificados',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Menor precio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Mayor precio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Más recientes',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ];
          },
          onChanged: (value) {
            if (value == null) return;
            setState(() => _sortOption = value);
            _applyFilters();
          },
        ),
      ],
    );
  }

  Widget _buildResults(bool isDark) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchServices,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 48, color: AppColors.border),
            const SizedBox(height: 12),
            Text(
              'No se encontraron servicios con estos filtros',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      children: _filtered
          .map(
            (service) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _ResultCard(
                data: service,
                isFavorite: service.id != null &&
                    _favoriteServiceIds.contains(service.id),
                onFavoriteTap: () => _toggleFavorite(service, context),
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServiceDetailScreen(
                        data: service,
                        isFavorite: service.id != null &&
                            _favoriteServiceIds.contains(service.id),
                        onFavoriteToggle: () async {
                          await _toggleFavorite(service, context);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;
    final Color scaffoldBg =
        isDark ? AppColors.backgroundDark : AppColors.backgroundWhite;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchServices,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _buildHeader(isDark),
              const SizedBox(height: 12),
              _buildFiltersCard(isDark),
              const SizedBox(height: 12),
              _buildResults(isDark),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  const _FilterLabel(this.text, {this.isDark = false});
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkText : AppColors.textPrimary,
      ),
    );
  }
}

class _PriceTag extends StatelessWidget {
  const _PriceTag(
      {required this.label, required this.value, this.isDark = false});
  final String label;
  final double value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[300] : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '\$${value.toStringAsFixed(0)}',
            style: TextStyle(
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.data,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.isDark,
    required this.onTap,
  });

  final ServiceCardData data;
  final bool isFavorite;
  final Future<bool> Function() onFavoriteTap;
  final bool isDark;
  final VoidCallback onTap;

  bool get _hasMedia => data.imageUrls.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final ratingText = data.ratingLabel;
    final Color cardColor = isDark ? AppColors.darkButtons : Colors.white;
    final Color primaryText =
        isDark ? AppColors.darkText : AppColors.textPrimary;
    final Color secondaryText =
        isDark ? Colors.grey[300]! : Colors.grey.shade700;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _hasMedia
                        ? _buildImage(data.imageUrls.first)
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.black38,
                              size: 48,
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '\$${data.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Material(
                      color: Colors.black45,
                      shape: const CircleBorder(),
                      child: IconButton(
                        onPressed: () {
                          onFavoriteTap();
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.redAccent : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: primaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Text(
                            ratingText,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: primaryText,
                            ),
                          ),
                          if (data.hasRatings)
                            const Icon(Icons.star_rounded,
                                size: 18, color: AppColors.notificacion),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.providerName,
                    style: TextStyle(
                      color: secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: data.categories
                        .take(3)
                        .map(
                          (cat) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    isDark ? Colors.white : AppColors.primary,
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey.shade800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
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
    if (url.startsWith('http://') || url.startsWith('https://')) {
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
