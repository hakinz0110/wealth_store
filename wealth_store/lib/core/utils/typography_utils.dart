import 'package:flutter/material.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';

/// Typography utility class for consistent text styling throughout the app
/// Provides semantic text styles with proper contrast ratios and emphasis treatments
class TypographyUtils {
  
  /// Get text style with proper color contrast for the current theme
  static TextStyle getTextStyle(
    BuildContext context,
    TextStyle baseStyle, {
    Color? color,
    bool isEmphasis = false,
    bool isSecondary = false,
    bool isDisabled = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color textColor;
    if (color != null) {
      textColor = color;
    } else if (isDisabled) {
      textColor = isDark 
          ? AppColors.onSurfaceDark.withValues(alpha: 0.38)
          : AppColors.onSurfaceLight.withValues(alpha: 0.38);
    } else if (isSecondary) {
      textColor = isDark 
          ? AppColors.onSurfaceVariantDark
          : AppColors.onSurfaceVariantLight;
    } else if (isEmphasis) {
      textColor = isDark 
          ? AppColors.onSurfaceDark
          : AppColors.onSurfaceLight;
    } else {
      textColor = isDark 
          ? AppColors.onSurfaceDark
          : AppColors.onSurfaceLight;
    }
    
    return baseStyle.copyWith(color: textColor);
  }
  
  /// Price text styles with proper emphasis and color
  static TextStyle getPriceStyle(
    BuildContext context, {
    PriceSize size = PriceSize.medium,
    bool isDiscounted = false,
    bool isOnSale = false,
  }) {
    TextStyle baseStyle;
    switch (size) {
      case PriceSize.large:
        baseStyle = AppTextStyles.priceLarge;
        break;
      case PriceSize.medium:
        baseStyle = AppTextStyles.priceMedium;
        break;
      case PriceSize.small:
        baseStyle = AppTextStyles.priceSmall;
        break;
    }
    
    Color priceColor;
    if (isDiscounted) {
      priceColor = Theme.of(context).brightness == Brightness.dark
          ? AppColors.onSurfaceVariantDark
          : AppColors.onSurfaceVariantLight;
      baseStyle = AppTextStyles.discountPrice;
    } else if (isOnSale) {
      priceColor = AppColors.error;
    } else {
      priceColor = AppColors.primary;
    }
    
    return baseStyle.copyWith(color: priceColor);
  }
  
  /// Product title styles with proper hierarchy
  static TextStyle getProductTitleStyle(
    BuildContext context, {
    ProductTitleSize size = ProductTitleSize.medium,
    bool isEmphasis = false,
  }) {
    TextStyle baseStyle;
    switch (size) {
      case ProductTitleSize.large:
        baseStyle = AppTextStyles.productTitleLarge;
        break;
      case ProductTitleSize.medium:
        baseStyle = AppTextStyles.productTitleMedium;
        break;
    }
    
    return getTextStyle(
      context,
      baseStyle,
      isEmphasis: isEmphasis,
    );
  }
  
  /// Status badge styles with semantic colors
  static TextStyle getStatusStyle(
    BuildContext context,
    StatusType status,
  ) {
    TextStyle baseStyle;
    Color statusColor;
    
    switch (status) {
      case StatusType.success:
        baseStyle = AppTextStyles.statusSuccess;
        statusColor = AppColors.success;
        break;
      case StatusType.warning:
        baseStyle = AppTextStyles.statusWarning;
        statusColor = AppColors.warning;
        break;
      case StatusType.error:
        baseStyle = AppTextStyles.statusError;
        statusColor = AppColors.error;
        break;
      case StatusType.info:
        baseStyle = AppTextStyles.labelSmall;
        statusColor = AppColors.primary;
        break;
    }
    
    return baseStyle.copyWith(color: statusColor);
  }
  
  /// Button text styles with proper emphasis
  static TextStyle getButtonStyle(
    BuildContext context, {
    ButtonSize size = ButtonSize.medium,
    ButtonType type = ButtonType.primary,
  }) {
    TextStyle baseStyle;
    switch (size) {
      case ButtonSize.large:
        baseStyle = AppTextStyles.buttonLarge;
        break;
      case ButtonSize.medium:
        baseStyle = AppTextStyles.buttonMedium;
        break;
      case ButtonSize.small:
        baseStyle = AppTextStyles.buttonSmall;
        break;
    }
    
    Color buttonColor;
    switch (type) {
      case ButtonType.primary:
        buttonColor = AppColors.onPrimary;
        break;
      case ButtonType.secondary:
        buttonColor = AppColors.primary;
        break;
      case ButtonType.tertiary:
        buttonColor = Theme.of(context).brightness == Brightness.dark
            ? AppColors.onSurfaceDark
            : AppColors.onSurfaceLight;
        break;
    }
    
    return baseStyle.copyWith(color: buttonColor);
  }
  
  /// Heading styles with proper hierarchy and contrast
  static TextStyle getHeadingStyle(
    BuildContext context,
    HeadingLevel level, {
    bool isEmphasis = false,
  }) {
    TextStyle baseStyle;
    switch (level) {
      case HeadingLevel.h1:
        baseStyle = AppTextStyles.headlineLarge;
        break;
      case HeadingLevel.h2:
        baseStyle = AppTextStyles.headlineMedium;
        break;
      case HeadingLevel.h3:
        baseStyle = AppTextStyles.headlineSmall;
        break;
      case HeadingLevel.h4:
        baseStyle = AppTextStyles.titleLarge;
        break;
      case HeadingLevel.h5:
        baseStyle = AppTextStyles.titleMedium;
        break;
      case HeadingLevel.h6:
        baseStyle = AppTextStyles.titleSmall;
        break;
    }
    
    return getTextStyle(
      context,
      baseStyle,
      isEmphasis: isEmphasis,
    );
  }
  
  /// Body text styles with optimal readability
  static TextStyle getBodyStyle(
    BuildContext context, {
    BodySize size = BodySize.medium,
    bool isSecondary = false,
    bool isEmphasis = false,
  }) {
    TextStyle baseStyle;
    switch (size) {
      case BodySize.large:
        baseStyle = AppTextStyles.bodyLarge;
        break;
      case BodySize.medium:
        baseStyle = AppTextStyles.bodyMedium;
        break;
      case BodySize.small:
        baseStyle = AppTextStyles.bodySmall;
        break;
    }
    
    return getTextStyle(
      context,
      baseStyle,
      isSecondary: isSecondary,
      isEmphasis: isEmphasis,
    );
  }
  
  /// Label styles for UI elements
  static TextStyle getLabelStyle(
    BuildContext context, {
    LabelSize size = LabelSize.medium,
    bool isSecondary = false,
  }) {
    TextStyle baseStyle;
    switch (size) {
      case LabelSize.large:
        baseStyle = AppTextStyles.labelLarge;
        break;
      case LabelSize.medium:
        baseStyle = AppTextStyles.labelMedium;
        break;
      case LabelSize.small:
        baseStyle = AppTextStyles.labelSmall;
        break;
    }
    
    return getTextStyle(
      context,
      baseStyle,
      isSecondary: isSecondary,
    );
  }
  
  /// Check if text color meets WCAG contrast requirements
  static bool hasGoodContrast(Color textColor, Color backgroundColor) {
    final textLuminance = textColor.computeLuminance();
    final backgroundLuminance = backgroundColor.computeLuminance();
    
    final contrast = (textLuminance > backgroundLuminance)
        ? (textLuminance + 0.05) / (backgroundLuminance + 0.05)
        : (backgroundLuminance + 0.05) / (textLuminance + 0.05);
    
    // WCAG AA standard requires 4.5:1 for normal text, 3:1 for large text
    return contrast >= 4.5;
  }
  
  /// Get appropriate text color for background to ensure good contrast
  static Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

/// Enums for typography variants
enum PriceSize { large, medium, small }
enum ProductTitleSize { large, medium }
enum StatusType { success, warning, error, info }
enum ButtonSize { large, medium, small }
enum ButtonType { primary, secondary, tertiary }
enum HeadingLevel { h1, h2, h3, h4, h5, h6 }
enum BodySize { large, medium, small }
enum LabelSize { large, medium, small }