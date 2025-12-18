import 'package:equatable/equatable.dart';

class NotificationItem extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // 'budget_alert', 'mission_alert', 'daily_reminder', 'system'
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, title, body, type, isRead, createdAt];
}
