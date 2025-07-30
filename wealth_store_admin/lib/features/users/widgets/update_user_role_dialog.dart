import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/user_models.dart';
import '../providers/user_providers.dart';
import '../../../shared/utils/logger.dart';

class UpdateUserRoleDialog extends HookConsumerWidget {
  final User user;

  const UpdateUserRoleDialog({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = useState<UserRole>(user.role);
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    return AlertDialog(
      title: const Text('Update User Role'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update role for ${user.displayName}'),
            const SizedBox(height: 16),
            
            // Role selection
            DropdownButtonFormField<UserRole>(
              value: selectedRole.value,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: UserRole.values
                  .where((role) => role != UserRole.admin) // Prevent changing to admin role
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role.displayName),
                      ))
                  .toList(),
              onChanged: isLoading.value
                  ? null
                  : (value) {
                      if (value != null) {
                        selectedRole.value = value;
                      }
                    },
            ),
            
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
          onPressed: isLoading.value || selectedRole.value == user.role
              ? null
              : () async {
                  try {
                    isLoading.value = true;
                    errorMessage.value = null;
                    
                    Logger.info('Updating role for user ${user.id} to ${selectedRole.value.name}');
                    
                    final crudOperations = ref.read(userCrudProvider);
                    await crudOperations.updateUserRole(user.id, selectedRole.value.name);
                    
                    // Refresh users list
                    ref.invalidate(paginatedUsersProvider);
                    
                    if (context.mounted) {
                      Navigator.of(context).pop(true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('User role updated to ${selectedRole.value.displayName}'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    Logger.error('Failed to update user role', e);
                    errorMessage.value = 'Failed to update role: ${e.toString()}';
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
              : const Text('Update Role', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}