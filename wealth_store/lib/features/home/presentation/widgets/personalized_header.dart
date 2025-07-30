import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/features/auth/domain/auth_notifier.dart';
import 'package:wealth_app/features/notifications/domain/notification_notifier.dart';

class PersonalizedHeader extends ConsumerWidget {
  const PersonalizedHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final notificationState = ref.watch(notificationNotifierProvider);
    
    // Get user name, fallback to "User" if not available
    final userName = authState.customer?.fullName ?? 
                    authState.user?.email?.split('@').first ?? 
                    'User';
    
    // Get unread notification count
    final unreadCount = notificationState.unreadCount;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good day for shopping',
                  style: TypographyUtils.getBodyStyle(
                    context,
                    size: BodySize.medium,
                    isSecondary: true,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: TypographyUtils.getHeadingStyle(
                    context,
                    HeadingLevel.h3,
                    isEmphasis: true,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Notification icon with badge
          _buildNotificationIcon(context, unreadCount),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context, int unreadCount) {
    return InkWell(
      onTap: () {
        context.push('/notifications');
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Notification icon
            Center(
              child: Icon(
                Icons.notifications_outlined,
                size: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            
            // Badge for unread count
            if (unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16),
                  height: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}