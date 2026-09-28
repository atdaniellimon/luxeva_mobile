import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../widgets/dynamic_notice.dart';

class DocumentsScreen extends StatelessWidget {
  final UserSession user;

  const DocumentsScreen({super.key, required this.user});

  void _handleDownload(BuildContext context, String filename, String label) {
    HapticFeedback.lightImpact();
    DynamicNotice.show(
      context,
      message: 'Documento listo',
      subtitle: '$label descargado correctamente',
      icon: CupertinoIcons.arrow_down_doc,
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
          'DOCUMENTOS',
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            // Section 1: Estados de Cuenta
            const Text(
              'ESTADOS DE CUENTA MENSUALES',
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
                  _DocumentRow(
                    title: 'Septiembre 2026',
                    period: '01 Sep – 30 Sep 2026',
                    onDownload: () => _handleDownload(context, 'luxeva_ec_2026_09.pdf', 'Septiembre 2026'),
                  ),
                  Container(height: LuxevaTheme.hairline, color: LuxevaTheme.dividerColor),
                  _DocumentRow(
                    title: 'Agosto 2026',
                    period: '01 Ago – 31 Ago 2026',
                    onDownload: () => _handleDownload(context, 'luxeva_ec_2026_08.pdf', 'Agosto 2026'),
                  ),
                  Container(height: LuxevaTheme.hairline, color: LuxevaTheme.dividerColor),
                  _DocumentRow(
                    title: 'Julio 2026',
                    period: '01 Jul – 31 Jul 2026',
                    onDownload: () => _handleDownload(context, 'luxeva_ec_2026_07.pdf', 'Julio 2026'),
                  ),
                  Container(height: LuxevaTheme.hairline, color: LuxevaTheme.dividerColor),
                  _DocumentRow(
                    title: 'Junio 2026',
                    period: '01 Jun – 30 Jun 2026',
                    onDownload: () => _handleDownload(context, 'luxeva_ec_2026_06.pdf', 'Junio 2026'),
                  ),
                  Container(height: LuxevaTheme.hairline, color: LuxevaTheme.dividerColor),
                  _DocumentRow(
                    title: 'Mayo 2026',
                    period: '01 May – 31 May 2026',
                    onDownload: () => _handleDownload(context, 'luxeva_ec_2026_05.pdf', 'Mayo 2026'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Section 2: Constancias y Certificados
            const Text(
              'CONSTANCIAS Y CERTIFICACIONES',
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
                  _DocumentRow(
                    title: 'Constancia de Titularidad',
                    period: 'Cuenta ${user.accountNumber} • Membretada',
                    onDownload: () => _handleDownload(context, 'luxeva_titularidad.pdf', 'Constancia de Titularidad'),
                  ),
                  Container(height: LuxevaTheme.hairline, color: LuxevaTheme.dividerColor),
                  _DocumentRow(
                    title: 'Constancia Fiscal Anual (SAT)',
                    period: 'Ejercicio Fiscal 2025 • Retenciones',
                    onDownload: () => _handleDownload(context, 'luxeva_fiscal_2025.pdf', 'Constancia Fiscal 2025'),
                  ),
                  Container(height: LuxevaTheme.hairline, color: LuxevaTheme.dividerColor),
                  _DocumentRow(
                    title: 'Contrato de Apertura de Bóveda',
                    period: 'Firma electrónica y acuerdos de custodia',
                    onDownload: () => _handleDownload(context, 'luxeva_contrato_apertura.pdf', 'Contrato de Apertura'),
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

class _DocumentRow extends StatelessWidget {
  final String title;
  final String period;
  final VoidCallback onDownload;

  const _DocumentRow({
    required this.title,
    required this.period,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: LuxevaTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  period,
                  style: const TextStyle(
                    fontSize: 11,
                    color: LuxevaTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: const Color(0x18CBBD93),
            borderRadius: BorderRadius.circular(8),
            onPressed: onDownload,
            child: const Text(
              'PDF',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: LuxevaTheme.goldLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
