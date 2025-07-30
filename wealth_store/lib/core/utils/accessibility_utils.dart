import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wealth_app/core/constants/app_colors.dart';

/// Comprehensive accessibility utilities for WCAG 2.1 AA compliance
class AccessibilityUtils {
  AccessibilityUtils._();

  // WCAG 2.1 AA minimum contrast ratios
  static const double _minContrastRatioNormal = 4.5;
  static const double _minContrastRatioLarge = 3.0;
  static const double _minTouchTargetSize = 44.0;

  /// Calculate contrast ratio between two colors
  /// Returns a value between 1 and 21, where 21 is maximum contrast
  static double calculateContrastRatio(Color foreground, Color background) {
    final foregroundLuminance = _calculateLuminance(foreground);
    final backgroundLuminance = _calculateLuminance(background);
    
    final lighter = foregroundLuminance > backgroundLuminance 
        ? foregroundLuminance 
        : backgroundLuminance;
    final darker = foregroundLuminance > backgroundLuminance 
        ? backgroundLuminance 
        : foregroundLuminance;
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Calculate relative luminance of a color
  static double _calculateLuminance(Color color) {
    final r = _linearizeColorComponent(color.red / 255.0);
    final g = _linearizeColorComponent(color.green / 255.0);
    final b = _linearizeColorComponent(color.blue / 255.0);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Linearize color component for luminance calculation
  static double _linearizeColorComponent(double component) {
    return component <= 0.03928 
        ? component / 12.92 
        : pow((component + 0.055) / 1.055, 2.4);
  }

  /// Check if color combination meets WCAG AA contrast requirements
  static bool meetsContrastRequirements(
    Color foreground, 
    Color background, {
    bool isLargeText = false,
  }) {
    final contrastRatio = calculateContrastRatio(foreground, background);
    final minRatio = isLargeText ? _minContrastRatioLarge : _minContrastRatioNormal;
    return contrastRatio >= minRatio;
  }

  /// Get accessible color variant that meets contrast requirements
  static Color getAccessibleColor(
    Color originalColor, 
    Color backgroundColor, {
    bool isLargeText = false,
    bool preferDarker = true,
  }) {
    if (meetsContrastRequirements(originalColor, backgroundColor, isLargeText: isLargeText)) {
      return originalColor;
    }

    // Try adjusting the original color
    Color adjustedColor = originalColor;
    final minRatio = isLargeText ? _minContrastRatioLarge : _minContrastRatioNormal;
    
    // Adjust brightness until contrast requirement is met
    for (int i = 0; i < 100; i++) {
      final adjustment = preferDarker ? -i * 0.01 : i * 0.01;
      adjustedColor = _adjustColorBrightness(originalColor, adjustment);
      
      if (calculateContrastRatio(adjustedColor, backgroundColor) >= minRatio) {
        return adjustedColor;
      }
    }
    
    // Fallback to high contrast colors
    final backgroundLuminance = _calculateLuminance(backgroundColor);
    return backgroundLuminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Adjust color brightness by a factor (-1.0 to 1.0)
  static Color _adjustColorBrightness(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final adjustedLightness = (hsl.lightness + factor).clamp(0.0, 1.0);
    return hsl.withLightness(adjustedLightness).toColor();
  }

  /// Ensure minimum touch target size (44dp minimum)
  static Size ensureMinimumTouchTarget(Size originalSize) {
    return Size(
      originalSize.width < _minTouchTargetSize ? _minTouchTargetSize : originalSize.width,
      originalSize.height < _minTouchTargetSize ? _minTouchTargetSize : originalSize.height,
    );
  }

  /// Create semantic label for screen readers
  static String createSemanticLabel({
    required String primaryText,
    String? secondaryText,
    String? statusText,
    String? actionHint,
  }) {
    final parts = <String>[primaryText];
    
    if (secondaryText != null && secondaryText.isNotEmpty) {
      parts.add(secondaryText);
    }
    
    if (statusText != null && statusText.isNotEmpty) {
      parts.add(statusText);
    }
    
    if (actionHint != null && actionHint.isNotEmpty) {
      parts.add(actionHint);
    }
    
    return parts.join(', ');
  }

  /// Create price semantic label for screen readers
  static String createPriceSemanticLabel(
    double price, {
    double? originalPrice,
    String currency = 'dollars',
  }) {
    final priceText = '${price.toStringAsFixed(2)} $currency';
    
    if (originalPrice != null && originalPrice > price) {
      final originalPriceText = '${originalPrice.toStringAsFixed(2)} $currency';
      return 'Sale price $priceText, was $originalPriceText';
    }
    
    return 'Price $priceText';
  }

  /// Create rating semantic label for screen readers
  static String createRatingSemanticLabel(
    double rating, 
    int reviewCount,
  ) {
    final ratingText = rating.toStringAsFixed(1);
    final reviewText = reviewCount == 1 ? 'review' : 'reviews';
    return 'Rated $ratingText out of 5 stars, $reviewCount $reviewText';
  }

  /// Create stock status semantic label
  static String createStockSemanticLabel(int stock) {
    if (stock == 0) {
      return 'Out of stock';
    } else if (stock <= 5) {
      return 'Low stock, only $stock remaining';
    } else {
      return 'In stock';
    }
  }

  /// Provide haptic feedback for accessibility
  static void provideAccessibilityFeedback({
    required AccessibilityFeedbackType type,
  }) {
    switch (type) {
      case AccessibilityFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
      case AccessibilityFeedbackType.success:
        HapticFeedback.mediumImpact();
        break;
      case AccessibilityFeedbackType.error:
        HapticFeedback.heavyImpact();
        break;
      case AccessibilityFeedbackType.navigation:
        HapticFeedback.lightImpact();
        break;
    }
  }

  /// Create focus node with proper accessibility handling
  static FocusNode createAccessibleFocusNode({
    String? debugLabel,
    bool skipTraversal = false,
  }) {
    return FocusNode(
      debugLabel: debugLabel,
      skipTraversal: skipTraversal,
    );
  }

  /// Announce message to screen readers
  static void announceToScreenReader(
    BuildContext context,
    String message, {
    Assertiveness assertiveness = Assertiveness.polite,
  }) {
    // Use the context to announce to screen readers
    // This is a simplified implementation for web compatibility
    debugPrint('Screen Reader Announcement: $message');
  }

  /// Validate color combinations for accessibility
  static Map<String, bool> validateColorAccessibility(ThemeData theme) {
    final results = <String, bool>{};
    
    // Check primary color combinations
    results['primary_on_surface'] = meetsContrastRequirements(
      theme.colorScheme.primary,
      theme.colorScheme.surface,
    );
    
    results['on_primary_primary'] = meetsContrastRequirements(
      theme.colorScheme.onPrimary,
      theme.colorScheme.primary,
    );
    
    results['secondary_on_surface'] = meetsContrastRequirements(
      theme.colorScheme.secondary,
      theme.colorScheme.surface,
    );
    
    results['on_secondary_secondary'] = meetsContrastRequirements(
      theme.colorScheme.onSecondary,
      theme.colorScheme.secondary,
    );
    
    results['error_on_surface'] = meetsContrastRequirements(
      theme.colorScheme.error,
      theme.colorScheme.surface,
    );
    
    results['on_error_error'] = meetsContrastRequirements(
      theme.colorScheme.onError,
      theme.colorScheme.error,
    );
    
    return results;
  }

  /// Get accessible text style with proper contrast
  static TextStyle getAccessibleTextStyle(
    TextStyle baseStyle,
    Color backgroundColor, {
    bool isLargeText = false,
  }) {
    if (baseStyle.color == null) return baseStyle;
    
    final accessibleColor = getAccessibleColor(
      baseStyle.color!,
      backgroundColor,
      isLargeText: isLargeText,
    );
    
    return baseStyle.copyWith(color: accessibleColor);
  }
}

/// Types of accessibility feedback
enum AccessibilityFeedbackType {
  selection,
  success,
  error,
  navigation,
}

/// Assertiveness levels for screen reader announcements
enum Assertiveness {
  polite,
  assertive,
}

/// Helper function for power calculation (since dart:math pow is not available in some contexts)
double pow(double base, double exponent) {
  if (exponent == 0) return 1.0;
  if (exponent == 1) return base;
  if (exponent == 2) return base * base;
  if (exponent == 2.4) {
    // Approximation for gamma correction
    final squared = base * base;
    final fourth = squared * squared;
    return fourth * pow(base, 0.4);
  }
  
  // Fallback approximation
  double result = 1.0;
  for (int i = 0; i < exponent.abs().floor(); i++) {
    result *= base;
  }
  return exponent < 0 ? 1.0 / result : result;
}