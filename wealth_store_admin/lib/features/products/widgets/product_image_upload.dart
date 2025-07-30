import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../services/product_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/product_providers.dart';

class ProductImageUpload extends HookConsumerWidget {
  final List<String> imageUrls;
  final Function(List<String>) onImagesChanged;
  final bool enabled;

  const ProductImageUpload({
    super.key,
    required this.imageUrls,
    required this.onImagesChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUploading = useState(false);
    final uploadProgress = useState(0.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with upload button
        Row(
          children: [
            const Text(
              'Product Images',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (enabled) ...[
              OutlinedButton.icon(
                onPressed: () => _browseStorage(context),
                icon: const Icon(Icons.storage, size: 18),
                label: const Text('Browse Storage'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: isUploading.value ? null : () => _pickAndUploadImages(
                  context,
                  ref,
                  isUploading,
                  uploadProgress,
                ),
                icon: isUploading.value 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate, size: 18),
                label: Text(isUploading.value ? 'Uploading...' : 'Add Images'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Upload progress
        if (isUploading.value) ...[
          LinearProgressIndicator(
            value: uploadProgress.value,
            backgroundColor: AppColors.borderLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
          const SizedBox(height: 16),
        ],
        
        // Images grid
        if (imageUrls.isNotEmpty) ...[
          _buildImagesGrid(context),
        ] else ...[
          _buildEmptyState(),
        ],
      ],
    );
  }

  Widget _buildImagesGrid(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return _buildImageTile(context, imageUrls[index], index);
        },
      ),
    );
  }

  Widget _buildImageTile(BuildContext context, String imageUrl, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.backgroundLight,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          color: AppColors.textMuted,
                          size: 24,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Failed to load',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Delete button
          if (enabled)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                  onPressed: () => _removeImage(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ),
            ),
          
          // Primary image indicator
          if (index == 0)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Primary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.borderLight,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 12),
            Text(
              'No images added yet',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Click "Add Images" to upload product photos',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImages(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> isUploading,
    ValueNotifier<double> uploadProgress,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      isUploading.value = true;
      uploadProgress.value = 0.0;

      final productService = ref.read(productServiceProvider);
      final newImageUrls = <String>[];

      for (int i = 0; i < result.files.length; i++) {
        final file = result.files[i];
        if (file.bytes == null) continue;

        try {
          // Validate file type
          final fileExtension = file.name.split('.').last.toLowerCase();
          final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
          
          if (!allowedExtensions.contains(fileExtension)) {
            throw Exception('File type not supported. Please use JPG, PNG, GIF or WebP images.');
          }
          
          // Validate file size (max 5MB)
          final maxSize = 5 * 1024 * 1024; // 5MB
          if (file.size > maxSize) {
            throw Exception('File size exceeds 5MB limit.');
          }
          
          final imageUrl = await productService.uploadProductImageBytes(
            file.bytes!,
            file.name,
          );
          newImageUrls.add(imageUrl);
          
          // Update progress
          uploadProgress.value = (i + 1) / result.files.length;
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload ${file.name}: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }

      // Update the image URLs list
      final updatedUrls = [...imageUrls, ...newImageUrls];
      onImagesChanged(updatedUrls);

      if (context.mounted && newImageUrls.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully uploaded ${newImageUrls.length} image(s)'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload images: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  void _removeImage(int index) {
    final updatedUrls = List<String>.from(imageUrls);
    
    // Optionally delete from storage (commented out for safety)
    // final productService = ProductService();
    // productService.deleteProductImage(updatedUrls[index]);
    
    updatedUrls.removeAt(index);
    onImagesChanged(updatedUrls);
  }

  void _browseStorage(BuildContext context) {
    // Navigate to storage page where users can browse and select existing files
    context.go('/storage');
  }
}