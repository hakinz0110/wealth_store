import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/user_models.dart';
import '../providers/user_providers.dart';
import '../widgets/user_status_badge.dart';
import '../widgets/user_details_dialog.dart';
import '../widgets/user_filters_panel.dart';
import '../widgets/update_user_status_dialog.dart';
import '../widgets/update_user_role_dialog.dart';
import '../widgets/user_role_badge.dart';
import 'users_screen_extensions.dart';


class UsersScreen extends HookConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final showFilters = useState(false);
    
    // Watch current filters and pagination
    final currentFilters = ref.watch(userFiltersProvider);
    final currentPage = ref.watch(userCurrentPageProvider);
    final itemsPerPage = ref.watch(userItemsPerPageProvider);
    
    // Watch users based on search query or filters
    final usersAsync = searchQuery.value.isEmpty
        ? ref.watch(paginatedUsersProvider(UserPaginationParams(
            filters: currentFilters,
            page: currentPage,
            limit: itemsPerPage,
          )))
        : ref.watch(searchUsersProvider(searchQuery.value));

    return AdminLayout(
      title: 'Users',
      currentRoute: '/users',
      breadcrumbs: const ['Dashboard', 'Users'],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with search, filters, and actions
          _buildHeader(context, ref, searchController, searchQuery, showFilters),
          const SizedBox(height: 16),
          
          // Filters panel (collapsible)
          if (showFilters.value) ...[
            UserFiltersPanel(
              onFiltersChanged: (filters) {
                ref.read(userFiltersProvider.notifier).state = filters;
                ref.read(userCurrentPageProvider.notifier).state = 1; // Reset to first page
              },
            ),
            const SizedBox(height: 16),
          ],
          
          // Users content
          Expanded(
            child: usersAsync.when(
              data: (users) => _buildUsersContent(context, ref, users),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(context, ref, error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    TextEditingController searchController,
    ValueNotifier<String> searchQuery,
    ValueNotifier<bool> showFilters,
  ) {
    return Row(
      children: [
        // Search field
        Expanded(
          flex: 2,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search users by email, name, or phone...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              searchQuery.value = value;
            },
          ),
        ),
        const SizedBox(width: 16),
        
        // Filters toggle button
        OutlinedButton.icon(
          onPressed: () => showFilters.value = !showFilters.value,
          icon: Icon(
            showFilters.value ? Icons.filter_list_off : Icons.filter_list,
            color: AppColors.primary,
          ),
          label: Text(
            showFilters.value ? 'Hide Filters' : 'Show Filters',
            style: const TextStyle(color: AppColors.primary),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Export button
        ElevatedButton.icon(
          onPressed: () => _exportUsers(context, ref),
          icon: const Icon(Icons.download, color: Colors.white),
          label: const Text('Export', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsersContent(BuildContext context, WidgetRef ref, List<User> users) {
    if (users.isEmpty) {
      return _buildEmptyState(context, ref);
    }

    return Column(
      children: [
        // Users table
        Expanded(
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                // Table header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(flex: 3, child: Text('User', style: TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Text('Role', style: TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Text('Orders', style: TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Text('Total Spent', style: TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Text('Registered', style: TextStyle(fontWeight: FontWeight.w600))),
                      SizedBox(width: 120, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
                
                // Table content
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _buildUserRow(context, ref, user, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Pagination
        const SizedBox(height: 16),
        _buildPagination(context, ref),
      ],
    );
  }

  Widget _buildUserRow(BuildContext context, WidgetRef ref, User user, int index) {
    final isEven = index % 2 == 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : AppColors.backgroundLight,
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // User info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: user.profile?.avatarUrl != null
                      ? NetworkImage(user.profile!.avatarUrl!)
                      : null,
                  child: user.profile?.avatarUrl == null
                      ? Text(
                          user.initials,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (user.isSuspicious) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.warning,
                              size: 16,
                              color: AppColors.warning,
                            ),
                          ],
                          if (!user.isEmailVerified) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.email_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Role
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _showUpdateRoleDialog(context, ref, user),
              child: UserRoleBadge(role: user.role),
            ),
          ),
          
          // Status
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _showUpdateStatusDialog(context, ref, user),
              child: UserStatusBadge(status: user.status),
            ),
          ),
          
          // Orders
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.totalOrders}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (user.totalOrders > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Avg: ${user.formattedAverageOrderValue}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Total spent
          Expanded(
            flex: 2,
            child: Text(
              user.formattedTotalSpent,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          // Registration date
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(user.createdAt),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if (user.lastLoginAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Last: ${DateFormat('MMM dd').format(user.lastLoginAt!)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Actions
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // View details button
                IconButton(
                  onPressed: () => _showUserDetails(context, ref, user),
                  icon: const Icon(Icons.visibility, size: 18),
                  color: AppColors.primary,
                  tooltip: 'View details',
                ),
                
                // Update status button
                IconButton(
                  onPressed: () => _showUpdateStatusDialog(context, ref, user),
                  icon: const Icon(Icons.edit, size: 18),
                  color: AppColors.warning,
                  tooltip: 'Update status',
                ),
                
                // More actions menu
                PopupMenuButton<String>(
                  onSelected: (value) => _handleUserAction(context, ref, user, value),
                  itemBuilder: (context) => [
                    if (user.isSuspicious)
                      const PopupMenuItem(
                        value: 'clear_suspicious',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: AppColors.success),
                            SizedBox(width: 8),
                            Text('Clear Suspicious Flag', style: TextStyle(color: AppColors.success)),
                          ],
                        ),
                      )
                    else
                      const PopupMenuItem(
                        value: 'mark_suspicious',
                        child: Row(
                          children: [
                            Icon(Icons.warning, size: 16, color: AppColors.warning),
                            SizedBox(width: 8),
                            Text('Mark as Suspicious', style: TextStyle(color: AppColors.warning)),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'view_orders',
                      child: Row(
                        children: [
                          Icon(Icons.shopping_cart, size: 16),
                          SizedBox(width: 8),
                          Text('View Orders'),
                        ],
                      ),
                    ),
                    if (user.status != UserStatus.banned)
                      const PopupMenuItem(
                        value: 'ban_user',
                        child: Row(
                          children: [
                            Icon(Icons.block, size: 16, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Ban User', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                  ],
                  icon: const Icon(Icons.more_vert, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(userCurrentPageProvider);
    final itemsPerPage = ref.watch(userItemsPerPageProvider);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Items per page selector
        Row(
          children: [
            const Text('Rows per page:', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: itemsPerPage,
              onChanged: (value) {
                if (value != null) {
                  ref.read(userItemsPerPageProvider.notifier).state = value;
                  ref.read(userCurrentPageProvider.notifier).state = 1; // Reset to first page
                }
              },
              items: [10, 20, 50, 100].map((value) => DropdownMenuItem(
                value: value,
                child: Text('$value'),
              )).toList(),
              underline: Container(),
            ),
          ],
        ),
        
        // Page navigation
        Row(
          children: [
            IconButton(
              onPressed: currentPage > 1
                  ? () => ref.read(userCurrentPageProvider.notifier).state = currentPage - 1
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              'Page $currentPage',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            IconButton(
              onPressed: () => ref.read(userCurrentPageProvider.notifier).state = currentPage + 1,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No users found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Users will appear here once they register',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(paginatedUsersProvider(UserPaginationParams(
              page: ref.read(userCurrentPageProvider),
              limit: ref.read(userItemsPerPageProvider),
            ))),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Refresh', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load users',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(paginatedUsersProvider(UserPaginationParams(
              page: ref.read(userCurrentPageProvider),
              limit: ref.read(userItemsPerPageProvider),
            ))),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Retry', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(BuildContext context, WidgetRef ref, User user) {
    showUserDetails(context, ref, user);
  }

  void _showUpdateStatusDialog(BuildContext context, WidgetRef ref, User user) {
    showUpdateStatusDialog(context, ref, user);
  }
  
  void _showUpdateRoleDialog(BuildContext context, WidgetRef ref, User user) {
    showUpdateRoleDialog(context, ref, user);
  }

  void _handleUserAction(BuildContext context, WidgetRef ref, User user, String action) {
    switch (action) {
      case 'mark_suspicious':
        markUserAsSuspicious(context, ref, user);
        break;
      case 'clear_suspicious':
        clearSuspiciousFlag(context, ref, user);
        break;
      case 'view_orders':
        viewUserOrders(context, ref, user);
        break;
      case 'ban_user':
        banUser(context, ref, user);
        break;
    }
  }

  void _exportUsers(BuildContext context, WidgetRef ref) {
    exportUsers(context, ref);
  }
}

class _SuspiciousReasonDialog extends HookWidget {
  final User user;
  final Function(String) onConfirm;

  const _SuspiciousReasonDialog({
    required this.user,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final reasonController = useTextEditingController();
    final isLoading = useState(false);

    return AlertDialog(
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
              enabled: !isLoading.value,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading.value ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading.value || reasonController.text.trim().isEmpty
              ? null
              : () async {
                  isLoading.value = true;
                  Navigator.of(context).pop();
                  onConfirm(reasonController.text.trim());
                },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
          child: isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Mark as Suspicious', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}