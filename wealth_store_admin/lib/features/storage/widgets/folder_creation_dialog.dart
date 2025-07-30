import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../providers/file_operation_providers.dart';
import '../services/file_validator.dart';
import '../constants/storage_constants.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/utils/logger.dart';

/// Dialog for creating new folders with validation and nested structure support
class FolderCreationDialog extends HookConsumerWidget {
  final String bucketId;
  final String? parentPath;
  final Function(String)? onFolderCreated;
  final VoidCallback? onCancel;

  const FolderCreationDialog({
    super.key,
    required this.bucketId,
    this.parentPath,
    this.onFolderCreated,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State hooks
    final folderNameController = useTextEditingController();
    final isCreating = useState<bool>(false);
    final validationError = useState<String?>(null);
    final showAdvancedOptions = useState<bool>(false);
    final createNestedFolders = useState<bool>(false);
    
    // Focus node
    final focusNode = useFocusNode();
    
    // Providers
    final fileOperations = ref.read(fileOperationMethodsProvider);
    final validator = StorageFileValidator.createWithBucketRules();
    
    // Screen size
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < StorageConstants.mobileBreakpoint;
    
    // Auto-focus on text field
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        focusNode.requestFocus();
      });
      return null;
    }, []);
    
    // Validate folder name on change
    useEffect(() {
      void validateFolderName() {
        final folderName = folderNameController.text.trim();
        if (folderName.isEmpty) {
          validationError.value = null;
          return;
        }
        
        final errors = _validateFolderName(folderName, validator);
        validationError.value = errors.isNotEmpty ? errors.first : null;
      }
      
      folderNameController.addListener(validateFolderName);
      return () => folderNameController.removeListener(validateFolderName);
    }, [folderNameController]);
    
    // Handle folder creation
    Future<void> handleCreateFolder() async {
      final folderName = folderNameController.text.trim();
      if (folderName.isEmpty) return;
      
      final errors = _validateFolderName(folderName, validator);
      if (errors.isNotEmpty) {
        validationError.value = errors.first;
        return;
      }
      
      try {
        isCreating.value = true;
        validationError.value = null;
        
        if (createNestedFolders.value && folderName.contains('/')) {
          // Create nested folder structure
          await _createNestedFolders(folderName, fileOperations);
        } else {
          // Create single folder
          final result = await fileOperations.createFolder(
            bucketId,
            folderName,
            parentPath: parentPath,
          );
          
          if (!result.success) {
            validationError.value = result.error ?? 'Failed to create folder';
            return;
          }
        }
        
        // Success
        onFolderCreated?.call(folderName);
        Navigator.of(context).pop();
      } catch (e) {
        Logger.error('Folder creation failed', e);
        validationError.value = 'Failed to create folder: ${e.toString()}';
      } finally {
        isCreating.value = false;
      }
    }
    
    // Handle form submission
    void handleSubmit() {
      if (!isCreating.value && validationError.value == null) {
        handleCreateFolder();
      }
    }
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isMobile ? screenSize.width * 0.9 : 400,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context, isMobile),
            
            // Content
            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current location info
                  if (parentPath != null && parentPath!.isNotEmpty)
                    _buildLocationInfo(context, parentPath!, isMobile),
                  
                  // Folder name input
                  _buildFolderNameInput(
                    context,
                    folderNameController,
                    focusNode,
                    validationError.value,
                    handleSubmit,
                    isMobile,
                  ),
                  
                  // Advanced options
                  _buildAdvancedOptions(
                    context,
                    showAdvancedOptions.value,
                    createNestedFolders.value,
                    () => showAdvancedOptions.value = !showAdvancedOptions.value,
                    (value) => createNestedFolders.value = value,
                    isMobile,
                  ),
                  
                  // Folder naming rules
                  _buildNamingRules(context, isMobile),
                  
                  const SizedBox(height: 24),
                  
                  // Actions
                  _buildActions(
                    context,
                    folderNameController.text.trim(),
                    validationError.value,
                    isCreating.value,
                    handleCreateFolder,
                    onCancel,
                    isMobile,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.create_new_folder,
            color: AppColors.primaryBlue,
            size: isMobile ? 20 : 24,
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Text(
            'Create New Folder',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Close',
            splashRadius: 16,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLocationInfo(BuildContext context, String parentPath, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(
            Icons.folder,
            size: 16,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 8),
          Text(
            'Creating in: ',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              parentPath,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFolderNameInput(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    String? error,
    VoidCallback onSubmit,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Folder Name',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Enter folder name',
            hintStyle: TextStyle(
              color: AppColors.textMuted,
              fontSize: isMobile ? 14 : 16,
            ),
            prefixIcon: Icon(
              Icons.folder_outlined,
              color: error != null ? AppColors.error : AppColors.textMuted,
              size: 20,
            ),
            errorText: error,
            errorStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.error,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            filled: true,
            fillColor: AppColors.backgroundLight,
          ),
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: AppColors.textPrimary,
          ),
          onSubmitted: (_) => onSubmit(),
        ),
      ],
    );
  }
  
  Widget _buildAdvancedOptions(
    BuildContext context,
    bool showAdvanced,
    bool createNested,
    VoidCallback onToggleAdvanced,
    Function(bool) onToggleNested,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        InkWell(
          onTap: onToggleAdvanced,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  showAdvanced ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Advanced Options',
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showAdvanced) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: createNested,
                      onChanged: (value) => onToggleNested(value ?? false),
                      activeColor: AppColors.primaryBlue,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create nested folders',
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Use "/" to create nested folder structure (e.g., "docs/images")',
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildNamingRules(BuildContext context, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.info,
              ),
              const SizedBox(width: 6),
              Text(
                'Folder Naming Rules',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._getFolderNamingRules().map((rule) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: AppColors.textMuted,
                  ),
                ),
                Expanded(
                  child: Text(
                    rule,
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Widget _buildActions(
    BuildContext context,
    String folderName,
    String? error,
    bool isCreating,
    VoidCallback onCreate,
    VoidCallback? onCancel,
    bool isMobile,
  ) {
    final canCreate = folderName.isNotEmpty && error == null && !isCreating;
    
    return Row(
      children: [
        const Spacer(),
        TextButton(
          onPressed: isCreating ? null : (onCancel ?? () => Navigator.of(context).pop()),
          child: const Text('Cancel'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: canCreate ? onCreate : null,
          icon: isCreating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.create_new_folder, size: 16),
          label: Text(isCreating ? 'Creating...' : 'Create Folder'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 20,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
  
  List<String> _validateFolderName(String folderName, StorageFileValidator validator) {
    final errors = <String>[];
    
    // Basic validation
    if (folderName.isEmpty) {
      errors.add('Folder name cannot be empty');
      return errors;
    }
    
    // Length validation
    if (folderName.length > 255) {
      errors.add('Folder name cannot exceed 255 characters');
    }
    
    // Character validation
    final invalidChars = RegExp(r'[<>:"|?*\\]');
    if (invalidChars.hasMatch(folderName)) {
      errors.add('Folder name contains invalid characters');
    }
    
    // Reserved names
    const reservedNames = ['.', '..', 'CON', 'PRN', 'AUX', 'NUL'];
    if (reservedNames.contains(folderName.toUpperCase())) {
      errors.add('Folder name is reserved');
    }
    
    // Leading/trailing spaces or dots
    if (folderName.startsWith(' ') || folderName.endsWith(' ') ||
        folderName.startsWith('.') || folderName.endsWith('.')) {
      errors.add('Folder name cannot start or end with spaces or dots');
    }
    
    // Nested folder validation
    if (folderName.contains('/')) {
      final parts = folderName.split('/');
      for (final part in parts) {
        if (part.isEmpty) {
          errors.add('Empty folder names in path are not allowed');
          break;
        }
        if (part.length > 100) {
          errors.add('Individual folder names cannot exceed 100 characters');
          break;
        }
      }
    }
    
    return errors;
  }
  
  List<String> _getFolderNamingRules() {
    return [
      'Cannot contain: < > : " | ? * \\',
      'Cannot be empty or exceed 255 characters',
      'Cannot start or end with spaces or dots',
      'Cannot use reserved names (CON, PRN, AUX, NUL)',
      'Use "/" for nested folders (e.g., "docs/images")',
      'Individual folder names limited to 100 characters',
    ];
  }
  
  Future<void> _createNestedFolders(String folderPath, FileOperationMethods fileOperations) async {
    final parts = folderPath.split('/').where((part) => part.isNotEmpty).toList();
    String currentPath = parentPath ?? '';
    
    for (final part in parts) {
      final fullPath = currentPath.isEmpty ? part : '$currentPath/$part';
      
      final result = await fileOperations.createFolder(bucketId, part, parentPath: currentPath);
      if (!result.success) {
        throw Exception('Failed to create folder "$part": ${result.error}');
      }
      
      currentPath = fullPath;
    }
  }
}