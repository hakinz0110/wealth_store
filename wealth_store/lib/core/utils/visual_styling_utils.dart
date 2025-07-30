import 'package:flutter/material.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_shadows.dart';
import 'package:wealth_app/core/constants/app_design_tokens.dart';

/// Visual styling utility class for consistent visual effects throughout the app
/// Provides enhanced color states, gradients, shadows, and theme transitions
class VisualStylingUtils {
  
  /// Get interactive color states for buttons and interactive elements
  static MaterialStateProperty<Color?> getInteractiveColor({
    required Color baseColor,
    Color? hoverColor,
    Color? pressedColor,
    Color? focusedColor,
    Color? disabledColor,
  }) {
    return MaterialStateProperty.resolveWith<Color?>((states) {
      if (states.contains(MaterialState.disabled)) {
        return disabledColor ?? baseColor.withValues(alpha: 0.38);
      }
      if (states.contains(MaterialState.pressed)) {
        return pressedColor ?? _darkenColor(baseColor, 0.1);
      }
      if (states.contains(MaterialState.hovered)) {
        return hoverColor ?? _lightenColor(baseColor, 0.05);
      }
      if (states.contains(MaterialState.focused)) {
        return focusedColor ?? baseColor;
      }
      return baseColor;
    });
  }
  
  /// Get interactive overlay colors for ripple effects
  static MaterialStateProperty<Color?> getInteractiveOverlay({
    required Color baseColor,
    double hoverOpacity = 0.08,
    double pressedOpacity = 0.12,
    double focusedOpacity = 0.12,
  }) {
    return MaterialStateProperty.resolveWith<Color?>((states) {
      if (states.contains(MaterialState.pressed)) {
        return baseColor.withValues(alpha: pressedOpacity);
      }
      if (states.contains(MaterialState.hovered)) {
        return baseColor.withValues(alpha: hoverOpacity);
      }
      if (states.contains(MaterialState.focused)) {
        return baseColor.withValues(alpha: focusedOpacity);
      }
      return null;
    });
  }
  
  /// Get semantic color for status indicators
  static Color getSemanticColor(SemanticColorType type, {bool isDark = false}) {
    switch (type) {
      case SemanticColorType.success:
        return AppColors.success;
      case SemanticColorType.warning:
        return AppColors.warning;
      case SemanticColorType.error:
        return AppColors.error;
      case SemanticColorType.info:
        return AppColors.primary;
      case SemanticColorType.neutral:
        return isDark ? AppColors.neutral400 : AppColors.neutral600;
    }
  }
  
  /// Get semantic background color for status containers
  static Color getSemanticBackgroundColor(SemanticColorType type, {bool isDark = false}) {
    switch (type) {
      case SemanticColorType.success:
        return isDark 
            ? AppColors.success.withValues(alpha: 0.2)
            : AppColors.successContainer;
      case SemanticColorType.warning:
        return isDark 
            ? AppColors.warning.withValues(alpha: 0.2)
            : AppColors.warningContainer;
      case SemanticColorType.error:
        return isDark 
            ? AppColors.error.withValues(alpha: 0.2)
            : AppColors.errorContainer;
      case SemanticColorType.info:
        return isDark 
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.primaryContainer;
      case SemanticColorType.neutral:
        return isDark ? AppColors.neutral800 : AppColors.neutral100;
    }
  }
  
  /// Create enhanced gradient decorations
  static BoxDecoration getGradientDecoration({
    required GradientType type,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    LinearGradient gradient;
    
    switch (type) {
      case GradientType.primary:
        gradient = AppColors.primaryGradient;
        break;
      case GradientType.surface:
        gradient = AppColors.surfaceGradient;
        break;
      case GradientType.success:
        gradient = const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case GradientType.warning:
        gradient = const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case GradientType.error:
        gradient = const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case GradientType.shimmer:
        gradient = const LinearGradient(
          colors: [
            Color(0xFFE5E7EB),
            Color(0xFFF3F4F6),
            Color(0xFFE5E7EB),
          ],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment(-1.0, -0.3),
          end: Alignment(1.0, 0.3),
        );
        break;
    }
    
    return BoxDecoration(
      gradient: gradient,
      borderRadius: borderRadius ?? AppDesignTokens.radiusMd,
      boxShadow: boxShadow,
    );
  }
  
  /// Create frosted glass effect decoration
  static BoxDecoration getFrostedGlassDecoration({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    double opacity = 0.8,
  }) {
    return BoxDecoration(
      color: (backgroundColor ?? Colors.white).withValues(alpha: opacity),
      borderRadius: borderRadius ?? AppDesignTokens.radiusMd,
      boxShadow: AppShadows.frostedGlass,
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.2),
        width: 1,
      ),
    );
  }
  
  /// Create elevated card decoration with enhanced shadows
  static BoxDecoration getElevatedCardDecoration({
    required BuildContext context,
    double elevation = 2,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    bool isHovered = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveElevation = isHovered ? elevation + 2 : elevation;
    
    return BoxDecoration(
      color: backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
      borderRadius: borderRadius ?? AppDesignTokens.cardRadius,
      boxShadow: AppShadows.getElevationShadow(effectiveElevation),
      border: isDark 
          ? Border.all(
              color: AppColors.outline.withValues(alpha: 0.2),
              width: 0.5,
            )
          : null,
    );
  }
  
  /// Create modern button decoration with state-aware styling
  static BoxDecoration getButtonDecoration({
    required BuildContext context,
    required ButtonVariant variant,
    bool isPressed = false,
    bool isHovered = false,
    bool isDisabled = false,
    BorderRadius? borderRadius,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color backgroundColor;
    List<BoxShadow>? boxShadow;
    Border? border;
    
    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = isDisabled 
            ? AppColors.primary.withValues(alpha: 0.38)
            : isPressed 
                ? _darkenColor(AppColors.primary, 0.1)
                : isHovered 
                    ? _lightenColor(AppColors.primary, 0.05)
                    : AppColors.primary;
        boxShadow = isPressed ? AppShadows.buttonPressed : AppShadows.button;
        break;
        
      case ButtonVariant.secondary:
        backgroundColor = isDisabled 
            ? (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight).withValues(alpha: 0.38)
            : isPressed 
                ? (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight).withValues(alpha: 0.8)
                : isHovered 
                    ? (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight).withValues(alpha: 0.6)
                    : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight);
        border = Border.all(
          color: isDisabled 
              ? AppColors.outline.withValues(alpha: 0.38)
              : AppColors.outline,
          width: 1,
        );
        boxShadow = isPressed ? AppShadows.buttonPressed : AppShadows.button;
        break;
        
      case ButtonVariant.tertiary:
        backgroundColor = isDisabled 
            ? Colors.transparent
            : isPressed 
                ? AppColors.primary.withValues(alpha: 0.12)
                : isHovered 
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.transparent;
        boxShadow = null;
        break;
    }
    
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: borderRadius ?? AppDesignTokens.buttonRadius,
      boxShadow: boxShadow,
      border: border,
    );
  }
  
  /// Create status badge decoration with semantic colors
  static BoxDecoration getStatusBadgeDecoration({
    required SemanticColorType status,
    required BuildContext context,
    BorderRadius? borderRadius,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BoxDecoration(
      color: getSemanticBackgroundColor(status, isDark: isDark),
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      border: Border.all(
        color: getSemanticColor(status, isDark: isDark).withValues(alpha: 0.3),
        width: 1,
      ),
    );
  }
  
  /// Create animated theme transition
  static Widget createThemeTransition({
    required Widget child,
    required Duration duration,
    Curve curve = Curves.easeInOut,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      child: child,
    );
  }
  
  /// Helper method to lighten a color
  static Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Helper method to darken a color
  static Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Get theme-aware surface color with proper contrast
  static Color getSurfaceColor(BuildContext context, {double elevation = 0}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isDark) {
      // In dark theme, higher elevation = lighter surface
      final baseColor = AppColors.surfaceDark;
      final elevationOpacity = (elevation * 0.05).clamp(0.0, 0.15);
      return Color.alphaBlend(
        Colors.white.withValues(alpha: elevationOpacity),
        baseColor,
      );
    } else {
      return AppColors.surfaceLight;
    }
  }
  
  /// Get theme-aware text color with proper contrast
  static Color getTextColor(BuildContext context, {bool isSecondary = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isSecondary) {
      return isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight;
    } else {
      return isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight;
    }
  }
}

/// Enums for visual styling variants
enum SemanticColorType { success, warning, error, info, neutral }
enum GradientType { primary, surface, success, warning, error, shimmer }
enum ButtonVariant { primary, secondary, tertiary }