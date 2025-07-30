import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/storage_models.dart';
import '../constants/storage_constants.dart';
import '../../../shared/constants/app_colors.dart';

/// Mobile-optimized upload interface with drag-and-drop and camera integration
class MobileUploadInterface extends HookConsumerWidget {
  final String bucketId;
  final String currentPath;
  final Function(List<String>)? onFilesSelected;
  final VoidCallback? onClose;
  final bool showCameraOption;
  final bool showGalleryOption;
  final bool showDocumentOption;

  const MobileUploadInterface({
    super.key,
    required this.bucketId,
    required this.currentPath,
    this.onFilesSelected,
    this.onClose,
    this.showCameraOption = true,
    this.showGalleryOption = true,
    this.showDocumentOption = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDragOver = useState<bool>(false);
    final uploadProgress = useState<double>(0.0);
    final isUploading = useState<bool>(false);
    
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < StorageConstants.mobileBreakpoint;

    return Container(
      height: screenSize.height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Upload Files',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          
          const Divider(color: AppColors.borderLight),
          
          // Upload options
          Expanded(
            child: isUploading.value
                ? _buildUploadProgress(uploadProgress.value)
                : _buildUploadOptions(
                    context,
                    isDragOver.value,
                    (files) {
                      isUploading.value = true;
                      onFilesSelected?.call(files);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadOptions(
    BuildContext context,
    bool isDragOver,
    Function(List<String>) onFilesSelected,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Drag and drop area
          GestureDetector(
            onTap: () => _showFilePickerOptions(context, onFilesSelected),
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: isDragOver 
                    ? AppColors.primaryBlue.withOpacity(0.1)
                    : AppColors.backgroundLight,
                border: Border.all(
                  color: isDragOver 
                      ? AppColors.primaryBlue
                      : AppColors.borderLight,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: isDragOver 
                        ? AppColors.primaryBlue
                        : AppColors.textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to select files',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDragOver 
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'or drag and drop files here',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick action buttons
          Row(
            children: [
              if (showCameraOption)
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () => _openCamera(onFilesSelected),
                  ),
                ),
              
              if (showCameraOption && showGalleryOption)
                const SizedBox(width: 12),
              
              if (showGalleryOption)
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () => _openGallery(onFilesSelected),
                  ),
                ),
              
              if ((showCameraOption || showGalleryOption) && showDocumentOption)
                const SizedBox(width: 12),
              
              if (showDocumentOption)
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.description_outlined,
                    label: 'Documents',
                    onTap: () => _openDocuments(onFilesSelected),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Upload guidelines
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Upload Guidelines',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Maximum file size: ${_formatFileSize(StorageConstants.maxGeneralFileSize)}\n'
                  '• Supported formats: Images, Videos, Documents\n'
                  '• Multiple files can be selected at once',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadProgress(double progress) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: AppColors.borderLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Uploading files...',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% complete',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilePickerOptions(BuildContext context, Function(List<String>) onFilesSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select File Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            if (showCameraOption)
              _buildFileSourceOption(
                context,
                icon: Icons.camera_alt,
                title: 'Camera',
                subtitle: 'Take a photo or video',
                onTap: () {
                  Navigator.pop(context);
                  _openCamera(onFilesSelected);
                },
              ),
            
            if (showGalleryOption)
              _buildFileSourceOption(
                context,
                icon: Icons.photo_library,
                title: 'Photo Library',
                subtitle: 'Choose from gallery',
                onTap: () {
                  Navigator.pop(context);
                  _openGallery(onFilesSelected);
                },
              ),
            
            if (showDocumentOption)
              _buildFileSourceOption(
                context,
                icon: Icons.folder,
                title: 'Files',
                subtitle: 'Browse device files',
                onTap: () {
                  Navigator.pop(context);
                  _openDocuments(onFilesSelected);
                },
              ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSourceOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCamera(Function(List<String>) onFilesSelected) {
    // TODO: Implement camera functionality
    // This would typically use image_picker package
    print('Opening camera...');
  }

  void _openGallery(Function(List<String>) onFilesSelected) {
    // TODO: Implement gallery functionality
    // This would typically use image_picker package
    print('Opening gallery...');
  }

  void _openDocuments(Function(List<String>) onFilesSelected) {
    // TODO: Implement document picker functionality
    // This would typically use file_picker package
    print('Opening document picker...');
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

/// Mobile file preview widget with swipe navigation
class MobileFilePreview extends StatefulWidget {
  final StorageFile file;
  final List<StorageFile> allFiles;
  final VoidCallback? onClose;
  final Function(StorageFile)? onFileChanged;

  const MobileFilePreview({
    super.key,
    required this.file,
    required this.allFiles,
    this.onClose,
    this.onFileChanged,
  });

  @override
  State<MobileFilePreview> createState() => _MobileFilePreviewState();
}

class _MobileFilePreviewState extends State<MobileFilePreview> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.allFiles.indexWhere((f) => f.id == widget.file.id);
    if (_currentIndex == -1) _currentIndex = 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        leading: IconButton(
          onPressed: widget.onClose,
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        title: Text(
          widget.allFiles[_currentIndex].name,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => _showFileActions(context),
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.allFiles.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          widget.onFileChanged?.call(widget.allFiles[index]);
        },
        itemBuilder: (context, index) {
          final file = widget.allFiles[index];
          return _buildFilePreview(file);
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.black.withOpacity(0.7),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_currentIndex + 1} of ${widget.allFiles.length}',
              style: const TextStyle(color: Colors.white),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _currentIndex > 0 ? _previousFile : null,
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                ),
                IconButton(
                  onPressed: _currentIndex < widget.allFiles.length - 1 ? _nextFile : null,
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(StorageFile file) {
    if (file.fileType == StorageFileType.image) {
      return InteractiveViewer(
        child: Center(
          child: Image.network(
            file.publicUrl ?? '',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.white54,
                ),
              );
            },
          ),
        ),
      );
    } else if (file.fileType == StorageFileType.video) {
      // TODO: Implement video player
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              'Video preview not implemented',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              file.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              file.formattedSize,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
  }

  void _previousFile() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextFile() {
    if (_currentIndex < widget.allFiles.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showFileActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'File Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action items would go here
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}