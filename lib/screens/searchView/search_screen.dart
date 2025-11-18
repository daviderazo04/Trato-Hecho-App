import 'package:flutter/material.dart';

import '../../config/appColors.dart';

enum SearchMode {
  services,
  providers,
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  SearchMode _mode = SearchMode.services;
  String? _selectedBudget;
  DateTime? _selectedDate;

  final List<_SearchModeOption> _modeOptions = const [
    _SearchModeOption(
      mode: SearchMode.services,
      icon: Icons.event_available,
      label: 'Servicios',
    ),
    _SearchModeOption(
      mode: SearchMode.providers,
      icon: Icons.store_mall_directory,
      label: 'Proveedores',
    ),
  ];

  final List<String> _budgetRanges = const [
    'Hasta \$100',
    '\$100 - \$300',
    'Más de \$300',
  ];

  final List<String> _recentSearches = const [
    'Mariachi en Quito',
    'Animador infantil',
    'Catering gourmet',
  ];

  final List<SearchCategoryData> _categories = const [
    SearchCategoryData(icon: Icons.celebration, label: 'Fiestas temáticas'),
    SearchCategoryData(icon: Icons.music_note, label: 'Música en vivo'),
    SearchCategoryData(icon: Icons.restaurant_menu, label: 'Catering'),
    SearchCategoryData(icon: Icons.light, label: 'Iluminación y sonido'),
    SearchCategoryData(icon: Icons.video_camera_back, label: 'Foto y video'),
    SearchCategoryData(icon: Icons.chair, label: 'Alquiler de mobiliario'),
  ];

  final List<SearchHighlightData> _highlights = const [
    SearchHighlightData(
      title: 'Mariachi "El Sol"',
      location: 'Quito, Ecuador',
      priceLabel: 'Desde \$150',
      rating: 4.6,
      category: 'Música',
      imageUrl:
          'https://img.vorecol.com/ia-images/1502/mazamitla-mariachi15.jpeg',
    ),
    SearchHighlightData(
      title: 'Animación infantil Blinky',
      location: 'Cuenca, Ecuador',
      priceLabel: 'Desde \$90',
      rating: 4.2,
      category: 'Fiestas',
      imageUrl:
          'https://boomerangfiesta.com/wp-content/uploads/2023/01/photo_2023-01-06_07-12-01-225x300.jpg',
    ),
    SearchHighlightData(
      title: 'Banquetes Gourmet',
      location: 'Guayaquil, Ecuador',
      priceLabel: 'Desde \$18 p/p',
      rating: 4.8,
      category: 'Catering',
      imageUrl:
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
    ),
  ];

  @override
  void dispose() {
    _serviceController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    const List<String> monthNames = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${date.day} de ${monthNames[date.month - 1]} ${date.year}';
  }

  void _onSearch() {
    final String modeLabel =
        _mode == SearchMode.services ? 'servicios' : 'proveedores';
    final String serviceLabel =
        _serviceController.text.isEmpty ? 'todo' : _serviceController.text;
    final String locationLabel = _locationController.text.isEmpty
        ? 'cualquier ciudad'
        : _locationController.text;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Buscando $modeLabel de "$serviceLabel" en $locationLabel',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(context),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Recomendados para ti',
                subtitle: 'Descubre talentos destacados para tu evento',
              ),
              const SizedBox(height: 12),
              _buildHighlights(),
              const SizedBox(height: 28),
              _SectionHeader(
                title: 'Explora por categoría',
                subtitle: 'Encuentra especialistas según el tipo de servicio',
              ),
              const SizedBox(height: 12),
              _buildCategoryWrap(),
              const SizedBox(height: 28),
              _SectionHeader(
                title: 'Búsquedas recientes',
                subtitle: 'Retoma donde te quedaste',
              ),
              const SizedBox(height: 12),
              _buildRecentChips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
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
              color: AppColors.primary.withOpacity(0.28),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModeSelector(),
              const SizedBox(height: 24),
              Text(
                'Planifica el evento perfecto',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Busca talento, proveedores o paquetes personalizados en cuestión de minutos.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
              ),
              const SizedBox(height: 28),
              _buildSearchForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: _modeOptions.map((option) {
          final bool isSelected = option.mode == _mode;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isSelected) {
                  setState(() {
                    _mode = option.mode;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      option.icon,
                      size: 28,
                      color: isSelected ? AppColors.primary : Colors.white,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option.label,
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchForm(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final fieldTheme =
        (theme.inputDecorationTheme as InputDecorationTheme).copyWith(
      fillColor: AppColors.backgroundWhite,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Theme(
        data: theme.copyWith(inputDecorationTheme: fieldTheme),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('¿Qué necesitas?'),
            const SizedBox(height: 6),
            TextField(
              controller: _serviceController,
              decoration: _inputDecoration(
                hint: 'Mariachi, fotógrafo, animador...',
                icon: Icons.search,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Fecha del evento'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: _inputDecoration(
                          hint: 'Selecciona fecha',
                          icon: Icons.calendar_today,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Ciudad'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _locationController,
                        decoration: _inputDecoration(
                          hint: 'Quito, Guayaquil...',
                          icon: Icons.location_on_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel('Presupuesto estimado'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedBudget,
              items: _budgetRanges
                  .map(
                    (range) => DropdownMenuItem<String>(
                      value: range,
                      child: Text(range),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBudget = value;
                });
              },
              decoration: _inputDecoration(
                hint: 'Selecciona un rango',
                icon: Icons.price_check,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Buscar opciones',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null
          ? Icon(
              icon,
              color: AppColors.primary,
            )
          : null,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildHighlights() {
    return SizedBox(
      height: 222,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _highlights.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final highlight = _highlights[index];
          return _HighlightCard(data: highlight);
        },
      ),
    );
  }

  Widget _buildCategoryWrap() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _categories
            .map(
              (category) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildRecentChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _recentSearches
            .map(
              (search) => Chip(
                label: Text(search),
                backgroundColor: AppColors.backgroundWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.data});

  final SearchHighlightData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.network(
                data.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.08),
                      Colors.black.withOpacity(0.72),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  data.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 14,
              right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.location,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: AppColors.notificacion,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        data.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        data.priceLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchCategoryData {
  const SearchCategoryData({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class SearchHighlightData {
  const SearchHighlightData({
    required this.title,
    required this.location,
    required this.priceLabel,
    required this.rating,
    required this.category,
    required this.imageUrl,
  });

  final String title;
  final String location;
  final String priceLabel;
  final double rating;
  final String category;
  final String imageUrl;
}

class _SearchModeOption {
  const _SearchModeOption({
    required this.mode,
    required this.icon,
    required this.label,
  });

  final SearchMode mode;
  final IconData icon;
  final String label;
}
