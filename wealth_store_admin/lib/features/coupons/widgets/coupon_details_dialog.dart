import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/coupon_models.dart';
import 'coupon_status_badge.dart';

class CouponDetailsDialog extends StatelessWidget {
  final Coupon coupon;

  const CouponDetailsDialog({
    super.key,
    required this.coupon,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Coupon Details',
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
            
            // Coupon header
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                              ),
                              child: Text(
                                coupon.code,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            CouponStatusBadge(status: coupon.computedStatus),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          coupon.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (coupon.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            coupon.description!,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
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
                    // Discount and usage info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Discount information
                        Expanded(
                          child: _buildInfoCard(
                            'Discount Information',
                            [
                              _buildInfoRow('Type', coupon.discountType.displayName),
                              _buildInfoRow('Value', coupon.formattedDiscountValue),
                              if (coupon.minimumOrderAmount != null)
                                _buildInfoRow('Minimum Order', coupon.formattedMinimumOrderAmount),
                              if (coupon.maximumDiscountAmount != null)
                                _buildInfoRow('Maximum Discount', coupon.formattedMaximumDiscountAmount),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Usage information
                        Expanded(
                          child: _buildInfoCard(
                            'Usage Information',
                            [
                              _buildInfoRow('Used', coupon.usageDisplay),
                              if (coupon.usageLimit != null) ...[
                                _buildInfoRow('Usage Rate', '${coupon.usagePercentage.toStringAsFixed(1)}%'),
                                const SizedBox(height: 8),
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
                              if (coupon.isFirstTimeUserOnly)
                                _buildInfoRow('Restriction', 'First-time users only'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Validity and dates
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Validity period
                        Expanded(
                          child: _buildInfoCard(
                            'Validity Period',
                            [
                              if (coupon.startDate != null)
                                _buildInfoRow('Start Date', DateFormat('MMM dd, yyyy at HH:mm').format(coupon.startDate!))
                              else
                                _buildInfoRow('Start Date', 'Immediate'),
                              if (coupon.endDate != null)
                                _buildInfoRow('End Date', DateFormat('MMM dd, yyyy at HH:mm').format(coupon.endDate!))
                              else
                                _buildInfoRow('End Date', 'No expiry'),
                              if (coupon.isExpired)
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.warning, color: AppColors.error, size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        'This coupon has expired',
                                        style: TextStyle(color: AppColors.error, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // System information
                        Expanded(
                          child: _buildInfoCard(
                            'System Information',
                            [
                              _buildInfoRow('Created', DateFormat('MMM dd, yyyy at HH:mm').format(coupon.createdAt)),
                              _buildInfoRow('Last Updated', DateFormat('MMM dd, yyyy at HH:mm').format(coupon.updatedAt)),
                              _buildInfoRow('Status', coupon.status.displayName),
                              _buildInfoRow('Computed Status', coupon.computedStatus.displayName),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Applicable products/categories (if any)
                    if (coupon.applicableCategories != null || coupon.applicableProducts != null) ...[
                      _buildInfoCard(
                        'Restrictions',
                        [
                          if (coupon.applicableCategories != null && coupon.applicableCategories!.isNotEmpty)
                            _buildInfoRow('Categories', coupon.applicableCategories!.join(', ')),
                          if (coupon.applicableProducts != null && coupon.applicableProducts!.isNotEmpty)
                            _buildInfoRow('Products', coupon.applicableProducts!.join(', ')),
                        ],
                      ),
                    ],
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}