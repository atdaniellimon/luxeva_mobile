import 'package:flutter/cupertino.dart';
import '../config/theme.dart';
import '../models/user.dart';

class LuxuryCardWidget extends StatelessWidget {
  final UserSession user;

  const LuxuryCardWidget({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF22222A),
            Color(0xFF141418),
            Color(0xFF0A0A0D),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        border: Border.all(
          color: LuxevaTheme.borderGold,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
          BoxShadow(
            color: Color(0x1ACBBD93),
            blurRadius: 10,
            spreadRadius: -2,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Metallic specular gloss overlay
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    LuxevaTheme.goldLight.withOpacity(0.12),
                    const Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row: Chip and Brand
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Gold EMV Chip
                    Container(
                      width: 42,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC0A86A),
                        borderRadius: BorderRadius.circular(6),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFDFD4B3),
                            Color(0xFFCBBD93),
                            Color(0xFFA69668),
                          ],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 32,
                          height: 22,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0x40000000), width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'LUXEVA',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.5,
                        color: LuxevaTheme.goldLight,
                      ),
                    ),
                  ],
                ),

                // Card Number
                Text(
                  user.maskedAccount,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                    color: LuxevaTheme.textPrimary,
                  ),
                ),

                // Bottom row: Member Name and Tier
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
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: LuxevaTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'VENCE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: LuxevaTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '12/29',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: LuxevaTheme.goldAccent.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
