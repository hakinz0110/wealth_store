import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/storage_models.dart';
import '../interfaces/storage_interfaces.dart';
import '../constants/storage_constants.dart';
import '../../../shared/utils/logger.dart';

/// Service for chunked file uploads with resume capability
class ChunkedUploadService {
  final IStorageRepository _repository;
  
  // Active uploads tracking
  final Map<String, _ChunkedUpload> _activeUploads = {};
  final Map<String, StreamController<UploadProgress>> _progressControllers = {};
  
  // Configuration
  static const int defaultChunkSize = 1024 * 1024; // 1MB
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const int maxConcurrentChunks = 3;
  
  ChunkedUploadService({required IStorageRepository repository})
      : _repository = repository;

  /// Start a chunked upload
  Stream<UploadProgress> uploadFile({
    required String bucketId,
    required String path,
    required String fileName,
    required Uint8List fileData,
    required String mimeType,
    int? chunkSize,
    Map<String, String>? metadata,
  }) {
    final uploadId = _generateUploadId(bucketId, path, fileName);
    chunkSize ??= defaultChunkSize;
    
    // Create progress controller
    final progressController = StreamController<UploadProgress>.broadcast();
    _progressControllers[uploadId] = progressController;
    
    // Create chunked upload
    final upload = _ChunkedUpload(
      uploadId: uploadId,
      bucketId: bucketId,
      path: path,
      fileName: fileName,
      fileData: fileData,
      mimeType: mimeType,
      chunkSize: chunkSize,
      metadata: metadata ?? {},
      totalSize: fileData.length,
    );
    
    _activeUploads[uploadId] = upload;
    
    // Start upload process
    _startUpload(upload, progressController);
    
    Logger.info('Started chunked upload for $fileName (${fileData.length} bytes, ${upload.totalChunks} chunks)');
    
    return progressController.stream;
  }

  /// Resume a paused upload
  Stream<UploadProgress> resumeUpload(String uploadId) {
    final upload = _activeUploads[uploadId];
    if (upload == null) {
      throw Exception('Upload not found: $uploadId');
    }
    
    if (upload.status != UploadStatus.paused) {
      throw Exception('Upload is not paused: $uploadId');
    }
    
    final progressController = _progressControllers[uploadId];
    if (progressController == null) {
      throw Exception('Progress controller not found: $uploadId');
    }
    
    upload.status = UploadStatus.uploading;
    _continueUpload(upload, progressController);
    
    Logger.info('Resumed chunked upload: $uploadId');
    
    return progressController.stream;
  }

  /// Pause an active upload
  void pauseUpload(String uploadId) {
    final upload = _activeUploads[uploadId];
    if (upload != null && upload.status == UploadStatus.uploading) {
      upload.status = UploadStatus.paused;
      Logger.info('Paused chunked upload: $uploadId');
    }
  }

  /// Cancel an upload
  void cancelUpload(String uploadId) {
    final upload = _activeUploads[uploadId];
    if (upload != null) {
      upload.status = UploadStatus.cancelled;
      
      // Clean up
      _activeUploads.remove(uploadId);
      final progressController = _progressControllers.remove(uploadId);
      progressController?.close();
      
      Logger.info('Cancelled chunked upload: $uploadId');
    }
  }

  /// Get upload progress
  UploadProgress? getUploadProgress(String uploadId) {
    final upload = _activeUploads[uploadId];
    if (upload == null) return null;
    
    return UploadProgress(
      uploadId: uploadId,
      fileName: upload.fileName,
      bytesUploaded: upload.uploadedChunks.length * upload.chunkSize,
      totalBytes: upload.totalSize,
      status: upload.status,
      speed: upload.averageSpeed,
      remainingTime: upload.estimatedRemainingTime,
      error: upload.lastError,
    );
  }

  /// Get all active uploads
  List<UploadProgress> getActiveUploads() {
    return _activeUploads.keys
        .map((uploadId) => getUploadProgress(uploadId))
        .where((progress) => progress != null)
        .cast<UploadProgress>()
        .toList();
  }

  /// Start the upload process
  Future<void> _startUpload(
    _ChunkedUpload upload,
    StreamController<UploadProgress> progressController,
  ) async {
    try {
      upload.status = UploadStatus.uploading;
      upload.startTime = DateTime.now();
      
      // Initialize upload session with the repository
      await _initializeUploadSession(upload);
      
      // Start uploading chunks
      await _continueUpload(upload, progressController);
      
    } catch (e) {
      upload.status = UploadStatus.failed;
      upload.lastError = e.toString();
      
      final progress = _createProgress(upload);
      progressController.add(progress);
      progressController.close();
      
      Logger.error('Failed to start chunked upload for ${upload.fileName}', e);
    }
  }

  /// Continue uploading chunks
  Future<void> _continueUpload(
    _ChunkedUpload upload,
    StreamController<UploadProgress> progressController,
  ) async {
    try {
      // Upload chunks concurrently
      final futures = <Future<void>>[];
      int concurrentUploads = 0;
      
      for (int chunkIndex = 0; chunkIndex < upload.totalChunks; chunkIndex++) {
        // Skip already uploaded chunks
        if (upload.uploadedChunks.contains(chunkIndex)) {
          continue;
        }
        
        // Check if upload was paused or cancelled
        if (upload.status != UploadStatus.uploading) {
          break;
        }
        
        // Limit concurrent uploads
        if (concurrentUploads >= maxConcurrentChunks) {
          await Future.any(futures);
          futures.removeWhere((future) => future.isCompleted);
          concurrentUploads--;
        }
        
        // Start chunk upload
        final future = _uploadChunk(upload, chunkIndex, progressController);
        futures.add(future);
        concurrentUploads++;
      }
      
      // Wait for all remaining chunks
      await Future.wait(futures);
      
      // Finalize upload if all chunks are uploaded
      if (upload.uploadedChunks.length == upload.totalChunks && 
          upload.status == UploadStatus.uploading) {
        await _finalizeUpload(upload, progressController);
      }
      
    } catch (e) {
      upload.status = UploadStatus.failed;
      upload.lastError = e.toString();
      
      final progress = _createProgress(upload);
      progressController.add(progress);
      
      Logger.error('Failed to continue chunked upload for ${upload.fileName}', e);
    }
  }

  /// Upload a single chunk
  Future<void> _uploadChunk(
    _ChunkedUpload upload,
    int chunkIndex,
    StreamController<UploadProgress> progressController,
  ) async {
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        // Check if upload was paused or cancelled
        if (upload.status != UploadStatus.uploading) {
          return;
        }
        
        // Get chunk data
        final chunkData = _getChunkData(upload, chunkIndex);
        
        // Upload chunk
        await _repository.uploadChunk(
          uploadId: upload.uploadId,
          chunkIndex: chunkIndex,
          chunkData: chunkData,
        );
        
        // Mark chunk as uploaded
        upload.uploadedChunks.add(chunkIndex);
        upload.updateSpeed();
        
        // Send progress update
        final progress = _createProgress(upload);
        progressController.add(progress);
        
        Logger.debug('Uploaded chunk $chunkIndex/${upload.totalChunks} for ${upload.fileName}');
        return;
        
      } catch (e) {
        retryCount++;
        
        if (retryCount >= maxRetries) {
          Logger.error('Failed to upload chunk $chunkIndex for ${upload.fileName} after $maxRetries retries', e);
          throw e;
        }
        
        Logger.warning('Retrying chunk $chunkIndex upload for ${upload.fileName} (attempt $retryCount)');
        await Future.delayed(retryDelay * retryCount);
      }
    }
  }

  /// Initialize upload session
  Future<void> _initializeUploadSession(_ChunkedUpload upload) async {
    // This would initialize a multipart upload session with the storage provider
    // For now, we'll simulate this
    await Future.delayed(const Duration(milliseconds: 100));
    Logger.debug('Initialized upload session for ${upload.fileName}');
  }

  /// Finalize upload
  Future<void> _finalizeUpload(
    _ChunkedUpload upload,
    StreamController<UploadProgress> progressController,
  ) async {
    try {
      upload.status = UploadStatus.finalizing;
      
      // Send progress update
      final progress = _createProgress(upload);
      progressController.add(progress);
      
      // Finalize the upload with the repository
      final uploadedFile = await _repository.finalizeChunkedUpload(
        uploadId: upload.uploadId,
        bucketId: upload.bucketId,
        path: upload.path,
        fileName: upload.fileName,
        mimeType: upload.mimeType,
        metadata: upload.metadata,
      );
      
      upload.status = UploadStatus.completed;
      upload.uploadedFile = uploadedFile;
      
      // Send final progress update
      final finalProgress = _createProgress(upload);
      progressController.add(finalProgress);
      progressController.close();
      
      // Clean up
      _activeUploads.remove(upload.uploadId);
      _progressControllers.remove(upload.uploadId);
      
      Logger.info('Completed chunked upload for ${upload.fileName}');
      
    } catch (e) {
      upload.status = UploadStatus.failed;
      upload.lastError = e.toString();
      
      final progress = _createProgress(upload);
      progressController.add(progress);
      progressController.close();
      
      Logger.error('Failed to finalize chunked upload for ${upload.fileName}', e);
    }
  }

  /// Get chunk data for a specific chunk index
  Uint8List _getChunkData(_ChunkedUpload upload, int chunkIndex) {
    final startByte = chunkIndex * upload.chunkSize;
    final endByte = math.min(startByte + upload.chunkSize, upload.fileData.length);
    
    return upload.fileData.sublist(startByte, endByte);
  }

  /// Create progress object from upload state
  UploadProgress _createProgress(_ChunkedUpload upload) {
    final bytesUploaded = upload.uploadedChunks.length * upload.chunkSize;
    
    return UploadProgress(
      uploadId: upload.uploadId,
      fileName: upload.fileName,
      bytesUploaded: bytesUploaded,
      totalBytes: upload.totalSize,
      status: upload.status,
      speed: upload.averageSpeed,
      remainingTime: upload.estimatedRemainingTime,
      error: upload.lastError,
    );
  }

  /// Generate unique upload ID
  String _generateUploadId(String bucketId, String path, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = '${bucketId}_${path}_${fileName}_$timestamp'.hashCode;
    return 'upload_${hash.abs()}';
  }

  /// Dispose resources
  void dispose() {
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
    _activeUploads.clear();
  }
}

/// Internal chunked upload state
class _ChunkedUpload {
  final String uploadId;
  final String bucketId;
  final String path;
  final String fileName;
  final Uint8List fileData;
  final String mimeType;
  final int chunkSize;
  final Map<String, String> metadata;
  final int totalSize;
  final int totalChunks;
  
  UploadStatus status = UploadStatus.pending;
  final Set<int> uploadedChunks = <int>{};
  String? lastError;
  StorageFile? uploadedFile;
  
  // Performance tracking
  DateTime? startTime;
  final List<_SpeedSample> speedSamples = [];
  
  _ChunkedUpload({
    required this.uploadId,
    required this.bucketId,
    required this.path,
    required this.fileName,
    required this.fileData,
    required this.mimeType,
    required this.chunkSize,
    required this.metadata,
    required this.totalSize,
  }) : totalChunks = (totalSize / chunkSize).ceil();

  /// Update speed calculation
  void updateSpeed() {
    if (startTime == null) return;
    
    final now = DateTime.now();
    final elapsed = now.difference(startTime!);
    final bytesUploaded = uploadedChunks.length * chunkSize;
    
    // Add speed sample
    speedSamples.add(_SpeedSample(
      timestamp: now,
      bytesUploaded: bytesUploaded,
    ));
    
    // Keep only recent samples (last 10 seconds)
    speedSamples.removeWhere((sample) => 
        now.difference(sample.timestamp) > const Duration(seconds: 10));
  }

  /// Get average upload speed in bytes per second
  double get averageSpeed {
    if (speedSamples.length < 2) return 0.0;
    
    final oldest = speedSamples.first;
    final newest = speedSamples.last;
    
    final timeDiff = newest.timestamp.difference(oldest.timestamp).inMilliseconds / 1000.0;
    final bytesDiff = newest.bytesUploaded - oldest.bytesUploaded;
    
    return timeDiff > 0 ? bytesDiff / timeDiff : 0.0;
  }

  /// Get estimated remaining time
  Duration? get estimatedRemainingTime {
    final speed = averageSpeed;
    if (speed <= 0) return null;
    
    final remainingBytes = totalSize - (uploadedChunks.length * chunkSize);
    final remainingSeconds = remainingBytes / speed;
    
    return Duration(seconds: remainingSeconds.round());
  }
}

/// Speed sample for calculating average upload speed
class _SpeedSample {
  final DateTime timestamp;
  final int bytesUploaded;

  _SpeedSample({
    required this.timestamp,
    required this.bytesUploaded,
  });
}

/// Upload progress data class
class UploadProgress {
  final String uploadId;
  final String fileName;
  final int bytesUploaded;
  final int totalBytes;
  final UploadStatus status;
  final double speed; // bytes per second
  final Duration? remainingTime;
  final String? error;

  const UploadProgress({
    required this.uploadId,
    required this.fileName,
    required this.bytesUploaded,
    required this.totalBytes,
    required this.status,
    required this.speed,
    this.remainingTime,
    this.error,
  });

  /// Get upload progress as percentage (0.0 to 1.0)
  double get progress {
    if (totalBytes == 0) return 0.0;
    return (bytesUploaded / totalBytes).clamp(0.0, 1.0);
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
    return 'UploadProgress(fileName: $fileName, progress: ${(progress * 100).toStringAsFixed(1)}%, status: $status)';
  }
}

/// Upload status enumeration
enum UploadStatus {
  pending,
  uploading,
  paused,
  finalizing,
  completed,
  failed,
  cancelled,
}