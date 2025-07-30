import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wealth_app/core/utils/visual_styling_utils.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';

/// Enhanced status badge with semantic colors and animations
class EnhancedStatusBadge extends StatelessWidget {
  final String text;
  final SemanticColorType status;
  final IconData? icon;
  final bool showPulse;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  
  const EnhancedStatusBadge({
    super.key,
    required this.text,
    required this.status,
    this.icon,
    this.showPulse = false,
    this.onTap,
    this.padding,
    this.borderRadius,
  });
  
  /// Factory constructors for common status types
  factory EnhancedStatusBadge.success({
    required String text,
    IconData? icon,
    bool showPulse = false,
    VoidCallback? onTap,
  }) {
    return EnhancedStatusBadge(
      text: text,
      status: SemanticColorType.success,
      icon: icon ?? Icons.check_circle_outline,
      showPulse: showPulse,
      onTap: onTap,
    );
  }
  
  factory EnhancedStatusBadge.warning({
    required String text,
    IconData? icon,
    bool showPulse = false,
    VoidCallback? onTap,
  }) {
    return EnhancedStatusBadge(
      text: text,
      status: SemanticColorType.warning,
      icon: icon ?? Icons.warning_amber_outlined,
      showPulse: showPulse,
      onTap: onTap,
    );
  }
  
  factory EnhancedStatusBadge.error({
    required String text,
    IconData? icon,
    bool showPulse = false,
    VoidCallback? onTap,
  }) {
    return EnhancedStatusBadge(
      text: text,
      status: SemanticColorType.error,
      icon: icon ?? Icons.error_outline,
      showPulse: showPulse,
      onTap: onTap,
    );
  }
  
  factory EnhancedStatusBadge.info({
    required String text,
    IconData? icon,
    bool showPulse = false,
    VoidCallback? onTap,
  }) {
    return EnhancedStatusBadge(
      text: text,
      status: SemanticColorType.info,
      icon: icon ?? Icons.info_outline,
      showPulse: showPulse,
      onTap: onTap,
    );
  }
  
  factory EnhancedStatusBadge.neutral({
    required String text,
    IconData? icon,
    bool showPulse = false,
    VoidCallback? onTap,
  }) {
    return EnhancedStatusBadge(
      text: text,
      status: SemanticColorType.neutral,
      icon: icon,
      showPulse: showPulse,
      onTap: onTap,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = VisualStylingUtils.getSemanticColor(status, isDark: isDark);
    
    Widget badge = Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: VisualStylingUtils.getStatusBadgeDecoration(
        status: status,
        context: context,
        borderRadius: borderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: statusColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TypographyUtils.getStatusStyle(
              context,
              _getStatusType(status),
            ),
          ),
        ],
      ),
    );
    
    // Add pulse animation if requested
    if (showPulse) {
      badge = badge
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 2000.ms,
            color: statusColor.withValues(alpha: 0.3),
          )
          .then()
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.05, 1.05),
            duration: 1000.ms,
            curve: Curves.easeInOut,
          )
          .then()
          .scale(
            begin: const Offset(1.05, 1.05),
            end: const Offset(1.0, 1.0),
            duration: 1000.ms,
            curve: Curves.easeInOut,
          );
    }
    
    // Make tappable if onTap is provided
    if (onTap != null) {
      badge = GestureDetector(
        onTap: onTap,
        child: badge,
      );
    }
    
    return badge;
  }
  
  StatusType _getStatusType(SemanticColorType semanticType) {
    switch (semanticType) {
      case SemanticColorType.success:
        return StatusType.success;
      case SemanticColorType.warning:
        return StatusType.warning;
      case SemanticColorType.error:
        return StatusType.error;
      case SemanticColorType.info:
      case SemanticColorType.neutral:
        return StatusType.info;
    }
  }
}

/// Enhanced notification badge with count and animations
class EnhancedNotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  final Color? backgroundColor;
  final Color? textColor;
  final double? size;
  final bool showAnimation;
  
  const EnhancedNotificationBadge({
    super.key,
    required this.count,
    required this.child,
    this.backgroundColor,
    this.textColor,
    this.size,
    this.showAnimation = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBackgroundColor = backgroundColor ?? 
        VisualStylingUtils.getSemanticColor(SemanticColorType.error, isDark: isDark);
    final effectiveTextColor = textColor ?? Colors.white;
    final effectiveSize = size ?? 18.0;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              width: effectiveSize,
              height: effectiveSize,
              decoration: BoxDecoration(
                color: effectiveBackgroundColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: effectiveBackgroundColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: TypographyUtils.getLabelStyle(
                    context,
                    size: LabelSize.small,
                  ).copyWith(
                    color: effectiveTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: count > 99 ? 9 : 11,
                  ),
                ),
              ),
            ).animate(
              target: showAnimation ? 1 : 0,
            ).scale(
              begin: const Offset(0.0, 0.0),
              end: const Offset(1.0, 1.0),
              duration: 300.ms,
              curve: Curves.elasticOut,
            ).fadeIn(
              duration: 200.ms,
            ),
          ),
      ],
    );
  }
}