import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import '../models/storage_models.dart';
import '../interfaces/storage_interfaces.dart';
import '../constants/storage_constants.dart';
import '../../../shared/utils/logger.dart';
import 'chunked_upload_service.dart';

/// Manager for handling concurrent file uploads with queue management
class ConcurrentUploadManager {
  final ChunkedUploadService _chunkedUploadService;
  
  // Upload queue and active uploads
  final Queue<_UploadRequest> _uploadQueue = Queue<_UploadRequest>();
  final Map<String, _UploadRequest> _activeUploads = {};
  final Map<String, StreamController<UploadProgress>> _progressControllers = {};
  
  // Configuration
  final int maxConcurrentUploads;
  final int maxQueueSize;
  final bool enableChunkedUploads;
  final int chunkSizeThreshold; // Files larger than this will use chunked upload
  
  // Statistics
  int _totalUploadsStarted = 0;
  int _totalUploadsCompleted = 0;
  int _totalUploadsFailed = 0;
  DateTime? _lastUploadTime;
  
  ConcurrentUploadManager({
    required ChunkedUploadService chunkedUploadService,
    this.maxConcurrentUploads = StorageConstants.maxConcurrentUploads,
    this.maxQueueSize = 50,
    this.enableChunkedUploads = true,
    this.chunkSizeThreshold = 5 * 1024 * 1024, // 5MB
  }) : _chunkedUploadService = chunkedUploadService;

  /// Add files to upload queue
  List<String> queueUploads({
    required String bucketId,
    required String path,
    required List<FileUploadData> files,
    UploadPriority priority = UploadPriority.normal,
  }) {
    final uploadIds = <String>[];
    
    for (final file in files) {
      // Check queue size limit
      if (_uploadQueue.length >= maxQueueSize) {
        Logger.warning('Upload queue is full, skipping ${file.fileName}');
        continue;
      }
      
      // Create upload request
      final uploadId = _generateUploadId(bucketId, path, file.fileName);
      final request = _UploadRequest(
        uploadId: uploadId,
        bucketId: bucketId,
        path: path,
        file: file,
        priority: priority,
        queuedAt: DateTime.now(),
      );
      
      // Add to queue based on priority
      if (priority == UploadPriority.high) {
        // Add high priority uploads to the front
        final highPriorityIndex = _uploadQueue
            .toList()
            .indexWhere((req) => req.priority != UploadPriority.high);
        
        if (highPriorityIndex == -1) {
          _uploadQueue.addLast(request);
        } else {
          final queueList = _uploadQueue.toList();
          queueList.insert(highPriorityIndex, request);
          _uploadQueue.clear();
          _uploadQueue.addAll(queueList);
        }
      } else {
        _uploadQueue.addLast(request);
      }
      
      uploadIds.add(uploadId);
      
      // Create progress controller
      final progressController = StreamController<UploadProgress>.broadcast();
      _progressControllers[uploadId] = progressController;
    }
    
    Logger.info('Queued ${uploadIds.length} uploads for $bucketId/$path');
    
    // Start processing queue
    _processQueue();
    
    return uploadIds;
  }

  /// Get upload progress stream
  Stream<UploadProgress>? getUploadProgress(String uploadId) {
    return _progressControllers[uploadId]?.stream;
  }

  /// Get all upload progress
  Stream<List<UploadProgress>> getAllUploadProgress() {
    return Stream.periodic(const Duration(milliseconds: 500), (_) {
      final allProgress = <UploadProgress>[];
      
      // Add active uploads
      for (final uploadId in _activeUploads.keys) {
        final progress = _chunkedUploadService.getUploadProgress(uploadId);
        if (progress != null) {
          allProgress.add(progress);
        }
      }
      
      // Add queued uploads
      for (final request in _uploadQueue) {
        allProgress.add(UploadProgress(
          uploadId: request.uploadId,
          fileName: request.file.fileName,
          bytesUploaded: 0,
          totalBytes: request.file.data.length,
          status: UploadStatus.pending,
          speed: 0.0,
        ));
      }
      
      return allProgress;
    });
  }

  /// Pause an upload
  void pauseUpload(String uploadId) {
    if (_activeUploads.containsKey(uploadId)) {
      _chunkedUploadService.pauseUpload(uploadId);
      Logger.info('Paused upload: $uploadId');
    }
  }

  /// Resume an upload
  void resumeUpload(String uploadId) {
    if (_activeUploads.containsKey(uploadId)) {
      final progressStream = _chunkedUploadService.resumeUpload(uploadId);
      _listenToUploadProgress(uploadId, progressStream);
      Logger.info('Resumed upload: $uploadId');
    }
  }

  /// Cancel an upload
  void cancelUpload(String uploadId) {
    // Remove from queue if not started
    _uploadQueue.removeWhere((request) => request.uploadId == uploadId);
    
    // Cancel active upload
    if (_activeUploads.containsKey(uploadId)) {
      _chunkedUploadService.cancelUpload(uploadId);
      _activeUploads.remove(uploadId);
    }
    
    // Clean up progress controller
    final progressController = _progressControllers.remove(uploadId);
    progressController?.close();
    
    Logger.info('Cancelled upload: $uploadId');
    
    // Process next in queue
    _processQueue();
  }

  /// Cancel all uploads
  void cancelAllUploads() {
    final uploadIds = [
      ..._uploadQueue.map((req) => req.uploadId),
      ..._activeUploads.keys,
    ];
    
    for (final uploadId in uploadIds) {
      cancelUpload(uploadId);
    }
    
    Logger.info('Cancelled all uploads');
  }

  /// Pause all uploads
  void pauseAllUploads() {
    for (final uploadId in _activeUploads.keys) {
      pauseUpload(uploadId);
    }
    Logger.info('Paused all uploads');
  }

  /// Resume all uploads
  void resumeAllUploads() {
    for (final uploadId in _activeUploads.keys) {
      resumeUpload(uploadId);
    }
    Logger.info('Resumed all uploads');
  }

  /// Get upload statistics
  UploadStatistics getStatistics() {
    return UploadStatistics(
      totalUploadsStarted: _totalUploadsStarted,
      totalUploadsCompleted: _totalUploadsCompleted,
      totalUploadsFailed: _totalUploadsFailed,
      activeUploads: _activeUploads.length,
      queuedUploads: _uploadQueue.length,
      lastUploadTime: _lastUploadTime,
    );
  }

  /// Clear completed uploads from tracking
  void clearCompletedUploads() {
    final completedIds = <String>[];
    
    for (final uploadId in _activeUploads.keys) {
      final progress = _chunkedUploadService.getUploadProgress(uploadId);
      if (progress?.status == UploadStatus.completed ||
          progress?.status == UploadStatus.failed ||
          progress?.status == UploadStatus.cancelled) {
        completedIds.add(uploadId);
      }
    }
    
    for (final uploadId in completedIds) {
      _activeUploads.remove(uploadId);
      final progressController = _progressControllers.remove(uploadId);
      progressController?.close();
    }
    
    Logger.info('Cleared ${completedIds.length} completed uploads');
  }

  /// Process upload queue
  void _processQueue() {
    // Start uploads up to the concurrent limit
    while (_activeUploads.length < maxConcurrentUploads && _uploadQueue.isNotEmpty) {
      final request = _uploadQueue.removeFirst();
      _startUpload(request);
    }
  }

  /// Start an individual upload
  void _startUpload(_UploadRequest request) {
    try {
      _activeUploads[request.uploadId] = request;
      _totalUploadsStarted++;
      _lastUploadTime = DateTime.now();
      
      Logger.info('Starting upload: ${request.file.fileName} (${request.file.data.length} bytes)');
      
      // Determine upload method based on file size
      Stream<UploadProgress> progressStream;
      
      if (enableChunkedUploads && request.file.data.length > chunkSizeThreshold) {
        // Use chunked upload for large files
        progressStream = _chunkedUploadService.uploadFile(
          bucketId: request.bucketId,
          path: request.path,
          fileName: request.file.fileName,
          fileData: request.file.data,
          mimeType: request.file.mimeType,
          metadata: request.file.metadata,
        );
      } else {
        // Use regular upload for small files
        progressStream = _startRegularUpload(request);
      }
      
      _listenToUploadProgress(request.uploadId, progressStream);
      
    } catch (e) {
      Logger.error('Failed to start upload for ${request.file.fileName}', e);
      _handleUploadError(request.uploadId, e.toString());
    }
  }

  /// Start regular (non-chunked) upload
  Stream<UploadProgress> _startRegularUpload(_UploadRequest request) {
    final controller = StreamController<UploadProgress>();
    
    // Simulate regular upload progress
    _simulateRegularUpload(request, controller);
    
    return controller.stream;
  }

  /// Simulate regular upload (replace with actual implementation)
  Future<void> _simulateRegularUpload(
    _UploadRequest request,
    StreamController<UploadProgress> controller,
  ) async {
    try {
      final totalBytes = request.file.data.length;
      const updateInterval = Duration(milliseconds: 100);
      const simulatedSpeed = 1024 * 1024; // 1MB/s
      
      int bytesUploaded = 0;
      final startTime = DateTime.now();
      
      while (bytesUploaded < totalBytes) {
        await Future.delayed(updateInterval);
        
        // Simulate upload progress
        final elapsed = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
        bytesUploaded = (elapsed * simulatedSpeed).round().clamp(0, totalBytes);
        
        final progress = UploadProgress(
          uploadId: request.uploadId,
          fileName: request.file.fileName,
          bytesUploaded: bytesUploaded,
          totalBytes: totalBytes,
          status: UploadStatus.uploading,
          speed: simulatedSpeed.toDouble(),
        );
        
        controller.add(progress);
      }
      
      // Complete upload
      final finalProgress = UploadProgress(
        uploadId: request.uploadId,
        fileName: request.file.fileName,
        bytesUploaded: totalBytes,
        totalBytes: totalBytes,
        status: UploadStatus.completed,
        speed: simulatedSpeed.toDouble(),
      );
      
      controller.add(finalProgress);
      controller.close();
      
    } catch (e) {
      final errorProgress = UploadProgress(
        uploadId: request.uploadId,
        fileName: request.file.fileName,
        bytesUploaded: 0,
        totalBytes: request.file.data.length,
        status: UploadStatus.failed,
        speed: 0.0,
        error: e.toString(),
      );
      
      controller.add(errorProgress);
      controller.close();
    }
  }

  /// Listen to upload progress and forward to main controller
  void _listenToUploadProgress(String uploadId, Stream<UploadProgress> progressStream) {
    final mainController = _progressControllers[uploadId];
    if (mainController == null) return;
    
    progressStream.listen(
      (progress) {
        mainController.add(progress);
        
        // Handle upload completion
        if (progress.status == UploadStatus.completed) {
          _handleUploadComplete(uploadId);
        } else if (progress.status == UploadStatus.failed) {
          _handleUploadError(uploadId, progress.error ?? 'Unknown error');
        }
      },
      onError: (error) {
        _handleUploadError(uploadId, error.toString());
      },
      onDone: () {
        // Upload stream completed
      },
    );
  }

  /// Handle upload completion
  void _handleUploadComplete(String uploadId) {
    _totalUploadsCompleted++;
    _activeUploads.remove(uploadId);
    
    Logger.info('Upload completed: $uploadId');
    
    // Process next in queue
    _processQueue();
  }

  /// Handle upload error
  void _handleUploadError(String uploadId, String error) {
    _totalUploadsFailed++;
    _activeUploads.remove(uploadId);
    
    final progressController = _progressControllers[uploadId];
    if (progressController != null) {
      final request = _activeUploads[uploadId];
      final errorProgress = UploadProgress(
        uploadId: uploadId,
        fileName: request?.file.fileName ?? 'Unknown',
        bytesUploaded: 0,
        totalBytes: request?.file.data.length ?? 0,
        status: UploadStatus.failed,
        speed: 0.0,
        error: error,
      );
      
      progressController.add(errorProgress);
    }
    
    Logger.error('Upload failed: $uploadId - $error');
    
    // Process next in queue
    _processQueue();
  }

  /// Generate unique upload ID
  String _generateUploadId(String bucketId, String path, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = '${bucketId}_${path}_${fileName}_$timestamp'.hashCode;
    return 'upload_${hash.abs()}';
  }

  /// Dispose resources
  void dispose() {
    cancelAllUploads();
    _chunkedUploadService.dispose();
  }
}

/// Upload request data class
class _UploadRequest {
  final String uploadId;
  final String bucketId;
  final String path;
  final FileUploadData file;
  final UploadPriority priority;
  final DateTime queuedAt;

  _UploadRequest({
    required this.uploadId,
    required this.bucketId,
    required this.path,
    required this.file,
    required this.priority,
    required this.queuedAt,
  });
}

/// File upload data class
class FileUploadData {
  final String fileName;
  final Uint8List data;
  final String mimeType;
  final Map<String, String> metadata;

  const FileUploadData({
    required this.fileName,
    required this.data,
    required this.mimeType,
    this.metadata = const {},
  });
}

/// Upload priority levels
enum UploadPriority {
  low,
  normal,
  high,
}

/// Upload statistics data class
class UploadStatistics {
  final int totalUploadsStarted;
  final int totalUploadsCompleted;
  final int totalUploadsFailed;
  final int activeUploads;
  final int queuedUploads;
  final DateTime? lastUploadTime;

  const UploadStatistics({
    required this.totalUploadsStarted,
    required this.totalUploadsCompleted,
    required this.totalUploadsFailed,
    required this.activeUploads,
    required this.queuedUploads,
    this.lastUploadTime,
  });

  /// Get success rate as percentage
  double get successRate {
    final totalCompleted = totalUploadsCompleted + totalUploadsFailed;
    if (totalCompleted == 0) return 0.0;
    return (totalUploadsCompleted / totalCompleted) * 100;
  }

  @override
  String toString() {
    return 'UploadStatistics(started: $totalUploadsStarted, completed: $totalUploadsCompleted, '
           'failed: $totalUploadsFailed, active: $activeUploads, queued: $queuedUploads)';
  }
}