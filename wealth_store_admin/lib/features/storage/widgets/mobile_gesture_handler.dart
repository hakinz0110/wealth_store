import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/storage_models.dart';
import '../constants/storage_constants.dart';
import '../../../shared/constants/app_colors.dart';

/// Mobile gesture handler for file operations with swipe and long-press support
class MobileGestureHandler extends StatefulWidget {
  final Widget child;
  final StorageFile file;
  final Function(StorageFile)? onTap;
  final Function(StorageFile)? onDoubleTap;
  final Function(StorageFile, Offset)? onLongPress;
  final Function(StorageFile, SwipeDirection)? onSwipe;
  final bool enableSwipeGestures;
  final bool enableLongPress;

  const MobileGestureHandler({
    super.key,
    required this.child,
    required this.file,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSwipe,
    this.enableSwipeGestures = true,
    this.enableLongPress = true,
  });

  @override
  State<MobileGestureHandler> createState() => _MobileGestureHandlerState();
}

class _MobileGestureHandlerState extends State<MobileGestureHandler>
    with TickerProviderStateMixin {
  late AnimationController _swipeController;
  late AnimationController _pressController;
  late Animation<double> _swipeAnimation;
  late Animation<double> _pressAnimation;
  
  Offset? _panStart;
  bool _isLongPressing = false;
  SwipeDirection? _swipeDirection;

  @override
  void initState() {
    super.initState();
    
    _swipeController = AnimationController(
      duration: StorageConstants.shortAnimation,
      vsync: this,
    );
    
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _swipeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));
    
    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    if (!widget.enableSwipeGestures) return;
    _panStart = details.localPosition;
    _swipeDirection = null;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.enableSwipeGestures || _panStart == null) return;
    
    final delta = details.localPosition - _panStart!;
    final distance = delta.distance;
    
    if (distance > 20) { // Minimum swipe distance
      if (delta.dx.abs() > delta.dy.abs()) {
        // Horizontal swipe
        _swipeDirection = delta.dx > 0 ? SwipeDirection.right : SwipeDirection.left;
      } else {
        // Vertical swipe
        _swipeDirection = delta.dy > 0 ? SwipeDirection.down : SwipeDirection.up;
      }
      
      // Update animation based on swipe progress
      final progress = (distance / 100).clamp(0.0, 1.0);
      _swipeController.value = progress;
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!widget.enableSwipeGestures || _swipeDirection == null) {
      _swipeController.reverse();
      return;
    }
    
    final velocity = details.velocity.pixelsPerSecond.distance;
    
    if (velocity > 300) { // Minimum swipe velocity
      widget.onSwipe?.call(widget.file, _swipeDirection!);
      _swipeController.forward().then((_) {
        _swipeController.reverse();
      });
    } else {
      _swipeController.reverse();
    }
    
    _panStart = null;
    _swipeDirection = null;
  }

  void _handleTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _pressController.reverse();
    if (!_isLongPressing) {
      widget.onTap?.call(widget.file);
    }
    _isLongPressing = false;
  }

  void _handleTapCancel() {
    _pressController.reverse();
    _isLongPressing = false;
  }

  void _handleLongPress() {
    if (!widget.enableLongPress) return;
    
    _isLongPressing = true;
    _pressController.reverse();
    
    // Provide haptic feedback
    HapticFeedback.mediumImpact();
    
    // Get the render box to calculate position
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final center = Offset(
        position.dx + renderBox.size.width / 2,
        position.dy + renderBox.size.height / 2,
      );
      widget.onLongPress?.call(widget.file, center);
    }
  }

  void _handleDoubleTap() {
    widget.onDoubleTap?.call(widget.file);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: _handleLongPress,
      onDoubleTap: _handleDoubleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_swipeAnimation, _pressAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pressAnimation.value,
            child: Transform.translate(
              offset: _getSwipeOffset(),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: _isLongPressing ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }

  Offset _getSwipeOffset() {
    if (_swipeDirection == null) return Offset.zero;
    
    const maxOffset = 20.0;
    final progress = _swipeAnimation.value;
    
    switch (_swipeDirection!) {
      case SwipeDirection.left:
        return Offset(-maxOffset * progress, 0);
      case SwipeDirection.right:
        return Offset(maxOffset * progress, 0);
      case SwipeDirection.up:
        return Offset(0, -maxOffset * progress);
      case SwipeDirection.down:
        return Offset(0, maxOffset * progress);
    }
  }
}

/// Swipe direction enumeration
enum SwipeDirection {
  left,
  right,
  up,
  down,
}

/// Mobile-optimized context menu for file operations
class MobileContextMenu extends StatelessWidget {
  final StorageFile file;
  final List<StorageFile> selectedFiles;
  final Offset position;
  final VoidCallback onClose;
  final Function(StorageFile)? onRename;
  final Function(StorageFile)? onMove;
  final Function(StorageFile)? onDetails;
  final Function(List<StorageFile>)? onDelete;
  final Function(StorageFile)? onShare;
  final Function(StorageFile)? onDownload;

  const MobileContextMenu({
    super.key,
    required this.file,
    required this.selectedFiles,
    required this.position,
    required this.onClose,
    this.onRename,
    this.onMove,
    this.onDetails,
    this.onDelete,
    this.onShare,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < StorageConstants.mobileBreakpoint;
    
    if (!isMobile) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.borderLight),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          file.isFolder ? Icons.folder : Icons.insert_drive_file,
                          color: AppColors.primaryBlue,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            file.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                  
                  // Actions
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        if (onDetails != null)
                          _buildMenuItem(
                            icon: Icons.info_outline,
                            label: 'Details',
                            onTap: () {
                              onClose();
                              onDetails!(file);
                            },
                          ),
                        
                        if (onRename != null)
                          _buildMenuItem(
                            icon: Icons.edit_outlined,
                            label: 'Rename',
                            onTap: () {
                              onClose();
                              onRename!(file);
                            },
                          ),
                        
                        if (onMove != null)
                          _buildMenuItem(
                            icon: Icons.drive_file_move_outlined,
                            label: 'Move',
                            onTap: () {
                              onClose();
                              onMove!(file);
                            },
                          ),
                        
                        if (onShare != null && !file.isFolder)
                          _buildMenuItem(
                            icon: Icons.share_outlined,
                            label: 'Share',
                            onTap: () {
                              onClose();
                              onShare!(file);
                            },
                          ),
                        
                        if (onDownload != null && !file.isFolder)
                          _buildMenuItem(
                            icon: Icons.download_outlined,
                            label: 'Download',
                            onTap: () {
                              onClose();
                              onDownload!(file);
                            },
                          ),
                        
                        if (onDelete != null)
                          _buildMenuItem(
                            icon: Icons.delete_outline,
                            label: 'Delete',
                            onTap: () {
                              onClose();
                              onDelete!(selectedFiles.isNotEmpty ? selectedFiles : [file]);
                            },
                            isDestructive: true,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isDestructive ? AppColors.error : AppColors.textSecondary,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}