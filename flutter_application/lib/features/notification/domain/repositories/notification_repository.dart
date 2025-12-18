import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/notification/domain/entities/notification_item.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationItem>>> getNotifications(String userId);
  Future<Either<Failure, void>> markAsRead(String notificationId);
}
