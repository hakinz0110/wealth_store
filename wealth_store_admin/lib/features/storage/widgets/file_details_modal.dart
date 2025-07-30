import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/storage_models.dart';
import '../services/url_manager.dart';
import '../constants/storage_constants.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/utils/logger.dart';
import 'file_preview_widget.dart';
import 'url_sharing_widget.dart';

/// Modal dialog for displaying detailed file information and preview
class FileDetailsModal extends HookConsumerWidget {
  final StorageFile file;
  final VoidCallback? onClose;
  final Function(StorageFile)? onFileUpdated;
  final Function(StorageFile)? onFileDeleted;

  const FileDetailsModal({
    super.key,
    required this.file,
    this.onClose,
    this.onFileUpdated,
    this.onFileDeleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUrlCopying = useState(false);
    final copySuccessMessage = useState<String?>(null);
    final showUrlSharing = useState(false);
    
    // Auto-hide success message after 3 seconds
    useEffect(() {
      if (copySuccessMessage.value != null) {
        final timer = Future.delayed(const Duration(seconds: 3), () {
          copySuccessMessage.value = null;
        });
        return () => timer.ignore();
      }
      return null;
    }, [copySuccessMessage.value]);

    return Stack(
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            constraints: const BoxConstraints(
              maxWidth: 1000,
              maxHeight: 800,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                _buildHeader(context),
                
                // Content
                Expanded(
                  child: Row(
                    children: [
                      // Preview area
                      Expanded(
                        flex: 2,
                        child: _buildPreviewArea(context),
                      ),
                      
                      // Details panel
                      Container(
                        width: 300,
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppColors.borderLight,
                              width: 1,
                            ),
                          ),
                        ),
                        child: _buildDetailsPanel(
                          context,
                          isUrlCopying.value,
                          copySuccessMessage.value,
                          showUrlSharing.value,
                          (copying) => isUrlCopying.value = copying,
                          (message) => copySuccessMessage.value = message,
                          (show) => showUrlSharing.value = show,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // URL Sharing Modal
        if (showUrlSharing.value)
          UrlSharingWidget(
            file: file,
            onClose: () => showUrlSharing.value = false,
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // File icon
          _buildFileIcon(file, size: 32),
          
          const SizedBox(width: 12),
          
          // File name and type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  file.fileType.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Close button
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            color: AppColors.textSecondary,
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: _buildFilePreview(context),
      ),
    );
  }

  Widget _buildFilePreview(BuildContext context) {
    return FilePreviewWidget(
      file: file,
      maxWidth: 600,
      maxHeight: 400,
    );
  }



  Widget _buildDetailsPanel(
    BuildContext context,
    bool isUrlCopying,
    String? copySuccessMessage,
    bool showUrlSharing,
    Function(bool) setUrlCopying,
    Function(String?) setCopySuccessMessage,
    Function(bool) setShowUrlSharing,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File Information Section
          _buildSectionHeader('File Information'),
          const SizedBox(height: 12),
          _buildInfoRow('Name', file.name),
          _buildInfoRow('Size', file.isFolder ? '-' : file.formattedSize),
          _buildInfoRow('Type', file.fileType.displayName),
          if (file.mimeType != null)
            _buildInfoRow('MIME Type', file.mimeType!),
          _buildInfoRow('Extension', file.extension.isEmpty ? '-' : '.${file.extension}'),
          
          const SizedBox(height: 24),
          
          // Location Section
          _buildSectionHeader('Location'),
          const SizedBox(height: 12),
          _buildInfoRow('Bucket', file.bucketId),
          _buildInfoRow('Path', file.path),
          
          const SizedBox(height: 24),
          
          // Timestamps Section
          _buildSectionHeader('Timestamps'),
          const SizedBox(height: 12),
          _buildInfoRow('Created', _formatDateTime(file.createdAt)),
          _buildInfoRow('Modified', _formatDateTime(file.updatedAt)),
          
          const SizedBox(height: 24),
          
          // URL Section (only for files, not folders)
          if (!file.isFolder) ...[
            _buildSectionHeader('Public URL'),
            const SizedBox(height: 12),
            _buildUrlSection(
              context,
              isUrlCopying,
              copySuccessMessage,
              setUrlCopying,
              setCopySuccessMessage,
              setShowUrlSharing,
            ),
            
            const SizedBox(height: 24),
          ],
          
          // Metadata Section (if available)
          if (file.metadata.isNotEmpty) ...[
            _buildSectionHeader('Metadata'),
            const SizedBox(height: 12),
            ...file.metadata.entries.map((entry) => 
              _buildInfoRow(entry.key, entry.value.toString())
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlSection(
    BuildContext context,
    bool isUrlCopying,
    String? copySuccessMessage,
    Function(bool) setUrlCopying,
    Function(String?) setCopySuccessMessage,
    Function(bool) setShowUrlSharing,
  ) {
    final publicUrl = file.publicUrl;
    
    if (publicUrl == null || publicUrl.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.textMuted,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'No public URL available',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // URL display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  publicUrl,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // URL Action buttons
        Row(
          children: [
            // Copy URL button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isUrlCopying ? null : () => _copyUrlToClipboard(
                  publicUrl,
                  setUrlCopying,
                  setCopySuccessMessage,
                ),
                icon: isUrlCopying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.copy, size: 16),
                label: Text(isUrlCopying ? 'Copying...' : 'Copy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Share button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => setShowUrlSharing(true),
                icon: const Icon(Icons.share, size: 16),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // Success message
        if (copySuccessMessage != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    copySuccessMessage,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

    // Get icon based on file type
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

  Future<void> _copyUrlToClipboard(
    String url,
    Function(bool) setUrlCopying,
    Function(String?) setCopySuccessMessage,
  ) async {
    setUrlCopying(true);
    
    try {
      final success = await StorageUrlManager.copyUrlToClipboard(url);
      
      if (success) {
        setCopySuccessMessage(StorageConstants.successUrlCopied);
        Logger.info('URL copied to clipboard successfully');
      } else {
        setCopySuccessMessage('Failed to copy URL to clipboard');
        Logger.error('Failed to copy URL to clipboard');
      }
    } catch (e) {
      setCopySuccessMessage('Failed to copy URL to clipboard');
      Logger.error('Error copying URL to clipboard', e);
    } finally {
      setUrlCopying(false);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      }
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}