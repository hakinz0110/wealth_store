import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/supabase_service.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';
import 'package:wealth_app/shared/models/app_notification.dart';

part 'notification_repository.g.dart';

class NotificationRepository {
  final SupabaseClient _client;

  NotificationRepository(this._client);

  Future<List<AppNotification>> getNotifications(String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response.map((json) => AppNotification.fromJson(json)).toList();
    } catch (e) {
      throw DataException('Failed to load notifications: $e');
    }
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false)
          .count();
      
      return response.count;
    } catch (e) {
      throw DataException('Failed to get unread count: $e');
    }
  }

  Future<void> markAsRead(int notificationId, String userId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', userId);
    } catch (e) {
      throw DataException('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw DataException('Failed to mark all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(int notificationId, String userId) async {
    try {
      await _client
          .from('notifications')
          .delete()
          .eq('id', notificationId)
          .eq('user_id', userId);
    } catch (e) {
      throw DataException('Failed to delete notification: $e');
    }
  }

  Future<void> deleteAllNotifications(String userId) async {
    try {
      await _client
          .from('notifications')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      throw DataException('Failed to delete all notifications: $e');
    }
  }

  // Subscribe to real-time notifications
  RealtimeChannel subscribeToNotifications(String userId, Function(AppNotification) onNotification) {
    final channel = _client
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            final notification = AppNotification.fromJson(payload.newRecord);
            onNotification(notification);
          },
        );
    
    channel.subscribe();
    
    return channel;
  }
}

@riverpod
NotificationRepository notificationRepository(NotificationRepositoryRef ref) {
  return NotificationRepository(ref.watch(supabaseProvider));
} 