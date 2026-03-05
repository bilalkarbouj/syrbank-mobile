import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bank_app/core/socket/socket_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationData {
  final String id;
  final String type;
  final String message;
  final Map<String, dynamic> raw;
  final DateTime date;
  bool isRead;

  NotificationData({
    required this.id,
    required this.type,
    required this.message,
    required this.raw,
    required this.date,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'message': message,
    'raw': raw,
    'date': date.toIso8601String(),
    'isRead': isRead,
  };

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      NotificationData(
        id: json['id'],
        type: json['type'],
        message: json['message'],
        raw: Map<String, dynamic>.from(json['raw']),
        date: DateTime.parse(json['date']),
        isRead: json['isRead'],
      );
}

class NotificationListNotifier extends StateNotifier<List<NotificationData>> {
  NotificationListNotifier() : super([]) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('notif_history');
    if (saved != null) {
      final List decoded = jsonDecode(saved);
      state = decoded.map((e) => NotificationData.fromJson(e)).toList();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'notif_history',
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
  }

  void addNotification(NotificationData data) {
    state = [data, ...state];
    _save();
  }

  void markAllAsRead() {
    if (state.any((n) => !n.isRead)) {
      // Sadece okunmamış varsa güncelle
      state = [
        for (final n in state)
          NotificationData(
            id: n.id,
            type: n.type,
            message: n.message,
            raw: n.raw,
            date: n.date,
            isRead: true,
          ),
      ];
      _save();
    }
  }

  void removeNotification(String id) {
    state = state.where((n) => n.id != id).toList();
    _save();
  }

  int get unreadCount => state.where((n) => !n.isRead).length;
}

final notificationListProvider =
    StateNotifierProvider<NotificationListNotifier, List<NotificationData>>(
      (ref) => NotificationListNotifier(),
    );

// Ayarlar için olan provider (Önceki kodunla aynı)
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, bool>((ref) {
      return NotificationSettingsNotifier();
    });

class NotificationSettingsNotifier extends StateNotifier<bool> {
  NotificationSettingsNotifier() : super(true);
  void toggle(bool value) => state = value;
}

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService(ref);
});
