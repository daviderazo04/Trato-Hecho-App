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

  List<_FaqItem> get _clientFaqs => const [
        _FaqItem(
          question: '¿Cómo contrato un servicio?',
          answer:
              'Abre el chat con el proveedor desde la app, pide la oferta o paquete que necesitas y confirma fecha, horario y condiciones. Paga dentro de la app para reservar.',
        ),
        _FaqItem(
          question: '¿Puedo pedir una oferta personalizada?',
          answer:
              'Sí. Envía por chat fecha, horario, aforo, dirección y lo que requieres (equipo de sonido, repertorio, temática, extras). El proveedor te enviará la oferta ajustada.',
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
              'Depende de la política de cancelación o reagendamiento del proveedor. Escríbele por el chat y solicita nueva fecha; podrían aplicar diferencias de tarifa.',
        ),
        _FaqItem(
          question: '¿Qué pasa si el proveedor no llega (no-show)?',
          answer:
              'Aplicamos las políticas de la plataforma: puedes pedir devolución y dejar tu reseña. Revisa las condiciones de cancelación y evidencias en el chat.',
        ),
        _FaqItem(
          question: '¿Cómo elijo al mejor proveedor?',
          answer:
              'Revisa reseñas, portafolio (fotos/videos), tiempos de respuesta y si tiene Sello Verificado. Compara precios y lo que incluye cada oferta.',
        ),
        _FaqItem(
          question: '¿Qué hago si me piden pagar por fuera de la app?',
          answer:
              'No aceptes. Paga solo por la app para estar protegido. Reporta el mensaje en el chat.',
        ),
        _FaqItem(
          question: '¿Cuándo se libera el pago al proveedor?',
          answer:
              'Tras el check-out o cuando termina la ventana de confirmación del cliente, según el método de pago.',
        ),
        _FaqItem(
          question: '¿Debemos dejar todo por escrito en la app?',
          answer:
              'Sí. Usa el chat para acordar dirección, horarios, setlist, equipo, extras y políticas. Así queda registro ante cualquier disputa.',
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
          question: '¿Puedo trabajar fuera de mi ciudad?',
          answer:
              'Sí. Define tu zona de cobertura, viáticos y tiempos de traslado en tu oferta.',
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
              'Completa perfil, sube portafolio, responde rápido, mantén buen rating y obtén el Sello Verificado (identidad y datos validados).',
        ),
        _FaqItem(
          question: '¿Cómo manejo requisitos técnicos?',
          answer:
              'Incluye en tu oferta un checklist de sonido, electricidad, escenario y montaje. Confírmalo en el chat antes del evento.',
        ),
        _FaqItem(
          question: '¿Puedo agregar asistentes o staff?',
          answer:
              'Sí, si tu categoría lo permite. Deben cumplir reglas de la comunidad y, si aplica, también ser verificados.',
        ),
        _FaqItem(
          question: '¿Qué es el Sello de Proveedor Verificado?',
          answer:
              'Un distintivo por validar cédula + selfie, correo/teléfono, antecedentes y (opcional) domicilio. Activa también 2FA.',
        ),
        _FaqItem(
          question: '¿Puedo usar la app si soy menor de edad?',
          answer:
              'No. El modo proveedor es solo para mayores de edad con documento vigente.',
        ),
        _FaqItem(
          question: '¿Puedo subir fotos/videos del evento?',
          answer:
              'Sí, con permiso del cliente. Revisa derechos de imagen y créditos si compartes material promocional.',
        ),
        _FaqItem(
          question: '¿Cómo mejoro mi perfil?',
          answer:
              'Foto clara, bio breve, categorías correctas, portafolio, precios transparentes, políticas visibles y tiempo de respuesta bajo.',
        ),
      ];

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
            _Header(
              isDarkMode: isDarkMode,
              onBack: () => Navigator.pop(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _SegmentedSwitch(
                isClient: _isClient,
                onChanged: (value) {
                  setState(() => _isClient = value);
                },
                isDarkMode: isDarkMode,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemBuilder: (context, index) {
                  final item = faqs[index];
                  return _FaqTile(
                    question: item.question,
                    answer: item.answer,
                    isDarkMode: isDarkMode,
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemCount: faqs.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.isDarkMode,
    required this.onBack,
  });

  final bool isDarkMode;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final Color barColor =
        isDarkMode ? AppColors.darkButtons : AppColors.primary;
    final Color iconColor = isDarkMode ? Colors.white : Colors.white;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 14),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: barColor),
              onPressed: onBack,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Preguntas Frecuentes',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          Icon(Icons.help_outline, color: iconColor),
        ],
      ),
    );
  }
}

class _SegmentedSwitch extends StatelessWidget {
  const _SegmentedSwitch({
    required this.isClient,
    required this.onChanged,
    required this.isDarkMode,
  });

  final bool isClient;
  final ValueChanged<bool> onChanged;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final Color activeColor =
        isDarkMode ? Colors.white : AppColors.primary.withOpacity(0.9);
    final Color inactiveColor =
        isDarkMode ? AppColors.darkButtons : Colors.grey.shade200;
    final Color textColor =
        isDarkMode ? AppColors.darkText : AppColors.textPrimary;

    return Container(
      decoration: BoxDecoration(
        color: inactiveColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _SegmentButton(
            label: 'Clientes',
            selected: isClient,
            onTap: () => onChanged(true),
            activeColor: activeColor,
            textColor: textColor,
          ),
          _SegmentButton(
            label: 'Proveedores',
            selected: !isClient,
            onTap: () => onChanged(false),
            activeColor: activeColor,
            textColor: textColor,
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.activeColor,
    required this.textColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

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
      ],
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}
