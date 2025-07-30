import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/order_models.dart';
import 'order_status_badge.dart';

class OrderDetailsDialog extends StatelessWidget {
  final Order order;
  final Function(OrderStatus)? onStatusUpdate;

  const OrderDetailsDialog({
    super.key,
    required this.order,
    this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Order Details',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Order info header
            Container(
              padding: const EdgeInsets.all(16),
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
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created: ${DateFormat('MMM dd, yyyy at HH:mm').format(order.createdAt)}',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      OrderStatusBadge(status: order.status),
                      const SizedBox(height: 8),
                      PaymentStatusBadge(status: order.paymentStatus),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer and shipping info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer info
                        Expanded(
                          child: _buildInfoCard(
                            'Customer Information',
                            [
                              _buildInfoRow('Name', order.userName ?? 'N/A'),
                              _buildInfoRow('Email', order.userEmail),
                              if (order.shippingAddress.phoneNumber != null)
                                _buildInfoRow('Phone', order.shippingAddress.phoneNumber!),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Shipping address
                        Expanded(
                          child: _buildInfoCard(
                            'Shipping Address',
                            [
                              _buildInfoRow('Name', order.shippingAddress.fullName),
                              _buildInfoRow('Address', order.shippingAddress.formattedAddress),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Order items
                    _buildInfoCard(
                      'Order Items (${order.totalItems} items)',
                      order.items.map((item) => _buildOrderItem(item)).toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Payment and order summary
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Payment info
                        Expanded(
                          child: _buildInfoCard(
                            'Payment Information',
                            [
                              _buildInfoRow('Method', order.paymentMethod ?? 'N/A'),
                              _buildInfoRow('Status', order.paymentStatus.displayName),
                              if (order.paymentTransactionId != null)
                                _buildInfoRow('Transaction ID', order.paymentTransactionId!),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Order summary
                        Expanded(
                          child: _buildInfoCard(
                            'Order Summary',
                            [
                              _buildInfoRow('Subtotal', order.formattedSubtotal),
                              _buildInfoRow('Tax', order.formattedTaxAmount),
                              _buildInfoRow('Shipping', order.formattedShippingAmount),
                              if (order.discountAmount > 0)
                                _buildInfoRow('Discount', '-${order.formattedDiscountAmount}'),
                              const Divider(),
                              _buildInfoRow(
                                'Total',
                                order.formattedTotalAmount,
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Tracking and notes
                    if (order.trackingNumber != null || order.notes != null) ...[
                      _buildInfoCard(
                        'Additional Information',
                        [
                          if (order.trackingNumber != null)
                            _buildInfoRow('Tracking Number', order.trackingNumber!),
                          if (order.notes != null)
                            _buildInfoRow('Notes', order.notes!),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Timeline
                    _buildTimelineCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                fontSize: isTotal ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: item.productImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      item.productImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.image,
                    color: AppColors.textSecondary,
                  ),
          ),
          const SizedBox(width: 12),
          
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.formattedUnitPrice} × ${item.quantity}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Total price
          Text(
            item.formattedTotalPrice,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    final timelineEvents = <Map<String, dynamic>>[];
    
    // Add created event
    timelineEvents.add({
      'title': 'Order Created',
      'date': order.createdAt,
      'status': 'completed',
    });
    
    // Add status-based events
    if (order.status.index >= OrderStatus.processing.index) {
      timelineEvents.add({
        'title': 'Order Processing',
        'date': order.updatedAt,
        'status': 'completed',
      });
    }
    
    if (order.shippedAt != null) {
      timelineEvents.add({
        'title': 'Order Shipped',
        'date': order.shippedAt!,
        'status': 'completed',
        'details': order.trackingNumber != null ? 'Tracking: ${order.trackingNumber}' : null,
      });
    }
    
    if (order.deliveredAt != null) {
      timelineEvents.add({
        'title': 'Order Delivered',
        'date': order.deliveredAt!,
        'status': 'completed',
      });
    }
    
    if (order.status == OrderStatus.cancelled) {
      timelineEvents.add({
        'title': 'Order Cancelled',
        'date': order.updatedAt,
        'status': 'cancelled',
      });
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Timeline',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...timelineEvents.asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              final isLast = index == timelineEvents.length - 1;
              
              return _buildTimelineEvent(
                event['title'],
                event['date'],
                event['status'],
                details: event['details'],
                isLast: isLast,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineEvent(
    String title,
    DateTime date,
    String status, {
    String? details,
    bool isLast = false,
  }) {
    final isCompleted = status == 'completed';
    final isCancelled = status == 'cancelled';
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isCancelled
                    ? AppColors.error
                    : isCompleted
                        ? AppColors.success
                        : AppColors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        
        // Event details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isCancelled ? AppColors.error : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('MMM dd, yyyy at HH:mm').format(date),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              if (details != null) ...[
                const SizedBox(height: 2),
                Text(
                  details,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}