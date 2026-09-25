import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../theme/luxeva_theme.dart';

class LuxuryCardWidget extends StatefulWidget {
  final UserSession session;
  const LuxuryCardWidget({super.key, required this.session});

  @override
  State<LuxuryCardWidget> createState() => _LuxuryCardWidgetState();
}

class _LuxuryCardWidgetState extends State<LuxuryCardWidget> {
  bool _showCvv = false;
  String _cvv = '849';

  void _regenerateCvv() {
    HapticFeedback.mediumImpact();
    setState(() {
      _showCvv = !_showCvv;
      if (_showCvv) {
        _cvv = (100 + (DateTime.now().millisecond % 899)).toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 215,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF26262E),
            Color(0xFF141418),
            Color(0xFF0A0A0D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: LuxevaTheme.borderGold,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 32,
            offset: Offset(0, 16),
          ),
          BoxShadow(
            color: Color(0x1ACBBD93),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Metallic Chip
              Container(
                width: 44,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDFD4B3), Color(0xFFCBBD93), Color(0xFF9E8B5B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF5E5437), width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(width: 1, color: const Color(0x66000000)),
                    Container(width: 1, color: const Color(0x66000000)),
                  ],
                ),
              ),
              const Text(
                'LUXEVA',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: LuxevaTheme.accentGold,
                ),
              ),
            ],
          ),
          // Account / Card number
          Text(
            '•••• •••• •••• ${widget.session.lastFourDigits}',
            style: const TextStyle(
              fontSize: 19,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
              color: LuxevaTheme.textPrimary,
              fontFamily: 'Courier',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TITULAR ACREDITADO',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                      color: LuxevaTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.session.fullName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                      color: LuxevaTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _regenerateCvv,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0x1ACBBD93),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: LuxevaTheme.borderGold, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.lock_shield,
                        size: 13,
                        color: LuxevaTheme.accentGold,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _showCvv ? 'CVV $_cvv' : 'CVV DINÁMICO',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: LuxevaTheme.accentGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
