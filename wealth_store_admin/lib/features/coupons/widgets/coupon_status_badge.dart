import 'package:flutter/material.dart';
import '../../../models/coupon_models.dart';

class CouponStatusBadge extends StatelessWidget {
  final CouponStatus status;
  final bool isSmall;

  const CouponStatusBadge({
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
      case CouponStatus.active:
        return const Color(0xFFD1FAE5); // Light green
      case CouponStatus.inactive:
        return const Color(0xFFF3F4F6); // Light gray
      case CouponStatus.expired:
        return const Color(0xFFFEE2E2); // Light red
      case CouponStatus.exhausted:
        return const Color(0xFFFEF3C7); // Light yellow
    }
  }

  Color _getTextColor() {
    switch (status) {
      case CouponStatus.active:
        return const Color(0xFF059669); // Green
      case CouponStatus.inactive:
        return const Color(0xFF6B7280); // Gray
      case CouponStatus.expired:
        return const Color(0xFFDC2626); // Red
      case CouponStatus.exhausted:
        return const Color(0xFFD97706); // Orange
    }
  }
}

class DiscountTypeBadge extends StatelessWidget {
  final DiscountType type;
  final bool isSmall;

  const DiscountTypeBadge({
    super.key,
    required this.type,
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
        type.displayName,
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
    switch (type) {
      case DiscountType.percentage:
        return const Color(0xFFDBEAFE); // Light blue
      case DiscountType.fixed:
        return const Color(0xFFE0E7FF); // Light purple
    }
  }

  Color _getTextColor() {
    switch (type) {
      case DiscountType.percentage:
        return const Color(0xFF2563EB); // Blue
      case DiscountType.fixed:
        return const Color(0xFF7C3AED); // Purple
    }
  }
}