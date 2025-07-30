import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/coupon.dart';
import 'supabase_service.dart';

part 'coupon_service.g.dart';

@riverpod
CouponService couponService(CouponServiceRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return CouponService(supabase);
}

class CouponService {
  final SupabaseClient _client;
  static const String _tableName = 'coupons';
  
  CouponService(this._client);
  
  /// Get all coupons with optional filtering
  Future<List<Coupon>> getCoupons({
    bool? isActive,
    bool? includeExpired = false,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client.from(_tableName).select('*');
      
      // Apply active filter if specified
      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }
      
      // Filter out expired coupons unless explicitly requested
      if (includeExpired != null && !includeExpired) {
        query = query.or('expires_at.is.null,expires_at.gte.${DateTime.now().toIso8601String()}');
      }
      
      // Apply sorting and pagination
      var transformQuery = query.order('created_at', ascending: false);
      
      if (limit != null) {
        transformQuery = transformQuery.limit(limit);
      }
      
      if (offset != null) {
        transformQuery = transformQuery.range(offset, offset + (limit ?? 10) - 1);
      }
      
      final response = await transformQuery;
      
      return (response as List<dynamic>)
          .map((json) => Coupon.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch coupons: $e');
    }
  }
  
  /// Get active coupons only (for customer app display)
  Future<List<Coupon>> getActiveCoupons({int? limit}) async {
    return getCoupons(isActive: true, includeExpired: false, limit: limit);
  }
  
  /// Get a single coupon by ID
  Future<Coupon?> getCouponById(String id) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('*')
          .eq('id', id)
          .single();
      
      return Coupon.fromJson(response);
    } catch (e) {
      if (e is PostgrestException && e.code == 'PGRST116') {
        return null; // Coupon not found
      }
      throw Exception('Failed to fetch coupon: $e');
    }
  }
  
  /// Get a coupon by code (for validation during checkout)
  Future<Coupon?> getCouponByCode(String code) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('*')
          .eq('code', code.toUpperCase())
          .single();
      
      return Coupon.fromJson(response);
    } catch (e) {
      if (e is PostgrestException && e.code == 'PGRST116') {
        return null; // Coupon not found
      }
      throw Exception('Failed to fetch coupon by code: $e');
    }
  }
  
  /// Create a new coupon (Admin only)
  Future<Coupon> createCoupon(CouponFormData data) async {
    try {
      final couponData = data.toJson();
      // Ensure code is uppercase for consistency
      couponData['code'] = couponData['code'].toString().toUpperCase();
      // Add timestamps
      couponData['created_at'] = DateTime.now().toIso8601String();
      couponData['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _client
          .from(_tableName)
          .insert(couponData)
          .select()
          .single();
      
      return Coupon.fromJson(response);
    } catch (e) {
      if (e is PostgrestException && e.code == '23505') {
        throw Exception('Coupon code already exists');
      }
      throw Exception('Failed to create coupon: $e');
    }
  }
  
  /// Update an existing coupon (Admin only)
  Future<Coupon> updateCoupon(String id, CouponFormData data) async {
    try {
      final couponData = data.toJson();
      // Ensure code is uppercase for consistency
      couponData['code'] = couponData['code'].toString().toUpperCase();
      // Update timestamp
      couponData['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _client
          .from(_tableName)
          .update(couponData)
          .eq('id', id)
          .select()
          .single();
      
      return Coupon.fromJson(response);
    } catch (e) {
      if (e is PostgrestException && e.code == '23505') {
        throw Exception('Coupon code already exists');
      }
      throw Exception('Failed to update coupon: $e');
    }
  }
  
  /// Delete a coupon (Admin only)
  Future<void> deleteCoupon(String id) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete coupon: $e');
    }
  }
  
  /// Toggle coupon active status (Admin only)
  Future<Coupon> toggleCouponStatus(String id) async {
    try {
      // First get the current coupon
      final current = await getCouponById(id);
      if (current == null) {
        throw Exception('Coupon not found');
      }
      
      final response = await _client
          .from(_tableName)
          .update({
            'is_active': !current.isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();
      
      return Coupon.fromJson(response);
    } catch (e) {
      throw Exception('Failed to toggle coupon status: $e');
    }
  }
  
  /// Validate a coupon for a specific order amount
  Future<CouponValidationResult> validateCoupon(String code, double orderAmount) async {
    try {
      final coupon = await getCouponByCode(code);
      
      if (coupon == null) {
        return CouponValidationResult.invalid('Coupon not found');
      }
      
      if (!coupon.isActive) {
        return CouponValidationResult.invalid('Coupon is not active');
      }
      
      if (coupon.isExpired) {
        return CouponValidationResult.invalid('Coupon has expired');
      }
      
      if (coupon.isUsageLimitReached) {
        return CouponValidationResult.invalid('Coupon usage limit reached');
      }
      
      if (!coupon.canApplyToOrder(orderAmount)) {
        final minAmount = coupon.minOrderAmount ?? 0;
        return CouponValidationResult.invalid(
          'Minimum order amount of \$${minAmount.toStringAsFixed(2)} required'
        );
      }
      
      final discountAmount = coupon.calculateDiscount(orderAmount);
      return CouponValidationResult.valid(discountAmount);
      
    } catch (e) {
      return CouponValidationResult.invalid('Failed to validate coupon: $e');
    }
  }
  
  /// Apply a coupon (increment usage count)
  Future<Coupon> applyCoupon(String id) async {
    try {
      final coupon = await getCouponById(id);
      if (coupon == null) {
        throw Exception('Coupon not found');
      }
      
      final response = await _client
          .from(_tableName)
          .update({
            'current_uses': coupon.currentUses + 1,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();
      
      return Coupon.fromJson(response);
    } catch (e) {
      throw Exception('Failed to apply coupon: $e');
    }
  }
  
  /// Get coupon usage statistics (Admin only)
  Future<Map<String, dynamic>> getCouponStats(String id) async {
    try {
      final coupon = await getCouponById(id);
      if (coupon == null) {
        throw Exception('Coupon not found');
      }
      
      return {
        'total_uses': coupon.currentUses,
        'remaining_uses': coupon.remainingUses,
        'usage_percentage': coupon.maxUses != null 
            ? (coupon.currentUses / coupon.maxUses! * 100).round()
            : null,
        'is_expired': coupon.isExpired,
        'days_until_expiry': coupon.expiresAt?.difference(DateTime.now()).inDays,
      };
    } catch (e) {
      throw Exception('Failed to get coupon stats: $e');
    }
  }
  
  /// Get expiring coupons (Admin only)
  Future<List<Coupon>> getExpiringCoupons({int daysAhead = 7}) async {
    try {
      final futureDate = DateTime.now().add(Duration(days: daysAhead));
      
      final response = await _client
          .from(_tableName)
          .select('*')
          .eq('is_active', true)
          .lte('expires_at', futureDate.toIso8601String())
          .gte('expires_at', DateTime.now().toIso8601String())
          .order('expires_at', ascending: true);
      
      return (response as List<dynamic>)
          .map((json) => Coupon.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch expiring coupons: $e');
    }
  }
  
  /// Get coupon count for pagination
  Future<int> getCouponCount({bool? isActive, bool? includeExpired = false}) async {
    try {
      var query = _client.from(_tableName).select('id');
      
      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }
      
      if (includeExpired != null && !includeExpired) {
        query = query.or('expires_at.is.null,expires_at.gte.${DateTime.now().toIso8601String()}');
      }
      
      final response = await query;
      return (response as List<dynamic>).length;
    } catch (e) {
      throw Exception('Failed to get coupon count: $e');
    }
  }
  
  /// Get active coupon count
  Future<int> getActiveCouponCount() async {
    return getCouponCount(isActive: true, includeExpired: false);
  }
  
  /// Batch operations for admin
  Future<List<Coupon>> createMultipleCoupons(List<CouponFormData> coupons) async {
    try {
      final couponsData = coupons.map((c) {
        final data = c.toJson();
        data['code'] = data['code'].toString().toUpperCase();
        data['created_at'] = DateTime.now().toIso8601String();
        data['updated_at'] = DateTime.now().toIso8601String();
        return data;
      }).toList();
      
      final response = await _client
          .from(_tableName)
          .insert(couponsData)
          .select();
      
      return (response as List<dynamic>)
          .map((json) => Coupon.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to create multiple coupons: $e');
    }
  }
  
  Future<void> deleteMultipleCoupons(List<String> ids) async {
    try {
      // Delete coupons one by one for now
      for (final id in ids) {
        await deleteCoupon(id);
      }
    } catch (e) {
      throw Exception('Failed to delete multiple coupons: $e');
    }
  }
  
  /// Real-time subscription for coupons
  Stream<List<Coupon>> watchCoupons({bool? isActive}) {
    // For now, return a simple stream that fetches coupons periodically
    // This can be enhanced later with proper real-time subscriptions
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      return await getCoupons(isActive: isActive);
    }).asyncMap((future) => future);
  }
  
  /// Real-time subscription for active coupons only
  Stream<List<Coupon>> watchActiveCoupons() {
    return watchCoupons(isActive: true);
  }
  
  /// Connection health check
  Future<bool> checkConnection() async {
    try {
      await _client.from(_tableName).select('id').limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}