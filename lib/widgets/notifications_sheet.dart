import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../services/notification_service.dart';

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.lightImpact();
    // Mark notifications as read
    NotificationService.instance.markAllAsRead();

    return showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => const NotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: LuxevaTheme.surfaceLayer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(LuxevaTheme.continuousRadius)),
        border: Border(
          top: BorderSide(color: LuxevaTheme.borderGold, width: LuxevaTheme.hairline),
        ),
      ),
      child: Column(
        children: [
          // Drag indicator pill
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0x30FFFFFF),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(CupertinoIcons.bell_fill, size: 18, color: LuxevaTheme.goldAccent),
                    SizedBox(width: 8),
                    Text(
                      'NOTIFICACIONES',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: LuxevaTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text(
                    'Limpiar',
                    style: TextStyle(fontSize: 13, color: LuxevaTheme.textSecondary),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    NotificationService.instance.clearAll();
                  },
                ),
              ],
            ),
          ),

          Container(
            height: LuxevaTheme.hairline,
            color: LuxevaTheme.borderSubtle,
          ),

          // Notification List
          Expanded(
            child: ValueListenableBuilder<List<LuxevaNotification>>(
              valueListenable: NotificationService.instance.notifications,
              builder: (context, notifs, _) {
                if (notifs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.bell_slash, size: 36, color: LuxevaTheme.textSecondary),
                        SizedBox(height: 12),
                        Text(
                          'SIN NOTIFICACIONES PENDIENTES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: LuxevaTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: notifs.length,
                  separatorBuilder: (_, __) => Container(
                    height: LuxevaTheme.hairline,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: LuxevaTheme.dividerColor,
                  ),
                  itemBuilder: (context, idx) {
                    final item = notifs[idx];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _iconBgForType(item.type),
                            ),
                            child: Icon(
                              _iconForType(item.type),
                              size: 16,
                              color: _iconColorForType(item.type),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: LuxevaTheme.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      _formatTime(item.timestamp),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: LuxevaTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.message,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: LuxevaTheme.textSecondary,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconForType(String type) {
    switch (type) {
      case 'deposit':
        return CupertinoIcons.arrow_down_left;
      case 'transfer':
        return CupertinoIcons.arrow_up_right;
      case 'cash':
        return CupertinoIcons.money_dollar_circle;
      case 'card':
        return CupertinoIcons.creditcard;
      default:
        return CupertinoIcons.shield_fill;
    }
  }

  static Color _iconColorForType(String type) {
    switch (type) {
      case 'deposit':
        return LuxevaTheme.greenPositive;
      case 'transfer':
        return LuxevaTheme.goldLight;
      case 'cash':
        return LuxevaTheme.goldAccent;
      case 'card':
        return LuxevaTheme.goldAccent;
      default:
        return LuxevaTheme.textSecondary;
    }
  }

  static Color _iconBgForType(String type) {
    switch (type) {
      case 'deposit':
        return LuxevaTheme.greenPositive.withOpacity(0.12);
      case 'transfer':
      case 'cash':
      case 'card':
        return LuxevaTheme.goldAccent.withOpacity(0.12);
      default:
        return const Color(0x18FFFFFF);
    }
  }

  static String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${dt.day}/${dt.month}';
  }
}
