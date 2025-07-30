import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:async';
import '../../services/supabase_service.dart';
import '../../shared/utils/logger.dart';

class FileManager extends StatefulWidget {
  const FileManager({super.key});

  @override
  State<FileManager> createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  List<Bucket> _buckets = [];
  List<FileObject> _files = [];
  String? _selectedBucket;
  String _currentPath = '';
  bool _isLoading = false;
  bool _isUploading = false;
  String? _error;
  Timer? _autoSyncTimer;

  @override
  void initState() {
    super.initState();
    _loadBuckets();
    _startAutoSync();
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    super.dispose();
  }

  void _startAutoSync() {
    _autoSyncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_selectedBucket != null) {
        _loadFiles(_selectedBucket!, path: _currentPath);
      }
    });
  }

  Future<void> _loadBuckets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('DEBUG: Starting to load buckets...');
      print('DEBUG: Current user: ${SupabaseService.client.auth.currentUser?.email}');
      
      // Since listBuckets() returns 0 due to permissions, let's test known buckets directly
      final knownBucketNames = [
        'books', 'clothings', 'phones', 'product-images', 'banner-images',
        'category-icons', 'customer-avatars', 'admin-avatars', 'project-images',
        'brand-logos', 'user-avatars', 'media'
      ];
      
      final accessibleBuckets = <Bucket>[];
      
      print('DEBUG: Testing access to known buckets...');
      for (final bucketName in knownBucketNames) {
        try {
          // Test if we can access this bucket by trying to list its contents
          final files = await SupabaseService.client.storage.from(bucketName).list();
          print('DEBUG: ✓ Bucket "$bucketName" accessible with ${files.length} files');
          
          // Create a bucket object for accessible buckets
          final bucket = Bucket(
            id: bucketName,
            name: bucketName,
            public: true, // Assume public since we can access it
            owner: SupabaseService.client.auth.currentUser?.id ?? '',
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          );
          accessibleBuckets.add(bucket);
        } catch (e) {
          print('DEBUG: ✗ Bucket "$bucketName" not accessible: $e');
        }
      }
      
      print('DEBUG: Found ${accessibleBuckets.length} accessible buckets');
      
      if (mounted) {
        setState(() {
          _buckets = accessibleBuckets;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG: Error loading buckets: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load buckets: $e';
          _isLoading = false;
        });
      }
      Logger.error('Failed to load buckets', e);
    }
  }

  Future<void> _loadFiles(String bucketId, {String? path}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final files = await SupabaseService.client.storage
          .from(bucketId)
          .list(path: path?.isEmpty == true ? null : path);
      
      setState(() {
        _files = files;
        _selectedBucket = bucketId;
        _currentPath = path ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load files: $e';
        _isLoading = false;
      });
      Logger.error('Failed to load files from bucket $bucketId', e);
    }
  }

  Future<void> _uploadFiles() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = true;
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty && _selectedBucket != null) {
        setState(() {
          _isUploading = true;
        });

        try {
          for (final file in files) {
            final reader = html.FileReader();
            reader.readAsArrayBuffer(file);
            
            await reader.onLoad.first;
            final bytes = reader.result as List<int>;
            
            final fileName = file.name;
            final filePath = _currentPath.isEmpty ? fileName : '$_currentPath/$fileName';
            
            await SupabaseService.client.storage
                .from(_selectedBucket!)
                .uploadBinary(filePath, Uint8List.fromList(bytes));
          }
          
          // Refresh file list
          await _loadFiles(_selectedBucket!, path: _currentPath);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully uploaded ${files.length} file(s)'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          setState(() {
            _isUploading = false;
          });
        }
      }
    });
  }

  Future<void> _deleteFile(FileObject file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && _selectedBucket != null) {
      try {
        final filePath = _currentPath.isEmpty ? file.name : '$_currentPath/${file.name}';
        await SupabaseService.client.storage
            .from(_selectedBucket!)
            .remove([filePath]);
        
        // Refresh file list
        await _loadFiles(_selectedBucket!, path: _currentPath);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${file.name}"'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createFolder() async {
    final controller = TextEditingController();
    final folderName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Folder Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (folderName != null && folderName.isNotEmpty && _selectedBucket != null) {
      try {
        // Create a placeholder file to represent the folder
        final folderPath = _currentPath.isEmpty 
            ? '$folderName/.gitkeep' 
            : '$_currentPath/$folderName/.gitkeep';
        
        await SupabaseService.client.storage
            .from(_selectedBucket!)
            .uploadBinary(folderPath, Uint8List.fromList([]));
        
        // Refresh file list
        await _loadFiles(_selectedBucket!, path: _currentPath);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created folder "$folderName"'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create folder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyPublicUrl(FileObject file) {
    if (_selectedBucket != null) {
      final filePath = _currentPath.isEmpty ? file.name : '$_currentPath/${file.name}';
      final publicUrl = SupabaseService.client.storage
          .from(_selectedBucket!)
          .getPublicUrl(filePath);
      
      Clipboard.setData(ClipboardData(text: publicUrl));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Public URL copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToFolder(String folderName) {
    final newPath = _currentPath.isEmpty ? folderName : '$_currentPath/$folderName';
    _loadFiles(_selectedBucket!, path: newPath);
  }

  void _navigateUp() {
    if (_currentPath.isNotEmpty) {
      final pathParts = _currentPath.split('/');
      pathParts.removeLast();
      final newPath = pathParts.join('/');
      _loadFiles(_selectedBucket!, path: newPath);
    }
  }

  void _previewImage(FileObject file) {
    final imageUrl = SupabaseService.client.storage
        .from(_selectedBucket!)
        .getPublicUrl(_currentPath.isEmpty ? file.name : '$_currentPath/${file.name}');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error, color: Colors.white, size: 64),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Size: ${_formatFileSize(file.metadata?['size'] ?? 0)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _copyPublicUrl(file),
                          icon: const Icon(Icons.link, size: 16),
                          label: const Text('Copy URL'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _deleteFile(file);
                          },
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBucketSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        border: Border(right: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
            ),
            child: Row(
              children: [
                Icon(Icons.storage, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Text(
                  'Storage',
                  style: TextStyle(
                    color: Colors.grey[200],
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Buckets list
          Expanded(
            child: _isLoading && _buckets.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _buckets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.storage, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No buckets found',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadBuckets,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _buckets.length,
                        itemBuilder: (context, index) {
                          final bucket = _buckets[index];
                          final isSelected = _selectedBucket == bucket.id;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2d2d2d) : null,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.folder,
                            color: isSelected ? Colors.white : Colors.grey[400],
                            size: 20,
                          ),
                          title: Text(
                            bucket.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[300],
                              fontSize: 14,
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: bucket.public ? Colors.green[700] : Colors.orange[700],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              bucket.public ? 'Public' : 'Private',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          onTap: () => _loadFiles(bucket.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileGrid() {
    if (_selectedBucket == null) {
      return const Center(
        child: Text(
          'Select a bucket to view files',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadFiles(_selectedBucket!),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with breadcrumbs and actions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              // Breadcrumbs
              Expanded(
                child: Row(
                  children: [
                    if (_currentPath.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _navigateUp,
                        tooltip: 'Go back',
                      ),
                    Text(
                      _selectedBucket!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (_currentPath.isNotEmpty) ...[
                      const Text(' / '),
                      Text(_currentPath.replaceAll('/', ' / ')),
                    ],
                  ],
                ),
              ),
              
              // Action buttons
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : _uploadFiles,
                    icon: _isUploading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_file),
                    label: Text(_isUploading ? 'Uploading...' : 'Upload files'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _createFolder,
                    icon: const Icon(Icons.create_new_folder),
                    label: const Text('Create folder'),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // File grid
        Expanded(
          child: _files.isEmpty
              ? const Center(
                  child: Text(
                    'No files in this bucket',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index];
                    final isFolder = file.metadata?['mimetype'] == null;
                    final isImage = file.metadata?['mimetype']?.startsWith('image/') == true;
                    
                    return Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: isFolder 
                            ? () => _navigateToFolder(file.name)
                            : isImage 
                                ? () => _previewImage(file)
                                : null,
                        child: Column(
                          children: [
                            // File preview/icon
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                                child: isFolder
                                    ? const Icon(
                                        Icons.folder,
                                        size: 48,
                                        color: Colors.orange,
                                      )
                                    : isImage
                                        ? ClipRRect(
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(4),
                                            ),
                                            child: Image.network(
                                              SupabaseService.client.storage
                                                  .from(_selectedBucket!)
                                                  .getPublicUrl(_currentPath.isEmpty 
                                                      ? file.name 
                                                      : '$_currentPath/${file.name}'),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.image, size: 48),
                                            ),
                                          )
                                        : Icon(
                                            _getFileIcon(file.name),
                                            size: 48,
                                            color: Colors.grey[600],
                                          ),
                              ),
                            ),
                            
                            // File info
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (!isFolder) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatFileSize(file.metadata?['size'] ?? 0),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            
                            // Actions
                            if (!isFolder)
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.link, size: 16),
                                      onPressed: () => _copyPublicUrl(file),
                                      tooltip: 'Copy public URL',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 16),
                                      onPressed: () => _deleteFile(file),
                                      tooltip: 'Delete file',
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
        return Icons.archive;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          _buildBucketSidebar(),
          Expanded(child: _buildFileGrid()),
        ],
      ),
    );
  }
}