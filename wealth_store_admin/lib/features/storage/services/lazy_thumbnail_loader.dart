import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/storage_models.dart';
import '../interfaces/storage_interfaces.dart';
import '../constants/storage_constants.dart';
import '../../../shared/utils/logger.dart';

/// Service for lazy loading file thumbnails with caching and priority queue
class LazyThumbnailLoader {
  static final LazyThumbnailLoader _instance = LazyThumbnailLoader._internal();
  factory LazyThumbnailLoader() => _instance;
  LazyThumbnailLoader._internal();

  final Map<String, Uint8List> _thumbnailCache = {};
  final Map<String, Completer<Uint8List?>> _loadingThumbnails = {};
  final List<_ThumbnailRequest> _requestQueue = [];
  final Set<String> _priorityFiles = {};
  
  Timer? _processingTimer;
  bool _isProcessing = false;
  
  // Configuration
  static const int maxCacheSize = 500;
  static const int maxConcurrentLoads = 3;
  static const Duration processingInterval = Duration(milliseconds: 100);
  
  int _currentConcurrentLoads = 0;

  /// Request a thumbnail for a file with optional priority
  Future<Uint8List?> getThumbnail(
    StorageFile file,
    IStorageRepository repository, {
    bool highPriority = false,
    Size? targetSize,
  }) async {
    final cacheKey = _getCacheKey(file, targetSize);
    
    // Return cached thumbnail if available
    if (_thumbnailCache.containsKey(cacheKey)) {
      Logger.debug('Thumbnail cache hit for ${file.name}');
      return _thumbnailCache[cacheKey];
    }
    
    // Return existing loading completer if already loading
    if (_loadingThumbnails.containsKey(cacheKey)) {
      Logger.debug('Thumbnail already loading for ${file.name}');
      return await _loadingThumbnails[cacheKey]!.future;
    }
    
    // Only load thumbnails for image files
    if (file.fileType != StorageFileType.image) {
      return null;
    }
    
    // Create loading completer
    final completer = Completer<Uint8List?>();
    _loadingThumbnails[cacheKey] = completer;
    
    // Add to request queue
    final request = _ThumbnailRequest(
      file: file,
      repository: repository,
      cacheKey: cacheKey,
      completer: completer,
      targetSize: targetSize,
      priority: highPriority ? ThumbnailPriority.high : ThumbnailPriority.normal,
      timestamp: DateTime.now(),
    );
    
    if (highPriority) {
      _priorityFiles.add(cacheKey);
      _requestQueue.insert(0, request);
    } else {
      _requestQueue.add(request);
    }
    
    // Start processing if not already running
    _startProcessing();
    
    Logger.debug('Queued thumbnail request for ${file.name} (priority: ${request.priority})');
    return await completer.future;
  }

  /// Preload thumbnails for visible files
  void preloadThumbnails(
    List<StorageFile> files,
    IStorageRepository repository, {
    Size? targetSize,
  }) {
    final imageFiles = files
        .where((file) => file.fileType == StorageFileType.image)
        .take(20) // Limit preload count
        .toList();
    
    for (final file in imageFiles) {
      final cacheKey = _getCacheKey(file, targetSize);
      
      // Skip if already cached or loading
      if (_thumbnailCache.containsKey(cacheKey) || 
          _loadingThumbnails.containsKey(cacheKey)) {
        continue;
      }
      
      // Add low priority request
      getThumbnail(file, repository, highPriority: false, targetSize: targetSize);
    }
    
    Logger.debug('Preloading thumbnails for ${imageFiles.length} files');
  }

  /// Set high priority for specific files (e.g., currently visible)
  void setPriority(List<StorageFile> files, {Size? targetSize}) {
    for (final file in files) {
      if (file.fileType == StorageFileType.image) {
        final cacheKey = _getCacheKey(file, targetSize);
        _priorityFiles.add(cacheKey);
        
        // Move to front of queue if already queued
        final existingIndex = _requestQueue.indexWhere((req) => req.cacheKey == cacheKey);
        if (existingIndex != -1) {
          final request = _requestQueue.removeAt(existingIndex);
          request.priority = ThumbnailPriority.high;
          _requestQueue.insert(0, request);
        }
      }
    }
  }

  /// Clear priority for files (e.g., no longer visible)
  void clearPriority(List<StorageFile> files, {Size? targetSize}) {
    for (final file in files) {
      if (file.fileType == StorageFileType.image) {
        final cacheKey = _getCacheKey(file, targetSize);
        _priorityFiles.remove(cacheKey);
      }
    }
  }

  /// Cancel pending thumbnail requests
  void cancelRequests(List<StorageFile> files, {Size? targetSize}) {
    for (final file in files) {
      final cacheKey = _getCacheKey(file, targetSize);
      
      // Remove from queue
      _requestQueue.removeWhere((req) => req.cacheKey == cacheKey);
      
      // Complete with null if loading
      if (_loadingThumbnails.containsKey(cacheKey)) {
        _loadingThumbnails[cacheKey]!.complete(null);
        _loadingThumbnails.remove(cacheKey);
      }
      
      _priorityFiles.remove(cacheKey);
    }
  }

  /// Clear thumbnail cache
  void clearCache() {
    _thumbnailCache.clear();
    _priorityFiles.clear();
    Logger.info('Cleared thumbnail cache');
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _thumbnailCache.length,
      'queueSize': _requestQueue.length,
      'loadingCount': _loadingThumbnails.length,
      'priorityCount': _priorityFiles.length,
      'concurrentLoads': _currentConcurrentLoads,
      'memoryUsage': _getEstimatedMemoryUsage(),
    };
  }

  /// Start processing thumbnail requests
  void _startProcessing() {
    if (_processingTimer != null && _processingTimer!.isActive) {
      return;
    }
    
    _processingTimer = Timer.periodic(processingInterval, (_) {
      _processQueue();
    });
  }

  /// Process thumbnail request queue
  Future<void> _processQueue() async {
    if (_isProcessing || _requestQueue.isEmpty || _currentConcurrentLoads >= maxConcurrentLoads) {
      return;
    }
    
    _isProcessing = true;
    
    try {
      // Sort queue by priority and timestamp
      _requestQueue.sort((a, b) {
        if (a.priority != b.priority) {
          return b.priority.index - a.priority.index; // High priority first
        }
        return a.timestamp.compareTo(b.timestamp); // Older requests first
      });
      
      // Process requests up to concurrent limit
      final requestsToProcess = <_ThumbnailRequest>[];
      while (requestsToProcess.length < maxConcurrentLoads - _currentConcurrentLoads && 
             _requestQueue.isNotEmpty) {
        requestsToProcess.add(_requestQueue.removeAt(0));
      }
      
      // Process requests concurrently
      final futures = requestsToProcess.map((request) => _processThumbnailRequest(request));
      await Future.wait(futures);
      
    } catch (e) {
      Logger.error('Error processing thumbnail queue', e);
    } finally {
      _isProcessing = false;
      
      // Stop timer if queue is empty
      if (_requestQueue.isEmpty) {
        _processingTimer?.cancel();
        _processingTimer = null;
      }
    }
  }

  /// Process a single thumbnail request
  Future<void> _processThumbnailRequest(_ThumbnailRequest request) async {
    _currentConcurrentLoads++;
    
    try {
      Logger.debug('Loading thumbnail for ${request.file.name}');
      
      // Generate thumbnail
      final thumbnailData = await _generateThumbnail(
        request.file,
        request.repository,
        request.targetSize,
      );
      
      if (thumbnailData != null) {
        // Cache the thumbnail
        _cacheThumbnail(request.cacheKey, thumbnailData);
        Logger.debug('Cached thumbnail for ${request.file.name}');
      }
      
      // Complete the request
      request.completer.complete(thumbnailData);
      
    } catch (e) {
      Logger.error('Failed to load thumbnail for ${request.file.name}', e);
      request.completer.complete(null);
    } finally {
      _loadingThumbnails.remove(request.cacheKey);
      _currentConcurrentLoads--;
    }
  }

  /// Generate thumbnail for a file
  Future<Uint8List?> _generateThumbnail(
    StorageFile file,
    IStorageRepository repository,
    Size? targetSize,
  ) async {
    try {
      // For now, return null as thumbnail generation would require
      // downloading the full image and resizing it
      // In a real implementation, this would:
      // 1. Download the image file
      // 2. Decode it
      // 3. Resize to target size
      // 4. Encode as JPEG/PNG
      
      // Simulate thumbnail generation delay
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Return null for now - in real implementation would return thumbnail bytes
      return null;
      
    } catch (e) {
      Logger.error('Failed to generate thumbnail for ${file.name}', e);
      return null;
    }
  }

  /// Cache a thumbnail with size management
  void _cacheThumbnail(String cacheKey, Uint8List thumbnailData) {
    // Remove oldest entries if cache is full
    if (_thumbnailCache.length >= maxCacheSize) {
      final keysToRemove = _thumbnailCache.keys.take(_thumbnailCache.length - maxCacheSize + 1);
      for (final key in keysToRemove) {
        _thumbnailCache.remove(key);
      }
    }
    
    _thumbnailCache[cacheKey] = thumbnailData;
  }

  /// Generate cache key for a file and target size
  String _getCacheKey(StorageFile file, Size? targetSize) {
    final sizeKey = targetSize != null ? '${targetSize.width}x${targetSize.height}' : 'default';
    return '${file.id}_$sizeKey';
  }

  /// Get estimated memory usage of thumbnail cache
  int _getEstimatedMemoryUsage() {
    int totalBytes = 0;
    for (final thumbnail in _thumbnailCache.values) {
      totalBytes += thumbnail.length;
    }
    return totalBytes;
  }

  /// Dispose resources
  void dispose() {
    _processingTimer?.cancel();
    _processingTimer = null;
    _thumbnailCache.clear();
    _loadingThumbnails.clear();
    _requestQueue.clear();
    _priorityFiles.clear();
  }
}

/// Thumbnail request data class
class _ThumbnailRequest {
  final StorageFile file;
  final IStorageRepository repository;
  final String cacheKey;
  final Completer<Uint8List?> completer;
  final Size? targetSize;
  ThumbnailPriority priority;
  final DateTime timestamp;

  _ThumbnailRequest({
    required this.file,
    required this.repository,
    required this.cacheKey,
    required this.completer,
    this.targetSize,
    required this.priority,
    required this.timestamp,
  });
}

/// Thumbnail loading priority levels
enum ThumbnailPriority {
  low,
  normal,
  high,
}