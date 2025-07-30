import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/user_models.dart';
import '../providers/user_providers.dart';
import '../widgets/update_user_role_dialog.dart';
import '../widgets/update_user_status_dialog.dart';
import '../widgets/user_details_dialog.dart';

// Method to show user details dialog
void showUserDetails(BuildContext context, WidgetRef ref, User user) {
  showDialog(
    context: context,
    builder: (context) => UserDetailsDialog(user: user),
  );
}

// Method to show update status dialog
void showUpdateStatusDialog(BuildContext context, WidgetRef ref, User user) {
  showDialog(
    context: context,
    builder: (context) => UpdateUserStatusDialog(user: user),
  );
}

// Method to show update role dialog
void showUpdateRoleDialog(BuildContext context, WidgetRef ref, User user) {
  showDialog(
    context: context,
    builder: (context) => UpdateUserRoleDialog(user: user),
  );
}

// Method to mark user as suspicious
void markUserAsSuspicious(BuildContext context, WidgetRef ref, User user) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Mark as Suspicious'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mark ${user.displayName} as suspicious?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Reason *',
                border: OutlineInputBorder(),
                hintText: 'Enter reason for marking as suspicious...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            try {
              final crudOperations = ref.read(userCrudProvider);
              await crudOperations.markUserAsSuspicious(user.id, 'Suspicious activity detected');
              
              // Refresh users list
              ref.invalidate(paginatedUsersProvider);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User marked as suspicious'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
          child: const Text('Mark as Suspicious', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

// Method to clear suspicious flag
Future<void> clearSuspiciousFlag(BuildContext context, WidgetRef ref, User user) async {
  try {
    final crudOperations = ref.read(userCrudProvider);
    await crudOperations.clearSuspiciousFlag(user.id);
    
    // Refresh users list
    ref.invalidate(paginatedUsersProvider);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Suspicious flag cleared'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

// Method to view user orders
void viewUserOrders(BuildContext context, WidgetRef ref, User user) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('User orders view coming soon'),
      backgroundColor: AppColors.warning,
    ),
  );
}

// Method to ban user
void banUser(BuildContext context, WidgetRef ref, User user) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Ban User'),
      content: Text('Are you sure you want to ban ${user.displayName}? This action will prevent them from accessing the platform.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            try {
              final crudOperations = ref.read(userCrudProvider);
              await crudOperations.updateUserStatus(user.id, UserStatus.banned, reason: 'Banned by admin');
              
              // Refresh users list
              ref.invalidate(paginatedUsersProvider);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User banned successfully'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Ban User', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

// Method to export users
void exportUsers(BuildContext context, WidgetRef ref) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Export feature coming soon'),
      backgroundColor: AppColors.warning,
    ),
  );
}