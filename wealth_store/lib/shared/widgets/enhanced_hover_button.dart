import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wealth_app/core/utils/haptic_feedback_utils.dart';

/// Enhanced button with prominent hover effects and visual contrast
class EnhancedHoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? hoverColor;
  final Color? pressColor;
  final double? elevation;
  final double? hoverElevation;
  final bool enabled;
  final String? tooltip;
  final String? semanticLabel;
  final String? semanticHint;
  final double hoverScale;
  final double pressScale;
  final Duration animationDuration;
  
  const EnhancedHoverButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.hoverColor,
    this.pressColor,
    this.elevation,
    this.hoverElevation,
    this.enabled = true,
    this.tooltip,
    this.semanticLabel,
    this.semanticHint,
    this.hoverScale = 1.05,
    this.pressScale = 0.95,
    this.animationDuration = const Duration(milliseconds: 200),
  });
  
  @override
  State<EnhancedHoverButton> createState() => _EnhancedHoverButtonState();
}

class _EnhancedHoverButtonState extends State<EnhancedHoverButton> {
  bool _isHovered = false;
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Default colors based on theme
    final defaultBackgroundColor = widget.backgroundColor ?? Colors.transparent;
    final defaultHoverColor = widget.hoverColor ?? 
        (isDark 
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05));
    final defaultPressColor = widget.pressColor ?? 
        (isDark 
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.black.withValues(alpha: 0.1));
    
    Color currentColor = defaultBackgroundColor;
    if (_isPressed) {
      currentColor = defaultPressColor;
    } else if (_isHovered) {
      currentColor = defaultHoverColor;
    }
    
    double currentScale = 1.0;
    if (_isPressed) {
      currentScale = widget.pressScale;
    } else if (_isHovered) {
      currentScale = widget.hoverScale;
    }
    
    double currentElevation = widget.elevation ?? 0;
    if (_isHovered) {
      currentElevation = widget.hoverElevation ?? (widget.elevation ?? 0) + 4;
    }
    
    Widget button = MouseRegion(
      cursor: widget.enabled && widget.onPressed != null 
          ? SystemMouseCursors.click 
          : SystemMouseCursors.basic,
      onEnter: widget.enabled ? (_) => _setHovered(true) : null,
      onExit: widget.enabled ? (_) => _setHovered(false) : null,
      child: GestureDetector(
        onTapDown: widget.enabled && widget.onPressed != null 
            ? (_) => _setPressed(true) : null,
        onTapUp: widget.enabled && widget.onPressed != null 
            ? (_) => _setPressed(false) : null,
        onTapCancel: widget.enabled && widget.onPressed != null 
            ? () => _setPressed(false) : null,
        onTap: widget.enabled ? () {
          HapticFeedbackUtils.buttonPress();
          widget.onPressed?.call();
        } : null,
        child: AnimatedContainer(
          duration: widget.animationDuration,
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..scale(currentScale),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            boxShadow: currentElevation > 0 ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
                blurRadius: currentElevation,
                offset: Offset(0, currentElevation / 2),
              ),
            ] : null,
          ),
          child: widget.child,
        ),
      ),
    );
    
    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }
    
    if (widget.semanticLabel != null) {
      button = Semantics(
        label: widget.semanticLabel,
        hint: widget.semanticHint,
        button: widget.onPressed != null,
        enabled: widget.enabled,
        onTap: widget.onPressed,
        child: button,
      );
    }
    
    return button;
  }
  
  void _setHovered(bool hovered) {
    if (_isHovered == hovered) return;
    setState(() => _isHovered = hovered);
    if (hovered) {
      HapticFeedbackUtils.lightImpact();
    }
  }
  
  void _setPressed(bool pressed) {
    if (_isPressed == pressed) return;
    setState(() => _isPressed = pressed);
    if (pressed) {
      HapticFeedbackUtils.buttonPress();
    }
  }
}