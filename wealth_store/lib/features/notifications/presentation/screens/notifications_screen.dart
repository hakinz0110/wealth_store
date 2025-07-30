import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/features/notifications/domain/notification_notifier.dart';
import 'package:wealth_app/shared/models/app_notification.dart';
import 'package:wealth_app/shared/widgets/base_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationNotifierProvider);
    
    return BaseScreen(
      title: 'Notifications',
      showBackButton: true,
      actions: [
        if (notificationState.notifications.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearConfirmation(context, ref),
          ),
      ],
      body: notificationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationState.notifications.isEmpty
              ? _buildEmptyState(context)
              : _buildNotificationsList(context, ref, notificationState.notifications),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'No Notifications',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'You don\'t have any notifications yet',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    WidgetRef ref,
    List<AppNotification> notifications,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationNotifierProvider.notifier).loadNotifications();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.small),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(context, ref, notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.small),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.medium),
        leading: CircleAvatar(
          backgroundColor: notification.isRead
              ? Colors.grey.shade200
              : AppColors.primary.withValues(alpha: 0.1),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: notification.isRead ? Colors.grey : AppColors.primary,
          ),
        ),
        title: Text(
          notification.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.small),
            Text(notification.message),
            const SizedBox(height: AppSpacing.small),
            Text(
              notification.createdAt != null 
                  ? _formatDate(notification.createdAt!) 
                  : 'Unknown date',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
        onTap: () {
          // Mark as read
          if (!notification.isRead) {
            ref.read(notificationNotifierProvider.notifier).markAsRead(notification.id);
          }
          
          // Navigate based on notification type and data
          if (notification.data != null) {
            if (notification.data!.containsKey('productId')) {
              final productId = notification.data!['productId'];
              context.push('/product/$productId');
            } else if (notification.data!.containsKey('orderId')) {
              final orderId = notification.data!['orderId'];
              context.push('/order-details/$orderId');
            } else if (notification.data!.containsKey('categoryId')) {
              final categoryId = notification.data!['categoryId'];
              context.push('/category/$categoryId');
            }
          }
        },
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: () {
            ref.read(notificationNotifierProvider.notifier).deleteNotification(notification.id);
          },
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_bag;
      case 'promotion':
        return Icons.local_offer;
      case 'product':
        return Icons.inventory;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(notificationNotifierProvider.notifier).clearAllNotifications();
              Navigator.pop(context);
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
} 