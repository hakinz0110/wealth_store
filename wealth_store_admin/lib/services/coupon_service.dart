import '../models/coupon_models.dart';
import '../shared/utils/logger.dart';
import '../shared/utils/error_handler.dart';
import 'supabase_service.dart';

class CouponService {
  static const String _tableName = 'coupons';

  // Get all coupons from Supabase with optional filters
  Future<List<Coupon>> getCoupons({
    CouponFilters? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Logger.info('Fetching coupons from Supabase - Page: $page, Limit: $limit');
      
      var query = SupabaseService.client
          .from(_tableName)
          .select('*');

      // Apply filters
      if (filters != null) {
        if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
          query = query.or('code.ilike.%${filters.searchQuery}%,name.ilike.%${filters.searchQuery}%');
        }
        
        if (filters.status != null) {
          query = query.eq('status', filters.status!.name);
        }
        
        if (filters.discountType != null) {
          query = query.eq('discount_type', filters.discountType!.name);
        }
        
        if (filters.isActive != null) {
          query = query.eq('is_active', filters.isActive!);
        }
      }

      // Apply sorting
      if (filters?.sortBy != null) {
        String orderColumn;
        switch (filters!.sortBy!) {
          case CouponSortBy.code:
            orderColumn = 'code';
            break;
          case CouponSortBy.name:
            orderColumn = 'name';
            break;
          case CouponSortBy.discountValue:
            orderColumn = 'discount_value';
            break;
          case CouponSortBy.usageCount:
            orderColumn = 'usage_count';
            break;
          case CouponSortBy.createdAt:
          default:
            orderColumn = 'created_at';
            break;
        }
        
        query = query.order(orderColumn, ascending: filters.sortOrder == SortOrder.ascending);
      } else {
        query = query.order('created_at', ascending: false);
      }

      // Apply pagination
      final offset = (page - 1) * limit;
      query = query.range(offset, offset + limit - 1);

      final response = await query;
      return response.map<Coupon>((json) => Coupon.fromJson(json)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get coupons', e, stackTrace);
      rethrow;
    }
  }

  // Get coupon by ID from Supabase
  Future<Coupon?> getCouponById(String id) async {
    try {
      Logger.info('Fetching coupon by ID: $id');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*')
          .eq('id', id)
          .single();

      return Coupon.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get coupon by ID', e, stackTrace);
      return null;
    }
  }

  // Get coupon by code from Supabase
  Future<Coupon?> getCouponByCode(String code) async {
    try {
      Logger.info('Fetching coupon by code: $code');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*')
          .eq('code', code.toUpperCase())
          .single();

      return Coupon.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get coupon by code', e, stackTrace);
      return null;
    }
  }

  // Create new coupon in Supabase
  Future<Coupon> createCoupon(CouponFormData data) async {
    try {
      Logger.info('Creating new coupon: ${data.code}');

      // Validate data
      final errors = validateCouponData(data);
      if (errors.isNotEmpty) {
        throw Exception('Validation failed: ${errors.map((e) => e.message).join(', ')}');
      }

      // Check if coupon code already exists
      final existingCoupons = await SupabaseService.client
          .from(_tableName)
          .select('id')
          .eq('code', data.code.toUpperCase());

      if (existingCoupons.isNotEmpty) {
        throw Exception('Coupon code already exists');
      }

      // Insert new coupon
      final response = await SupabaseService.client
          .from(_tableName)
          .insert({
            'code': data.code.toUpperCase(),
            'name': data.name,
            'description': data.description,
            'discount_type': data.discountType.name,
            'discount_value': data.discountValue,
            'minimum_order_amount': data.minimumOrderAmount,
            'maximum_discount_amount': data.maximumDiscountAmount,
            'usage_limit': data.usageLimit,
            'usage_count': 0,
            'is_active': data.isActive,
            'start_date': data.startDate.toIso8601String(),
            'end_date': data.endDate?.toIso8601String(),
            'applicable_categories': data.applicableCategories,
            'applicable_products': data.applicableProducts,
            'is_first_time_user_only': data.isFirstTimeUserOnly,
            'status': _calculateCouponStatus(data),
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      Logger.info('Coupon created successfully: ${data.code}');
      return Coupon.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Create coupon', e, stackTrace);
      rethrow;
    }
  }

  // Update coupon in Supabase
  Future<Coupon> updateCoupon(String id, CouponFormData data) async {
    try {
      Logger.info('Updating coupon: $id');

      // Validate data
      final errors = validateCouponData(data);
      if (errors.isNotEmpty) {
        throw Exception('Validation failed: ${errors.map((e) => e.message).join(', ')}');
      }

      // Check if coupon code already exists (excluding current coupon)
      final existingCoupons = await SupabaseService.client
          .from(_tableName)
          .select('id')
          .eq('code', data.code.toUpperCase())
          .neq('id', id);

      if (existingCoupons.isNotEmpty) {
        throw Exception('Coupon code already exists');
      }

      // Get current coupon to preserve usage_count
      final currentCoupon = await getCouponById(id);
      if (currentCoupon == null) {
        throw Exception('Coupon not found');
      }

      // Update coupon
      final response = await SupabaseService.client
          .from(_tableName)
          .update({
            'code': data.code.toUpperCase(),
            'name': data.name,
            'description': data.description,
            'discount_type': data.discountType.name,
            'discount_value': data.discountValue,
            'minimum_order_amount': data.minimumOrderAmount,
            'maximum_discount_amount': data.maximumDiscountAmount,
            'usage_limit': data.usageLimit,
            'is_active': data.isActive,
            'start_date': data.startDate.toIso8601String(),
            'end_date': data.endDate?.toIso8601String(),
            'applicable_categories': data.applicableCategories,
            'applicable_products': data.applicableProducts,
            'is_first_time_user_only': data.isFirstTimeUserOnly,
            'status': _calculateCouponStatus(data, currentCoupon.usageCount),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      Logger.info('Coupon updated successfully: $id');
      return Coupon.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Update coupon', e, stackTrace);
      rethrow;
    }
  }

  // Delete coupon from Supabase
  Future<void> deleteCoupon(String id) async {
    try {
      Logger.info('Deleting coupon: $id');

      await SupabaseService.client
          .from(_tableName)
          .delete()
          .eq('id', id);

      Logger.info('Coupon deleted successfully: $id');
    } catch (e, stackTrace) {
      ErrorHandler.logError('Delete coupon', e, stackTrace);
      rethrow;
    }
  }

  // Toggle coupon active status
  Future<Coupon> toggleCouponStatus(String id) async {
    try {
      Logger.info('Toggling coupon status: $id');

      final coupon = await getCouponById(id);
      if (coupon == null) {
        throw Exception('Coupon not found');
      }

      final newStatus = !coupon.isActive;
      final response = await SupabaseService.client
          .from(_tableName)
          .update({
            'is_active': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      Logger.info('Coupon status toggled successfully: $id');
      return Coupon.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Toggle coupon status', e, stackTrace);
      rethrow;
    }
  }

  // Get coupon usage statistics
  Future<Map<String, dynamic>> getCouponUsageStats(String id) async {
    try {
      Logger.info('Fetching coupon usage stats: $id');

      final coupon = await getCouponById(id);
      if (coupon == null) {
        throw Exception('Coupon not found');
      }

      // Calculate usage percentage
      final usagePercentage = coupon.usageLimit > 0 
          ? (coupon.usageCount / coupon.usageLimit * 100).round()
          : 0;

      // Get recent usage (if order_coupons table exists)
      // This would require a separate table to track coupon usage
      
      return {
        'total_usage': coupon.usageCount,
        'usage_limit': coupon.usageLimit,
        'usage_percentage': usagePercentage,
        'remaining_uses': coupon.usageLimit > 0 
            ? (coupon.usageLimit - coupon.usageCount).clamp(0, coupon.usageLimit)
            : null,
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get coupon usage stats', e, stackTrace);
      rethrow;
    }
  }

  // Static validation methods for form fields
  static String? validateCouponCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Coupon code is required';
    }
    if (value.trim().length < 3) {
      return 'Coupon code must be at least 3 characters long';
    }
    if (value.trim().length > 20) {
      return 'Coupon code cannot exceed 20 characters';
    }
    return null;
  }

  static String? validateCouponName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Coupon name is required';
    }
    return null;
  }

  static String? validateCouponDescription(String? value) {
    // Description is optional, so no validation needed
    return null;
  }

  static String? validateDiscountValue(String? value, DiscountType discountType) {
    if (value == null || value.trim().isEmpty) {
      return 'Discount value is required';
    }
    
    final discountValue = double.tryParse(value);
    if (discountValue == null) {
      return 'Please enter a valid number';
    }
    
    if (discountValue <= 0) {
      return 'Discount value must be greater than 0';
    }
    
    if (discountType == DiscountType.percentage && discountValue > 100) {
      return 'Percentage discount cannot exceed 100%';
    }
    
    if (discountType == DiscountType.fixed && discountValue > 10000) {
      return 'Fixed discount cannot exceed \$10,000';
    }
    
    return null;
  }

  static String? validateMinimumOrderAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }
    
    if (amount < 0) {
      return 'Minimum order amount cannot be negative';
    }
    
    return null;
  }

  static String? validateMaximumDiscountAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }
    
    if (amount <= 0) {
      return 'Maximum discount amount must be greater than 0';
    }
    
    return null;
  }

  static String? validateUsageLimit(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    final limit = int.tryParse(value);
    if (limit == null) {
      return 'Please enter a valid number';
    }
    
    if (limit <= 0) {
      return 'Usage limit must be greater than 0';
    }
    
    return null;
  }

  // Validate coupon data
  List<CouponValidationError> validateCouponData(CouponFormData data) {
    final errors = <CouponValidationError>[];

    // Code validation
    if (data.code.trim().isEmpty) {
      errors.add(const CouponValidationError(
        field: 'code',
        message: 'Coupon code is required',
      ));
    } else if (data.code.trim().length < 3) {
      errors.add(const CouponValidationError(
        field: 'code',
        message: 'Coupon code must be at least 3 characters long',
      ));
    } else if (data.code.trim().length > 20) {
      errors.add(const CouponValidationError(
        field: 'code',
        message: 'Coupon code cannot exceed 20 characters',
      ));
    }

    // Name validation
    if (data.name.trim().isEmpty) {
      errors.add(const CouponValidationError(
        field: 'name',
        message: 'Coupon name is required',
      ));
    }

    // Discount value validation
    if (data.discountValue <= 0) {
      errors.add(const CouponValidationError(
        field: 'discountValue',
        message: 'Discount value must be greater than 0',
      ));
    } else if (data.discountType == DiscountType.percentage && data.discountValue > 100) {
      errors.add(const CouponValidationError(
        field: 'discountValue',
        message: 'Percentage discount cannot exceed 100%',
      ));
    } else if (data.discountType == DiscountType.fixed && data.discountValue > 10000) {
      errors.add(const CouponValidationError(
        field: 'discountValue',
        message: 'Fixed discount cannot exceed \$10,000',
      ));
    }

    // Minimum order amount validation
    if (data.minimumOrderAmount != null && data.minimumOrderAmount! < 0) {
      errors.add(const CouponValidationError(
        field: 'minimumOrderAmount',
        message: 'Minimum order amount cannot be negative',
      ));
    }

    // Usage limit validation
    if (data.usageLimit != null && data.usageLimit! <= 0) {
      errors.add(const CouponValidationError(
        field: 'usageLimit',
        message: 'Usage limit must be greater than 0',
      ));
    }

    // Date validation
    if (data.endDate != null && data.endDate!.isBefore(data.startDate)) {
      errors.add(const CouponValidationError(
        field: 'endDate',
        message: 'End date must be after start date',
      ));
    }

    return errors;
  }

  // Update coupon status
  Future<Coupon> updateCouponStatus(String id, CouponStatus status) async {
    try {
      Logger.info('Updating coupon status: $id to ${status.name}');

      final response = await SupabaseService.client
          .from(_tableName)
          .update({
            'status': status.name,
            'is_active': status == CouponStatus.active,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      Logger.info('Coupon status updated successfully: $id');
      return Coupon.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Update coupon status', e, stackTrace);
      rethrow;
    }
  }

  // Get active coupons
  Future<List<Coupon>> getActiveCoupons() async {
    try {
      Logger.info('Fetching active coupons');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*')
          .eq('status', CouponStatus.active.name)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return response.map<Coupon>((json) => Coupon.fromJson(json)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get active coupons', e, stackTrace);
      rethrow;
    }
  }

  // Get expired coupons
  Future<List<Coupon>> getExpiredCoupons() async {
    try {
      Logger.info('Fetching expired coupons');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*')
          .eq('status', CouponStatus.expired.name)
          .order('end_date', ascending: false);

      return response.map<Coupon>((json) => Coupon.fromJson(json)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get expired coupons', e, stackTrace);
      rethrow;
    }
  }

  // Search coupons
  Future<List<Coupon>> searchCoupons(String query) async {
    try {
      Logger.info('Searching coupons with query: $query');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*')
          .or('code.ilike.%$query%,name.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);

      return response.map<Coupon>((json) => Coupon.fromJson(json)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Search coupons', e, stackTrace);
      rethrow;
    }
  }

  // Get coupon statistics
  Future<CouponStatistics> getCouponStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Logger.info('Fetching coupon statistics');
      
      var query = SupabaseService.client.from(_tableName).select('*');
      
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final coupons = response.map<Coupon>((json) => Coupon.fromJson(json)).toList();

      // Calculate statistics
      final totalCoupons = coupons.length;
      final activeCoupons = coupons.where((c) => c.status == CouponStatus.active).length;
      final expiredCoupons = coupons.where((c) => c.status == CouponStatus.expired).length;
      final exhaustedCoupons = coupons.where((c) => c.status == CouponStatus.exhausted).length;
      final totalUsageCount = coupons.fold<int>(0, (sum, c) => sum + c.usageCount);
      
      // For now, we'll set totalDiscountGiven to 0 since we don't have order data
      // In a real implementation, this would query the orders table
      final totalDiscountGiven = 0.0;

      final couponsByStatus = <String, int>{};
      final couponsByType = <String, int>{};
      final discountByMonth = <String, double>{};

      for (final coupon in coupons) {
        // Count by status
        final statusKey = coupon.status.displayName;
        couponsByStatus[statusKey] = (couponsByStatus[statusKey] ?? 0) + 1;

        // Count by type
        final typeKey = coupon.discountType.displayName;
        couponsByType[typeKey] = (couponsByType[typeKey] ?? 0) + 1;

        // Discount by month (placeholder - would need order data for real calculation)
        final monthKey = '${coupon.createdAt.year}-${coupon.createdAt.month.toString().padLeft(2, '0')}';
        discountByMonth[monthKey] = (discountByMonth[monthKey] ?? 0.0) + 0.0;
      }

      return CouponStatistics(
        totalCoupons: totalCoupons,
        activeCoupons: activeCoupons,
        expiredCoupons: expiredCoupons,
        exhaustedCoupons: exhaustedCoupons,
        totalDiscountGiven: totalDiscountGiven,
        totalUsageCount: totalUsageCount,
        couponsByStatus: couponsByStatus,
        couponsByType: couponsByType,
        discountByMonth: discountByMonth,
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get coupon statistics', e, stackTrace);
      rethrow;
    }
  }

  // Calculate coupon status based on data
  String _calculateCouponStatus(CouponFormData data, [int usageCount = 0]) {
    final now = DateTime.now();
    
    if (!data.isActive) {
      return CouponStatus.inactive.name;
    }
    
    if (data.startDate != null && data.startDate!.isAfter(now)) {
      return 'scheduled'; // We need to add this status or use inactive
    }
    
    if (data.endDate != null && data.endDate!.isBefore(now)) {
      return CouponStatus.expired.name;
    }
    
    if (data.usageLimit != null && usageCount >= data.usageLimit!) {
      return CouponStatus.exhausted.name;
    }
    
    return CouponStatus.active.name;
  }
}