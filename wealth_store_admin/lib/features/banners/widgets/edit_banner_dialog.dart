import 'package:flutter/material.dart';
import '../../../services/banner_service.dart';
import '../../../models/banner_models.dart' as banner_models;
import 'banner_image_upload.dart';

class EditBannerDialog extends StatefulWidget {
  final banner_models.Banner banner;

  const EditBannerDialog({
    super.key,
    required this.banner,
  });

  @override
  State<EditBannerDialog> createState() => _EditBannerDialogState();
}

class _EditBannerDialogState extends State<EditBannerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _linkUrlController;
  late final TextEditingController _sortOrderController;
  final BannerService _bannerService = BannerService();
  
  bool _isLoading = false;
  late bool _isActive;
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.banner.title);
    _descriptionController = TextEditingController(text: widget.banner.description ?? '');
    _linkUrlController = TextEditingController(text: widget.banner.linkUrl ?? '');
    _sortOrderController = TextEditingController(text: widget.banner.sortOrder.toString());
    _isActive = widget.banner.isActive;
    _imageUrl = widget.banner.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkUrlController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _saveBanner() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final formData = banner_models.BannerFormData(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        imageUrl: _imageUrl.trim(),
        linkUrl: _linkUrlController.text.trim().isEmpty 
            ? null 
            : _linkUrlController.text.trim(),
        sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
        isActive: _isActive,
      );

      await _bannerService.updateBanner(widget.banner.id, formData);
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banner updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating banner: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.edit, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Banner',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Current Image Preview
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                    image: DecorationImage(
                      image: NetworkImage(widget.banner.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Banner Title *',
                    hintText: 'Enter banner title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Banner title is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Banner title must be at least 2 characters';
                    }
                    if (value.trim().length > 100) {
                      return 'Banner title cannot exceed 100 characters';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter banner description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value != null && value.trim().length > 500) {
                      return 'Description cannot exceed 500 characters';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // Banner Image Upload
                // TODO: Fix BannerImageUpload widget usage
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('Image upload placeholder'),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Link URL
                TextFormField(
                  controller: _linkUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Link URL',
                    hintText: 'Enter link URL (optional)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final urlPattern = RegExp(r'^https?://');
                      if (!urlPattern.hasMatch(value.trim())) {
                        return 'Please enter a valid URL starting with http:// or https://';
                      }
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // Sort Order and Active Status
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _sortOrderController,
                        decoration: const InputDecoration(
                          labelText: 'Sort Order',
                          hintText: '0',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final order = int.tryParse(value);
                            if (order == null) {
                              return 'Please enter a valid number';
                            }
                            if (order < 0) {
                              return 'Sort order cannot be negative';
                            }
                          }
                          return null;
                        },
                        enabled: !_isLoading,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 120,
                      child: CheckboxListTile(
                        title: const Text('Active'),
                        value: _isActive,
                        onChanged: _isLoading ? null : (value) {
                          setState(() {
                            _isActive = value ?? true;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveBanner,
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Update Banner'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}