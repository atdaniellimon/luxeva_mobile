import 'package:flutter/cupertino.dart';
import '../config/theme.dart';
import '../models/user.dart';

class LuxuryCardWidget extends StatelessWidget {
  final UserSession user;
  final String? customCardNumber;
  final String? cvv;
  final bool showSensitive;
  final bool isFrozen;

  const LuxuryCardWidget({
    super.key,
    required this.user,
    this.customCardNumber,
    this.cvv,
    this.showSensitive = false,
    this.isFrozen = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayNumber = showSensitive && customCardNumber != null
        ? '${customCardNumber!.substring(0, 4)}  ${customCardNumber!.substring(4, 8)}  ${customCardNumber!.substring(8, 12)}  ${customCardNumber!.substring(12, 16)}'
        : user.maskedAccount;

    return AspectRatio(
      aspectRatio: 1.586, // ISO/IEC 7810 ID-1 standard ratio
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LuxevaTheme.radiusCard),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isFrozen
                ? [
                    const Color(0xFF1C1315),
                    const Color(0xFF130C0E),
                    const Color(0xFF0C0708),
                  ]
                : [
                    const Color(0xFF222329),
                    const Color(0xFF16171C),
                    const Color(0xFF0E0F12),
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
          border: Border.all(
            color: isFrozen
                ? LuxevaTheme.redNegative.withOpacity(0.4)
                : LuxevaTheme.borderGold.withOpacity(0.3),
            width: LuxevaTheme.hairline,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x60000000),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: EMV Chip and LUXEVA wordmark
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Flat Architectural EMV Chip
                  Container(
                    width: 40,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC0A86A),
                      borderRadius: BorderRadius.circular(5),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE2D7B8),
                          Color(0xFFCBBD93),
                          Color(0xFFA8996C),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 28,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0x35000000), width: 0.8),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),

                  // Brand Wordmark
                  Row(
                    children: [
                      if (isFrozen) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: LuxevaTheme.redNegative.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PAUSADA',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: LuxevaTheme.redNegative,
                            ),
                          ),
                        ),
                      ],
                      const Text(
                        'LUXEVA',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3.5,
                          color: LuxevaTheme.goldLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Card Number (Laser-etched optical monospace)
              Text(
                displayNumber,
                style: LuxevaTheme.cardLaserNumber(
                  fontSize: 16,
                  color: LuxevaTheme.textPrimary,
                ),
              ),

              // Bottom Row: Cardholder Name, Expiry and CVV
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TITULAR ACREDITADO',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: LuxevaTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user.fullName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: LuxevaTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'VENCE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: LuxevaTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '12/29',
                            style: LuxevaTheme.tabularFigures(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: LuxevaTheme.goldAccent,
                            ),
                          ),
                        ],
                      ),
                      if (showSensitive && cvv != null) ...[
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'CVV',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: LuxevaTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              cvv!,
                              style: LuxevaTheme.tabularFigures(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: LuxevaTheme.goldAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
