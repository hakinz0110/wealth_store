import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/constants/app_colors.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final double changePercentage;
  final String comparisonText;
  final IconData icon;
  final Color? iconColor;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.changePercentage,
    required this.comparisonText,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = changePercentage >= 0;
    final changeColor = isPositive ? AppColors.success : AppColors.error;
    final changeIcon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and icon
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  icon,
                  size: 18,
                  color: iconColor ?? AppColors.textMuted,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Main value
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Change indicator - Stack vertically on small screens
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 150) {
                  // Stack vertically for very small cards
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            changeIcon,
                            size: 14,
                            color: changeColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isPositive ? '+' : ''}${changePercentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: changeColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        comparisonText,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  );
                } else {
                  // Horizontal layout for normal cards
                  return Row(
                    children: [
                      Icon(
                        changeIcon,
                        size: 14,
                        color: changeColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isPositive ? '+' : ''}${changePercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: changeColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          comparisonText,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Factory constructors for different metric types
  factory MetricCard.salesTotal({
    required double amount,
    required double changePercentage,
  }) {
    return MetricCard(
      title: 'Sales Total',
      value: NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount),
      changePercentage: changePercentage,
      comparisonText: 'Compared to last month',
      icon: Icons.trending_up,
      iconColor: AppColors.success,
    );
  }

  factory MetricCard.averageOrderValue({
    required double amount,
    required double changePercentage,
  }) {
    return MetricCard(
      title: 'Average Order Value',
      value: NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount),
      changePercentage: changePercentage,
      comparisonText: 'Compared to last month',
      icon: Icons.shopping_cart,
      iconColor: AppColors.info,
    );
  }

  factory MetricCard.totalOrders({
    required int count,
    required double changePercentage,
  }) {
    return MetricCard(
      title: 'Total Orders',
      value: NumberFormat('#,###').format(count),
      changePercentage: changePercentage,
      comparisonText: 'Compared to last month',
      icon: Icons.receipt_long,
      iconColor: AppColors.warning,
    );
  }

  factory MetricCard.visitors({
    required int count,
    required double changePercentage,
  }) {
    return MetricCard(
      title: 'Visitors',
      value: NumberFormat('#,###').format(count),
      changePercentage: changePercentage,
      comparisonText: 'Compared to last month',
      icon: Icons.people,
      iconColor: AppColors.chartPurple,
    );
  }
}