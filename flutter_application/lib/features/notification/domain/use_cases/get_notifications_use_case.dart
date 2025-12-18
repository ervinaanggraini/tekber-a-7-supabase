import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/notification/domain/entities/notification_item.dart';
import 'package:flutter_application/features/notification/domain/repositories/notification_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<NotificationItem>>> call(String userId) {
    return repository.getNotifications(userId);
  }
}
