import 'package:flutter/material.dart';
import '../../../models/order_models.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool isSmall;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: _getTextColor(),
          fontSize: isSmall ? 10 : 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFFEF3C7); // Light yellow
      case OrderStatus.processing:
        return const Color(0xFFDBEAFE); // Light blue
      case OrderStatus.shipped:
        return const Color(0xFFE0E7FF); // Light purple
      case OrderStatus.delivered:
        return const Color(0xFFD1FAE5); // Light green
      case OrderStatus.cancelled:
        return const Color(0xFFFEE2E2); // Light red
      case OrderStatus.refunded:
        return const Color(0xFFF3F4F6); // Light gray
    }
  }

  Color _getTextColor() {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFD97706); // Orange
      case OrderStatus.processing:
        return const Color(0xFF2563EB); // Blue
      case OrderStatus.shipped:
        return const Color(0xFF7C3AED); // Purple
      case OrderStatus.delivered:
        return const Color(0xFF059669); // Green
      case OrderStatus.cancelled:
        return const Color(0xFFDC2626); // Red
      case OrderStatus.refunded:
        return const Color(0xFF6B7280); // Gray
    }
  }
}

class PaymentStatusBadge extends StatelessWidget {
  final PaymentStatus status;
  final bool isSmall;

  const PaymentStatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: _getTextColor(),
          fontSize: isSmall ? 10 : 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case PaymentStatus.pending:
        return const Color(0xFFFEF3C7); // Light yellow
      case PaymentStatus.paid:
        return const Color(0xFFD1FAE5); // Light green
      case PaymentStatus.failed:
        return const Color(0xFFFEE2E2); // Light red
      case PaymentStatus.refunded:
        return const Color(0xFFF3F4F6); // Light gray
    }
  }

  Color _getTextColor() {
    switch (status) {
      case PaymentStatus.pending:
        return const Color(0xFFD97706); // Orange
      case PaymentStatus.paid:
        return const Color(0xFF059669); // Green
      case PaymentStatus.failed:
        return const Color(0xFFDC2626); // Red
      case PaymentStatus.refunded:
        return const Color(0xFF6B7280); // Gray
    }
  }
}