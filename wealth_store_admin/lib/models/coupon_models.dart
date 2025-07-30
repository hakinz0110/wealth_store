enum DiscountType {
  percentage,
  fixed;

  String get displayName {
    switch (this) {
      case DiscountType.percentage:
        return 'Percentage';
      case DiscountType.fixed:
        return 'Fixed Amount';
    }
  }

  static DiscountType fromString(String type) {
    return DiscountType.values.firstWhere(
      (e) => e.name == type.toLowerCase(),
      orElse: () => DiscountType.percentage,
    );
  }
}

enum CouponStatus {
  active,
  inactive,
  expired,
  exhausted;

  String get displayName {
    switch (this) {
      case CouponStatus.active:
        return 'Active';
      case CouponStatus.inactive:
        return 'Inactive';
      case CouponStatus.expired:
        return 'Expired';
      case CouponStatus.exhausted:
        return 'Exhausted';
    }
  }

  String get color {
    switch (this) {
      case CouponStatus.active:
        return '#10B981'; // Green
      case CouponStatus.inactive:
        return '#6B7280'; // Gray
      case CouponStatus.expired:
        return '#EF4444'; // Red
      case CouponStatus.exhausted:
        return '#F59E0B'; // Orange
    }
  }

  static CouponStatus fromString(String status) {
    return CouponStatus.values.firstWhere(
      (e) => e.name == status.toLowerCase(),
      orElse: () => CouponStatus.active,
    );
  }
}

class Coupon {
  final String id;
  final String code;
  final String name;
  final String? description;
  final DiscountType discountType;
  final double discountValue;
  final double? minimumOrderAmount;
  final double? maximumDiscountAmount;
  final int? usageLimit;
  final int usageCount;
  final DateTime? startDate;
  final DateTime? endDate;
  final CouponStatus status;
  final List<String>? applicableCategories;
  final List<String>? applicableProducts;
  final bool isFirstTimeUserOnly;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Coupon({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minimumOrderAmount,
    this.maximumDiscountAmount,
    this.usageLimit,
    this.usageCount = 0,
    this.startDate,
    this.endDate,
    required this.status,
    this.applicableCategories,
    this.applicableProducts,
    this.isFirstTimeUserOnly = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      discountType: DiscountType.fromString(json['discount_type'] as String),
      discountValue: (json['discount_value'] as num).toDouble(),
      minimumOrderAmount: (json['minimum_order_amount'] as num?)?.toDouble(),
      maximumDiscountAmount: (json['maximum_discount_amount'] as num?)?.toDouble(),
      usageLimit: (json['usage_limit'] as num?)?.toInt(),
      usageCount: (json['usage_count'] as num?)?.toInt() ?? 0,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      status: CouponStatus.fromString(json['status'] as String? ?? 'active'),
      applicableCategories: (json['applicable_categories'] as List<dynamic>?)?.cast<String>(),
      applicableProducts: (json['applicable_products'] as List<dynamic>?)?.cast<String>(),
      isFirstTimeUserOnly: json['is_first_time_user_only'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'discount_type': discountType.name,
      'discount_value': discountValue,
      'minimum_order_amount': minimumOrderAmount,
      'maximum_discount_amount': maximumDiscountAmount,
      'usage_limit': usageLimit,
      'usage_count': usageCount,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status.name,
      'applicable_categories': applicableCategories,
      'applicable_products': applicableProducts,
      'is_first_time_user_only': isFirstTimeUserOnly,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Coupon copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    DiscountType? discountType,
    double? discountValue,
    double? minimumOrderAmount,
    double? maximumDiscountAmount,
    int? usageLimit,
    int? usageCount,
    DateTime? startDate,
    DateTime? endDate,
    CouponStatus? status,
    List<String>? applicableCategories,
    List<String>? applicableProducts,
    bool? isFirstTimeUserOnly,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      maximumDiscountAmount: maximumDiscountAmount ?? this.maximumDiscountAmount,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      applicableCategories: applicableCategories ?? this.applicableCategories,
      applicableProducts: applicableProducts ?? this.applicableProducts,
      isFirstTimeUserOnly: isFirstTimeUserOnly ?? this.isFirstTimeUserOnly,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  String get formattedDiscountValue {
    if (discountType == DiscountType.percentage) {
      return '${discountValue.toStringAsFixed(0)}%';
    } else {
      return '\$${discountValue.toStringAsFixed(2)}';
    }
  }

  String get formattedMinimumOrderAmount => minimumOrderAmount != null 
      ? '\$${minimumOrderAmount!.toStringAsFixed(2)}' 
      : 'No minimum';

  String get formattedMaximumDiscountAmount => maximumDiscountAmount != null 
      ? '\$${maximumDiscountAmount!.toStringAsFixed(2)}' 
      : 'No limit';

  bool get isExpired => endDate != null && DateTime.now().isAfter(endDate!);
  bool get isNotStarted => startDate != null && DateTime.now().isBefore(startDate!);
  bool get isExhausted => usageLimit != null && usageCount >= usageLimit!;
  bool get isActiveComputed => isActive && status == CouponStatus.active && !isExpired && !isNotStarted && !isExhausted;

  double get usagePercentage => usageLimit != null && usageLimit! > 0 
      ? (usageCount / usageLimit!) * 100 
      : 0.0;

  String get usageDisplay => usageLimit != null 
      ? '$usageCount / $usageLimit' 
      : '$usageCount';

  CouponStatus get computedStatus {
    if (status == CouponStatus.inactive) return CouponStatus.inactive;
    if (isExpired) return CouponStatus.expired;
    if (isExhausted) return CouponStatus.exhausted;
    return CouponStatus.active;
  }
}

// Coupon filters and sorting
enum CouponSortBy {
  code,
  name,
  createdAt,
  endDate,
  usageCount,
  discountValue,
  status,
}

enum SortOrder {
  ascending,
  descending,
}

class CouponFilters {
  final CouponStatus? status;
  final DiscountType? discountType;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minDiscountValue;
  final double? maxDiscountValue;
  final bool? hasUsageLimit;
  final bool? isExpired;
  final bool? isFirstTimeUserOnly;
  final String? searchQuery; // Search by code, name, or description
  final CouponSortBy sortBy;
  final SortOrder sortOrder;

  const CouponFilters({
    this.status,
    this.discountType,
    this.startDate,
    this.endDate,
    this.minDiscountValue,
    this.maxDiscountValue,
    this.hasUsageLimit,
    this.isExpired,
    this.isFirstTimeUserOnly,
    this.searchQuery,
    this.sortBy = CouponSortBy.createdAt,
    this.sortOrder = SortOrder.descending,
  });

  CouponFilters copyWith({
    CouponStatus? status,
    DiscountType? discountType,
    DateTime? startDate,
    DateTime? endDate,
    double? minDiscountValue,
    double? maxDiscountValue,
    bool? hasUsageLimit,
    bool? isExpired,
    bool? isFirstTimeUserOnly,
    String? searchQuery,
    CouponSortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    return CouponFilters(
      status: status ?? this.status,
      discountType: discountType ?? this.discountType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minDiscountValue: minDiscountValue ?? this.minDiscountValue,
      maxDiscountValue: maxDiscountValue ?? this.maxDiscountValue,
      hasUsageLimit: hasUsageLimit ?? this.hasUsageLimit,
      isExpired: isExpired ?? this.isExpired,
      isFirstTimeUserOnly: isFirstTimeUserOnly ?? this.isFirstTimeUserOnly,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status?.name,
      'discount_type': discountType?.name,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'min_discount_value': minDiscountValue,
      'max_discount_value': maxDiscountValue,
      'has_usage_limit': hasUsageLimit,
      'is_expired': isExpired,
      'is_first_time_user_only': isFirstTimeUserOnly,
      'search_query': searchQuery,
      'sort_by': sortBy.name,
      'sort_order': sortOrder.name,
    };
  }
}

// Coupon form data
class CouponFormData {
  final String code;
  final String name;
  final String? description;
  final DiscountType discountType;
  final double discountValue;
  final double? minimumOrderAmount;
  final double? maximumDiscountAmount;
  final int? usageLimit;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? applicableCategories;
  final List<String>? applicableProducts;
  final bool isFirstTimeUserOnly;
  final bool isActive;

  const CouponFormData({
    required this.code,
    required this.name,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minimumOrderAmount,
    this.maximumDiscountAmount,
    this.usageLimit,
    this.startDate,
    this.endDate,
    this.applicableCategories,
    this.applicableProducts,
    this.isFirstTimeUserOnly = false,
    this.isActive = true,
  });

  factory CouponFormData.empty() {
    return const CouponFormData(
      code: '',
      name: '',
      discountType: DiscountType.percentage,
      discountValue: 0.0,
      isActive: true,
    );
  }

  factory CouponFormData.fromCoupon(Coupon coupon) {
    return CouponFormData(
      code: coupon.code,
      name: coupon.name,
      description: coupon.description,
      discountType: coupon.discountType,
      discountValue: coupon.discountValue,
      minimumOrderAmount: coupon.minimumOrderAmount,
      maximumDiscountAmount: coupon.maximumDiscountAmount,
      usageLimit: coupon.usageLimit,
      startDate: coupon.startDate,
      endDate: coupon.endDate,
      applicableCategories: coupon.applicableCategories,
      applicableProducts: coupon.applicableProducts,
      isFirstTimeUserOnly: coupon.isFirstTimeUserOnly,
      isActive: coupon.status == CouponStatus.active,
    );
  }

  CouponFormData copyWith({
    String? code,
    String? name,
    String? description,
    DiscountType? discountType,
    double? discountValue,
    double? minimumOrderAmount,
    double? maximumDiscountAmount,
    int? usageLimit,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? applicableCategories,
    List<String>? applicableProducts,
    bool? isFirstTimeUserOnly,
    bool? isActive,
  }) {
    return CouponFormData(
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      maximumDiscountAmount: maximumDiscountAmount ?? this.maximumDiscountAmount,
      usageLimit: usageLimit ?? this.usageLimit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      applicableCategories: applicableCategories ?? this.applicableCategories,
      applicableProducts: applicableProducts ?? this.applicableProducts,
      isFirstTimeUserOnly: isFirstTimeUserOnly ?? this.isFirstTimeUserOnly,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'discount_type': discountType.name,
      'discount_value': discountValue,
      'minimum_order_amount': minimumOrderAmount,
      'maximum_discount_amount': maximumDiscountAmount,
      'usage_limit': usageLimit,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'applicable_categories': applicableCategories,
      'applicable_products': applicableProducts,
      'is_first_time_user_only': isFirstTimeUserOnly,
      'is_active': isActive,
    };
  }
}

// Coupon statistics for dashboard
class CouponStatistics {
  final int totalCoupons;
  final int activeCoupons;
  final int expiredCoupons;
  final int exhaustedCoupons;
  final double totalDiscountGiven;
  final int totalUsageCount;
  final Map<String, int> couponsByStatus;
  final Map<String, int> couponsByType;
  final Map<String, double> discountByMonth;

  const CouponStatistics({
    required this.totalCoupons,
    required this.activeCoupons,
    required this.expiredCoupons,
    required this.exhaustedCoupons,
    required this.totalDiscountGiven,
    required this.totalUsageCount,
    required this.couponsByStatus,
    required this.couponsByType,
    required this.discountByMonth,
  });

  factory CouponStatistics.fromJson(Map<String, dynamic> json) {
    return CouponStatistics(
      totalCoupons: (json['total_coupons'] as num).toInt(),
      activeCoupons: (json['active_coupons'] as num).toInt(),
      expiredCoupons: (json['expired_coupons'] as num).toInt(),
      exhaustedCoupons: (json['exhausted_coupons'] as num).toInt(),
      totalDiscountGiven: (json['total_discount_given'] as num).toDouble(),
      totalUsageCount: (json['total_usage_count'] as num).toInt(),
      couponsByStatus: Map<String, int>.from(json['coupons_by_status'] as Map),
      couponsByType: Map<String, int>.from(json['coupons_by_type'] as Map),
      discountByMonth: Map<String, double>.from(json['discount_by_month'] as Map),
    );
  }

  String get formattedTotalDiscountGiven => '\$${totalDiscountGiven.toStringAsFixed(2)}';
}

// Coupon validation error
class CouponValidationError {
  final String field;
  final String message;

  const CouponValidationError({
    required this.field,
    required this.message,
  });
}