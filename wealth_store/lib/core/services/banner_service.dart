import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/banner.dart';
import 'supabase_service.dart';

part 'banner_service.g.dart';

@riverpod
BannerService bannerService(BannerServiceRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return BannerService(supabase);
}

class BannerService {
  final SupabaseClient _client;
  static const String _tableName = 'banners';
  
  BannerService(this._client);
  
  /// Get all banners with optional filtering
  Future<List<Banner>> getBanners({
    bool? isActive,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client.from(_tableName).select('*');
      
      // Apply active filter if specified
      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }
      
      // Apply sorting and pagination - chain them properly
      var transformQuery = query.order('sort_order', ascending: true);
      
      if (limit != null) {
        transformQuery = transformQuery.limit(limit);
      }
      
      if (offset != null) {
        transformQuery = transformQuery.range(offset, offset + (limit ?? 10) - 1);
      }
      
      final response = await transformQuery;
      
      return (response as List<dynamic>)
          .map((json) => Banner.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch banners: $e');
    }
  }
  
  /// Get active banners only (for customer app display)
  Future<List<Banner>> getActiveBanners({int? limit}) async {
    return getBanners(isActive: true, limit: limit);
  }
  
  /// Get a single banner by ID
  Future<Banner?> getBannerById(String id) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('*')
          .eq('id', id)
          .single();
      
      return Banner.fromJson(response);
    } catch (e) {
      if (e is PostgrestException && e.code == 'PGRST116') {
        return null; // Banner not found
      }
      throw Exception('Failed to fetch banner: $e');
    }
  }
  
  /// Create a new banner (Admin only)
  Future<Banner> createBanner(BannerFormData data) async {
    try {
      final bannerData = data.toJson();
      // Add timestamps
      bannerData['created_at'] = DateTime.now().toIso8601String();
      bannerData['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _client
          .from(_tableName)
          .insert(bannerData)
          .select()
          .single();
      
      return Banner.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create banner: $e');
    }
  }
  
  /// Update an existing banner (Admin only)
  Future<Banner> updateBanner(String id, BannerFormData data) async {
    try {
      final bannerData = data.toJson();
      // Update timestamp
      bannerData['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _client
          .from(_tableName)
          .update(bannerData)
          .eq('id', id)
          .select()
          .single();
      
      return Banner.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update banner: $e');
    }
  }
  
  /// Delete a banner (Admin only)
  Future<void> deleteBanner(String id) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete banner: $e');
    }
  }
  
  /// Toggle banner active status (Admin only)
  Future<Banner> toggleBannerStatus(String id) async {
    try {
      // First get the current banner
      final current = await getBannerById(id);
      if (current == null) {
        throw Exception('Banner not found');
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
      
      return Banner.fromJson(response);
    } catch (e) {
      throw Exception('Failed to toggle banner status: $e');
    }
  }
  
  /// Update banner sort order (Admin only)
  Future<Banner> updateBannerOrder(String id, int newOrder) async {
    try {
      final response = await _client
          .from(_tableName)
          .update({
            'sort_order': newOrder,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();
      
      return Banner.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update banner order: $e');
    }
  }
  
  /// Reorder multiple banners (Admin only)
  Future<List<Banner>> reorderBanners(List<String> bannerIds) async {
    try {
      final updatedBanners = <Banner>[];
      
      for (int i = 0; i < bannerIds.length; i++) {
        final banner = await updateBannerOrder(bannerIds[i], i);
        updatedBanners.add(banner);
      }
      
      return updatedBanners;
    } catch (e) {
      throw Exception('Failed to reorder banners: $e');
    }
  }
  
  /// Get banner count for pagination
  Future<int> getBannerCount({bool? isActive}) async {
    try {
      var query = _client.from(_tableName).select('id');
      
      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }
      
      final response = await query;
      return (response as List<dynamic>).length;
    } catch (e) {
      throw Exception('Failed to get banner count: $e');
    }
  }
  
  /// Get active banner count
  Future<int> getActiveBannerCount() async {
    return getBannerCount(isActive: true);
  }
  
  /// Batch operations for admin
  Future<List<Banner>> createMultipleBanners(List<BannerFormData> banners) async {
    try {
      final bannersData = banners.map((b) {
        final data = b.toJson();
        data['created_at'] = DateTime.now().toIso8601String();
        data['updated_at'] = DateTime.now().toIso8601String();
        return data;
      }).toList();
      
      final response = await _client
          .from(_tableName)
          .insert(bannersData)
          .select();
      
      return (response as List<dynamic>)
          .map((json) => Banner.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to create multiple banners: $e');
    }
  }
  
  Future<void> deleteMultipleBanners(List<String> ids) async {
    try {
      // Delete banners one by one for now
      for (final id in ids) {
        await deleteBanner(id);
      }
    } catch (e) {
      throw Exception('Failed to delete multiple banners: $e');
    }
  }
  
  /// Real-time subscription for banners
  Stream<List<Banner>> watchBanners({bool? isActive}) {
    // For now, return a simple stream that fetches banners periodically
    // This can be enhanced later with proper real-time subscriptions
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      return await getBanners(isActive: isActive);
    }).asyncMap((future) => future);
  }
  
  /// Real-time subscription for active banners only
  Stream<List<Banner>> watchActiveBanners() {
    return watchBanners(isActive: true);
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