import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/features/auth/domain/auth_notifier.dart';
import 'package:wealth_app/features/notifications/data/notification_repository.dart';
import 'package:wealth_app/features/notifications/domain/notification_state.dart';
import 'package:wealth_app/shared/models/app_notification.dart';

part 'notification_notifier.g.dart';

@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  RealtimeChannel? _notificationChannel;
  
  @override
  NotificationState build() {
    ref.onDispose(() {
      _cancelSubscription();
    });
    
    _setupNotificationListener();
    loadNotifications();
    
    return const NotificationState();
  }
  
  void _cancelSubscription() {
    _notificationChannel?.unsubscribe();
    _notificationChannel = null;
  }
  
  void _setupNotificationListener() {
    final authState = ref.read(authNotifierProvider);
    
    if (!authState.isAuthenticated || authState.customer == null) {
      return;
    }
    
    _notificationChannel = ref.read(notificationRepositoryProvider).subscribeToNotifications(
      authState.customer!.id,
      (notification) {
        // Add new notification to the list
        final updatedNotifications = [notification, ...state.notifications];
        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: state.unreadCount + 1,
        );
      },
    );
  }
  
  Future<void> loadNotifications() async {
    final authState = ref.read(authNotifierProvider);
    
    if (!authState.isAuthenticated || authState.customer == null) {
      state = state.copyWith(
        error: "User not authenticated",
        isLoading: false,
      );
      return;
    }
    
    state = state.copyWith(isLoading: true);
    
    try {
      final notifications = await ref.read(notificationRepositoryProvider).getNotifications(
        authState.customer!.id,
      );
      
      final unreadCount = notifications.where((n) => !n.isRead).length;
      
      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to load notifications: $e",
      );
    }
  }
  
  Future<void> markAsRead(int notificationId) async {
    final authState = ref.read(authNotifierProvider);
    
    if (!authState.isAuthenticated || authState.customer == null) {
      return;
    }
    
    try {
      await ref.read(notificationRepositoryProvider).markAsRead(
        notificationId,
        authState.customer!.id,
      );
      
      // Update local state
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: state.unreadCount - 1,
      );
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> markAllAsRead() async {
    final authState = ref.read(authNotifierProvider);
    
    if (!authState.isAuthenticated || authState.customer == null) {
      return;
    }
    
    try {
      await ref.read(notificationRepositoryProvider).markAllAsRead(
        authState.customer!.id,
      );
      
      // Update local state
      final updatedNotifications = state.notifications.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> deleteNotification(int notificationId) async {
    final authState = ref.read(authNotifierProvider);
    
    if (!authState.isAuthenticated || authState.customer == null) {
      return;
    }
    
    try {
      await ref.read(notificationRepositoryProvider).deleteNotification(
        notificationId,
        authState.customer!.id,
      );
      
      // Update local state
      final notification = state.notifications.firstWhere(
        (n) => n.id == notificationId,
        orElse: () => const AppNotification(
          id: -1,
          title: '',
          message: '',
          type: '',
          createdAt: null,
        ),
      );
      
      final isUnread = notification.id != -1 && !notification.isRead;
      final updatedNotifications = state.notifications.where(
        (n) => n.id != notificationId
      ).toList();
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: isUnread ? state.unreadCount - 1 : state.unreadCount,
      );
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> clearAllNotifications() async {
    final authState = ref.read(authNotifierProvider);
    
    if (!authState.isAuthenticated || authState.customer == null) {
      return;
    }
    
    try {
      await ref.read(notificationRepositoryProvider).deleteAllNotifications(
        authState.customer!.id,
      );
      
      // Update local state
      state = state.copyWith(
        notifications: [],
        unreadCount: 0,
      );
    } catch (e) {
      // Handle error
    }
  }
} 