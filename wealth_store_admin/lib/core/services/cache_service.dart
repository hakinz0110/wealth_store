import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

class CacheService {
  static const String _keyPrefix = 'admin_cache_';
  static const Duration _defaultTtl = Duration(minutes: 10); // Shorter TTL for admin data
  
  // Cache keys
  static const String productsKey = 'products';
  static const String categoriesKey = 'categories';
  static const String bannersKey = 'banners';
  static const String couponsKey = 'coupons';
  static const String ordersKey = 'orders';
  static const String usersKey = 'users';
  static const String mediaFilesKey = 'media_files';
  
  /// Get cached data with TTL check
  Future<T?> get<T>(
    String key, 
    T Function(Map<String, dynamic>) fromJson, {
    Duration? ttl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _keyPrefix + key;
      final timestampKey = '${cacheKey}_timestamp';
      
      final cachedData = prefs.getString(cacheKey);
      final timestamp = prefs.getInt(timestampKey);
      
      if (cachedData == null || timestamp == null) {
        return null;
      }
      
      // Check if cache has expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final cacheTtl = ttl ?? _defaultTtl;
      
      if (now.difference(cacheTime) > cacheTtl) {
        // Cache expired, remove it
        await _remove(key);
        return null;
      }
      
      final jsonData = json.decode(cachedData) as Map<String, dynamic>;
      return fromJson(jsonData);
    } catch (e) {
      // If there's any error reading cache, return null
      return null;
    }
  }
  
  /// Get cached list data with TTL check
  Future<List<T>?> getList<T>(
    String key, 
    T Function(Map<String, dynamic>) fromJson, {
    Duration? ttl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _keyPrefix + key;
      final timestampKey = '${cacheKey}_timestamp';
      
      final cachedData = prefs.getString(cacheKey);
      final timestamp = prefs.getInt(timestampKey);
      
      if (cachedData == null || timestamp == null) {
        return null;
      }
      
      // Check if cache has expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final cacheTtl = ttl ?? _defaultTtl;
      
      if (now.difference(cacheTime) > cacheTtl) {
        // Cache expired, remove it
        await _remove(key);
        return null;
      }
      
      final jsonList = json.decode(cachedData) as List<dynamic>;
      return jsonList
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If there's any error reading cache, return null
      return null;
    }
  }
  
  /// Set cache data with timestamp
  Future<void> set<T>(
    String key, 
    T data, 
    Map<String, dynamic> Function(T) toJson,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _keyPrefix + key;
      final timestampKey = '${cacheKey}_timestamp';
      
      final jsonData = json.encode(toJson(data));
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      await prefs.setString(cacheKey, jsonData);
      await prefs.setInt(timestampKey, timestamp);
    } catch (e) {
      // Silently fail cache writes
    }
  }
  
  /// Set cache list data with timestamp
  Future<void> setList<T>(
    String key, 
    List<T> data, 
    Map<String, dynamic> Function(T) toJson,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _keyPrefix + key;
      final timestampKey = '${cacheKey}_timestamp';
      
      final jsonList = data.map((item) => toJson(item)).toList();
      final jsonData = json.encode(jsonList);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      await prefs.setString(cacheKey, jsonData);
      await prefs.setInt(timestampKey, timestamp);
    } catch (e) {
      // Silently fail cache writes
    }
  }
  
  /// Remove specific cache entry
  Future<void> _remove(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _keyPrefix + key;
      final timestampKey = '${cacheKey}_timestamp';
      
      await prefs.remove(cacheKey);
      await prefs.remove(timestampKey);
    } catch (e) {
      // Silently fail cache removals
    }
  }
  
  /// Clear specific cache entry (public method)
  Future<void> clearCache(String key) async {
    await _remove(key);
  }
  
  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_keyPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      // Silently fail cache clearing
    }
  }
  
  /// Check if cache exists and is valid
  Future<bool> hasValidCache(String key, {Duration? ttl}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _keyPrefix + key;
      final timestampKey = '${cacheKey}_timestamp';
      
      final cachedData = prefs.getString(cacheKey);
      final timestamp = prefs.getInt(timestampKey);
      
      if (cachedData == null || timestamp == null) {
        return false;
      }
      
      // Check if cache has expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final cacheTtl = ttl ?? _defaultTtl;
      
      return now.difference(cacheTime) <= cacheTtl;
    } catch (e) {
      return false;
    }
  }
  
  /// Invalidate cache when data is modified
  Future<void> invalidateRelatedCache(String entityType) async {
    switch (entityType) {
      case 'product':
        await clearCache(productsKey);
        await clearCache(categoriesKey); // Products affect category counts
        break;
      case 'category':
        await clearCache(categoriesKey);
        await clearCache(productsKey); // Categories affect product listings
        break;
      case 'order':
        await clearCache(ordersKey);
        await clearCache(productsKey); // Orders affect stock levels
        break;
      case 'banner':
        await clearCache(bannersKey);
        break;
      case 'coupon':
        await clearCache(couponsKey);
        break;
      case 'user':
        await clearCache(usersKey);
        break;
      case 'media':
        await clearCache(mediaFilesKey);
        break;
    }
  }
  
  /// Cache management - remove expired entries
  Future<void> cleanupExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final now = DateTime.now();
      
      for (final key in keys) {
        if (key.startsWith(_keyPrefix) && key.endsWith('_timestamp')) {
          final timestamp = prefs.getInt(key);
          if (timestamp != null) {
            final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            if (now.difference(cacheTime) > _defaultTtl) {
              // Remove both data and timestamp
              final dataKey = key.replaceAll('_timestamp', '');
              await prefs.remove(dataKey);
              await prefs.remove(key);
            }
          }
        }
      }
    } catch (e) {
      // Silently fail cleanup
    }
  }
}