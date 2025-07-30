import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../models/storage_models.dart';
import '../constants/storage_constants.dart';

/// Helper class for accessibility features in storage management
class AccessibilityHelper {
  /// Get semantic label for a storage file
  static String getFileSemanticLabel(StorageFile file) {
    if (file.isFolder) {
      return 'Folder ${file.name}';
    }
    
    final fileType = _getFileTypeDescription(file.name);
    final sizeDescription = _getSizeDescription(file.size);
    
    return '$fileType ${file.name}, size $sizeDescription';
  }
  
  /// Get semantic hint for a storage file
  static String getFileSemanticHint(StorageFile file) {
    if (file.isFolder) {
      return 'Double tap to open folder';
    }
    
    return 'Double tap to view file details, long press for options';
  }
  
  /// Get semantic label for bucket
  static String getBucketSemanticLabel(StorageBucket bucket) {
    final visibility = bucket.isPublic ? 'Public' : 'Private';
    return '$visibility bucket ${bucket.name}';
  }
  
  /// Get semantic hint for bucket
  static String getBucketSemanticHint(StorageBucket bucket) {
    return 'Tap to select bucket and view files';
  }
  
  /// Get semantic label for upload button
  static String getUploadButtonSemanticLabel() {
    return StorageConstants.accessibilityLabels['uploadButton'] ?? 'Upload files';
  }
  
  /// Get semantic label for delete button
  static String getDeleteButtonSemanticLabel(int fileCount) {
    if (fileCount == 1) {
      return 'Delete selected file';
    }
    return 'Delete $fileCount selected files';
  }
  
  /// Get semantic label for view mode toggle
  static String getViewModeSemanticLabel(ViewMode currentMode) {
    final nextMode = currentMode == ViewMode.grid ? 'list' : 'grid';
    return 'Switch to $nextMode view';
  }
  
  /// Get semantic label for search input
  static String getSearchSemanticLabel() {
    return StorageConstants.accessibilityLabels['searchInput'] ?? 'Search files and folders';
  }
  
  /// Get semantic label for breadcrumb navigation
  static String getBreadcrumbSemanticLabel(String name, bool isLast) {
    if (isLast) {
      return 'Current location: $name';
    }
    return 'Navigate to $name';
  }
  
  /// Get semantic label for progress indicator
  static String getProgressSemanticLabel(double progress) {
    final percentage = (progress * 100).round();
    return 'Upload progress: $percentage percent';
  }
  
  /// Get semantic label for file operation
  static String getFileOperationSemanticLabel(String operation, String fileName) {
    switch (operation.toLowerCase()) {
      case 'rename':
        return 'Rename $fileName';
      case 'delete':
        return 'Delete $fileName';
      case 'move':
        return 'Move $fileName';
      case 'copy':
        return 'Copy $fileName';
      default:
        return '$operation $fileName';
    }
  }
  
  /// Create semantic properties for a file item
  static SemanticsProperties createFileSemantics(StorageFile file, {
    bool isSelected = false,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return SemanticsProperties(
      label: getFileSemanticLabel(file),
      hint: getFileSemanticHint(file),
      selected: isSelected,
      button: true,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
  
  /// Create semantic properties for a bucket item
  static SemanticsProperties createBucketSemantics(StorageBucket bucket, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return SemanticsProperties(
      label: getBucketSemanticLabel(bucket),
      hint: getBucketSemanticHint(bucket),
      selected: isSelected,
      button: true,
      onTap: onTap,
    );
  }
  
  /// Create semantic properties for action buttons
  static SemanticsProperties createActionButtonSemantics(String action, {
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    final label = StorageConstants.accessibilityLabels[action] ?? action;
    
    return SemanticsProperties(
      label: label,
      button: true,
      enabled: enabled,
      onTap: enabled ? onTap : null,
    );
  }
  
  /// Announce a message to screen readers
  static void announceMessage(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }
  
  /// Announce upload progress
  static void announceUploadProgress(BuildContext context, String fileName, double progress) {
    final percentage = (progress * 100).round();
    final message = 'Uploading $fileName: $percentage percent complete';
    announceMessage(context, message);
  }
  
  /// Announce file operation completion
  static void announceOperationComplete(BuildContext context, String operation, String fileName) {
    final message = '$operation completed for $fileName';
    announceMessage(context, message);
  }
  
  /// Announce error messages
  static void announceError(BuildContext context, String error) {
    announceMessage(context, 'Error: $error');
  }
  
  /// Get file type description for accessibility
  static String _getFileTypeDescription(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    
    if (StorageConstants.allowedImageTypes.contains(extension)) {
      return 'Image file';
    } else if (StorageConstants.allowedVideoTypes.contains(extension)) {
      return 'Video file';
    } else if (StorageConstants.allowedDocumentTypes.contains(extension)) {
      return 'Document file';
    } else if (StorageConstants.allowedAudioTypes.contains(extension)) {
      return 'Audio file';
    }
    
    return 'File';
  }
  
  /// Get human-readable size description
  static String _getSizeDescription(int bytes) {
    if (bytes < 1024) {
      return '$bytes bytes';
    } else if (bytes < 1024 * 1024) {
      final kb = (bytes / 1024).toStringAsFixed(1);
      return '$kb KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
      return '$mb MB';
    } else {
      final gb = (bytes / (1024 * 1024 * 1024)).toStringAsFixed(1);
      return '$gb GB';
    }
  }
  
  /// Create focus node with semantic label
  static FocusNode createLabeledFocusNode(String label) {
    final focusNode = FocusNode();
    focusNode.debugLabel = label;
    return focusNode;
  }
  
  /// Wrap widget with semantic container
  static Widget wrapWithSemantics({
    required Widget child,
    required String label,
    String? hint,
    bool button = false,
    bool selected = false,
    bool enabled = true,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: button,
      selected: selected,
      enabled: enabled,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }
  
  /// Create accessible tooltip
  static Widget createAccessibleTooltip({
    required Widget child,
    required String message,
    String? semanticLabel,
  }) {
    return Tooltip(
      message: message,
      child: Semantics(
        label: semanticLabel ?? message,
        child: child,
      ),
    );
  }
}