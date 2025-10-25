import 'package:flutter/material.dart';

class HomeFeedScreen extends StatelessWidget {
  HomeFeedScreen({super.key});

  final List<_CategoryItemData> _categories = const [
    _CategoryItemData(icon: Icons.celebration, label: 'Fiestas'),
    _CategoryItemData(icon: Icons.music_note, label: 'Música'),
    _CategoryItemData(icon: Icons.emoji_people, label: 'Baile'),
  ];

  final List<_ServiceCardData> _services = const [
    _ServiceCardData(
      imageUrl:
          'https://img.vorecol.com/ia-images/1502/mazamitla-mariachi15.jpeg',
      title: "Mariachi \"El Sol\"",
      provider: 'Gustavo',
      rating: 4.6,
    ),
    _ServiceCardData(
      imageUrl:
          'https://boomerangfiesta.com/wp-content/uploads/2023/01/photo_2023-01-06_07-12-01-225x300.jpg',
      title: 'Animadores Infantiles',
      provider: 'Blinky',
      rating: 4.2,
    ),
    _ServiceCardData(
      imageUrl:
          'https://showsparafiestas.org/wp-content/uploads/2012/05/salasa-778.jpg?w=564',
      title: 'Bailarines Profesionales',
      provider: 'Ballet Folklórico',
      rating: 4.7,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color accentColor = const Color(0xFFE53935);

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
              for (final service in _services)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _ServiceCard(
                    data: service,
                    accentColor: accentColor,
                    textTheme: theme.textTheme,
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

  final List<_CategoryItemData> categories;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ArrowButton(icon: Icons.arrow_back_ios_new, color: accentColor),
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

  final _CategoryItemData data;
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

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.data,
    required this.accentColor,
    required this.textTheme,
  });

  final _ServiceCardData data;
  final Color accentColor;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
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
                  child: Image.network(
                    data.imageUrl,
                    fit: BoxFit.cover,
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
                    children: List.generate(
                      3,
                      (index) => Container(
                        width: index == 1 ? 12 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index == 1
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              data.title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                Text(
                  data.provider,
                  style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
                const Spacer(),
                Text(
                  data.rating.toStringAsFixed(1),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.star,
                  color: Colors.amber,
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
  });

  final IconData icon;
  final Color background;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        prefixIcon: const Icon(Icons.search),
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

class _CategoryItemData {
  const _CategoryItemData({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class _ServiceCardData {
  const _ServiceCardData({
    required this.imageUrl,
    required this.title,
    required this.provider,
    required this.rating,
  });

  final String imageUrl;
  final String title;
  final String provider;
  final double rating;
}
