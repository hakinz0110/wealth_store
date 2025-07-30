import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/storage_models.dart';
import '../providers/file_operation_providers.dart';
import '../providers/storage_providers.dart';
import '../services/upload_progress_tracker.dart';
import '../constants/storage_constants.dart';
import '../../../shared/constants/app_colors.dart';

/// Widget for displaying upload progress with individual file progress bars
class UploadProgressWidget extends HookConsumerWidget {
  final bool showOverallProgress;
  final bool showIndividualProgress;
  final bool allowCancellation;
  final VoidCallback? onAllUploadsComplete;
  final Function(String)? onUploadCancelled;
  final Function(String, String)? onUploadRetry;

  const UploadProgressWidget({
    super.key,
    this.showOverallProgress = true,
    this.showIndividualProgress = true,
    this.allowCancellation = true,
    this.onAllUploadsComplete,
    this.onUploadCancelled,
    this.onUploadRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch upload progress
    final uploadProgressAsync = ref.watch(uploadProgressStreamProvider);
    final activeUploads = ref.watch(activeUploadsProvider);
    final completedUploads = ref.watch(completedUploadsProvider);
    final failedUploads = ref.watch(failedUploadsProvider);
    
    // Get progress tracker for operations
    final progressTracker = ref.read(uploadProgressTrackerProvider);
    
    // Screen size
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < StorageConstants.mobileBreakpoint;
    
    return uploadProgressAsync.when(
      data: (progressMap) {
        if (progressMap.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Container(
          margin: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(
                context,
                activeUploads.length,
                completedUploads.length,
                failedUploads.length,
                progressTracker,
                isMobile,
              ),
              
              // Overall progress
              if (showOverallProgress && activeUploads.isNotEmpty)
                _buildOverallProgress(
                  context,
                  progressTracker,
                  activeUploads,
                  isMobile,
                ),
              
              // Individual file progress
              if (showIndividualProgress && progressMap.isNotEmpty)
                _buildIndividualProgress(
                  context,
                  progressMap.values.toList(),
                  progressTracker,
                  isMobile,
                ),
              
              // Actions
              if (activeUploads.isNotEmpty || failedUploads.isNotEmpty)
                _buildActions(
                  context,
                  activeUploads,
                  failedUploads,
                  progressTracker,
                  isMobile,
                ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => _buildErrorState(context, error.toString()),
    );
  }
  
  Widget _buildHeader(
    BuildContext context,
    int activeCount,
    int completedCount,
    int failedCount,
    dynamic progressTracker,
    bool isMobile,
  ) {
    final totalCount = activeCount + completedCount + failedCount;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_upload,
            color: AppColors.primaryBlue,
            size: isMobile ? 20 : 24,
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Progress',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (totalCount > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    _getStatusText(activeCount, completedCount, failedCount),
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (activeCount > 0)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildOverallProgress(
    BuildContext context,
    dynamic progressTracker,
    List<StorageUploadProgress> activeUploads,
    bool isMobile,
  ) {
    if (progressTracker is! StorageUploadProgressTracker) {
      return const SizedBox.shrink();
    }
    
    final overallProgress = progressTracker.overallProgress;
    final totalUploadedBytes = progressTracker.totalUploadedBytes;
    final totalBytesToUpload = progressTracker.totalBytesToUpload;
    final estimatedTimeRemaining = progressTracker.estimatedTimeRemaining;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${(overallProgress * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: overallProgress,
            backgroundColor: AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (totalBytesToUpload > 0)
                Text(
                  '${_formatBytes(totalUploadedBytes)} / ${_formatBytes(totalBytesToUpload)}',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: AppColors.textMuted,
                  ),
                ),
              if (estimatedTimeRemaining != null)
                Text(
                  'ETA: ${_formatDuration(estimatedTimeRemaining)}',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildIndividualProgress(
    BuildContext context,
    List<StorageUploadProgress> uploads,
    dynamic progressTracker,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 8 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Files',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...uploads.map((upload) => _buildFileProgressItem(
            context,
            upload,
            progressTracker,
            isMobile,
          )),
        ],
      ),
    );
  }
  
  Widget _buildFileProgressItem(
    BuildContext context,
    StorageUploadProgress upload,
    dynamic progressTracker,
    bool isMobile,
  ) {
    final isActive = !upload.isComplete && upload.error == null;
    final hasError = upload.error != null;
    final isCompleted = upload.isComplete && upload.error == null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: hasError 
            ? AppColors.error.withValues(alpha: 0.05)
            : isCompleted
                ? AppColors.success.withValues(alpha: 0.05)
                : AppColors.backgroundLight,
        border: Border.all(
          color: hasError 
              ? AppColors.error
              : isCompleted
                  ? AppColors.success
                  : AppColors.borderLight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File name and status
          Row(
            children: [
              Icon(
                hasError 
                    ? Icons.error_outline
                    : isCompleted
                        ? Icons.check_circle_outline
                        : Icons.insert_drive_file,
                size: 16,
                color: hasError 
                    ? AppColors.error
                    : isCompleted
                        ? AppColors.success
                        : AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  upload.fileName,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w500,
                    color: hasError 
                        ? AppColors.error
                        : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isActive && allowCancellation)
                IconButton(
                  onPressed: () => _cancelUpload(upload.fileName, progressTracker),
                  icon: const Icon(Icons.close, size: 16),
                  color: AppColors.textSecondary,
                  tooltip: 'Cancel upload',
                  splashRadius: 12,
                ),
              if (hasError)
                IconButton(
                  onPressed: () => _retryUpload(upload.fileName, upload.error!),
                  icon: const Icon(Icons.refresh, size: 16),
                  color: AppColors.primaryBlue,
                  tooltip: 'Retry upload',
                  splashRadius: 12,
                ),
            ],
          ),
          
          // Progress bar (for active uploads)
          if (isActive) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: upload.progress,
                    backgroundColor: AppColors.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(upload.progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
          
          // Error message
          if (hasError) ...[
            const SizedBox(height: 8),
            Text(
              upload.error!,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: AppColors.error,
              ),
            ),
          ],
          
          // Upload speed and size info
          if (isActive && upload.uploadedBytes != null && upload.totalBytes != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatBytes(upload.uploadedBytes!)} / ${_formatBytes(upload.totalBytes!)}',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    color: AppColors.textMuted,
                  ),
                ),
                if (upload.formattedSpeed.isNotEmpty)
                  Text(
                    upload.formattedSpeed,
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 11,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildActions(
    BuildContext context,
    List<StorageUploadProgress> activeUploads,
    List<StorageUploadProgress> failedUploads,
    dynamic progressTracker,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          // Cancel all button
          if (activeUploads.isNotEmpty && allowCancellation)
            TextButton.icon(
              onPressed: () => _cancelAllUploads(progressTracker),
              icon: const Icon(Icons.cancel_outlined, size: 16),
              label: Text(isMobile ? 'Cancel' : 'Cancel All'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
            ),
          
          // Retry failed button
          if (failedUploads.isNotEmpty) ...[
            if (activeUploads.isNotEmpty) const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => _retryFailedUploads(failedUploads),
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(isMobile ? 'Retry' : 'Retry Failed'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
          ],
          
          const Spacer(),
          
          // Clear completed button
          TextButton.icon(
            onPressed: () => _clearCompleted(progressTracker),
            icon: const Icon(Icons.clear_all, size: 16),
            label: Text(isMobile ? 'Clear' : 'Clear Completed'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.error),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Upload progress error: $error',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getStatusText(int active, int completed, int failed) {
    final parts = <String>[];
    
    if (active > 0) {
      parts.add('$active uploading');
    }
    if (completed > 0) {
      parts.add('$completed completed');
    }
    if (failed > 0) {
      parts.add('$failed failed');
    }
    
    return parts.join(' • ');
  }
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
  
  void _cancelUpload(String fileName, dynamic progressTracker) {
    if (progressTracker is StorageUploadProgressTracker) {
      progressTracker.cancelUpload(fileName);
      onUploadCancelled?.call(fileName);
    }
  }
  
  void _cancelAllUploads(dynamic progressTracker) {
    if (progressTracker is StorageUploadProgressTracker) {
      final activeUploads = progressTracker.getActiveUploads();
      for (final upload in activeUploads) {
        progressTracker.cancelUpload(upload.fileName);
        onUploadCancelled?.call(upload.fileName);
      }
    }
  }
  
  void _retryUpload(String fileName, String error) {
    onUploadRetry?.call(fileName, error);
  }
  
  void _retryFailedUploads(List<StorageUploadProgress> failedUploads) {
    for (final upload in failedUploads) {
      if (upload.error != null) {
        onUploadRetry?.call(upload.fileName, upload.error!);
      }
    }
  }
  
  void _clearCompleted(dynamic progressTracker) {
    if (progressTracker is StorageUploadProgressTracker) {
      progressTracker.clearCompleted();
    }
  }
}