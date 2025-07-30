import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../models/coupon_models.dart';
import '../../../services/coupon_service.dart';

// Coupon service provider
final couponServiceProvider = Provider<CouponService>((ref) {
  return CouponService();
});

// Coupons list provider with filters
final couponsListProvider = FutureProvider.family<List<Coupon>, CouponFilters?>((ref, filters) async {
  final service = ref.read(couponServiceProvider);
  return await service.getCoupons(filters: filters);
});

// Paginated coupons provider
final paginatedCouponsProvider = FutureProvider.family<List<Coupon>, CouponPaginationParams>((ref, params) async {
  final service = ref.read(couponServiceProvider);
  return await service.getCoupons(
    filters: params.filters,
    page: params.page,
    limit: params.limit,
  );
});

// Coupon by ID provider
final couponByIdProvider = FutureProvider.family<Coupon?, String>((ref, id) async {
  final service = ref.read(couponServiceProvider);
  return await service.getCouponById(id);
});

// Coupon by code provider
final couponByCodeProvider = FutureProvider.family<Coupon?, String>((ref, code) async {
  final service = ref.read(couponServiceProvider);
  return await service.getCouponByCode(code);
});

// Active coupons provider
final activeCouponsProvider = FutureProvider<List<Coupon>>((ref) async {
  final service = ref.read(couponServiceProvider);
  return await service.getActiveCoupons();
});

// Expired coupons provider
final expiredCouponsProvider = FutureProvider<List<Coupon>>((ref) async {
  final service = ref.read(couponServiceProvider);
  return await service.getExpiredCoupons();
});

// Coupon statistics provider
final couponStatisticsProvider = FutureProvider.family<CouponStatistics, CouponDateRange?>((ref, dateRange) async {
  final service = ref.read(couponServiceProvider);
  return await service.getCouponStatistics(
    startDate: dateRange?.startDate,
    endDate: dateRange?.endDate,
  );
});

// Search coupons provider
final searchCouponsProvider = FutureProvider.family<List<Coupon>, String>((ref, query) async {
  if (query.trim().isEmpty) {
    final service = ref.read(couponServiceProvider);
    return await service.getCoupons();
  }
  
  final service = ref.read(couponServiceProvider);
  return await service.searchCoupons(query);
});

// Coupon CRUD operations provider
final couponCrudProvider = Provider<CouponCrudOperations>((ref) {
  return CouponCrudOperations(ref.read(couponServiceProvider));
});

// Coupon filters state provider
final couponFiltersProvider = StateProvider<CouponFilters>((ref) {
  return const CouponFilters();
});

// Current page provider for pagination
final couponCurrentPageProvider = StateProvider<int>((ref) => 1);

// Items per page provider
final couponItemsPerPageProvider = StateProvider<int>((ref) => 20);

// Selected coupons provider for bulk operations
final selectedCouponsProvider = StateProvider<Set<String>>((ref) => {});

class CouponCrudOperations {
  final CouponService _service;
  
  CouponCrudOperations(this._service);
  
  Future<Coupon> createCoupon(CouponFormData data) async {
    return await _service.createCoupon(data);
  }
  
  Future<Coupon> updateCoupon(String id, CouponFormData data) async {
    return await _service.updateCoupon(id, data);
  }
  
  Future<Coupon> updateCouponStatus(String id, CouponStatus status) async {
    return await _service.updateCouponStatus(id, status);
  }
  
  Future<void> deleteCoupon(String id) async {
    return await _service.deleteCoupon(id);
  }
}

// Helper classes for providers
class CouponPaginationParams {
  final CouponFilters? filters;
  final int page;
  final int limit;

  const CouponPaginationParams({
    this.filters,
    required this.page,
    required this.limit,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CouponPaginationParams &&
          runtimeType == other.runtimeType &&
          filters == other.filters &&
          page == other.page &&
          limit == other.limit;

  @override
  int get hashCode => filters.hashCode ^ page.hashCode ^ limit.hashCode;
}

class CouponDateRange {
  final DateTime? startDate;
  final DateTime? endDate;

  const CouponDateRange({
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CouponDateRange &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}

// Computed providers for dashboard metrics
final totalCouponsProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(couponStatisticsProvider(null)).when(
    data: (stats) => AsyncValue.data(stats.totalCoupons),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

final activeCouponsCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(couponStatisticsProvider(null)).when(
    data: (stats) => AsyncValue.data(stats.activeCoupons),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

final totalDiscountGivenProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(couponStatisticsProvider(null)).when(
    data: (stats) => AsyncValue.data(stats.totalDiscountGiven),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

final couponsByStatusProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  return ref.watch(couponStatisticsProvider(null)).when(
    data: (stats) => AsyncValue.data(stats.couponsByStatus),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

final couponsByTypeProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  return ref.watch(couponStatisticsProvider(null)).when(
    data: (stats) => AsyncValue.data(stats.couponsByType),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Coupon status filter options
final couponStatusOptionsProvider = Provider<List<CouponStatus>>((ref) {
  return CouponStatus.values;
});

// Discount type filter options
final discountTypeOptionsProvider = Provider<List<DiscountType>>((ref) {
  return DiscountType.values;
});

// Coupon sort options
final couponSortOptionsProvider = Provider<List<CouponSortBy>>((ref) {
  return CouponSortBy.values;
});