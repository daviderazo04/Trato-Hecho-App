import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/appColors.dart';
import '../../config/theme_provider.dart';
import '../../config/user_provider.dart';
import '../../services/contratacion_service.dart';

class ContratarServicioScreen extends StatefulWidget {
  const ContratarServicioScreen({
    super.key,
    required this.serviceId,
    this.serviceName,
    this.serviceImage,
    this.fallbackPrice,
  });

  final int serviceId;
  final String? serviceName;
  final String? serviceImage;
  final double? fallbackPrice;

  @override
  State<ContratarServicioScreen> createState() =>
      _ContratarServicioScreenState();
}

class _ContratarServicioScreenState extends State<ContratarServicioScreen> {
  final ContratacionService _contratacionService = ContratacionService();
  ServiceInfo? _serviceInfo;
  bool _loadingInfo = true;
  bool _submitting = false;
  String? _infoError;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    _loadServiceInfo();
  }

  Future<void> _loadServiceInfo() async {
    final info = await _contratacionService.getServiceInfo(widget.serviceId);
    if (!mounted) return;

    // Si no se pudo cargar, usamos el precio de respaldo si viene desde la pantalla anterior
    final resolvedInfo = info ??
        (widget.fallbackPrice != null
            ? ServiceInfo(
                nombre: widget.serviceName ?? 'Servicio',
                precio: widget.fallbackPrice!,
              )
            : null);

    setState(() {
      _serviceInfo = resolvedInfo;
      _loadingInfo = false;
      _infoError = resolvedInfo == null ? 'No se pudo cargar la información.' : null;
    });
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    if (_submitting) return;
    final now = DateTime.now();
    final initial = isStart
        ? (_fechaInicio ?? now)
        : (_fechaFin ?? _fechaInicio ?? now.add(const Duration(hours: 1)));

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _fechaInicio = combined;
        // Si la fecha fin es anterior, la limpiamos para evitar inconsistencias
        if (_fechaFin != null && _fechaFin!.isBefore(combined)) {
          _fechaFin = null;
        }
      } else {
        _fechaFin = combined;
      }
    });
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Selecciona fecha y hora';
    final timeOfDay = TimeOfDay.fromDateTime(dateTime);
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    return '${dateTime.year}-${twoDigits(dateTime.month)}-${twoDigits(dateTime.day)} '
        '${twoDigits(timeOfDay.hour)}:${twoDigits(timeOfDay.minute)}';
  }

  Future<void> _confirmar() async {
    if (_submitting) return;
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para contratar.')),
      );
      return;
    }
    if (_fechaInicio == null || _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha de inicio y fin.')),
      );
      return;
    }
    if (!_fechaInicio!.isBefore(_fechaFin!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('La fecha de inicio debe ser antes que la de fin.')),
      );
      return;
    }

    setState(() => _submitting = true);
    _showLoader();

    final result = await _contratacionService.contratar(
      userId: userId,
      servicioId: widget.serviceId,
      fechaInicio: _fechaInicio!,
      fechaFin: _fechaFin!,
    );

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop(); // Cierra loader
    setState(() => _submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? AppColors.success : AppColors.error,
      ),
    );

    if (result.success) {
      Navigator.pop(context, true);
    }
  }

  void _showLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hacer un trato'),
        backgroundColor:
            isDarkMode ? AppColors.backgroundDark : AppColors.backgroundWhite,
        iconTheme:
            IconThemeData(color: isDarkMode ? Colors.white : AppColors.borders),
        titleTextStyle: TextStyle(
          color: isDarkMode ? Colors.white : AppColors.borders,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        elevation: 0,
      ),
      backgroundColor:
          isDarkMode ? AppColors.backgroundDark : AppColors.backgroundWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _loadingInfo
              ? const Center(child: CircularProgressIndicator())
              : _infoError != null
                  ? Center(
                      child: Text(
                        _infoError!,
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.white70 : AppColors.textPrimary,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildServiceHeader(isDarkMode),
                        const SizedBox(height: 20),
                        Text(
                          'Selecciona el rango de fecha y hora',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSelector(
                          label: 'Fecha y hora de inicio',
                          value: _formatDateTime(_fechaInicio),
                          isDarkMode: isDarkMode,
                          onTap: () => _pickDateTime(isStart: true),
                        ),
                        const SizedBox(height: 12),
                        _buildSelector(
                          label: 'Fecha y hora de fin',
                          value: _formatDateTime(_fechaFin),
                          isDarkMode: isDarkMode,
                          onTap: () => _pickDateTime(isStart: false),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _confirmar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.notificacion,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _submitting ? 'Verificando...' : 'Confirmar',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildServiceHeader(bool isDarkMode) {
    final info = _serviceInfo;
    if (info == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkButtons : AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage:
                widget.serviceImage != null ? NetworkImage(widget.serviceImage!) : null,
            backgroundColor:
                widget.serviceImage == null ? Colors.grey[300] : Colors.transparent,
            child: widget.serviceImage == null
                ? const Icon(Icons.handshake, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.serviceName ?? info.nombre,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Precio: \$${info.precio.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : AppColors.gray,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelector({
    required String label,
    required String value,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : AppColors.gray,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkButtons : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDarkMode ? AppColors.darkBorders : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color:
                          isDarkMode ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
