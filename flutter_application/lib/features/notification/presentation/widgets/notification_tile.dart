import 'package:flutter/material.dart';
import 'package:flutter_application/features/notification/domain/entities/notification_item.dart';
import 'package:intl/intl.dart';

class NotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'budget_alert':
        iconData = Icons.warning_amber_rounded;
        iconColor = Colors.orange;
        break;
      case 'mission_alert':
        iconData = Icons.emoji_events_outlined;
        iconColor = Colors.purple;
        break;
      case 'daily_reminder':
        iconData = Icons.alarm;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.notifications_none;
        iconColor = Colors.grey;
    }

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(iconData, color: iconColor),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.body),
          const SizedBox(height: 4),
          Text(
            DateFormat('dd MMM yyyy HH:mm').format(notification.createdAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      trailing: !notification.isRead
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
