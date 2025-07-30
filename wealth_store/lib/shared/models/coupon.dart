import 'package:freezed_annotation/freezed_annotation.dart';

part 'coupon.freezed.dart';
part 'coupon.g.dart';

@freezed
class Coupon with _$Coupon {
  const factory Coupon({
    required String id,
    required String code,
    String? description,
    @JsonKey(name: 'discount_type') required String discountType, // 'percentage' or 'fixed'
    @JsonKey(name: 'discount_value') required double discountValue,
    @JsonKey(name: 'min_order_amount') double? minOrderAmount,
    @JsonKey(name: 'max_uses') int? maxUses,
    @JsonKey(name: 'current_uses') @Default(0) int currentUses,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Coupon;

  factory Coupon.fromJson(Map<String, dynamic> json) => _$CouponFromJson(json);
}

extension CouponValidation on Coupon {
  /// Check if coupon is valid for use
  bool get isValid {
    if (!isActive) return false;
    if (isExpired) return false;
    if (isUsageLimitReached) return false;
    return true;
  }
  
  /// Check if coupon has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
  
  /// Check if usage limit has been reached
  bool get isUsageLimitReached {
    if (maxUses == null) return false;
    return currentUses >= maxUses!;
  }
  
  /// Check if order amount meets minimum requirement
  bool canApplyToOrder(double orderAmount) {
    if (!isValid) return false;
    if (minOrderAmount == null) return true;
    return orderAmount >= minOrderAmount!;
  }
  
  /// Calculate discount amount for given order total
  double calculateDiscount(double orderAmount) {
    if (!canApplyToOrder(orderAmount)) return 0.0;
    
    switch (discountType) {
      case 'percentage':
        return orderAmount * (discountValue / 100);
      case 'fixed':
        return discountValue;
      default:
        return 0.0;
    }
  }
  
  /// Get remaining uses
  int? get remainingUses {
    if (maxUses == null) return null;
    return maxUses! - currentUses;
  }
}

@freezed
class CouponFormData with _$CouponFormData {
  const factory CouponFormData({
    required String code,
    String? description,
    @JsonKey(name: 'discount_type') required String discountType,
    @JsonKey(name: 'discount_value') required double discountValue,
    @JsonKey(name: 'min_order_amount') double? minOrderAmount,
    @JsonKey(name: 'max_uses') int? maxUses,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _CouponFormData;

  factory CouponFormData.fromJson(Map<String, dynamic> json) => _$CouponFormDataFromJson(json);
  
  factory CouponFormData.empty() {
    return const CouponFormData(
      code: '',
      discountType: 'percentage',
      discountValue: 0.0,
    );
  }
  
  factory CouponFormData.fromCoupon(Coupon coupon) {
    return CouponFormData(
      code: coupon.code,
      description: coupon.description,
      discountType: coupon.discountType,
      discountValue: coupon.discountValue,
      minOrderAmount: coupon.minOrderAmount,
      maxUses: coupon.maxUses,
      expiresAt: coupon.expiresAt,
      isActive: coupon.isActive,
    );
  }
}

@freezed
class CouponValidationResult with _$CouponValidationResult {
  const factory CouponValidationResult({
    required bool isValid,
    String? errorMessage,
    double? discountAmount,
  }) = _CouponValidationResult;
  
  factory CouponValidationResult.valid(double discountAmount) {
    return CouponValidationResult(
      isValid: true,
      discountAmount: discountAmount,
    );
  }
  
  factory CouponValidationResult.invalid(String errorMessage) {
    return CouponValidationResult(
      isValid: false,
      errorMessage: errorMessage,
    );
  }
}