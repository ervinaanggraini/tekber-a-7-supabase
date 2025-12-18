import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/notification/data/data_sources/notification_remote_data_source.dart';
import 'package:flutter_application/features/notification/domain/entities/notification_item.dart';
import 'package:flutter_application/features/notification/domain/repositories/notification_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<NotificationItem>>> getNotifications(String userId) async {
    try {
      final result = await remoteDataSource.getNotifications(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
