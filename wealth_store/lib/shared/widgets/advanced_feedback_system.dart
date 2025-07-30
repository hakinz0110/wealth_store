import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_design_tokens.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/core/utils/visual_styling_utils.dart';

/// Advanced feedback system for immediate visual confirmation and user guidance
class AdvancedFeedbackSystem {
  
  /// Show success feedback with checkmark animation
  static void showSuccess({
    required BuildContext context,
    required String message,
    IconData? icon,
    Duration? duration,
    VoidCallback? onComplete,
    bool enableHaptic = true,
  }) {
    if (enableHaptic) {
      HapticFeedback.mediumImpact();
    }
    
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => SuccessFeedbackWidget(
        message: message,
        icon: icon ?? Icons.check_circle,
        onComplete: () {
          overlayEntry.remove();
          onComplete?.call();
        },
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
    
    overlay.insert(overlayEntry);
  }
  
  /// Show error feedback with recovery actions
  static void showError({
    required BuildContext context,
    required String title,
    required String message,
    List<FeedbackAction>? actions,
    Duration? duration,
    bool enableHaptic = true,
  }) {
    if (enableHaptic) {
      HapticFeedback.heavyImpact();
    }
    
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => ErrorFeedbackWidget(
        title: title,
        message: message,
        actions: actions ?? [],
        onDismiss: () => overlayEntry.remove(),
        duration: duration,
      ),
    );
    
    overlay.insert(overlayEntry);
  }
  
  /// Show warning feedback with optional actions
  static void showWarning({
    required BuildContext context,
    required String message,
    List<FeedbackAction>? actions,
    Duration? duration,
    bool enableHaptic = true,
  }) {
    if (enableHaptic) {
      HapticFeedback.lightImpact();
    }
    
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => WarningFeedbackWidget(
        message: message,
        actions: actions ?? [],
        onDismiss: () => overlayEntry.remove(),
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
    
    overlay.insert(overlayEntry);
  }
  
  /// Show info feedback for general notifications
  static void showInfo({
    required BuildContext context,
    required String message,
    IconData? icon,
    Duration? duration,
    VoidCallback? onTap,
    bool enableHaptic = false,
  }) {
    if (enableHaptic) {
      HapticFeedback.selectionClick();
    }
    
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => InfoFeedbackWidget(
        message: message,
        icon: icon ?? Icons.info_outline,
        onDismiss: () => overlayEntry.remove(),
        onTap: onTap,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
    
    overlay.insert(overlayEntry);
  }
  
  /// Show loading feedback for ongoing operations
  static OverlayEntry showLoading({
    required BuildContext context,
    required String message,
    bool canCancel = false,
    VoidCallback? onCancel,
  }) {
    final overlay = Overlay.of(context);
    
    final overlayEntry = OverlayEntry(
      builder: (context) => LoadingFeedbackWidget(
        message: message,
        canCancel: canCancel,
        onCancel: onCancel,
      ),
    );
    
    overlay.insert(overlayEntry);
    return overlayEntry;
  }
  
  /// Show bottom sheet feedback for complex interactions
  static void showBottomSheetFeedback({
    required BuildContext context,
    required Widget content,
    String? title,
    List<FeedbackAction>? actions,
    bool isDismissible = true,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BottomSheetFeedbackWidget(
        title: title,
        content: content,
        actions: actions ?? [],
      ),
    );
  }
}

/// Success feedback widget with checkmark animation
class SuccessFeedbackWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final VoidCallback onComplete;
  final Duration duration;
  
  const SuccessFeedbackWidget({
    super.key,
    required this.message,
    required this.icon,
    required this.onComplete,
    required this.duration,
  });
  
  @override
  State<SuccessFeedbackWidget> createState() => _SuccessFeedbackWidgetState();
}

class _SuccessFeedbackWidgetState extends State<SuccessFeedbackWidget> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, widget.onComplete);
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: VisualStylingUtils.getStatusBadgeDecoration(
            status: SemanticColorType.success,
            context: context,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ).animate().scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: TypographyUtils.getBodyStyle(
                    context,
                    size: BodySize.medium,
                    isEmphasis: true,
                  ).copyWith(color: AppColors.success),
                ),
              ),
            ],
          ),
        ).animate().slideY(
          begin: -1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutBack,
        ).fadeIn(duration: 200.ms),
      ),
    );
  }
}

/// Error feedback widget with recovery actions
class ErrorFeedbackWidget extends StatefulWidget {
  final String title;
  final String message;
  final List<FeedbackAction> actions;
  final VoidCallback onDismiss;
  final Duration? duration;
  
  const ErrorFeedbackWidget({
    super.key,
    required this.title,
    required this.message,
    required this.actions,
    required this.onDismiss,
    this.duration,
  });
  
  @override
  State<ErrorFeedbackWidget> createState() => _ErrorFeedbackWidgetState();
}

class _ErrorFeedbackWidgetState extends State<ErrorFeedbackWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.duration != null) {
      Future.delayed(widget.duration!, widget.onDismiss);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: VisualStylingUtils.getStatusBadgeDecoration(
            status: SemanticColorType.error,
            context: context,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TypographyUtils.getHeadingStyle(
                        context,
                        HeadingLevel.h6,
                        isEmphasis: true,
                      ).copyWith(color: AppColors.error),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onDismiss,
                    icon: const Icon(Icons.close, size: 20),
                    color: AppColors.error,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.message,
                style: TypographyUtils.getBodyStyle(
                  context,
                  size: BodySize.medium,
                ),
              ),
              if (widget.actions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: widget.actions.map((action) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: TextButton(
                        onPressed: () {
                          action.onPressed();
                          widget.onDismiss();
                        },
                        child: Text(action.label),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ).animate().slideY(
          begin: -1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutBack,
        ).fadeIn(duration: 200.ms),
      ),
    );
  }
}

/// Warning feedback widget
class WarningFeedbackWidget extends StatefulWidget {
  final String message;
  final List<FeedbackAction> actions;
  final VoidCallback onDismiss;
  final Duration duration;
  
  const WarningFeedbackWidget({
    super.key,
    required this.message,
    required this.actions,
    required this.onDismiss,
    required this.duration,
  });
  
  @override
  State<WarningFeedbackWidget> createState() => _WarningFeedbackWidgetState();
}

class _WarningFeedbackWidgetState extends State<WarningFeedbackWidget> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, widget.onDismiss);
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: VisualStylingUtils.getStatusBadgeDecoration(
            status: SemanticColorType.warning,
            context: context,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: TypographyUtils.getBodyStyle(
                    context,
                    size: BodySize.medium,
                    isEmphasis: true,
                  ).copyWith(color: AppColors.warning),
                ),
              ),
              if (widget.actions.isNotEmpty)
                PopupMenuButton<FeedbackAction>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.warning,
                  ),
                  itemBuilder: (context) => widget.actions.map((action) {
                    return PopupMenuItem<FeedbackAction>(
                      value: action,
                      child: Text(action.label),
                    );
                  }).toList(),
                  onSelected: (action) {
                    action.onPressed();
                    widget.onDismiss();
                  },
                ),
            ],
          ),
        ).animate().slideY(
          begin: -1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutBack,
        ).fadeIn(duration: 200.ms),
      ),
    );
  }
}

/// Info feedback widget
class InfoFeedbackWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;
  final Duration duration;
  
  const InfoFeedbackWidget({
    super.key,
    required this.message,
    required this.icon,
    required this.onDismiss,
    this.onTap,
    required this.duration,
  });
  
  @override
  State<InfoFeedbackWidget> createState() => _InfoFeedbackWidgetState();
}

class _InfoFeedbackWidgetState extends State<InfoFeedbackWidget> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, widget.onDismiss);
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: VisualStylingUtils.getStatusBadgeDecoration(
              status: SemanticColorType.info,
              context: context,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: TypographyUtils.getBodyStyle(
                      context,
                      size: BodySize.medium,
                      isEmphasis: true,
                    ).copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ).animate().slideY(
          begin: -1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutBack,
        ).fadeIn(duration: 200.ms),
      ),
    );
  }
}

/// Loading feedback widget
class LoadingFeedbackWidget extends StatelessWidget {
  final String message;
  final bool canCancel;
  final VoidCallback? onCancel;
  
  const LoadingFeedbackWidget({
    super.key,
    required this.message,
    this.canCancel = false,
    this.onCancel,
  });
  
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            margin: EdgeInsets.all(AppSpacing.xl),
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: VisualStylingUtils.getElevatedCardDecoration(
              context: context,
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: TypographyUtils.getBodyStyle(
                    context,
                    size: BodySize.large,
                    isEmphasis: true,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (canCancel && onCancel != null) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet feedback widget
class BottomSheetFeedbackWidget extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<FeedbackAction> actions;
  
  const BottomSheetFeedbackWidget({
    super.key,
    this.title,
    required this.content,
    required this.actions,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          if (title != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                title!,
                style: TypographyUtils.getHeadingStyle(
                  context,
                  HeadingLevel.h5,
                  isEmphasis: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: content,
            ),
          ),
          // Actions
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: actions.map((action) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () {
                          action.onPressed();
                          Navigator.of(context).pop();
                        },
                        child: Text(action.label),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Feedback action model
class FeedbackAction {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  
  const FeedbackAction({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });
}