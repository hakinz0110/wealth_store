import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../services/storage_service.dart';
import '../../../shared/widgets/loading_widget.dart';

class BannerImageUpload extends StatefulWidget {
  final String? initialImageUrl;
  final Function(String imageUrl) onImageUploaded;
  final String bannerTitle;

  const BannerImageUpload({
    super.key,
    this.initialImageUrl,
    required this.onImageUploaded,
    required this.bannerTitle,
  });

  @override
  State<BannerImageUpload> createState() => _BannerImageUploadState();
}

class _BannerImageUploadState extends State<BannerImageUpload> {
  final StorageService _storageService = StorageService();
  String? _currentImageUrl;
  bool _isUploading = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.initialImageUrl;
  }

  Future<void> _pickAndUploadImage() async {
    try {
      // Pick image file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: false,
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.first.path!);
      
      setState(() {
        _isUploading = true;
        _uploadError = null;
      });

      // Upload image
      final imageUrl = await _storageService.uploadBannerImage(
        file,
        widget.bannerTitle.isNotEmpty ? widget.bannerTitle : 'banner',
      );

      setState(() {
        _currentImageUrl = imageUrl;
        _isUploading = false;
      });

      // Notify parent
      widget.onImageUploaded(imageUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadError = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _currentImageUrl = null;
      _uploadError = null;
    });
    widget.onImageUploaded('');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Banner Image *',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        
        // Image preview or upload area
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildImageContent(),
        ),
        
        const SizedBox(height: 8),
        
        // Upload/Remove buttons
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _isUploading ? null : () => context.go('/storage'),
              icon: const Icon(Icons.storage),
              label: const Text('Browse Storage'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickAndUploadImage,
              icon: _isUploading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload),
              label: Text(_currentImageUrl != null ? 'Change Image' : 'Upload Image'),
            ),
            
            if (_currentImageUrl != null) ...[
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _isUploading ? null : _removeImage,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Remove', style: TextStyle(color: Colors.red)),
              ),
            ],
          ],
        ),
        
        // Error message
        if (_uploadError != null) ...[
          const SizedBox(height: 8),
          Text(
            _uploadError!,
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 12,
            ),
          ),
        ],
        
        // Help text
        const SizedBox(height: 4),
        Text(
          'Supported formats: JPG, PNG, GIF, WebP. Max size: 5MB',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    if (_isUploading) {
      return const Center(
        child: LoadingWidget(message: 'Uploading image...'),
      );
    }

    if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _currentImageUrl!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[100],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      );
    }

    // Empty state
    return Container(
      color: Colors.grey[50],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No image selected',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Click "Upload Image" to select a banner image',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}