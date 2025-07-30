import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/user_models.dart';
import '../providers/user_providers.dart';

class UserFiltersPanel extends HookConsumerWidget {
  final Function(UserFilters) onFiltersChanged;

  const UserFiltersPanel({
    super.key,
    required this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilters = ref.watch(userFiltersProvider);
    
    // Filter state
    final selectedRole = useState<UserRole?>(currentFilters.role);
    final selectedStatus = useState<UserStatus?>(currentFilters.status);
    final registrationStartDate = useState<DateTime?>(currentFilters.registrationStartDate);
    final registrationEndDate = useState<DateTime?>(currentFilters.registrationEndDate);
    final lastLoginStartDate = useState<DateTime?>(currentFilters.lastLoginStartDate);
    final lastLoginEndDate = useState<DateTime?>(currentFilters.lastLoginEndDate);
    final emailVerified = useState<bool?>(currentFilters.emailVerified);
    final hasOrders = useState<bool?>(currentFilters.hasOrders);
    final isSuspicious = useState<bool?>(currentFilters.isSuspicious);
    final minTotalSpent = useTextEditingController(
      text: currentFilters.minTotalSpent?.toString() ?? '',
    );
    final maxTotalSpent = useTextEditingController(
      text: currentFilters.maxTotalSpent?.toString() ?? '',
    );
    final selectedSortBy = useState<UserSortBy>(currentFilters.sortBy);
    final selectedSortOrder = useState<SortOrder>(currentFilters.sortOrder);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.filter_list, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _clearFilters(
                    selectedRole,
                    selectedStatus,
                    registrationStartDate,
                    registrationEndDate,
                    lastLoginStartDate,
                    lastLoginEndDate,
                    emailVerified,
                    hasOrders,
                    isSuspicious,
                    minTotalSpent,
                    maxTotalSpent,
                    selectedSortBy,
                    selectedSortOrder,
                  ),
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Filter controls
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // User Role filter
                SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Role',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<UserRole?>(
                        value: selectedRole.value,
                        onChanged: (value) => selectedRole.value = value,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem<UserRole?>(
                            value: null,
                            child: Text('All Roles'),
                          ),
                          ...UserRole.values.map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role.displayName),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // User Status filter
                SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<UserStatus?>(
                        value: selectedStatus.value,
                        onChanged: (value) => selectedStatus.value = value,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem<UserStatus?>(
                            value: null,
                            child: Text('All Statuses'),
                          ),
                          ...UserStatus.values.map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.displayName),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Registration Date Range filter
                SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Registration Date',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _selectDate(context, registrationStartDate, 'Registration Start'),
                              child: Text(
                                registrationStartDate.value != null
                                    ? '${registrationStartDate.value!.day}/${registrationStartDate.value!.month}/${registrationStartDate.value!.year}'
                                    : 'Start Date',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('to'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _selectDate(context, registrationEndDate, 'Registration End'),
                              child: Text(
                                registrationEndDate.value != null
                                    ? '${registrationEndDate.value!.day}/${registrationEndDate.value!.month}/${registrationEndDate.value!.year}'
                                    : 'End Date',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Last Login Date Range filter
                SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last Login Date',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _selectDate(context, lastLoginStartDate, 'Last Login Start'),
                              child: Text(
                                lastLoginStartDate.value != null
                                    ? '${lastLoginStartDate.value!.day}/${lastLoginStartDate.value!.month}/${lastLoginStartDate.value!.year}'
                                    : 'Start Date',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('to'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _selectDate(context, lastLoginEndDate, 'Last Login End'),
                              child: Text(
                                lastLoginEndDate.value != null
                                    ? '${lastLoginEndDate.value!.day}/${lastLoginEndDate.value!.month}/${lastLoginEndDate.value!.year}'
                                    : 'End Date',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Total Spent Range filter
                SizedBox(
                  width: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Spent Range',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: minTotalSpent,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Min',
                                prefixText: '\$',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('to'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: maxTotalSpent,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Max',
                                prefixText: '\$',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Boolean filters
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email Verified',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<bool?>(
                        value: emailVerified.value,
                        onChanged: (value) => emailVerified.value = value,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem<bool?>(
                            value: null,
                            child: Text('All'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: true,
                            child: Text('Verified'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: false,
                            child: Text('Not Verified'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Has Orders',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<bool?>(
                        value: hasOrders.value,
                        onChanged: (value) => hasOrders.value = value,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem<bool?>(
                            value: null,
                            child: Text('All'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: true,
                            child: Text('Has Orders'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: false,
                            child: Text('No Orders'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Suspicious Activity',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<bool?>(
                        value: isSuspicious.value,
                        onChanged: (value) => isSuspicious.value = value,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem<bool?>(
                            value: null,
                            child: Text('All'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: true,
                            child: Text('Suspicious'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: false,
                            child: Text('Normal'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Sort options
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sort By',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<UserSortBy>(
                        value: selectedSortBy.value,
                        onChanged: (value) => selectedSortBy.value = value!,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: UserSortBy.values.map((sortBy) => DropdownMenuItem(
                          value: sortBy,
                          child: Text(_getSortByDisplayName(sortBy)),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                
                // Sort order
                SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<SortOrder>(
                        value: selectedSortOrder.value,
                        onChanged: (value) => selectedSortOrder.value = value!,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: SortOrder.ascending,
                            child: Text('Ascending'),
                          ),
                          DropdownMenuItem(
                            value: SortOrder.descending,
                            child: Text('Descending'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Apply filters button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => _applyFilters(
                    selectedRole.value,
                    selectedStatus.value,
                    registrationStartDate.value,
                    registrationEndDate.value,
                    lastLoginStartDate.value,
                    lastLoginEndDate.value,
                    emailVerified.value,
                    hasOrders.value,
                    isSuspicious.value,
                    minTotalSpent.text,
                    maxTotalSpent.text,
                    selectedSortBy.value,
                    selectedSortOrder.value,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate(BuildContext context, ValueNotifier<DateTime?> dateNotifier, String label) async {
    final date = await showDatePicker(
      context: context,
      initialDate: dateNotifier.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: label,
    );
    
    if (date != null) {
      dateNotifier.value = date;
    }
  }

  void _clearFilters(
    ValueNotifier<UserRole?> selectedRole,
    ValueNotifier<UserStatus?> selectedStatus,
    ValueNotifier<DateTime?> registrationStartDate,
    ValueNotifier<DateTime?> registrationEndDate,
    ValueNotifier<DateTime?> lastLoginStartDate,
    ValueNotifier<DateTime?> lastLoginEndDate,
    ValueNotifier<bool?> emailVerified,
    ValueNotifier<bool?> hasOrders,
    ValueNotifier<bool?> isSuspicious,
    TextEditingController minTotalSpent,
    TextEditingController maxTotalSpent,
    ValueNotifier<UserSortBy> selectedSortBy,
    ValueNotifier<SortOrder> selectedSortOrder,
  ) {
    selectedRole.value = null;
    selectedStatus.value = null;
    registrationStartDate.value = null;
    registrationEndDate.value = null;
    lastLoginStartDate.value = null;
    lastLoginEndDate.value = null;
    emailVerified.value = null;
    hasOrders.value = null;
    isSuspicious.value = null;
    minTotalSpent.clear();
    maxTotalSpent.clear();
    selectedSortBy.value = UserSortBy.createdAt;
    selectedSortOrder.value = SortOrder.descending;
    
    _applyFilters(null, null, null, null, null, null, null, null, null, '', '', UserSortBy.createdAt, SortOrder.descending);
  }

  void _applyFilters(
    UserRole? role,
    UserStatus? status,
    DateTime? registrationStartDate,
    DateTime? registrationEndDate,
    DateTime? lastLoginStartDate,
    DateTime? lastLoginEndDate,
    bool? emailVerified,
    bool? hasOrders,
    bool? isSuspicious,
    String minTotalSpentText,
    String maxTotalSpentText,
    UserSortBy sortBy,
    SortOrder sortOrder,
  ) {
    final minTotalSpent = double.tryParse(minTotalSpentText);
    final maxTotalSpent = double.tryParse(maxTotalSpentText);
    
    final filters = UserFilters(
      role: role,
      status: status,
      registrationStartDate: registrationStartDate,
      registrationEndDate: registrationEndDate,
      lastLoginStartDate: lastLoginStartDate,
      lastLoginEndDate: lastLoginEndDate,
      emailVerified: emailVerified,
      hasOrders: hasOrders,
      isSuspicious: isSuspicious,
      minTotalSpent: minTotalSpent,
      maxTotalSpent: maxTotalSpent,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
    
    onFiltersChanged(filters);
  }

  String _getSortByDisplayName(UserSortBy sortBy) {
    switch (sortBy) {
      case UserSortBy.email:
        return 'Email';
      case UserSortBy.createdAt:
        return 'Registration Date';
      case UserSortBy.lastLoginAt:
        return 'Last Login';
      case UserSortBy.totalOrders:
        return 'Total Orders';
      case UserSortBy.totalSpent:
        return 'Total Spent';
      case UserSortBy.status:
        return 'Status';
    }
  }
}