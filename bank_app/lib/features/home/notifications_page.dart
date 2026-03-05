import 'package:bank_app/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotificationGroup { today, yesterday, older }

NotificationGroup getGroup(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final d = DateTime(date.year, date.month, date.day);

  if (d == today) return NotificationGroup.today;
  if (d == yesterday) return NotificationGroup.yesterday;
  return NotificationGroup.older;
}

String groupTitle(NotificationGroup g) {
  switch (g) {
    case NotificationGroup.today:
      return "Bugün";
    case NotificationGroup.yesterday:
      return "Dün";
    case NotificationGroup.older:
      return "Daha Eski";
  }
}

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationListProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationListProvider.notifier).markAllAsRead();
    });

    if (notifications.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Bildirimler")),
        body: const Center(child: Text("Henüz bildiriminiz yok")),
      );
    }

    // 🔹 GRUPLA
    final Map<NotificationGroup, List<NotificationData>> grouped = {};

    for (final n in notifications) {
      final group = getGroup(n.date);
      grouped.putIfAbsent(group, () => []).add(n);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Bildirimler"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _groupHeader(entry.key),
              const SizedBox(height: 12),
              ...entry.value.map(
                (n) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NotificationCard(notification: n),
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _groupHeader(NotificationGroup group) {
    return Text(
      groupTitle(group),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationData notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTransfer = notification.type == "TRANSFER_RECEIVED";

    return Container(
      decoration: BoxDecoration(
        color: notification.isRead
            ? theme.cardColor
            : theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            width: 4,
            color: isTransfer ? Colors.green : theme.colorScheme.primary,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isTransfer
                  ? Colors.green.withOpacity(0.15)
                  : theme.colorScheme.primary.withOpacity(0.15),
              child: Icon(
                isTransfer ? Icons.south_west : Icons.notifications,
                color: isTransfer ? Colors.green : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.message,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(notification.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return "${d.day}/${d.month} "
        "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }
}

Widget _deleteBg() => Container(
  alignment: Alignment.centerRight,
  padding: const EdgeInsets.only(right: 20),
  decoration: BoxDecoration(
    color: Colors.red,
    borderRadius: BorderRadius.circular(16),
  ),
  child: const Icon(Icons.delete, color: Colors.white),
);

Widget _emptyState() => const Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.notifications_off, size: 72, color: Colors.grey),
      SizedBox(height: 16),
      Text(
        "Henüz bildiriminiz yok",
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    ],
  ),
);

String _formatDate(DateTime date) {
  return "${date.day}/${date.month}/${date.year} "
      "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
}
