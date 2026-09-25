import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

class DynamicNotice {
  static void show(
    BuildContext context, {
    required String message,
    IconData icon = CupertinoIcons.checkmark_shield_fill,
    String? subtitle,
    Duration duration = const Duration(seconds: 3),
  }) {
    HapticFeedback.lightImpact();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _DynamicNoticeWidget(
        message: message,
        subtitle: subtitle,
        icon: icon,
        onDismiss: () {
          entry.remove();
        },
        duration: duration,
      ),
    );

    overlay.insert(entry);
  }
}

class _DynamicNoticeWidget extends StatefulWidget {
  final String message;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onDismiss;
  final Duration duration;

  const _DynamicNoticeWidget({
    required this.message,
    this.subtitle,
    required this.icon,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_DynamicNoticeWidget> createState() => _DynamicNoticeWidgetState();
}

class _DynamicNoticeWidgetState extends State<_DynamicNoticeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();

    _dismissTimer = Timer(widget.duration, () async {
      if (mounted) {
        await _controller.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              _dismissTimer?.cancel();
              await _controller.reverse();
              widget.onDismiss();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xEB131317),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: LuxevaTheme.borderGold.withOpacity(0.4),
                  width: 0.8,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: LuxevaTheme.goldAccent.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(widget.icon, size: 16, color: LuxevaTheme.goldAccent),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.message,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: LuxevaTheme.textPrimary,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: LuxevaTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
