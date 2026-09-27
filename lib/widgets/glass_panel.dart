import 'dart:ui';
import 'package:flutter/cupertino.dart';
import '../config/theme.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final bool hasGoldBorder;
  final Color? borderColor;
  final Color? backgroundColor;
  final double blurSigma;
  final double borderWidth;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin = EdgeInsets.zero,
    this.borderRadius = LuxevaTheme.continuousRadius,
    this.hasGoldBorder = false,
    this.borderColor,
    this.backgroundColor,
    this.blurSigma = LuxevaTheme.liquidBlur,
    this.borderWidth = LuxevaTheme.hairline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? LuxevaTheme.glassBg,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? (hasGoldBorder ? LuxevaTheme.borderGold : LuxevaTheme.borderSubtle),
                width: borderWidth,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
