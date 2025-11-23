import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/appColors.dart';
import '../../config/theme_provider.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  bool _isClient = true;

  // --- DATA ---
  List<_FaqItem> get _clientFaqs => const [
        _FaqItem(
          question: '¿Cómo contrato un servicio?',
          answer:
              'Abre el chat con el proveedor desde la app, pide la oferta o paquete que necesitas y confirma fecha, horario y condiciones. Paga dentro de la app para reservar.',
        ),
        _FaqItem(
          question: '¿Puedo pedir una oferta personalizada?',
          answer:
              'Sí. Envía por chat fecha, horario, aforo, dirección y lo que requieres. El proveedor te enviará la oferta ajustada.',
        ),
        _FaqItem(
          question: '¿Cómo sé si el proveedor está disponible?',
          answer:
              'Escríbele por el chat para confirmar disponibilidad en la fecha y hora que necesitas.',
        ),
        _FaqItem(
          question: '¿Qué métodos de pago aceptan?',
          answer:
              'Los que ves en la app (tarjeta, transferencia, billetera). Siempre paga dentro de la app; no hagas pagos por fuera.',
        ),
        _FaqItem(
          question: '¿Mi pago está protegido?',
          answer:
              'Sí. Usamos protección de pago (escrow): el dinero se libera al proveedor tras el check-out o cuando confirmas que el servicio se cumplió.',
        ),
        _FaqItem(
          question: '¿Puedo reprogramar mi evento?',
          answer:
              'Depende de la política de cancelación o reagendamiento del proveedor. Escríbele por el chat y solicita nueva fecha.',
        ),
        _FaqItem(
          question: '¿Qué hago si me piden pagar por fuera de la app?',
          answer:
              'No aceptes. Paga solo por la app para estar protegido. Reporta el mensaje en el chat.',
        ),
      ];

  List<_FaqItem> get _providerFaqs => const [
        _FaqItem(
          question: '¿Quién puede ser proveedor?',
          answer:
              'Personas mayores de edad con un servicio de eventos que cumpla las reglas de la comunidad.',
        ),
        _FaqItem(
          question: '¿Debo subir mi cédula?',
          answer:
              'Sí, para verificar identidad y dar confianza a clientes. Es parte del proceso de validación.',
        ),
        _FaqItem(
          question: '¿Mi información está segura?',
          answer:
              'Usamos cifrado y acceso restringido solo para verificación. No se comparte con terceros sin base legal.',
        ),
        _FaqItem(
          question: '¿Cómo envío el link para que me contraten?',
          answer:
              'Desde tu panel o evento, elige “Enviar oferta” y comparte el link de tu servicio o paquete. El cliente paga desde ese link.',
        ),
        _FaqItem(
          question: '¿Cuándo recibo mi pago?',
          answer:
              'Tras el check-out y validación (automática o en 24–72h según método). Luego puedes retirarlo a tu cuenta/billetera.',
        ),
        _FaqItem(
          question: '¿Cómo mejoro mi visibilidad?',
          answer:
              'Completa perfil, sube portafolio, responde rápido, mantén buen rating y obtén el Sello Verificado.',
        ),
        _FaqItem(
          question: '¿Qué es el Sello de Proveedor Verificado?',
          answer:
              'Un distintivo por validar cédula + selfie, correo/teléfono y antecedentes.',
        ),
      ];

  // --- HELPER COLORS ---
  Color _cardColor(bool isDark) =>
      isDark ? AppColors.darkButtons : const Color(0xFFF0F4F8);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    final Color background =
        isDarkMode ? AppColors.backgroundDark : Colors.white;
    final Color textColor =
        isDarkMode ? AppColors.darkText : AppColors.textPrimary;

    final faqs = _isClient ? _clientFaqs : _providerFaqs;
    final title = _isClient ? 'FAQ Clientes' : 'FAQ Proveedores';

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER
            _Header(
              isDarkMode: isDarkMode,
              onBack: () => Navigator.pop(context),
            ),

            const SizedBox(height: 20),

            // 2. CLIENT/PROVIDER SWITCH (Consistent Design)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: _cardColor(isDarkMode),
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(
                    color:
                        isDarkMode ? AppColors.darkBorders : Colors.transparent,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isClient ? 'Modo Cliente' : 'Modo Proveedor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.9,
                      child: Switch(
                        // If _isClient is true, switch is OFF. If false (Provider), switch is ON.
                        value: !_isClient,
                        onChanged: (value) {
                          setState(() {
                            _isClient = !value;
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: AppColors.primary,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: const Color(0xFFB0B0B0),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 3. SECTION TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 4. FAQ LIST
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                itemBuilder: (context, index) {
                  final item = faqs[index];
                  return _FaqTile(
                    question: item.question,
                    answer: item.answer,
                    isDarkMode: isDarkMode,
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemCount: faqs.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HEADER WIDGET ---
class _Header extends StatelessWidget {
  const _Header({
    required this.isDarkMode,
    required this.onBack,
  });

  final bool isDarkMode;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    // Using styles consistent with other screens
    final Color barColor = AppColors.primary;
    final Color iconColor = Colors.white;

    return Container(
      width: double.infinity,
      // Matches the padding/style of RecentDeals/Favorites headers
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.arrow_back, color: barColor, size: 18),
              onPressed: onBack,
            ),
          ),
          const SizedBox(width: 20),
          const Text(
            'Preguntas Frecuentes',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          Icon(Icons.help_outline, color: iconColor),
        ],
      ),
    );
  }
}

// --- FAQ ITEM WIDGET ---
class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.question,
    required this.answer,
    required this.isDarkMode,
  });

  final String question;
  final String answer;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final Color questionColor =
        isDarkMode ? Colors.white : AppColors.textPrimary;
    final Color answerColor =
        isDarkMode ? Colors.grey[300]! : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: questionColor,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          answer,
          style: TextStyle(
            fontSize: 14,
            color: answerColor,
            height: 1.5,
          ),
        ),
        // Add a subtle divider for better readability
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Divider(
            color: isDarkMode ? Colors.white24 : Colors.grey[300],
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}
