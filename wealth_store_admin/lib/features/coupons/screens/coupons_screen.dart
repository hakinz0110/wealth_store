import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/coupon_models.dart';
import '../providers/coupon_providers.dart';
import '../widgets/coupon_status_badge.dart';
import '../widgets/coupon_form_dialog.dart';
import '../widgets/coupon_details_dialog.dart';
import '../widgets/coupon_filters_panel.dart';

class CouponsScreen extends HookConsumerWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final showFilters = useState(false);
    
    // Watch current filters and pagination
    final currentFilters = ref.watch(couponFiltersProvider);
    final currentPage = ref.watch(couponCurrentPageProvider);
    final itemsPerPage = ref.watch(couponItemsPerPageProvider);
    
    // Watch coupons based on search query or filters
    final couponsAsync = searchQuery.value.isEmpty
        ? ref.watch(paginatedCouponsProvider(CouponPaginationParams(
            filters: currentFilters,
            page: currentPage,
            limit: itemsPerPage,
          )))
        : ref.watch(searchCouponsProvider(searchQuery.value));

    return AdminLayout(
      title: 'Coupons',
      currentRoute: '/coupons',
      breadcrumbs: const ['Dashboard', 'Coupons'],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with search, filters, and actions
          _buildHeader(context, ref, searchController, searchQuery, showFilters),
          const SizedBox(height: 16),
          
          // Filters panel (collapsible)
          if (showFilters.value) ...[
            CouponFiltersPanel(
              onFiltersChanged: (filters) {
                ref.read(couponFiltersProvider.notifier).state = filters;
                ref.read(couponCurrentPageProvider.notifier).state = 1; // Reset to first page
              },
            ),
            const SizedBox(height: 16),
          ],
          
          // Coupons content
          Expanded(
            child: couponsAsync.when(
              data: (coupons) => _buildCouponsContent(context, ref, coupons),
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
              hintText: 'Search coupons by code, name, or description...',
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
        
        // Add Coupon button
        ElevatedButton.icon(
          onPressed: () => _showCouponDialog(context, ref),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Coupon', style: TextStyle(color: Colors.white)),
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

  Widget _buildCouponsContent(BuildContext context, WidgetRef ref, List<Coupon> coupons) {
    if (coupons.isEmpty) {
      return _buildEmptyState(context, ref);
    }

    return Column(
      children: [
        // Coupons table
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
                      Expanded(flex: 2, child: Text('Coupon', style: TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Text('Discount', style: TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(flex: 1, child: Text('Usage', style: TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Text('Valid Until', style: TextStyle(fontWeight: FontWeight.w600))),
                      SizedBox(width: 120, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
                
                // Table content
                Expanded(
                  child: ListView.builder(
                    itemCount: coupons.length,
                    itemBuilder: (context, index) {
                      final coupon = coupons[index];
                      return _buildCouponRow(context, ref, coupon, index);
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

  Widget _buildCouponRow(BuildContext context, WidgetRef ref, Coupon coupon, int index) {
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
          // Coupon info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        coupon.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (coupon.isFirstTimeUserOnly)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'New Users',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  coupon.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (coupon.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    coupon.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          // Discount info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DiscountTypeBadge(type: coupon.discountType, isSmall: true),
                    const SizedBox(width: 8),
                    Text(
                      coupon.formattedDiscountValue,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (coupon.minimumOrderAmount != null)
                  Text(
                    'Min: ${coupon.formattedMinimumOrderAmount}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          
          // Usage info
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.usageDisplay,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (coupon.usageLimit != null) ...[
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: coupon.usagePercentage / 100,
                    backgroundColor: AppColors.backgroundLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      coupon.usagePercentage >= 90 
                          ? AppColors.error 
                          : coupon.usagePercentage >= 70 
                              ? AppColors.warning 
                              : AppColors.success,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Status
          Expanded(
            flex: 1,
            child: CouponStatusBadge(status: coupon.computedStatus),
          ),
          
          // Valid until
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (coupon.endDate != null) ...[
                  Text(
                    DateFormat('MMM dd, yyyy').format(coupon.endDate!),
                    style: TextStyle(
                      color: coupon.isExpired ? AppColors.error : AppColors.textPrimary,
                      fontWeight: coupon.isExpired ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  if (coupon.isExpired)
                    const Text(
                      'Expired',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                ] else ...[
                  const Text(
                    'No expiry',
                    style: TextStyle(color: AppColors.textSecondary),
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
                  onPressed: () => _showCouponDetails(context, ref, coupon),
                  icon: const Icon(Icons.visibility, size: 18),
                  color: AppColors.primary,
                  tooltip: 'View details',
                ),
                
                // Edit button
                IconButton(
                  onPressed: () => _showCouponDialog(context, ref, coupon: coupon),
                  icon: const Icon(Icons.edit, size: 18),
                  color: AppColors.warning,
                  tooltip: 'Edit coupon',
                ),
                
                // More actions menu
                PopupMenuButton<String>(
                  onSelected: (value) => _handleCouponAction(context, ref, coupon, value),
                  itemBuilder: (context) => [
                    if (coupon.status == CouponStatus.active)
                      const PopupMenuItem(
                        value: 'deactivate',
                        child: Row(
                          children: [
                            Icon(Icons.pause, size: 16, color: AppColors.warning),
                            SizedBox(width: 8),
                            Text('Deactivate', style: TextStyle(color: AppColors.warning)),
                          ],
                        ),
                      )
                    else
                      const PopupMenuItem(
                        value: 'activate',
                        child: Row(
                          children: [
                            Icon(Icons.play_arrow, size: 16, color: AppColors.success),
                            SizedBox(width: 8),
                            Text('Activate', style: TextStyle(color: AppColors.success)),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(Icons.copy, size: 16),
                          SizedBox(width: 8),
                          Text('Duplicate'),
                        ],
                      ),
                    ),
                    if (coupon.usageCount == 0)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppColors.error)),
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
    final currentPage = ref.watch(couponCurrentPageProvider);
    final itemsPerPage = ref.watch(couponItemsPerPageProvider);
    
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
                  ref.read(couponItemsPerPageProvider.notifier).state = value;
                  ref.read(couponCurrentPageProvider.notifier).state = 1; // Reset to first page
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
                  ? () => ref.read(couponCurrentPageProvider.notifier).state = currentPage - 1
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              'Page $currentPage',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            IconButton(
              onPressed: () => ref.read(couponCurrentPageProvider.notifier).state = currentPage + 1,
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
            Icons.local_offer_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No coupons found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first coupon to start offering discounts',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCouponDialog(context, ref),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Coupon', style: TextStyle(color: Colors.white)),
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
            'Failed to load coupons',
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
            onPressed: () => ref.refresh(paginatedCouponsProvider(CouponPaginationParams(
              page: ref.read(couponCurrentPageProvider),
              limit: ref.read(couponItemsPerPageProvider),
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

  void _showCouponDialog(BuildContext context, WidgetRef ref, {Coupon? coupon}) {
    showDialog(
      context: context,
      builder: (context) => CouponFormDialog(coupon: coupon),
    );
  }

  void _showCouponDetails(BuildContext context, WidgetRef ref, Coupon coupon) {
    showDialog(
      context: context,
      builder: (context) => CouponDetailsDialog(coupon: coupon),
    );
  }

  void _handleCouponAction(BuildContext context, WidgetRef ref, Coupon coupon, String action) {
    switch (action) {
      case 'activate':
        _toggleCouponStatus(context, ref, coupon, CouponStatus.active);
        break;
      case 'deactivate':
        _toggleCouponStatus(context, ref, coupon, CouponStatus.inactive);
        break;
      case 'duplicate':
        _duplicateCoupon(context, ref, coupon);
        break;
      case 'delete':
        _deleteCoupon(context, ref, coupon);
        break;
    }
  }

  void _toggleCouponStatus(BuildContext context, WidgetRef ref, Coupon coupon, CouponStatus newStatus) async {
    try {
      final crudOperations = ref.read(couponCrudProvider);
      await crudOperations.updateCouponStatus(coupon.id, newStatus);
      
      // Refresh coupons list
      ref.invalidate(paginatedCouponsProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Coupon ${newStatus == CouponStatus.active ? 'activated' : 'deactivated'} successfully'),
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

  void _duplicateCoupon(BuildContext context, WidgetRef ref, Coupon coupon) {
    final duplicatedData = CouponFormData.fromCoupon(coupon).copyWith(
      code: '${coupon.code}_COPY',
      name: '${coupon.name} (Copy)',
    );
    
    showDialog(
      context: context,
      builder: (context) => CouponFormDialog(
        initialData: duplicatedData,
      ),
    );
  }

  void _deleteCoupon(BuildContext context, WidgetRef ref, Coupon coupon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Coupon'),
        content: Text('Are you sure you want to delete "${coupon.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final crudOperations = ref.read(couponCrudProvider);
                await crudOperations.deleteCoupon(coupon.id);
                
                // Refresh coupons list
                ref.invalidate(paginatedCouponsProvider);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Coupon deleted successfully'),
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
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}