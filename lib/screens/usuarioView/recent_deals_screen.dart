import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/appColors.dart';
import '../../config/theme_provider.dart';
import '../../config/user_provider.dart';
import '../../services/contratacion_service.dart';
import 'rate_service_screen.dart';

class RecentDealsScreen extends StatefulWidget {
  const RecentDealsScreen({super.key});

  @override
  State<RecentDealsScreen> createState() => _RecentDealsScreenState();
}

class _RecentDealsScreenState extends State<RecentDealsScreen>
    with SingleTickerProviderStateMixin {
  final ContratacionService _contratacionService = ContratacionService();

  ContratacionHistorial? _historial;
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _error = 'Inicia sesión para ver tu historial.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final resp = await _contratacionService.getHistorial(userId);
    if (!mounted) return;
    setState(() {
      _historial = resp;
      _isLoading = false;
      _error = resp == null ? 'No se pudo cargar el historial.' : null;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.backgroundDark : AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text('Tratos recientes'),
        backgroundColor:
            isDarkMode ? AppColors.backgroundDark : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Compras'),
            Tab(text: 'Ventas'),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
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
                    onRefresh: _loadData,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(_historial?.compras ?? [],
                            isCompra: true, isDarkMode: isDarkMode),
                        _buildList(_historial?.ventas ?? [],
                            isCompra: false, isDarkMode: isDarkMode),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildList(List<ContratoItem> items,
      {required bool isCompra, required bool isDarkMode}) {
    if (items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 40),
          Center(
            child: Text(
              'No hay ${isCompra ? 'compras' : 'ventas'}',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildDealCard(item, isCompra, isDarkMode);
      },
    );
  }

  Widget _buildDealCard(
      ContratoItem item, bool isCompra, bool isDarkMode) {
    final dateRange =
        '${_fmtDate(item.fechaInicio)} • ${_fmtHour(item.fechaInicio)} - ${_fmtHour(item.fechaFin)}';
    final badgeColor =
        isCompra ? AppColors.primary : AppColors.notificacion;
    final alreadyRated = isCompra && item.yaCalificado;
    final canReview = isCompra && item.finalizado && !item.yaCalificado;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkButtons : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: item.contraparteFoto != null
                    ? NetworkImage(item.contraparteFoto!)
                    : null,
                backgroundColor:
                    item.contraparteFoto == null ? Colors.grey[300] : null,
                child: item.contraparteFoto == null
                    ? const Icon(Icons.person, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.servicio.nombre,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.contraparteNombre,
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateRange,
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white70
                            : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: badgeColor),
                ),
                child: Text(
                  isCompra ? 'Compra' : 'Venta',
                  style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${item.servicio.precio.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.primary,
                ),
              ),
              if (alreadyRated)
                _buildRatedBadge(item.miNota ?? 0, isDarkMode)
              else if (canReview)
                TextButton.icon(
                  onPressed: () => _goToReview(item),
                  icon: const Icon(Icons.star_border, color: AppColors.amber),
                  label: const Text('Calificar'),
                )
              else
                Text(
                  item.finalizado
                      ? 'Esperando calificación'
                      : 'En curso',
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white70
                        : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatedBadge(int nota, bool isDarkMode) {
    final textColor =
        isDarkMode ? Colors.white : AppColors.textSecondary;
    final ratingText = nota > 0 ? '$nota/5' : 'N/A';

    return Row(
      children: [
        Text(
          'Ya calificado',
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.amber.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.amber.withOpacity(0.6),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.star,
                color: AppColors.amber,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                ratingText,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _goToReview(ContratoItem item) async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para calificar.')),
      );
      return;
    }

    final submitted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RateServiceScreen(
          servicioId: item.servicio.id,
          servicioNombre: item.servicio.nombre,
        ),
      ),
    );

    if (submitted == true) {
      _loadData(); // refrescar para actualizar estado
    }
  }

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  String _fmtHour(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
