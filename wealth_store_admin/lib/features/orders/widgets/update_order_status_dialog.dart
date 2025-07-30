import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/order_models.dart';
import '../../../services/order_service.dart';
import '../providers/order_providers.dart';
import 'order_status_badge.dart';

class UpdateOrderStatusDialog extends HookConsumerWidget {
  final Order order;

  const UpdateOrderStatusDialog({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final selectedStatus = useState<OrderStatus>(order.status);
    final notesController = useTextEditingController(text: order.notes ?? '');
    final trackingController = useTextEditingController(text: order.trackingNumber ?? '');
    final isLoading = useState(false);

    // Get available status transitions
    final availableStatuses = _getAvailableStatuses(order.status);

    return AlertDialog(
      title: Row(
        children: [
          const Text('Update Order Status'),
          const Spacer(),
          OrderStatusBadge(status: order.status, isSmall: true),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${order.userName ?? 'Unknown'} • ${order.formattedTotalAmount}',
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
              const SizedBox(height: 20),
              
              // Status selection
              const Text(
                'New Status',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<OrderStatus>(
                value: selectedStatus.value,
                onChanged: isLoading.value
                    ? null
                    : (value) {
                        if (value != null) {
                          selectedStatus.value = value;
                        }
                      },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: availableStatuses.map((status) => DropdownMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      OrderStatusBadge(status: status, isSmall: true),
                      const SizedBox(width: 8),
                      Text(status.displayName),
                    ],
                  ),
                )).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a status';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Tracking number (show when status is shipped or delivered)
              if (selectedStatus.value == OrderStatus.shipped || 
                  selectedStatus.value == OrderStatus.delivered) ...[
                const Text(
                  'Tracking Number',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: trackingController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter tracking number',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  validator: selectedStatus.value == OrderStatus.shipped
                      ? OrderService.validateTrackingNumber
                      : null,
                  enabled: !isLoading.value,
                ),
                const SizedBox(height: 16),
              ],
              
              // Notes
              const Text(
                'Notes (Optional)',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Add notes about this status change...',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                maxLines: 3,
                validator: OrderService.validateOrderNotes,
                enabled: !isLoading.value,
              ),
              
              // Status change warning
              if (selectedStatus.value != order.status) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusChangeColor(selectedStatus.value).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusChangeColor(selectedStatus.value).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusChangeIcon(selectedStatus.value),
                        color: _getStatusChangeColor(selectedStatus.value),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getStatusChangeMessage(order.status, selectedStatus.value),
                          style: TextStyle(
                            color: _getStatusChangeColor(selectedStatus.value),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading.value ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading.value || selectedStatus.value == order.status
              ? null
              : () => _handleSubmit(
                    context,
                    ref,
                    formKey,
                    selectedStatus.value,
                    notesController.text,
                    trackingController.text,
                    isLoading,
                  ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Update Status', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  List<OrderStatus> _getAvailableStatuses(OrderStatus currentStatus) {
    // Define valid status transitions
    const validTransitions = {
      OrderStatus.pending: [OrderStatus.pending, OrderStatus.processing, OrderStatus.cancelled],
      OrderStatus.processing: [OrderStatus.processing, OrderStatus.shipped, OrderStatus.cancelled],
      OrderStatus.shipped: [OrderStatus.shipped, OrderStatus.delivered, OrderStatus.cancelled],
      OrderStatus.delivered: [OrderStatus.delivered, OrderStatus.refunded],
      OrderStatus.cancelled: [OrderStatus.cancelled],
      OrderStatus.refunded: [OrderStatus.refunded],
    };

    return validTransitions[currentStatus] ?? [currentStatus];
  }

  Color _getStatusChangeColor(OrderStatus newStatus) {
    switch (newStatus) {
      case OrderStatus.processing:
        return AppColors.primary;
      case OrderStatus.shipped:
        return const Color(0xFF7C3AED); // Purple
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  IconData _getStatusChangeIcon(OrderStatus newStatus) {
    switch (newStatus) {
      case OrderStatus.processing:
        return Icons.hourglass_empty;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusChangeMessage(OrderStatus currentStatus, OrderStatus newStatus) {
    if (newStatus == OrderStatus.shipped) {
      return 'The customer will be notified about the shipment and tracking information.';
    } else if (newStatus == OrderStatus.delivered) {
      return 'This will mark the order as completed and update delivery metrics.';
    } else if (newStatus == OrderStatus.cancelled) {
      return 'This action will cancel the order. Make sure to process any refunds separately.';
    } else if (newStatus == OrderStatus.refunded) {
      return 'This will mark the order as refunded. Ensure the refund has been processed.';
    } else if (newStatus == OrderStatus.processing) {
      return 'The order will be marked as being processed and prepared for shipment.';
    }
    return 'The order status will be updated.';
  }

  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    OrderStatus newStatus,
    String notes,
    String trackingNumber,
    ValueNotifier<bool> isLoading,
  ) async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final crudOperations = ref.read(orderCrudProvider);
      
      await crudOperations.updateOrderStatus(
        order.id,
        newStatus,
        notes: notes.trim().isEmpty ? null : notes.trim(),
        trackingNumber: trackingNumber.trim().isEmpty ? null : trackingNumber.trim(),
      );

      // Refresh orders list
      ref.invalidate(paginatedOrdersProvider);
      ref.invalidate(orderByIdProvider);
      ref.invalidate(recentOrdersProvider);
      ref.invalidate(orderStatisticsProvider);

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${newStatus.displayName}'),
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
    } finally {
      isLoading.value = false;
    }
  }
}