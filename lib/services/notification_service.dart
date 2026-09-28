import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LuxevaNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type; // 'deposit', 'transfer', 'cash', 'card', 'security'
  final bool isRead;

  const LuxevaNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.type = 'security',
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'type': type,
        'isRead': isRead,
      };

  factory LuxevaNotification.fromJson(Map<String, dynamic> json) => LuxevaNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
        type: json['type'] as String? ?? 'security',
        isRead: json['isRead'] as bool? ?? false,
      );

  LuxevaNotification copyWith({bool? isRead}) => LuxevaNotification(
        id: id,
        title: title,
        message: message,
        timestamp: timestamp,
        type: type,
        isRead: isRead ?? this.isRead,
      );
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  static const String _storageKey = 'luxeva_offline_notifications_v1';

  final ValueNotifier<List<LuxevaNotification>> notifications =
      ValueNotifier<List<LuxevaNotification>>([]);

  int get unreadCount => notifications.value.where((n) => !n.isRead).length;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = jsonDecode(raw);
        notifications.value = decoded.map((item) => LuxevaNotification.fromJson(item)).toList();
      } else {
        // Seed default institutional welcome notification if empty
        notifications.value = [
          LuxevaNotification(
            id: 'init_welcome',
            title: 'Bóveda Luxeva Activa',
            message: 'Tu sesión bancaria institucional está protegida con Secure Enclave y STP Rail 24/7.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            type: 'security',
            isRead: false,
          ),
        ];
        await _save();
      }
    } catch (_) {}
  }

  Future<void> addNotification({
    required String title,
    required String message,
    String type = 'security',
  }) async {
    final newItem = LuxevaNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
    );

    notifications.value = [newItem, ...notifications.value];
    await _save();
  }

  Future<void> markAllAsRead() async {
    notifications.value = notifications.value.map((n) => n.copyWith(isRead: true)).toList();
    await _save();
  }

  Future<void> clearAll() async {
    notifications.value = [];
    await _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(notifications.value.map((n) => n.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }
}
