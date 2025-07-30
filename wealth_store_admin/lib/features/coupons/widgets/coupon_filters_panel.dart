import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/coupon_models.dart';
import '../providers/coupon_providers.dart';

class CouponFiltersPanel extends HookConsumerWidget {
  final Function(CouponFilters) onFiltersChanged;

  const CouponFiltersPanel({
    super.key,
    required this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilters = ref.watch(couponFiltersProvider);
    
    // Filter state
    final selectedStatus = useState<CouponStatus?>(currentFilters.status);
    final selectedDiscountType = useState<DiscountType?>(currentFilters.discountType);
    final startDate = useState<DateTime?>(currentFilters.startDate);
    final endDate = useState<DateTime?>(currentFilters.endDate);
    final minDiscountValue = useTextEditingController(
      text: currentFilters.minDiscountValue?.toString() ?? '',
    );
    final maxDiscountValue = useTextEditingController(
      text: currentFilters.maxDiscountValue?.toString() ?? '',
    );
    final hasUsageLimit = useState<bool?>(currentFilters.hasUsageLimit);
    final isExpired = useState<bool?>(currentFilters.isExpired);
    final isFirstTimeUserOnly = useState<bool?>(currentFilters.isFirstTimeUserOnly);
    final selectedSortBy = useState<CouponSortBy>(currentFilters.sortBy);
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
                    selectedStatus,
                    selectedDiscountType,
                    startDate,
                    endDate,
                    minDiscountValue,
                    maxDiscountValue,
                    hasUsageLimit,
                    isExpired,
                    isFirstTimeUserOnly,
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
                // Coupon Status filter
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
                      DropdownButtonFormField<CouponStatus?>(
                        value: selectedStatus.value,
                        onChanged: (value) => selectedStatus.value = value,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem<CouponStatus?>(
                            value: null,
                            child: Text('All Statuses'),
                          ),
                          ...CouponStatus.values.map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.displayName),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Discount Type filter
                SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Discount Type',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<DiscountType?>(
                        value: selectedDiscountType.value,
                        onChanged: (value) => selectedDiscountType.value = value,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem<DiscountType?>(
                            value: null,
                            child: Text('All Types'),
                          ),
                          ...DiscountType.values.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Date Range filter
                SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Created Date Range',
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
                              onPressed: () => _selectDate(context, startDate, 'Start Date'),
                              child: Text(
                                startDate.value != null
                                    ? '${startDate.value!.day}/${startDate.value!.month}/${startDate.value!.year}'
                                    : 'Start Date',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('to'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _selectDate(context, endDate, 'End Date'),
                              child: Text(
                                endDate.value != null
                                    ? '${endDate.value!.day}/${endDate.value!.month}/${endDate.value!.year}'
                                    : 'End Date',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Discount Value Range filter
                SizedBox(
                  width: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Discount Value Range',
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
                              controller: minDiscountValue,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Min',
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
                              controller: maxDiscountValue,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Max',
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
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Has Usage Limit',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<bool?>(
                        value: hasUsageLimit.value,
                        onChanged: (value) => hasUsageLimit.value = value,
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
                            child: Text('Limited'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: false,
                            child: Text('Unlimited'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expired',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<bool?>(
                        value: isExpired.value,
                        onChanged: (value) => isExpired.value = value,
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
                            child: Text('Expired'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: false,
                            child: Text('Active'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Users Only',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<bool?>(
                        value: isFirstTimeUserOnly.value,
                        onChanged: (value) => isFirstTimeUserOnly.value = value,
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
                            child: Text('New Users Only'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: false,
                            child: Text('All Users'),
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
                      DropdownButtonFormField<CouponSortBy>(
                        value: selectedSortBy.value,
                        onChanged: (value) => selectedSortBy.value = value!,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: CouponSortBy.values.map((sortBy) => DropdownMenuItem(
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
                    selectedStatus.value,
                    selectedDiscountType.value,
                    startDate.value,
                    endDate.value,
                    minDiscountValue.text,
                    maxDiscountValue.text,
                    hasUsageLimit.value,
                    isExpired.value,
                    isFirstTimeUserOnly.value,
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
    ValueNotifier<CouponStatus?> selectedStatus,
    ValueNotifier<DiscountType?> selectedDiscountType,
    ValueNotifier<DateTime?> startDate,
    ValueNotifier<DateTime?> endDate,
    TextEditingController minDiscountValue,
    TextEditingController maxDiscountValue,
    ValueNotifier<bool?> hasUsageLimit,
    ValueNotifier<bool?> isExpired,
    ValueNotifier<bool?> isFirstTimeUserOnly,
    ValueNotifier<CouponSortBy> selectedSortBy,
    ValueNotifier<SortOrder> selectedSortOrder,
  ) {
    selectedStatus.value = null;
    selectedDiscountType.value = null;
    startDate.value = null;
    endDate.value = null;
    minDiscountValue.clear();
    maxDiscountValue.clear();
    hasUsageLimit.value = null;
    isExpired.value = null;
    isFirstTimeUserOnly.value = null;
    selectedSortBy.value = CouponSortBy.createdAt;
    selectedSortOrder.value = SortOrder.descending;
    
    _applyFilters(null, null, null, null, '', '', null, null, null, CouponSortBy.createdAt, SortOrder.descending);
  }

  void _applyFilters(
    CouponStatus? status,
    DiscountType? discountType,
    DateTime? startDate,
    DateTime? endDate,
    String minDiscountValueText,
    String maxDiscountValueText,
    bool? hasUsageLimit,
    bool? isExpired,
    bool? isFirstTimeUserOnly,
    CouponSortBy sortBy,
    SortOrder sortOrder,
  ) {
    final minDiscountValue = double.tryParse(minDiscountValueText);
    final maxDiscountValue = double.tryParse(maxDiscountValueText);
    
    final filters = CouponFilters(
      status: status,
      discountType: discountType,
      startDate: startDate,
      endDate: endDate,
      minDiscountValue: minDiscountValue,
      maxDiscountValue: maxDiscountValue,
      hasUsageLimit: hasUsageLimit,
      isExpired: isExpired,
      isFirstTimeUserOnly: isFirstTimeUserOnly,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
    
    onFiltersChanged(filters);
  }

  String _getSortByDisplayName(CouponSortBy sortBy) {
    switch (sortBy) {
      case CouponSortBy.code:
        return 'Code';
      case CouponSortBy.name:
        return 'Name';
      case CouponSortBy.createdAt:
        return 'Created Date';
      case CouponSortBy.endDate:
        return 'End Date';
      case CouponSortBy.usageCount:
        return 'Usage Count';
      case CouponSortBy.discountValue:
        return 'Discount Value';
      case CouponSortBy.status:
        return 'Status';
    }
  }
}