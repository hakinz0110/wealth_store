import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/user_models.dart';
import '../providers/user_providers.dart';
import '../widgets/update_user_role_dialog.dart';
import '../widgets/update_user_status_dialog.dart';
import '../widgets/user_details_dialog.dart';
import '../../../shared/utils/logger.dart';

extension UsersScreenExtensions on Widget {
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
    final reasonController = TextEditingController();
    
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
                controller: reasonController,
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
            onPressed: reasonController.text.trim().isEmpty
                ? null
                : () async {
                    Navigator.of(context).pop();
                    try {
                      Logger.info('Marking user ${user.id} as suspicious');
                      
                      final crudOperations = ref.read(userCrudProvider);
                      await crudOperations.markUserAsSuspicious(
                        user.id, 
                        reasonController.text.trim(),
                      );
                      
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
                      Logger.error('Failed to mark user as suspicious', e);
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
      Logger.info('Clearing suspicious flag for user ${user.id}');
      
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
      Logger.error('Failed to clear suspicious flag', e);
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
    Logger.info('Viewing orders for user ${user.id}');
    
    // Get user order history
    final ordersFuture = ref.read(userCrudProvider).getUserOrderHistory(user.id);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Orders for ${user.displayName}'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: FutureBuilder(
            future: ordersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading orders: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No orders found for this user'),
                );
              }
              
              final orders = snapshot.data!;
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return ListTile(
                    title: Text('Order #${order.id.substring(0, 8)}'),
                    subtitle: Text('Status: ${order.status}'),
                    trailing: Text('\$${order.total.toStringAsFixed(2)}'),
                    onTap: () {
                      // Show order details
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Method to ban user
  void banUser(BuildContext context, WidgetRef ref, User user) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ban User'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to ban ${user.displayName}?'),
              const Text(
                'This action will prevent them from accessing the platform.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason *',
                  border: OutlineInputBorder(),
                  hintText: 'Enter reason for banning user...',
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
            onPressed: reasonController.text.trim().isEmpty
                ? null
                : () async {
                    Navigator.of(context).pop();
                    try {
                      Logger.info('Banning user ${user.id}');
                      
                      final crudOperations = ref.read(userCrudProvider);
                      await crudOperations.updateUserStatus(
                        user.id, 
                        UserStatus.banned, 
                        reason: reasonController.text.trim(),
                      );
                      
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
                      Logger.error('Failed to ban user', e);
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
    Logger.info('Exporting users');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature coming soon'),
        backgroundColor: AppColors.warning,
      ),
    );
  }
}