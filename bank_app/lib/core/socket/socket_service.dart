import 'package:bank_app/core/config/app_config.dart';
import 'package:bank_app/core/notification/local_notification_service.dart';
import 'package:bank_app/providers/auth_provider.dart';
import 'package:bank_app/providers/notification_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  final Ref ref; // ✅ RIVERPOD REF

  IO.Socket? _socket;

  SocketService(this.ref);

  void connect({required String accountNo, required String token}) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      AppConfig.apiBaseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({"Authorization": "Bearer $token"})
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint("🟢 Socket connected");
      _socket!.emit("join", accountNo);
    });

    _socket!.onReconnect((_) {
      debugPrint("🔄 Socket reconnected");
      _socket!.emit("join", accountNo);
    });

    _socket!.on("balance:update", (data) {
      final newBalance = (data["balance"] as num).toDouble();
      ref.read(authProvider.notifier).updateBalanceFromSocket(newBalance);
    });

    _socket!.on("notification", (data) {
      debugPrint("📩 Bildirim geldi: $data");
      _handleNotification(data);
    });

    _socket!.onDisconnect((_) {
      debugPrint("🔴 Socket disconnected");
    });
  }

  void _handleNotification(dynamic data) {
    if (data["type"] == "TRANSFER_RECEIVED") {
      final message = "${data["name"]} kişisinden ${data["amount"]} TL geldi";

      // 🛑 AYAR KONTROLÜ: Kullanıcı bildirimleri kapatmış mı?
      // notificationEnabledProvider: Senin daha önce yazdığın bool tutan provider
      final bool isNotifyEnabled = ref.read(notificationSettingsProvider);

      if (isNotifyEnabled) {
        // 🔔 Sadece ayar AÇIKSA sistem bildirimi gönder
        LocalNotificationService.show(title: "💸 Havale Alındı", body: message);
      }

      // 🔄 UI için provider'ı güncelle (Ayar kapalı olsa bile snackbar veya
      // uygulama içi bildirim listesinde görünmesi için if dışına koyabilirsin)
      ref
          .read(notificationListProvider.notifier)
          .addNotification(
            NotificationData(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: data["type"],
              message: message,
              raw: Map<String, dynamic>.from(data),
              date: DateTime.now(),
            ),
          );
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
