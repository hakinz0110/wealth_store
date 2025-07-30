import 'dart:async';
import '../interfaces/storage_interfaces.dart';
import '../models/storage_models.dart';
import '../../../shared/utils/logger.dart';

/// Concrete implementation of upload progress tracker
class StorageUploadProgressTracker implements IUploadProgressTracker {
  final Map<String, StorageUploadProgress> _activeUploads = {};
  final Map<String, StorageUploadProgress> _completedUploads = {};
  final StreamController<Map<String, StorageUploadProgress>> _progressController = 
      StreamController<Map<String, StorageUploadProgress>>.broadcast();

  /// Stream of upload progress updates
  Stream<Map<String, StorageUploadProgress>> get progressStream => _progressController.stream;

  @override
  void startTracking(String fileName) {
    try {
      final progress = StorageUploadProgress(
        fileName: fileName,
        progress: 0.0,
        isComplete: false,
      );
      
      _activeUploads[fileName] = progress;
      _notifyProgressUpdate();
      
      Logger.info('Started tracking upload for: $fileName');
    } catch (e) {
      Logger.error('Failed to start tracking upload for $fileName', e);
    }
  }

  @override
  void updateProgress(
    String fileName, 
    double progress, {
    int? uploadedBytes, 
    int? totalBytes,
  }) {
    try {
      final currentProgress = _activeUploads[fileName];
      if (currentProgress == null) {
        Logger.warning('Attempted to update progress for non-tracked file: $fileName');
        return;
      }

      // Ensure progress is between 0 and 1
      final clampedProgress = progress.clamp(0.0, 1.0);
      
      final updatedProgress = currentProgress.copyWith(
        progress: clampedProgress,
        uploadedBytes: uploadedBytes,
        totalBytes: totalBytes,
      );
      
      _activeUploads[fileName] = updatedProgress;
      _notifyProgressUpdate();
      
      Logger.debug('Updated upload progress for $fileName: ${(clampedProgress * 100).toStringAsFixed(1)}%');
    } catch (e) {
      Logger.error('Failed to update progress for $fileName', e);
    }
  }

  @override
  void completeUpload(String fileName, {StorageFile? file}) {
    try {
      final currentProgress = _activeUploads[fileName];
      if (currentProgress == null) {
        Logger.warning('Attempted to complete non-tracked upload: $fileName');
        return;
      }

      final completedProgress = currentProgress.copyWith(
        progress: 1.0,
        isComplete: true,
      );
      
      // Move from active to completed
      _activeUploads.remove(fileName);
      _completedUploads[fileName] = completedProgress;
      
      _notifyProgressUpdate();
      
      Logger.info('Completed upload tracking for: $fileName');
      
      // Auto-cleanup completed uploads after a delay
      Timer(const Duration(seconds: 30), () {
        _completedUploads.remove(fileName);
        _notifyProgressUpdate();
      });
    } catch (e) {
      Logger.error('Failed to complete upload tracking for $fileName', e);
    }
  }

  @override
  void failUpload(String fileName, String error) {
    try {
      final currentProgress = _activeUploads[fileName];
      if (currentProgress == null) {
        Logger.warning('Attempted to fail non-tracked upload: $fileName');
        return;
      }

      final failedProgress = currentProgress.copyWith(
        error: error,
        isComplete: false,
      );
      
      // Move from active to completed (with error)
      _activeUploads.remove(fileName);
      _completedUploads[fileName] = failedProgress;
      
      _notifyProgressUpdate();
      
      Logger.error('Upload failed for $fileName: $error');
      
      // Auto-cleanup failed uploads after a longer delay
      Timer(const Duration(minutes: 2), () {
        _completedUploads.remove(fileName);
        _notifyProgressUpdate();
      });
    } catch (e) {
      Logger.error('Failed to mark upload as failed for $fileName', e);
    }
  }

  @override
  StorageUploadProgress? getProgress(String fileName) {
    return _activeUploads[fileName] ?? _completedUploads[fileName];
  }

  @override
  List<StorageUploadProgress> getActiveUploads() {
    return _activeUploads.values.toList();
  }

  @override
  void cancelUpload(String fileName) {
    try {
      final removed = _activeUploads.remove(fileName);
      if (removed != null) {
        _notifyProgressUpdate();
        Logger.info('Cancelled upload tracking for: $fileName');
      } else {
        Logger.warning('Attempted to cancel non-tracked upload: $fileName');
      }
    } catch (e) {
      Logger.error('Failed to cancel upload for $fileName', e);
    }
  }

  @override
  void clearCompleted() {
    try {
      final clearedCount = _completedUploads.length;
      _completedUploads.clear();
      _notifyProgressUpdate();
      
      Logger.info('Cleared $clearedCount completed uploads');
    } catch (e) {
      Logger.error('Failed to clear completed uploads', e);
    }
  }

  /// Get all uploads (active and completed)
  Map<String, StorageUploadProgress> getAllUploads() {
    return {
      ..._activeUploads,
      ..._completedUploads,
    };
  }

  /// Get completed uploads
  List<StorageUploadProgress> getCompletedUploads() {
    return _completedUploads.values.toList();
  }

  /// Get failed uploads
  List<StorageUploadProgress> getFailedUploads() {
    return _completedUploads.values
        .where((progress) => progress.error != null)
        .toList();
  }

  /// Get successful uploads
  List<StorageUploadProgress> getSuccessfulUploads() {
    return _completedUploads.values
        .where((progress) => progress.isComplete && progress.error == null)
        .toList();
  }

  /// Check if any uploads are currently active
  bool get hasActiveUploads => _activeUploads.isNotEmpty;

  /// Get total number of active uploads
  int get activeUploadCount => _activeUploads.length;

  /// Get overall progress (average of all active uploads)
  double get overallProgress {
    if (_activeUploads.isEmpty) return 0.0;
    
    final totalProgress = _activeUploads.values
        .fold<double>(0.0, (sum, progress) => sum + progress.progress);
    
    return totalProgress / _activeUploads.length;
  }

  /// Get total bytes uploaded across all active uploads
  int get totalUploadedBytes {
    return _activeUploads.values
        .where((progress) => progress.uploadedBytes != null)
        .fold<int>(0, (sum, progress) => sum + progress.uploadedBytes!);
  }

  /// Get total bytes to upload across all active uploads
  int get totalBytesToUpload {
    return _activeUploads.values
        .where((progress) => progress.totalBytes != null)
        .fold<int>(0, (sum, progress) => sum + progress.totalBytes!);
  }

  /// Estimate remaining time for all uploads (in seconds)
  Duration? get estimatedTimeRemaining {
    if (_activeUploads.isEmpty) return null;
    
    final remainingBytes = totalBytesToUpload - totalUploadedBytes;
    if (remainingBytes <= 0) return Duration.zero;
    
    // Simple estimation based on current progress
    // This is a rough estimate and could be improved with actual speed tracking
    final averageProgress = overallProgress;
    if (averageProgress <= 0) return null;
    
    final estimatedTotalTime = DateTime.now().millisecondsSinceEpoch / averageProgress;
    final remainingTime = estimatedTotalTime - DateTime.now().millisecondsSinceEpoch;
    
    return Duration(milliseconds: remainingTime.round());
  }

  /// Batch start tracking for multiple files
  void startTrackingBatch(List<String> fileNames) {
    for (final fileName in fileNames) {
      startTracking(fileName);
    }
  }

  /// Batch cancel tracking for multiple files
  void cancelUploadBatch(List<String> fileNames) {
    for (final fileName in fileNames) {
      cancelUpload(fileName);
    }
  }

  /// Clear all uploads (active and completed)
  void clearAll() {
    try {
      final totalCleared = _activeUploads.length + _completedUploads.length;
      _activeUploads.clear();
      _completedUploads.clear();
      _notifyProgressUpdate();
      
      Logger.info('Cleared all uploads: $totalCleared items');
    } catch (e) {
      Logger.error('Failed to clear all uploads', e);
    }
  }

  /// Notify listeners of progress updates
  void _notifyProgressUpdate() {
    if (!_progressController.isClosed) {
      _progressController.add(getAllUploads());
    }
  }

  /// Dispose of resources
  void dispose() {
    try {
      _progressController.close();
      _activeUploads.clear();
      _completedUploads.clear();
      Logger.info('Upload progress tracker disposed');
    } catch (e) {
      Logger.error('Failed to dispose upload progress tracker', e);
    }
  }

  /// Create a snapshot of current state for debugging
  Map<String, dynamic> createSnapshot() {
    return {
      'activeUploads': _activeUploads.length,
      'completedUploads': _completedUploads.length,
      'overallProgress': overallProgress,
      'totalUploadedBytes': totalUploadedBytes,
      'totalBytesToUpload': totalBytesToUpload,
      'hasActiveUploads': hasActiveUploads,
      'uploads': getAllUploads().map((key, value) => MapEntry(key, {
        'fileName': value.fileName,
        'progress': value.progress,
        'isComplete': value.isComplete,
        'error': value.error,
        'uploadedBytes': value.uploadedBytes,
        'totalBytes': value.totalBytes,
      })),
    };
  }
}