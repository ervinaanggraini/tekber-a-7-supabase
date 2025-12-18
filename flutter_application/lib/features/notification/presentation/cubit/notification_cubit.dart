import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/notification/domain/use_cases/get_notifications_use_case.dart';
import 'package:flutter_application/features/notification/domain/use_cases/mark_notification_read_use_case.dart';
import 'package:flutter_application/features/notification/presentation/cubit/notification_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class NotificationCubit extends Cubit<NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;

  NotificationCubit(
    this.getNotificationsUseCase,
    this.markNotificationReadUseCase,
  ) : super(NotificationInitial());

  Future<void> loadNotifications(String userId) async {
    emit(NotificationLoading());
    final result = await getNotificationsUseCase(userId);
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notifications) => emit(NotificationLoaded(notifications)),
    );
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    final result = await markNotificationReadUseCase(notificationId);
    result.fold(
      (failure) => null, // Optionally handle error
      (_) => loadNotifications(userId), // Reload to update UI
    );
  }
}
