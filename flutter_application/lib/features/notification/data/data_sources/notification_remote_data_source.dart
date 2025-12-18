import 'package:flutter_application/features/notification/data/models/notification_item_model.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationItemModel>> getNotifications(String userId);
  Future<void> markAsRead(String notificationId);
}

@LazySingleton(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient supabaseClient;

  NotificationRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<NotificationItemModel>> getNotifications(String userId) async {
    final response = await supabaseClient
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => NotificationItemModel.fromJson(json)).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await supabaseClient
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }
}
