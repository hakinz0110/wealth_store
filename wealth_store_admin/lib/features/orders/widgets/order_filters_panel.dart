import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/order_models.dart';
import '../providers/order_providers.dart';

class OrderFiltersPanel extends HookConsumerWidget {
  final Function(OrderFilters) onFiltersChanged;

  const OrderFiltersPanel({
    super.key,
    required this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilters = ref.watch(orderFiltersProvider);
    
    // Filter state
    final selectedStatus = useState<OrderStatus?>(currentFilters.status);
    final selectedPaymentStatus = useState<PaymentStatus?>(currentFilters.paymentStatus);
    final startDate = useState<DateTime?>(currentFilters.startDate);
    final endDate = useState<DateTime?>(currentFilters.endDate);
    final minAmount = useTextEditingController(
      text: currentFilters.minAmount?.toString() ?? '',
    );
    final maxAmount = useTextEditingController(
      text: currentFilters.maxAmount?.toString() ?? '',
    );
    final selectedSortBy = useState<OrderSortBy>(currentFilters.sortBy);
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
                    selectedPaymentStatus,
                    startDate,
                    endDate,
                    minAmount,
                    maxAmount,
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
                // Order Status filter
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<OrderStatus?>(
                        value: selectedStatus.value,
                        onChanged: (value) => selectedStatus.value = value,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem<OrderStatus?>(
                            value: null,
                            child: Text('All Statuses'),
                          ),
                          ...OrderStatus.values.map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.displayName),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Payment Status filter
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<PaymentStatus?>(
                        value: selectedPaymentStatus.value,
                        onChanged: (value) => selectedPaymentStatus.value = value,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem<PaymentStatus?>(
                            value: null,
                            child: Text('All Payment Statuses'),
                          ),
                          ...PaymentStatus.values.map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.displayName),
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
                        'Date Range',
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
                
                // Amount Range filter
                SizedBox(
                  width: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amount Range',
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
                              controller: minAmount,
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
                              controller: maxAmount,
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
                      DropdownButtonFormField<OrderSortBy>(
                        value: selectedSortBy.value,
                        onChanged: (value) => selectedSortBy.value = value!,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: OrderSortBy.values.map((sortBy) => DropdownMenuItem(
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
                    selectedPaymentStatus.value,
                    startDate.value,
                    endDate.value,
                    minAmount.text,
                    maxAmount.text,
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
    ValueNotifier<OrderStatus?> selectedStatus,
    ValueNotifier<PaymentStatus?> selectedPaymentStatus,
    ValueNotifier<DateTime?> startDate,
    ValueNotifier<DateTime?> endDate,
    TextEditingController minAmount,
    TextEditingController maxAmount,
    ValueNotifier<OrderSortBy> selectedSortBy,
    ValueNotifier<SortOrder> selectedSortOrder,
  ) {
    selectedStatus.value = null;
    selectedPaymentStatus.value = null;
    startDate.value = null;
    endDate.value = null;
    minAmount.clear();
    maxAmount.clear();
    selectedSortBy.value = OrderSortBy.createdAt;
    selectedSortOrder.value = SortOrder.descending;
    
    _applyFilters(null, null, null, null, '', '', OrderSortBy.createdAt, SortOrder.descending);
  }

  void _applyFilters(
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
    String minAmountText,
    String maxAmountText,
    OrderSortBy sortBy,
    SortOrder sortOrder,
  ) {
    final minAmount = double.tryParse(minAmountText);
    final maxAmount = double.tryParse(maxAmountText);
    
    final filters = OrderFilters(
      status: status,
      paymentStatus: paymentStatus,
      startDate: startDate,
      endDate: endDate,
      minAmount: minAmount,
      maxAmount: maxAmount,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
    
    onFiltersChanged(filters);
  }

  String _getSortByDisplayName(OrderSortBy sortBy) {
    switch (sortBy) {
      case OrderSortBy.createdAt:
        return 'Created Date';
      case OrderSortBy.updatedAt:
        return 'Updated Date';
      case OrderSortBy.totalAmount:
        return 'Total Amount';
      case OrderSortBy.status:
        return 'Status';
      case OrderSortBy.userEmail:
        return 'Customer Email';
    }
  }
}