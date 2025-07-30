import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/storage_models.dart';
import '../providers/file_operation_providers.dart';
import '../providers/storage_providers.dart';
import '../constants/storage_constants.dart';
import '../../../shared/utils/logger.dart';

/// Widget that handles keyboard shortcuts for file operations
class KeyboardShortcutHandler extends ConsumerWidget {
  final Widget child;
  final Function(StorageFile)? onRename;
  final Function(StorageFile)? onDetails;
  final Function(List<StorageFile>)? onDelete;
  final VoidCallback? onUpload;
  final VoidCallback? onCreateFolder;
  final VoidCallback? onRefresh;
  final Function(String)? onSearch;

  const KeyboardShortcutHandler({
    super.key,
    required this.child,
    this.onRename,
    this.onDetails,
    this.onDelete,
    this.onUpload,
    this.onCreateFolder,
    this.onRefresh,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) => _handleKeyEvent(context, ref, event),
      child: child,
    );
  }

  KeyEventResult _handleKeyEvent(BuildContext context, WidgetRef ref, KeyEvent event) {
    // Only handle key down events
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final isCtrlPressed = event.logicalKey == LogicalKeyboardKey.controlLeft ||
        event.logicalKey == LogicalKeyboardKey.controlRight ||
        HardwareKeyboard.instance.isControlPressed;
    
    final isShiftPressed = event.logicalKey == LogicalKeyboardKey.shiftLeft ||
        event.logicalKey == LogicalKeyboardKey.shiftRight ||
        HardwareKeyboard.instance.isShiftPressed;

    try {
      // Handle different key combinations
      if (isCtrlPressed && isShiftPressed) {
        return _handleCtrlShiftKeys(context, ref, event.logicalKey);
      } else if (isCtrlPressed) {
        return _handleCtrlKeys(context, ref, event.logicalKey);
      } else {
        return _handleSingleKeys(context, ref, event.logicalKey);
      }
    } catch (e) {
      Logger.error('Error handling keyboard shortcut', e);
      return KeyEventResult.ignored;
    }
  }

  KeyEventResult _handleCtrlShiftKeys(BuildContext context, WidgetRef ref, LogicalKeyboardKey key) {
    switch (key) {
      case LogicalKeyboardKey.keyN:
        // Ctrl+Shift+N: Create new folder
        Logger.debug('Keyboard shortcut: Create folder (Ctrl+Shift+N)');
        onCreateFolder?.call();
        return KeyEventResult.handled;
      
      default:
        return KeyEventResult.ignored;
    }
  }

  KeyEventResult _handleCtrlKeys(BuildContext context, WidgetRef ref, LogicalKeyboardKey key) {
    switch (key) {
      case LogicalKeyboardKey.keyA:
        // Ctrl+A: Select all files
        Logger.debug('Keyboard shortcut: Select all (Ctrl+A)');
        final selectionMethods = ref.read(fileSelectionMethodsProvider);
        selectionMethods.selectAll();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.keyC:
        // Ctrl+C: Copy URL of selected file (if single selection)
        Logger.debug('Keyboard shortcut: Copy URL (Ctrl+C)');
        _handleCopyUrl(context, ref);
        return KeyEventResult.handled;

      case LogicalKeyboardKey.keyF:
        // Ctrl+F: Focus search
        Logger.debug('Keyboard shortcut: Search (Ctrl+F)');
        _focusSearch(context);
        return KeyEventResult.handled;

      case LogicalKeyboardKey.keyU:
        // Ctrl+U: Upload files
        Logger.debug('Keyboard shortcut: Upload (Ctrl+U)');
        onUpload?.call();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.keyX:
        // Ctrl+X: Move selected file (if single selection)
        Logger.debug('Keyboard shortcut: Move file (Ctrl+X)');
        _handleMoveFile(context, ref);
        return KeyEventResult.handled;

      default:
        return KeyEventResult.ignored;
    }
  }

  KeyEventResult _handleSingleKeys(BuildContext context, WidgetRef ref, LogicalKeyboardKey key) {
    switch (key) {
      case LogicalKeyboardKey.delete:
        // Delete: Delete selected files
        Logger.debug('Keyboard shortcut: Delete (Delete)');
        _handleDeleteFiles(context, ref);
        return KeyEventResult.handled;

      case LogicalKeyboardKey.f2:
        // F2: Rename selected file (if single selection)
        Logger.debug('Keyboard shortcut: Rename (F2)');
        _handleRenameFile(context, ref);
        return KeyEventResult.handled;

      case LogicalKeyboardKey.f5:
        // F5: Refresh
        Logger.debug('Keyboard shortcut: Refresh (F5)');
        onRefresh?.call();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.enter:
        // Enter: Open selected file/folder (if single selection)
        Logger.debug('Keyboard shortcut: Open (Enter)');
        _handleOpenFile(context, ref);
        return KeyEventResult.handled;

      case LogicalKeyboardKey.escape:
        // Escape: Clear selection
        Logger.debug('Keyboard shortcut: Clear selection (Escape)');
        final selectionMethods = ref.read(fileSelectionMethodsProvider);
        selectionMethods.clearSelection();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.backspace:
        // Backspace: Navigate to parent folder
        Logger.debug('Keyboard shortcut: Go back (Backspace)');
        _handleGoBack(context, ref);
        return KeyEventResult.handled;

      default:
        return KeyEventResult.ignored;
    }
  }

  void _handleCopyUrl(BuildContext context, WidgetRef ref) {
    final selectedFiles = ref.read(selectedFilesProvider);
    if (selectedFiles.length == 1) {
      final file = selectedFiles.first;
      if (!file.isFolder) {
        final fileOperations = ref.read(fileOperationMethodsProvider);
        final url = fileOperations.getPublicUrl(file);
        if (url.isNotEmpty) {
          Clipboard.setData(ClipboardData(text: url));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(StorageConstants.successUrlCopied),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  void _handleMoveFile(BuildContext context, WidgetRef ref) {
    final selectedFiles = ref.read(selectedFilesProvider);
    if (selectedFiles.length == 1) {
      final file = selectedFiles.first;
      // Trigger move dialog/modal
      // This would typically open a folder picker dialog
      Logger.info('Move file requested for: ${file.name}');
      // For now, just log - the actual move implementation would be in the parent widget
    }
  }

  void _handleDeleteFiles(BuildContext context, WidgetRef ref) {
    final selectedFiles = ref.read(selectedFilesProvider);
    if (selectedFiles.isNotEmpty) {
      onDelete?.call(selectedFiles.toList());
    }
  }

  void _handleRenameFile(BuildContext context, WidgetRef ref) {
    final selectedFiles = ref.read(selectedFilesProvider);
    if (selectedFiles.length == 1) {
      final file = selectedFiles.first;
      onRename?.call(file);
    }
  }

  void _handleOpenFile(BuildContext context, WidgetRef ref) {
    final selectedFiles = ref.read(selectedFilesProvider);
    if (selectedFiles.length == 1) {
      final file = selectedFiles.first;
      if (file.isFolder) {
        // Navigate into folder
        final bucketMethods = ref.read(bucketMethodsProvider);
        final selectedBucketId = ref.read(selectedBucketProvider);
        if (selectedBucketId != null) {
          bucketMethods.navigateToPath(selectedBucketId, file.path);
        }
      } else {
        // Open file details
        onDetails?.call(file);
      }
    }
  }

  void _handleGoBack(BuildContext context, WidgetRef ref) {
    final bucketMethods = ref.read(bucketMethodsProvider);
    final selectedBucketId = ref.read(selectedBucketProvider);
    final currentPath = selectedBucketId != null ? ref.read(currentPathProvider(selectedBucketId)) : '';
    
    if (selectedBucketId != null && currentPath.isNotEmpty) {
      // Navigate to parent folder
      final pathParts = currentPath.split('/');
      if (pathParts.length > 1) {
        pathParts.removeLast();
        final parentPath = pathParts.join('/');
        bucketMethods.navigateToPath(selectedBucketId, parentPath);
      } else {
        // Go to bucket root
        bucketMethods.navigateToPath(selectedBucketId, '');
      }
    }
  }

  void _focusSearch(BuildContext context) {
    // Find and focus the search field
    // This is a simplified implementation - in practice, you might use a FocusNode
    // passed from the parent widget or use a global key
    Logger.info('Search focus requested');
    onSearch?.call('');
  }
}

/// Extension to provide keyboard shortcut information
extension KeyboardShortcuts on StorageConstants {
  static const Map<String, String> shortcutDescriptions = {
    'Ctrl+A': 'Select all files',
    'Ctrl+C': 'Copy file URL',
    'Ctrl+F': 'Search files',
    'Ctrl+U': 'Upload files',
    'Ctrl+X': 'Move file',
    'Ctrl+Shift+N': 'Create new folder',
    'Delete': 'Delete selected files',
    'F2': 'Rename file',
    'F5': 'Refresh',
    'Enter': 'Open file/folder',
    'Escape': 'Clear selection',
    'Backspace': 'Go to parent folder',
  };

  static List<MapEntry<String, String>> get allShortcuts => 
      shortcutDescriptions.entries.toList();
}