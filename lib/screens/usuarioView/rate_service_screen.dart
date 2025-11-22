import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/appColors.dart';
import '../../config/theme_provider.dart';
import '../../config/user_provider.dart';
import '../../services/contratacion_service.dart';

class RateServiceScreen extends StatefulWidget {
  const RateServiceScreen({
    super.key,
    required this.servicioId,
    required this.servicioNombre,
  });

  final int servicioId;
  final String servicioNombre;

  @override
  State<RateServiceScreen> createState() => _RateServiceScreenState();
}

class _RateServiceScreenState extends State<RateServiceScreen> {
  int _nota = 5;
  bool _submitting = false;
  final ContratacionService _contratacionService = ContratacionService();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final Color background =
        isDarkMode ? AppColors.backgroundDark : AppColors.backgroundWhite;
    final Color textPrimary =
        isDarkMode ? AppColors.darkText : AppColors.textPrimary;
    final Color textSecondary =
        isDarkMode ? Colors.white70 : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calificar servicio'),
        backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.servicioNombre,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Selecciona tu calificación (1 es lo más bajo, 5 lo más alto)',
              style: TextStyle(color: textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                final active = starIndex <= _nota;
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _nota = starIndex;
                    });
                  },
                  icon: Icon(
                    active ? Icons.star : Icons.star_border,
                    color: active
                        ? Colors.amber
                        : (isDarkMode ? Colors.white38 : Colors.grey),
                    size: 32,
                  ),
                );
              }),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.notificacion,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _submitting ? 'Enviando...' : 'Enviar calificación',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para calificar.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final ok = await _contratacionService.calificar(
      userId: userId,
      servicioId: widget.servicioId,
      nota: _nota,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            ok ? 'Calificación enviada.' : 'No se pudo enviar la calificación.'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );

    if (ok) {
      Navigator.pop(context, true);
    }
  }
}
