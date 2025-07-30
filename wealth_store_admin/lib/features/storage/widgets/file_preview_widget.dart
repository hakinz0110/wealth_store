import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/storage_models.dart';
import '../constants/storage_constants.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/utils/logger.dart';

/// Widget for displaying file previews with zoom and controls
class FilePreviewWidget extends HookWidget {
  final StorageFile file;
  final double maxWidth;
  final double maxHeight;

  const FilePreviewWidget({
    super.key,
    required this.file,
    this.maxWidth = 600,
    this.maxHeight = 400,
  });

  @override
  Widget build(BuildContext context) {
    if (file.isFolder) {
      return _buildFolderPreview();
    }

    switch (file.fileType) {
      case StorageFileType.image:
        return _buildImagePreview();
      case StorageFileType.video:
        return _buildVideoPreview();
      case StorageFileType.document:
        return _buildDocumentPreview();
      default:
        return _buildGenericFilePreview();
    }
  }

  Widget _buildFolderPreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.folder,
          size: 120,
          color: AppColors.warning.withOpacity(0.7),
        ),
        const SizedBox(height: 16),
        const Text(
          'Folder',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (file.publicUrl == null || file.publicUrl!.isEmpty) {
      return _buildGenericFilePreview();
    }

    return _ImagePreviewWithZoom(
      imageUrl: file.publicUrl!,
      fileName: file.name,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  Widget _buildVideoPreview() {
    if (file.publicUrl == null || file.publicUrl!.isEmpty) {
      return _buildGenericFilePreview();
    }

    return _VideoPreviewWidget(
      videoUrl: file.publicUrl!,
      fileName: file.name,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  Widget _buildDocumentPreview() {
    if (file.publicUrl == null || file.publicUrl!.isEmpty) {
      return _buildGenericFilePreview();
    }

    return _DocumentPreviewWidget(
      documentUrl: file.publicUrl!,
      fileName: file.name,
      fileExtension: file.extension,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  Widget _buildGenericFilePreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFileIcon(file, size: 120),
        const SizedBox(height: 16),
        Text(
          file.fileType.displayName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          file.formattedSize,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildFileIcon(StorageFile file, {double size = 24}) {
    if (file.isFolder) {
      return Icon(
        Icons.folder,
        size: size,
        color: AppColors.warning,
      );
    }

    IconData iconData;
    Color iconColor;
    
    switch (file.fileType) {
      case StorageFileType.image:
        iconData = Icons.image;
        iconColor = AppColors.success;
        break;
      case StorageFileType.video:
        iconData = Icons.video_file;
        iconColor = AppColors.info;
        break;
      case StorageFileType.document:
        iconData = Icons.description;
        iconColor = AppColors.error;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = AppColors.textSecondary;
    }

    return Icon(
      iconData,
      size: size,
      color: iconColor,
    );
  }
}

/// Image preview widget with zoom functionality
class _ImagePreviewWithZoom extends HookWidget {
  final String imageUrl;
  final String fileName;
  final double maxWidth;
  final double maxHeight;

  const _ImagePreviewWithZoom({
    required this.imageUrl,
    required this.fileName,
    required this.maxWidth,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final transformationController = useTransformationController();
    final isZoomed = useState(false);
    
    // Reset zoom when image changes
    useEffect(() {
      transformationController.value = Matrix4.identity();
      isZoomed.value = false;
    }, [imageUrl]);

    // Listen to transformation changes
    useEffect(() {
      void onTransformationChanged() {
        final scale = transformationController.value.getMaxScaleOnAxis();
        isZoomed.value = scale > 1.0;
      }
      
      transformationController.addListener(onTransformationChanged);
      return () => transformationController.removeListener(onTransformationChanged);
    }, [transformationController]);

    return Column(
      children: [
        // Zoom controls
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildZoomButton(
                icon: Icons.zoom_in,
                tooltip: 'Zoom In',
                onPressed: () => _zoomIn(transformationController),
              ),
              const SizedBox(width: 8),
              _buildZoomButton(
                icon: Icons.zoom_out,
                tooltip: 'Zoom Out',
                onPressed: () => _zoomOut(transformationController),
              ),
              const SizedBox(width: 8),
              _buildZoomButton(
                icon: Icons.zoom_out_map,
                tooltip: 'Reset Zoom',
                onPressed: () => _resetZoom(transformationController, isZoomed),
              ),
              const SizedBox(width: 16),
              Text(
                '${(_getZoomLevel(transformationController) * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Image with zoom
        Expanded(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: InteractiveViewer(
                transformationController: transformationController,
                minScale: 0.5,
                maxScale: 5.0,
                constrained: false,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    
                    final progress = loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / 
                          loadingProgress.expectedTotalBytes!
                        : null;
                    
                    return Container(
                      width: 300,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            color: AppColors.primaryBlue,
                            strokeWidth: 2,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            progress != null 
                                ? '${(progress * 100).toInt()}%'
                                : 'Loading...',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    Logger.error('Failed to load image preview for $fileName', error);
                    return Container(
                      width: 300,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 48,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Failed to load image',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fileName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
          color: AppColors.textSecondary,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  void _zoomIn(TransformationController controller) {
    final currentScale = controller.value.getMaxScaleOnAxis();
    final newScale = (currentScale * 1.2).clamp(0.5, 5.0);
    controller.value = Matrix4.identity()..scale(newScale);
  }

  void _zoomOut(TransformationController controller) {
    final currentScale = controller.value.getMaxScaleOnAxis();
    final newScale = (currentScale / 1.2).clamp(0.5, 5.0);
    controller.value = Matrix4.identity()..scale(newScale);
  }

  void _resetZoom(TransformationController controller, ValueNotifier<bool> isZoomed) {
    controller.value = Matrix4.identity();
    isZoomed.value = false;
  }

  double _getZoomLevel(TransformationController controller) {
    return controller.value.getMaxScaleOnAxis();
  }
}

/// Video preview widget with controls
class _VideoPreviewWidget extends HookWidget {
  final String videoUrl;
  final String fileName;
  final double maxWidth;
  final double maxHeight;

  const _VideoPreviewWidget({
    required this.videoUrl,
    required this.fileName,
    required this.maxWidth,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaying = useState(false);
    final showControls = useState(true);
    
    // Auto-hide controls after 3 seconds
    useEffect(() {
      if (showControls.value) {
        final timer = Future.delayed(const Duration(seconds: 3), () {
          if (isPlaying.value) {
            showControls.value = false;
          }
        });
        return () => timer.ignore();
      }
      return null;
    }, [showControls.value, isPlaying.value]);

    return Container(
      width: maxWidth,
      height: maxHeight,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video thumbnail/placeholder
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_file,
                size: 80,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                fileName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Video Preview',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          
          // Play button overlay
          if (!isPlaying.value)
            GestureDetector(
              onTap: () {
                isPlaying.value = true;
                showControls.value = true;
                _playVideo(videoUrl);
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          
          // Video controls (when playing)
          if (isPlaying.value && showControls.value)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildVideoControls(
                isPlaying,
                showControls,
                () => _pauseVideo(),
                () => _stopVideo(isPlaying),
              ),
            ),
          
          // Tap to show controls
          if (isPlaying.value && !showControls.value)
            GestureDetector(
              onTap: () => showControls.value = true,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoControls(
    ValueNotifier<bool> isPlaying,
    ValueNotifier<bool> showControls,
    VoidCallback onPause,
    VoidCallback onStop,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          // Play/Pause button
          IconButton(
            onPressed: onPause,
            icon: Icon(
              isPlaying.value ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Progress bar placeholder
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                widthFactor: 0.3, // Placeholder progress
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Time display
          const Text(
            '0:30 / 2:15',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Stop button
          IconButton(
            onPressed: onStop,
            icon: const Icon(
              Icons.stop,
              color: Colors.white,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }

  void _playVideo(String url) {
    // In a real implementation, this would initialize a video player
    Logger.info('Playing video: $url');
  }

  void _pauseVideo() {
    // In a real implementation, this would pause the video player
    Logger.info('Pausing video');
  }

  void _stopVideo(ValueNotifier<bool> isPlaying) {
    // In a real implementation, this would stop the video player
    isPlaying.value = false;
    Logger.info('Stopping video');
  }
}

/// Document preview widget
class _DocumentPreviewWidget extends HookWidget {
  final String documentUrl;
  final String fileName;
  final String fileExtension;
  final double maxWidth;
  final double maxHeight;

  const _DocumentPreviewWidget({
    required this.documentUrl,
    required this.fileName,
    required this.fileExtension,
    required this.maxWidth,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);
    final hasError = useState(false);
    
    return Container(
      width: maxWidth,
      height: maxHeight,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Document header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                _buildDocumentIcon(fileExtension),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${fileExtension.toUpperCase()} Document',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Download/Open button
                IconButton(
                  onPressed: () => _openDocument(documentUrl),
                  icon: const Icon(Icons.open_in_new),
                  color: AppColors.primaryBlue,
                  tooltip: 'Open document',
                ),
              ],
            ),
          ),
          
          // Document preview area
          Expanded(
            child: _buildDocumentPreview(
              fileExtension,
              isLoading.value,
              hasError.value,
              () => isLoading.value = true,
              (error) => hasError.value = error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentIcon(String extension) {
    IconData iconData;
    Color iconColor;
    
    switch (extension.toLowerCase()) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = AppColors.error;
        break;
      case 'doc':
      case 'docx':
        iconData = Icons.description;
        iconColor = AppColors.info;
        break;
      case 'xls':
      case 'xlsx':
        iconData = Icons.table_chart;
        iconColor = AppColors.success;
        break;
      case 'ppt':
      case 'pptx':
        iconData = Icons.slideshow;
        iconColor = AppColors.warning;
        break;
      case 'txt':
        iconData = Icons.text_snippet;
        iconColor = AppColors.textSecondary;
        break;
      default:
        iconData = Icons.description;
        iconColor = AppColors.textSecondary;
    }
    
    return Icon(
      iconData,
      size: 32,
      color: iconColor,
    );
  }

  Widget _buildDocumentPreview(
    String extension,
    bool isLoading,
    bool hasError,
    VoidCallback setLoading,
    Function(bool) setError,
  ) {
    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            const Text(
              'Preview not available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Click "Open document" to view the file',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primaryBlue,
              strokeWidth: 2,
            ),
            SizedBox(height: 16),
            Text(
              'Loading preview...',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Document preview placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.borderLight,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Document header
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      extension.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                
                // Document content lines
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: List.generate(8, (index) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        height: 2,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Document Preview',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Full preview coming soon',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _openDocument(String url) {
    // In a real implementation, this would open the document in a new tab
    Logger.info('Opening document: $url');
  }
}