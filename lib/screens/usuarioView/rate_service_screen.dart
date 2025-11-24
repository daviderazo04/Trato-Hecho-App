import 'dart:ui';
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
        backgroundColor:
            isDarkMode ? AppColors.backgroundDark : AppColors.primary,
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
    final result = await _contratacionService.calificar(
      userId: userId,
      servicioId: widget.servicioId,
      nota: _nota,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } else {
      // Mensaje específico de calificación repetida
      if (result.message.toLowerCase().contains('ya ha calificado')) {
        _showAlreadyRatedDialog(result.message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showAlreadyRatedDialog(String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black54,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: curved,
              child: Center(
                child: Container(
                  width: 320,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2B6EA3), Color(0xFF1FA5E8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 62,
                        width: 62,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.18),
                        ),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFF1FA5E8),
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ya calificaste este servicio previamente',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Solo puedes calificar una vez cada servicio.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.9),
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1FA5E8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Entendido',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
