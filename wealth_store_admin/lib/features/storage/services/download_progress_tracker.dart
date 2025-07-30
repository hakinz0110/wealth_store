import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/storage_models.dart';
import '../interfaces/storage_interfaces.dart';
import '../constants/storage_constants.dart';
import '../../../shared/utils/logger.dart';

/// Service for tracking download progress with resume capability
class DownloadProgressTracker {
  final IStorageRepository _repository;
  
  // Active downloads tracking
  final Map<String, _DownloadRequest> _activeDownloads = {};
  final Map<String, StreamController<DownloadProgress>> _progressControllers = {};
  
  // Configuration
  static const int maxConcurrentDownloads = 3;
  static const int downloadChunkSize = 64 * 1024; // 64KB chunks
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  DownloadProgressTracker({required IStorageRepository repository})
      : _repository = repository;

  /// Start downloading a file
  Stream<DownloadProgress> downloadFile({
    required String bucketId,
    required String filePath,
    required String fileName,
    String? saveToPath,
    bool resumable = true,
  }) {
    final downloadId = _generateDownloadId(bucketId, filePath, fileName);
    
    // Create progress controller
    final progressController = StreamController<DownloadProgress>.broadcast();
    _progressControllers[downloadId] = progressController;
    
    // Create download request
    final request = _DownloadRequest(
      downloadId: downloadId,
      bucketId: bucketId,
      filePath: filePath,
      fileName: fileName,
      saveToPath: saveToPath,
      resumable: resumable,
    );
    
    _activeDownloads[downloadId] = request;
    
    // Start download
    _startDownload(request, progressController);
    
    Logger.info('Started download for $fileName');
    
    return progressController.stream;
  }

  /// Resume a paused download
  Stream<DownloadProgress> resumeDownload(String downloadId) {
    final request = _activeDownloads[downloadId];
    if (request == null) {
      throw Exception('Download not found: $downloadId');
    }
    
    if (request.status != DownloadStatus.paused) {
      throw Exception('Download is not paused: $downloadId');
    }
    
    final progressController = _progressControllers[downloadId];
    if (progressController == null) {
      throw Exception('Progress controller not found: $downloadId');
    }
    
    request.status = DownloadStatus.downloading;
    _continueDownload(request, progressController);
    
    Logger.info('Resumed download: $downloadId');
    
    return progressController.stream;
  }

  /// Pause an active download
  void pauseDownload(String downloadId) {
    final request = _activeDownloads[downloadId];
    if (request != null && request.status == DownloadStatus.downloading) {
      request.status = DownloadStatus.paused;
      Logger.info('Paused download: $downloadId');
    }
  }

  /// Cancel a download
  void cancelDownload(String downloadId) {
    final request = _activeDownloads[downloadId];
    if (request != null) {
      request.status = DownloadStatus.cancelled;
      
      // Clean up
      _activeDownloads.remove(downloadId);
      final progressController = _progressControllers.remove(downloadId);
      progressController?.close();
      
      Logger.info('Cancelled download: $downloadId');
    }
  }

  /// Get download progress
  DownloadProgress? getDownloadProgress(String downloadId) {
    final request = _activeDownloads[downloadId];
    if (request == null) return null;
    
    return DownloadProgress(
      downloadId: downloadId,
      fileName: request.fileName,
      bytesDownloaded: request.bytesDownloaded,
      totalBytes: request.totalBytes,
      status: request.status,
      speed: request.averageSpeed,
      remainingTime: request.estimatedRemainingTime,
      error: request.lastError,
    );
  }

  /// Get all active downloads
  List<DownloadProgress> getActiveDownloads() {
    return _activeDownloads.keys
        .map((downloadId) => getDownloadProgress(downloadId))
        .where((progress) => progress != null)
        .cast<DownloadProgress>()
        .toList();
  }

  /// Start the download process
  Future<void> _startDownload(
    _DownloadRequest request,
    StreamController<DownloadProgress> progressController,
  ) async {
    try {
      request.status = DownloadStatus.initializing;
      request.startTime = DateTime.now();
      
      // Get file information
      final fileInfo = await _repository.getFileInfo(
        bucketId: request.bucketId,
        filePath: request.filePath,
      );
      
      request.totalBytes = fileInfo.size;
      
      // Check if resuming is possible
      if (request.resumable && request.saveToPath != null) {
        // Check existing partial file
        // In a real implementation, you would check the local file system
        // For now, we'll assume no partial file exists
      }
      
      // Start downloading
      await _continueDownload(request, progressController);
      
    } catch (e) {
      request.status = DownloadStatus.failed;
      request.lastError = e.toString();
      
      final progress = _createProgress(request);
      progressController.add(progress);
      progressController.close();
      
      Logger.error('Failed to start download for ${request.fileName}', e);
    }
  }

  /// Continue downloading
  Future<void> _continueDownload(
    _DownloadRequest request,
    StreamController<DownloadProgress> progressController,
  ) async {
    try {
      request.status = DownloadStatus.downloading;
      
      // Download in chunks
      while (request.bytesDownloaded < request.totalBytes) {
        // Check if download was paused or cancelled
        if (request.status != DownloadStatus.downloading) {
          break;
        }
        
        // Calculate chunk size
        final remainingBytes = request.totalBytes - request.bytesDownloaded;
        final chunkSize = remainingBytes < downloadChunkSize 
            ? remainingBytes 
            : downloadChunkSize;
        
        // Download chunk
        await _downloadChunk(request, chunkSize, progressController);
      }
      
      // Complete download if all bytes downloaded
      if (request.bytesDownloaded >= request.totalBytes && 
          request.status == DownloadStatus.downloading) {
        await _completeDownload(request, progressController);
      }
      
    } catch (e) {
      request.status = DownloadStatus.failed;
      request.lastError = e.toString();
      
      final progress = _createProgress(request);
      progressController.add(progress);
      
      Logger.error('Failed to continue download for ${request.fileName}', e);
    }
  }

  /// Download a single chunk
  Future<void> _downloadChunk(
    _DownloadRequest request,
    int chunkSize,
    StreamController<DownloadProgress> progressController,
  ) async {
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        // Check if download was paused or cancelled
        if (request.status != DownloadStatus.downloading) {
          return;
        }
        
        // Download chunk from repository
        final chunkData = await _repository.downloadChunk(
          bucketId: request.bucketId,
          filePath: request.filePath,
          start: request.bytesDownloaded,
          length: chunkSize,
        );
        
        // Update progress
        request.bytesDownloaded += chunkData.length;
        request.downloadedData.addAll(chunkData);
        request.updateSpeed();
        
        // Send progress update
        final progress = _createProgress(request);
        progressController.add(progress);
        
        Logger.debug('Downloaded chunk for ${request.fileName}: ${request.bytesDownloaded}/${request.totalBytes}');
        return;
        
      } catch (e) {
        retryCount++;
        
        if (retryCount >= maxRetries) {
          Logger.error('Failed to download chunk for ${request.fileName} after $maxRetries retries', e);
          throw e;
        }
        
        Logger.warning('Retrying chunk download for ${request.fileName} (attempt $retryCount)');
        await Future.delayed(retryDelay * retryCount);
      }
    }
  }

  /// Complete download
  Future<void> _completeDownload(
    _DownloadRequest request,
    StreamController<DownloadProgress> progressController,
  ) async {
    try {
      request.status = DownloadStatus.completed;
      
      // Save file if path specified
      if (request.saveToPath != null) {
        // In a real implementation, you would save the file to the specified path
        // For now, we'll just log it
        Logger.info('Would save file to: ${request.saveToPath}');
      }
      
      // Send final progress update
      final finalProgress = _createProgress(request);
      progressController.add(finalProgress);
      progressController.close();
      
      // Clean up
      _activeDownloads.remove(request.downloadId);
      _progressControllers.remove(request.downloadId);
      
      Logger.info('Completed download for ${request.fileName}');
      
    } catch (e) {
      request.status = DownloadStatus.failed;
      request.lastError = e.toString();
      
      final progress = _createProgress(request);
      progressController.add(progress);
      progressController.close();
      
      Logger.error('Failed to complete download for ${request.fileName}', e);
    }
  }

  /// Create progress object from request state
  DownloadProgress _createProgress(_DownloadRequest request) {
    return DownloadProgress(
      downloadId: request.downloadId,
      fileName: request.fileName,
      bytesDownloaded: request.bytesDownloaded,
      totalBytes: request.totalBytes,
      status: request.status,
      speed: request.averageSpeed,
      remainingTime: request.estimatedRemainingTime,
      error: request.lastError,
    );
  }

  /// Generate unique download ID
  String _generateDownloadId(String bucketId, String filePath, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = '${bucketId}_${filePath}_${fileName}_$timestamp'.hashCode;
    return 'download_${hash.abs()}';
  }

  /// Dispose resources
  void dispose() {
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
    _activeDownloads.clear();
  }
}

/// Internal download request state
class _DownloadRequest {
  final String downloadId;
  final String bucketId;
  final String filePath;
  final String fileName;
  final String? saveToPath;
  final bool resumable;
  
  DownloadStatus status = DownloadStatus.pending;
  int bytesDownloaded = 0;
  int totalBytes = 0;
  final List<int> downloadedData = [];
  String? lastError;
  
  // Performance tracking
  DateTime? startTime;
  final List<_SpeedSample> speedSamples = [];
  
  _DownloadRequest({
    required this.downloadId,
    required this.bucketId,
    required this.filePath,
    required this.fileName,
    this.saveToPath,
    required this.resumable,
  });

  /// Update speed calculation
  void updateSpeed() {
    if (startTime == null) return;
    
    final now = DateTime.now();
    
    // Add speed sample
    speedSamples.add(_SpeedSample(
      timestamp: now,
      bytesDownloaded: bytesDownloaded,
    ));
    
    // Keep only recent samples (last 10 seconds)
    speedSamples.removeWhere((sample) => 
        now.difference(sample.timestamp) > const Duration(seconds: 10));
  }

  /// Get average download speed in bytes per second
  double get averageSpeed {
    if (speedSamples.length < 2) return 0.0;
    
    final oldest = speedSamples.first;
    final newest = speedSamples.last;
    
    final timeDiff = newest.timestamp.difference(oldest.timestamp).inMilliseconds / 1000.0;
    final bytesDiff = newest.bytesDownloaded - oldest.bytesDownloaded;
    
    return timeDiff > 0 ? bytesDiff / timeDiff : 0.0;
  }

  /// Get estimated remaining time
  Duration? get estimatedRemainingTime {
    final speed = averageSpeed;
    if (speed <= 0) return null;
    
    final remainingBytes = totalBytes - bytesDownloaded;
    final remainingSeconds = remainingBytes / speed;
    
    return Duration(seconds: remainingSeconds.round());
  }
}

/// Speed sample for calculating average download speed
class _SpeedSample {
  final DateTime timestamp;
  final int bytesDownloaded;

  _SpeedSample({
    required this.timestamp,
    required this.bytesDownloaded,
  });
}

/// Download progress data class
class DownloadProgress {
  final String downloadId;
  final String fileName;
  final int bytesDownloaded;
  final int totalBytes;
  final DownloadStatus status;
  final double speed; // bytes per second
  final Duration? remainingTime;
  final String? error;

  const DownloadProgress({
    required this.downloadId,
    required this.fileName,
    required this.bytesDownloaded,
    required this.totalBytes,
    required this.status,
    required this.speed,
    this.remainingTime,
    this.error,
  });

  /// Get download progress as percentage (0.0 to 1.0)
  double get progress {
    if (totalBytes == 0) return 0.0;
    return (bytesDownloaded / totalBytes).clamp(0.0, 1.0);
  }

  /// Get formatted speed string
  String get formattedSpeed {
    if (speed < 1024) {
      return '${speed.toStringAsFixed(0)} B/s';
    } else if (speed < 1024 * 1024) {
      return '${(speed / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${(speed / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
  }

  /// Get formatted remaining time string
  String get formattedRemainingTime {
    if (remainingTime == null) return 'Unknown';
    
    final seconds = remainingTime!.inSeconds;
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      return '${(seconds / 60).round()}m';
    } else {
      return '${(seconds / 3600).round()}h';
    }
  }

  @override
  String toString() {
    return 'DownloadProgress(fileName: $fileName, progress: ${(progress * 100).toStringAsFixed(1)}%, status: $status)';
  }
}

/// Download status enumeration
enum DownloadStatus {
  pending,
  initializing,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}