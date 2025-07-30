import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/user_models.dart';
import '../providers/user_providers.dart';
import '../../../shared/utils/logger.dart';

class UpdateUserStatusDialog extends HookConsumerWidget {
  final User user;

  const UpdateUserStatusDialog({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStatus = useState<UserStatus>(user.status);
    final reasonController = useTextEditingController();
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);
    final needsReason = useState(false);

    // Check if reason is required for the selected status
    useEffect(() {
      needsReason.value = selectedStatus.value == UserStatus.suspended || 
                          selectedStatus.value == UserStatus.banned;
      return null;
    }, [selectedStatus.value]);

    return AlertDialog(
      title: const Text('Update User Status'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update status for ${user.displayName}'),
            const SizedBox(height: 16),
            
            // Status selection
            DropdownButtonFormField<UserStatus>(
              value: selectedStatus.value,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: UserStatus.values
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getStatusColor(status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(status.displayName),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: isLoading.value
                  ? null
                  : (value) {
                      if (value != null) {
                        selectedStatus.value = value;
                      }
                    },
            ),
            
            // Reason field (required for suspended/banned)
            if (needsReason.value) ...[
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason *',
                  border: OutlineInputBorder(),
                  hintText: 'Enter reason for status change...',
                ),
                maxLines: 3,
                enabled: !isLoading.value,
              ),
            ],
            
            // Error message
            if (errorMessage.value != null) ...[
              const SizedBox(height: 16),
              Text(
                errorMessage.value!,
                style: const TextStyle(color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading.value ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading.value || selectedStatus.value == user.status ||
                    (needsReason.value && reasonController.text.trim().isEmpty)
              ? null
              : () async {
                  try {
                    isLoading.value = true;
                    errorMessage.value = null;
                    
                    final reason = needsReason.value ? reasonController.text.trim() : null;
                    
                    Logger.info('Updating status for user ${user.id} to ${selectedStatus.value.name}');
                    
                    final crudOperations = ref.read(userCrudProvider);
                    await crudOperations.updateUserStatus(
                      user.id, 
                      selectedStatus.value,
                      reason: reason,
                    );
                    
                    // Refresh users list
                    ref.invalidate(paginatedUsersProvider);
                    
                    if (context.mounted) {
                      Navigator.of(context).pop(true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('User status updated to ${selectedStatus.value.displayName}'),
                          backgroundColor: _getStatusColor(selectedStatus.value),
                        ),
                      );
                    }
                  } catch (e) {
                    Logger.error('Failed to update user status', e);
                    errorMessage.value = 'Failed to update status: ${e.toString()}';
                    isLoading.value = false;
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: isLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Update Status', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
  
  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return AppColors.success;
      case UserStatus.inactive:
        return AppColors.textSecondary;
      case UserStatus.suspended:
        return AppColors.warning;
      case UserStatus.banned:
        return AppColors.error;
    }
  }
}