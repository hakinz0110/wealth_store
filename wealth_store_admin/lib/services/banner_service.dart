import '../models/banner_models.dart';
import '../shared/utils/logger.dart';
import '../shared/utils/error_handler.dart';
import 'supabase_service.dart';

class BannerService {
  static const String _tableName = 'banners';

  // Get all banners with optional filtering
  Future<List<Banner>> getBanners({
    bool? isActive,
    int? limit,
    int? offset,
  }) async {
    try {
      Logger.info('Fetching banners from Supabase');
      
      var query = SupabaseService.client.from(_tableName).select('*');
      
      // Apply active filter if specified
      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }
      
      // Apply sorting and pagination
      var transformQuery = query.order('sort_order', ascending: true);
      
      if (limit != null) {
        transformQuery = transformQuery.limit(limit);
      }
      
      if (offset != null) {
        transformQuery = transformQuery.range(offset, offset + (limit ?? 10) - 1);
      }
      
      final response = await transformQuery;

      return response.map<Banner>((json) => Banner.fromJson(json)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get banners', e, stackTrace);
      rethrow;
    }
  }

  // Get active banners only
  Future<List<Banner>> getActiveBanners() async {
    try {
      Logger.info('Fetching active banners from Supabase');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*')
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return response.map<Banner>((json) => Banner.fromJson(json)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get active banners', e, stackTrace);
      rethrow;
    }
  }

  // Get banner by ID
  Future<Banner?> getBannerById(String id) async {
    try {
      Logger.info('Fetching banner by ID: $id');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*')
          .eq('id', id)
          .single();

      return Banner.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get banner by ID', e, stackTrace);
      return null;
    }
  }

  // Create new banner
  Future<Banner> createBanner(BannerFormData data) async {
    try {
      Logger.info('Creating new banner: ${data.title}');

      // Validate data
      final errors = validateBannerData(data);
      if (errors.isNotEmpty) {
        throw Exception('Validation failed: ${errors.map((e) => e.message).join(', ')}');
      }

      final response = await SupabaseService.client
          .from(_tableName)
          .insert({
            'title': data.title,
            'description': data.description,
            'image_url': data.imageUrl,
            'link_url': data.linkUrl,
            'sort_order': data.sortOrder,
            'is_active': data.isActive,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      Logger.info('Banner created successfully: ${data.title}');
      return Banner.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Create banner', e, stackTrace);
      rethrow;
    }
  }

  // Update banner
  Future<Banner> updateBanner(String id, BannerFormData data) async {
    try {
      Logger.info('Updating banner: $id');

      // Validate data
      final errors = validateBannerData(data);
      if (errors.isNotEmpty) {
        throw Exception('Validation failed: ${errors.map((e) => e.message).join(', ')}');
      }

      final response = await SupabaseService.client
          .from(_tableName)
          .update({
            'title': data.title,
            'description': data.description,
            'image_url': data.imageUrl,
            'link_url': data.linkUrl,
            'sort_order': data.sortOrder,
            'is_active': data.isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      Logger.info('Banner updated successfully: $id');
      return Banner.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Update banner', e, stackTrace);
      rethrow;
    }
  }

  // Delete banner
  Future<void> deleteBanner(String id) async {
    try {
      Logger.info('Deleting banner: $id');

      await SupabaseService.client
          .from(_tableName)
          .delete()
          .eq('id', id);

      Logger.info('Banner deleted successfully: $id');
    } catch (e, stackTrace) {
      ErrorHandler.logError('Delete banner', e, stackTrace);
      rethrow;
    }
  }

  // Update banner sort order
  Future<void> updateBannerOrder(String id, int newOrder) async {
    try {
      Logger.info('Updating banner order: $id to $newOrder');

      await SupabaseService.client
          .from(_tableName)
          .update({
            'sort_order': newOrder,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      Logger.info('Banner order updated successfully: $id');
    } catch (e, stackTrace) {
      ErrorHandler.logError('Update banner order', e, stackTrace);
      rethrow;
    }
  }

  // Toggle banner active status
  Future<Banner> toggleBannerStatus(String id) async {
    try {
      Logger.info('Toggling banner status: $id');

      final banner = await getBannerById(id);
      if (banner == null) {
        throw Exception('Banner not found');
      }

      final response = await SupabaseService.client
          .from(_tableName)
          .update({
            'is_active': !banner.isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      Logger.info('Banner status toggled successfully: $id');
      return Banner.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Toggle banner status', e, stackTrace);
      rethrow;
    }
  }

  // Get total banner count
  Future<int> getTotalBannerCount() async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('id');
      return response.length;
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get total banner count', e, stackTrace);
      return 0;
    }
  }

  // Get active banner count
  Future<int> getActiveBannerCount() async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('id')
          .eq('is_active', true);
      return response.length;
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get active banner count', e, stackTrace);
      return 0;
    }
  }

  // Validate banner data
  List<BannerValidationError> validateBannerData(BannerFormData data) {
    final errors = <BannerValidationError>[];

    // Title validation
    if (data.title.trim().isEmpty) {
      errors.add(const BannerValidationError(
        field: 'title',
        message: 'Banner title is required',
      ));
    } else if (data.title.trim().length < 2) {
      errors.add(const BannerValidationError(
        field: 'title',
        message: 'Banner title must be at least 2 characters long',
      ));
    } else if (data.title.trim().length > 100) {
      errors.add(const BannerValidationError(
        field: 'title',
        message: 'Banner title cannot exceed 100 characters',
      ));
    }

    // Image URL validation
    if (data.imageUrl.trim().isEmpty) {
      errors.add(const BannerValidationError(
        field: 'imageUrl',
        message: 'Banner image URL is required',
      ));
    } else {
      final urlPattern = RegExp(r'^https?://');
      if (!urlPattern.hasMatch(data.imageUrl.trim())) {
        errors.add(const BannerValidationError(
          field: 'imageUrl',
          message: 'Please enter a valid image URL starting with http:// or https://',
        ));
      }
    }

    // Description validation
    if (data.description != null && data.description!.trim().length > 500) {
      errors.add(const BannerValidationError(
        field: 'description',
        message: 'Description cannot exceed 500 characters',
      ));
    }

    // Link URL validation
    if (data.linkUrl != null && data.linkUrl!.trim().isNotEmpty) {
      final urlPattern = RegExp(r'^https?://');
      if (!urlPattern.hasMatch(data.linkUrl!.trim())) {
        errors.add(const BannerValidationError(
          field: 'linkUrl',
          message: 'Please enter a valid link URL starting with http:// or https://',
        ));
      }
    }

    // Sort order validation
    if (data.sortOrder < 0) {
      errors.add(const BannerValidationError(
        field: 'sortOrder',
        message: 'Sort order cannot be negative',
      ));
    }

    return errors;
  }
}