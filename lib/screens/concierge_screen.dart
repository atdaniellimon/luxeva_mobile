import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../services/notification_service.dart';
import '../widgets/dynamic_notice.dart';

class ConciergeScreen extends StatelessWidget {
  final UserSession user;

  const ConciergeScreen({super.key, required this.user});

  void _handleRequestLimit(BuildContext context) {
    HapticFeedback.lightImpact();
    final controller = TextEditingController();
    final conceptController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Solicitud de Elevación de Límite', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            children: [
              const Text('Indica el límite extraordinario requerido y el concepto para autorización inmediata:'),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: controller,
                keyboardType: TextInputType.number,
                placeholder: 'Monto requerido en MXN',
                placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 13),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: conceptController,
                placeholder: 'Concepto (ej. Compra de arte, viaje)',
                placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 13),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancelar', style: TextStyle(color: LuxevaTheme.textSecondary)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          CupertinoDialogAction(
            child: const Text('Enviar Solicitud', style: TextStyle(color: LuxevaTheme.goldAccent, fontWeight: FontWeight.w600)),
            onPressed: () {
              final amt = controller.text.trim();
              Navigator.of(ctx).pop();
              if (amt.isNotEmpty) {
                HapticFeedback.heavyImpact();
                NotificationService.instance.addNotification(
                  title: 'Solicitud de Límite Recibida',
                  message: 'Tu banquero privado está evaluando la ampliación de \$${amt} MXN.',
                  type: 'security',
                );
                DynamicNotice.show(
                  context,
                  message: 'Solicitud enviada a tu Banquero Privado',
                  subtitle: 'Evaluación y respuesta prioritaria en menos de 10 minutos.',
                  icon: CupertinoIcons.sparkles,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _handleRequestCard(BuildContext context) {
    HapticFeedback.lightImpact();
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Tarjeta Física de Titanio', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text('¿Deseas solicitar la emisión y entrega personalizada de una tarjeta de titanio grabada con tu nombre?'),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancelar', style: TextStyle(color: LuxevaTheme.textSecondary)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          CupertinoDialogAction(
            child: const Text('Confirmar Envío', style: TextStyle(color: LuxevaTheme.goldAccent, fontWeight: FontWeight.w600)),
            onPressed: () {
              Navigator.of(ctx).pop();
              HapticFeedback.heavyImpact();
              NotificationService.instance.addNotification(
                title: 'Emisión de Tarjeta en Proceso',
                message: 'Tarjeta de titanio grabada para ${user.fullName} enviada a producción.',
                type: 'card',
              );
              DynamicNotice.show(
                context,
                message: 'Tarjeta en producción artesanal',
                subtitle: 'Será entregada por mensajería blindada personalizada.',
                icon: CupertinoIcons.creditcard_fill,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: LuxevaTheme.obsidianBg,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: LuxevaTheme.glassBg,
        border: Border(
          bottom: BorderSide(
            color: LuxevaTheme.borderSubtle,
            width: LuxevaTheme.hairline,
          ),
        ),
        middle: Text(
          'CONCIERGE',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: LuxevaTheme.textPrimary,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: LuxevaTheme.surfaceLayer,
                borderRadius: BorderRadius.circular(LuxevaTheme.radiusStandard),
                border: Border.all(color: LuxevaTheme.borderGold, width: LuxevaTheme.hairline),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: LuxevaTheme.goldAccent.withOpacity(0.12),
                    ),
                    child: const Icon(CupertinoIcons.sparkles, size: 22, color: LuxevaTheme.goldAccent),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'MESA PRIVADA LUXEVA',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: LuxevaTheme.textPrimary, letterSpacing: 0.5),
                            ),
                            SizedBox(width: 8),
                            Icon(CupertinoIcons.circle_fill, size: 8, color: LuxevaTheme.greenPositive),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Atención institucional y acuerdos extraordinarios 24/7',
                          style: TextStyle(fontSize: 11, color: LuxevaTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Services Group
            const Text(
              'SERVICIOS DISPONIBLES',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: LuxevaTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: LuxevaTheme.surfaceLayer,
                borderRadius: BorderRadius.circular(LuxevaTheme.radiusStandard),
                border: Border.all(color: LuxevaTheme.borderSubtle, width: LuxevaTheme.hairline),
              ),
              child: Column(
                children: [
                  _ConciergeActionRow(
                    icon: CupertinoIcons.arrow_up_circle_fill,
                    title: 'Elevación de Límite de Tarjeta',
                    subtitle: 'Autorización inmediata para compras o subastas de alto valor',
                    onTap: () => _handleRequestLimit(context),
                  ),
                  Container(height: LuxevaTheme.hairline, color: LuxevaTheme.dividerColor),
                  _ConciergeActionRow(
                    icon: CupertinoIcons.creditcard_fill,
                    title: 'Solicitud de Tarjeta Física de Titanio',
                    subtitle: 'Emisión de plástico adicional o reemplazo por mensajería blindada',
                    onTap: () => _handleRequestCard(context),
                  ),
                  Container(height: LuxevaTheme.hairline, color: LuxevaTheme.dividerColor),
                  _ConciergeActionRow(
                    icon: CupertinoIcons.arrow_right_arrow_left,
                    title: 'Transferencias de Alto Monto',
                    subtitle: 'Dispersión SPEI personalizada con folio Banxico prioritario',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      DynamicNotice.show(
                        context,
                        message: 'Canal prioritario habilitado',
                        subtitle: 'Usa la pantalla de Transferencias para cualquier monto sin comisiones.',
                        icon: CupertinoIcons.checkmark_shield_fill,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Club Privileges
            const Text(
              'BENEFICIOS DE MEMBRESÍA ACTIVA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: LuxevaTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LuxevaTheme.surfaceLayer,
                borderRadius: BorderRadius.circular(LuxevaTheme.radiusStandard),
                border: Border.all(color: LuxevaTheme.borderSubtle, width: LuxevaTheme.hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'NIVEL DE SOCIO',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: LuxevaTheme.textSecondary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: LuxevaTheme.goldAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: LuxevaTheme.goldAccent.withOpacity(0.5), width: 0.5),
                        ),
                        child: Text(
                          user.tier.toUpperCase(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: LuxevaTheme.goldLight),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Custodia de capital con respaldo directo en Bóveda.\n• Asistencia de Concierge sin costo para reservas privadas y eventos.\n• Sin comisión por transferencias SPEI ni dispersiones interbancarias.',
                    style: TextStyle(fontSize: 12, color: LuxevaTheme.textSecondary, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ConciergeActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ConciergeActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        color: CupertinoColors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: LuxevaTheme.goldAccent),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: LuxevaTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: LuxevaTheme.textSecondary)),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, size: 14, color: LuxevaTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
