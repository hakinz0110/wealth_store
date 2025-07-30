import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/storage_models.dart';
import '../providers/storage_providers.dart';
import '../providers/file_operation_providers.dart';
import '../constants/storage_constants.dart';

import '../widgets/storage_sidebar.dart';
import '../widgets/storage_header.dart';
import '../widgets/storage_content.dart';
import '../widgets/storage_upload_modal.dart';
import '../widgets/upload_progress_widget.dart';

import '../widgets/file_context_menu.dart';
import '../widgets/file_deletion_dialog.dart';
import '../widgets/file_rename_dialog.dart';
import '../widgets/file_move_dialog.dart';
import '../widgets/batch_rename_dialog.dart';
import '../widgets/keyboard_shortcut_handler.dart';
import '../widgets/loading_animation.dart';
import '../../../shared/constants/app_colors.dart';

/// Main storage management page
class StorageManagementPage extends HookConsumerWidget {
  const StorageManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State hooks
    final viewMode = useState<ViewMode>(ViewMode.grid);
    final showUploadModal = useState<bool>(false);
    final sidebarCollapsed = useState<bool>(false);
    final contextMenuFile = useState<StorageFile?>(null);
    final contextMenuPosition = useState<Offset>(Offset.zero);
    final selectedFiles = useState<List<StorageFile>>([]);
    
    // Watch providers
    final selectedBucketId = ref.watch(selectedBucketProvider);
    final bucketMethods = ref.read(bucketMethodsProvider);
    final fileOperations = ref.read(fileOperationMethodsProvider);
    
    // Screen size and responsive breakpoints
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < StorageConstants.mobileBreakpoint;
    final isTablet = screenSize.width < StorageConstants.tabletBreakpoint;
    final isDesktop = screenSize.width >= StorageConstants.desktopBreakpoint;
    
    // Auto-collapse sidebar on mobile and tablet
    useEffect(() {
      if (isMobile) {
        sidebarCollapsed.value = true;
      } else if (isTablet && !isDesktop) {
        // On tablet, start collapsed but allow expansion
        sidebarCollapsed.value = true;
      }
      return null;
    }, [isMobile, isTablet, isDesktop]);
    
    // Handle upload button press
    void handleUpload() {
      if (selectedBucketId != null) {
        showUploadModal.value = true;
      }
    }
    
    // Handle create folder
    void handleCreateFolder() {
      if (selectedBucketId != null) {
        _showCreateFolderDialog(context, selectedBucketId, fileOperations);
      }
    }
    
    // Handle view mode change
    void handleViewModeChange(ViewMode newMode) {
      viewMode.value = newMode;
    }
    
    // Handle search
    void handleSearch(String query) {
      fileOperations.updateSearchQuery(query);
    }
    
    // Handle upload complete
    void handleUploadComplete() {
      showUploadModal.value = false;
      // Refresh current bucket
      if (selectedBucketId != null) {
        bucketMethods.refreshCurrentBucket();
      }
    }
    
    // Handle context menu
    void handleFileContextMenu(StorageFile file, Offset position) {
      contextMenuFile.value = file;
      contextMenuPosition.value = position;
    }
    
    // Handle context menu close
    void handleContextMenuClose() {
      contextMenuFile.value = null;
    }
    
    // Handle file selection change
    void handleSelectionChanged(List<StorageFile> files) {
      selectedFiles.value = files;
    }
    
    // Handle file rename
    void handleFileRename(StorageFile file) {
      showDialog(
        context: context,
        builder: (context) => FileRenameDialog(
          file: file,
          onSuccess: () {
            // Refresh the file list
            if (selectedBucketId != null) {
              bucketMethods.refreshCurrentBucket();
            }
          },
        ),
      );
    }
    
    // Handle batch rename
    void handleBatchRename(List<StorageFile> files) {
      if (files.isEmpty) return;
      
      showDialog(
        context: context,
        builder: (context) => BatchRenameDialog(
          files: files,
          onSuccess: () {
            // Clear selection and refresh
            selectedFiles.value = [];
            if (selectedBucketId != null) {
              bucketMethods.refreshCurrentBucket();
            }
          },
        ),
      );
    }
    
    // Handle files move
    void handleFilesMove(List<StorageFile> files) {
      if (files.isEmpty) return;
      
      showDialog(
        context: context,
        builder: (context) => FileMoveDialog(
          files: files,
          onSuccess: () {
            // Clear selection and refresh
            selectedFiles.value = [];
            if (selectedBucketId != null) {
              bucketMethods.refreshCurrentBucket();
            }
          },
        ),
      );
    }
    
    // Handle file move
    void handleFileMove(StorageFile file) {
      handleFilesMove([file]);
    }
    
    // Handle file details
    void handleFileDetails(StorageFile file) {
      // TODO: Implement in later task
      print('Show details for file: ${file.name}');
    }
    
    // Handle file deletion
    void handleFileDelete(List<StorageFile> files) {
      if (files.isEmpty) return;
      
      showDialog(
        context: context,
        builder: (context) => FileDeletionDialog(
          files: files,
          allowPermanentDelete: true,
          showUndoOption: true,
          onConfirm: () {
            // Clear selection after deletion
            selectedFiles.value = [];
            // Refresh the file list
            if (selectedBucketId != null) {
              bucketMethods.refreshCurrentBucket();
            }
          },
        ),
      );
    }
    
    // Handle refresh
    void handleRefresh() {
      if (selectedBucketId != null) {
        bucketMethods.refreshCurrentBucket();
      }
    }
    
    return KeyboardShortcutHandler(
        onRename: handleFileRename,
        onDetails: handleFileDetails,
        onDelete: handleFileDelete,
        onUpload: handleUpload,
        onCreateFolder: handleCreateFolder,
        onRefresh: handleRefresh,
        onSearch: (query) => handleSearch(query),
        child: Stack(
          children: [
            // Main layout - responsive row/column based on screen size
            isMobile ? _buildMobileLayout(
              context,
              sidebarCollapsed,
              selectedBucketId,
              viewMode,
              selectedFiles,
              handleUpload,
              handleCreateFolder,
              handleViewModeChange,
              handleSearch,
              handleSelectionChanged,
              handleFileContextMenu,
              handleFileDetails,
              bucketMethods,
            ) : Row(
            children: [
              // Sidebar - responsive width and collapse behavior
              if (!sidebarCollapsed.value || !isMobile)
                AnimatedContainer(
                  duration: StorageConstants.mediumAnimation,
                  width: _getSidebarWidth(isMobile, isTablet, sidebarCollapsed.value),
                  child: StorageSidebar(
                    isCollapsed: sidebarCollapsed.value,
                    onToggleCollapse: () {
                      sidebarCollapsed.value = !sidebarCollapsed.value;
                    },
                    width: _getSidebarWidth(isMobile, isTablet, false),
                    collapsedWidth: _getSidebarWidth(isMobile, isTablet, true),
                  ),
                ),
              
              // Main content
              Expanded(
                child: _buildMainContent(
                  context,
                  selectedBucketId,
                  viewMode.value,
                  selectedFiles.value,
                  handleUpload,
                  handleCreateFolder,
                  handleViewModeChange,
                  handleSearch,
                  handleSelectionChanged,
                  handleFileContextMenu,
                  handleFileDetails,
                  bucketMethods,
                  isMobile,
                  isTablet,
                ),
              ),
            ],
          ),
          
          // Mobile sidebar overlay
          if (isMobile && !sidebarCollapsed.value)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => sidebarCollapsed.value = true,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: StorageConstants.sidebarWidth * 0.85, // Slightly smaller on mobile
                      height: double.infinity,
                      child: StorageSidebar(
                        isCollapsed: false,
                        onToggleCollapse: () {
                          sidebarCollapsed.value = true;
                        },
                        width: StorageConstants.sidebarWidth * 0.85,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          
          // Upload modal
          if (showUploadModal.value && selectedBucketId != null)
            Positioned.fill(
              child: StorageUploadModal(
                bucketId: selectedBucketId,
                currentPath: bucketMethods.getCurrentPath(),
                onUploadComplete: handleUploadComplete,
                onClose: () => showUploadModal.value = false,
              ),
            ),
          
          // Context menu
          if (contextMenuFile.value != null)
            FileContextMenu(
              file: contextMenuFile.value!,
              selectedFiles: selectedFiles.value,
              position: contextMenuPosition.value,
              onClose: handleContextMenuClose,
              onRename: handleFileRename,
              onMove: handleFileMove,
              onDetails: handleFileDetails,
              onDelete: handleFileDelete,
              onBatchRename: handleBatchRename,
              onBatchMove: handleFilesMove,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Icon(
                    Icons.folder_open,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Text(
                  'Select a bucket to view files',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Text(
                  'Choose a storage bucket from the sidebar to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, String message) {
    return Center(
      child: LoadingAnimation(
        message: message,
        showMessage: true,
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // Helper method to get responsive sidebar width
  double _getSidebarWidth(bool isMobile, bool isTablet, bool isCollapsed) {
    if (isCollapsed) {
      return isMobile ? 0 : StorageConstants.collapsedSidebarWidth;
    }
    
    if (isMobile) {
      return StorageConstants.sidebarWidth * 0.85;
    } else if (isTablet) {
      return StorageConstants.sidebarWidth * 0.9;
    }
    
    return StorageConstants.sidebarWidth;
  }

  // Build mobile layout - simplified since AdminLayout handles the app bar
  Widget _buildMobileLayout(
    BuildContext context,
    ValueNotifier<bool> sidebarCollapsed,
    String? selectedBucketId,
    ValueNotifier<ViewMode> viewMode,
    ValueNotifier<List<StorageFile>> selectedFiles,
    VoidCallback handleUpload,
    VoidCallback handleCreateFolder,
    Function(ViewMode) handleViewModeChange,
    Function(String) handleSearch,
    Function(List<StorageFile>) handleSelectionChanged,
    Function(StorageFile, Offset) handleFileContextMenu,
    Function(StorageFile) handleFileDetails,
    BucketMethods bucketMethods,
  ) {
    return _buildMainContent(
      context,
      selectedBucketId,
      viewMode.value,
      selectedFiles.value,
      handleUpload,
      handleCreateFolder,
      handleViewModeChange,
      handleSearch,
      handleSelectionChanged,
      handleFileContextMenu,
      handleFileDetails,
      bucketMethods,
      true, // isMobile
      false, // isTablet
    );
  }

  // Build main content area
  Widget _buildMainContent(
    BuildContext context,
    String? selectedBucketId,
    ViewMode viewMode,
    List<StorageFile> selectedFiles,
    VoidCallback handleUpload,
    VoidCallback handleCreateFolder,
    Function(ViewMode) handleViewModeChange,
    Function(String) handleSearch,
    Function(List<StorageFile>) handleSelectionChanged,
    Function(StorageFile, Offset) handleFileContextMenu,
    Function(StorageFile) handleFileDetails,
    BucketMethods bucketMethods,
    bool isMobile,
    bool isTablet,
  ) {
    return Column(
      children: [
        // Header (only show on non-mobile)
        if (!isMobile)
          StorageHeader(
            viewMode: viewMode,
            onUpload: selectedBucketId != null ? handleUpload : null,
            onCreateFolder: selectedBucketId != null ? handleCreateFolder : null,
            onViewModeChanged: handleViewModeChange,
            onSearch: handleSearch,
            showSearch: true,
            showActions: true,
          ),
        
        // Content
        Expanded(
          child: Column(
            children: [
              // Upload progress widget
              UploadProgressWidget(
                onAllUploadsComplete: () {
                  // Refresh current bucket when all uploads complete
                  if (selectedBucketId != null) {
                    bucketMethods.refreshCurrentBucket();
                  }
                },
                onUploadCancelled: (fileName) {
                  // Handle upload cancellation
                },
                onUploadRetry: (fileName, error) {
                  // Handle upload retry
                },
              ),
              
              // Main content
              Expanded(
                child: selectedBucketId != null
                    ? Consumer(
                        builder: (context, ref, child) {
                          final filesAsync = ref.watch(currentBucketFilesProvider);
                          
                          return filesAsync.when(
                            data: (files) => AnimatedSwitcher(
                              duration: StorageConstants.mediumAnimation,
                              child: StorageContent(
                                key: ValueKey('content-$selectedBucketId'),
                                viewMode: viewMode,
                                allowMultiSelect: !isMobile,
                                onFileSelected: (file) {
                                  // Handle file selection
                                },
                                onFileDoubleClick: (file) {
                                  // Handle file double click
                                  if (file.isFolder) {
                                    bucketMethods.navigateToPath(selectedBucketId, file.path);
                                  } else {
                                    handleFileDetails(file);
                                  }
                                },
                                onSelectionChanged: handleSelectionChanged,
                                onFileContextMenu: handleFileContextMenu,
                              ),
                            ),
                            loading: () => _buildLoadingState(context, 'Loading files...'),
                            error: (error, stackTrace) => _buildErrorState(
                              context,
                              error.toString(),
                              () => bucketMethods.refreshCurrentBucket(),
                            ),
                          );
                        },
                      )
                    : _buildEmptyState(context),
              ),
            ],
          ),
        ),
      ],
    );
  }


  
  void _showCreateFolderDialog(
    BuildContext context,
    String bucketId,
    FileOperationMethods fileOperations,
  ) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Folder Name',
            hintText: 'Enter folder name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.of(context).pop();
              _createFolder(context, bucketId, value.trim(), fileOperations);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final folderName = controller.text.trim();
              if (folderName.isNotEmpty) {
                Navigator.of(context).pop();
                _createFolder(context, bucketId, folderName, fileOperations);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _createFolder(
    BuildContext context,
    String bucketId,
    String folderName,
    FileOperationMethods fileOperations,
  ) async {
    try {
      final result = await fileOperations.createFolder(bucketId, folderName);
      
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Folder "$folderName" created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create folder: ${result.error}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating folder: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}