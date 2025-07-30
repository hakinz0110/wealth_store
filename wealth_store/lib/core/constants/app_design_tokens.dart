import 'package:flutter/material.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_shadows.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';

/// Centralized design tokens for the Wealth App
/// Following Material Design 3 principles with custom brand adaptations
class AppDesignTokens {
  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationExtraSlow = Duration(milliseconds: 800);
  
  // Animation curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  
  // Border radius tokens
  static BorderRadius get radiusNone => BorderRadius.zero;
  static BorderRadius get radiusXs => BorderRadius.circular(AppSpacing.radiusXs);
  static BorderRadius get radiusSm => BorderRadius.circular(AppSpacing.radiusSm);
  static BorderRadius get radiusMd => BorderRadius.circular(AppSpacing.radiusMd);
  static BorderRadius get radiusLg => BorderRadius.circular(AppSpacing.radiusLg);
  static BorderRadius get radiusXl => BorderRadius.circular(AppSpacing.radiusXl);
  static BorderRadius get radiusXxl => BorderRadius.circular(AppSpacing.radiusXxl);
  static BorderRadius get radiusRound => BorderRadius.circular(AppSpacing.radiusRound);
  
  // Component-specific border radius
  static BorderRadius get buttonRadius => radiusSm;
  static BorderRadius get cardRadius => radiusMd;
  static BorderRadius get inputRadius => radiusSm;
  static BorderRadius get chipRadius => radiusRound;
  static BorderRadius get bottomSheetRadius => BorderRadius.only(
    topLeft: Radius.circular(AppSpacing.radiusLg),
    topRight: Radius.circular(AppSpacing.radiusLg),
  );
  
  // Edge insets tokens
  static EdgeInsets get paddingNone => EdgeInsets.zero;
  static EdgeInsets get paddingXs => EdgeInsets.all(AppSpacing.xs);
  static EdgeInsets get paddingSm => EdgeInsets.all(AppSpacing.sm);
  static EdgeInsets get paddingMd => EdgeInsets.all(AppSpacing.md);
  static EdgeInsets get paddingLg => EdgeInsets.all(AppSpacing.lg);
  static EdgeInsets get paddingXl => EdgeInsets.all(AppSpacing.xl);
  static EdgeInsets get paddingXxl => EdgeInsets.all(AppSpacing.xxl);
  
  // Symmetric padding
  static EdgeInsets get paddingHorizontalSm => EdgeInsets.symmetric(horizontal: AppSpacing.sm);
  static EdgeInsets get paddingHorizontalMd => EdgeInsets.symmetric(horizontal: AppSpacing.md);
  static EdgeInsets get paddingHorizontalLg => EdgeInsets.symmetric(horizontal: AppSpacing.lg);
  static EdgeInsets get paddingVerticalSm => EdgeInsets.symmetric(vertical: AppSpacing.sm);
  static EdgeInsets get paddingVerticalMd => EdgeInsets.symmetric(vertical: AppSpacing.md);
  static EdgeInsets get paddingVerticalLg => EdgeInsets.symmetric(vertical: AppSpacing.lg);
  
  // Component-specific padding
  static EdgeInsets get screenPadding => EdgeInsets.all(AppSpacing.screenPadding);
  static EdgeInsets get cardPadding => EdgeInsets.all(AppSpacing.cardPadding);
  static EdgeInsets get buttonPadding => EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.md,
  );
  static EdgeInsets get inputPadding => EdgeInsets.all(AppSpacing.inputPadding);
  
  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 40.0;
  static const double iconXxl = 48.0;
  
  // Avatar sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 80.0;
  static const double avatarXxl = 120.0;
  
  // Button heights
  static const double buttonHeightSm = 32.0;
  static const double buttonHeightMd = 40.0;
  static const double buttonHeightLg = 48.0;
  static const double buttonHeightXl = 56.0;
  
  // Input field heights
  static const double inputHeightSm = 40.0;
  static const double inputHeightMd = 48.0;
  static const double inputHeightLg = 56.0;
  
  // Opacity values
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.60;
  static const double opacityHigh = 0.87;
  static const double opacityFull = 1.0;
  
  // Z-index values for layering
  static const int zIndexBase = 0;
  static const int zIndexDropdown = 1000;
  static const int zIndexSticky = 1020;
  static const int zIndexFixed = 1030;
  static const int zIndexModalBackdrop = 1040;
  static const int zIndexModal = 1050;
  static const int zIndexPopover = 1060;
  static const int zIndexTooltip = 1070;
  static const int zIndexToast = 1080;
  
  // Breakpoints for responsive design
  static const double breakpointMobile = 450.0;
  static const double breakpointTablet = 800.0;
  static const double breakpointDesktop = 1200.0;
  static const double breakpointWide = 1920.0;
  
  // Grid system
  static const int gridColumns = 12;
  static const double gridGutter = AppSpacing.lg;
  
  // Common decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.surfaceLight,
    borderRadius: cardRadius,
    boxShadow: AppShadows.elevation2,
  );
  
  static BoxDecoration get inputDecoration => BoxDecoration(
    color: AppColors.surfaceVariantLight,
    borderRadius: inputRadius,
    boxShadow: AppShadows.input,
  );
  
  static BoxDecoration get buttonDecoration => BoxDecoration(
    color: AppColors.primary,
    borderRadius: buttonRadius,
    boxShadow: AppShadows.button,
  );
  
  // Gradient decorations
  static BoxDecoration get primaryGradientDecoration => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: buttonRadius,
    boxShadow: AppShadows.button,
  );
  
  static BoxDecoration get surfaceGradientDecoration => BoxDecoration(
    gradient: AppColors.surfaceGradient,
    borderRadius: cardRadius,
  );
  
  // Text themes for quick access
  static TextTheme get textTheme => const TextTheme(
    displayLarge: AppTextStyles.displayLarge,
    displayMedium: AppTextStyles.displayMedium,
    displaySmall: AppTextStyles.displaySmall,
    headlineLarge: AppTextStyles.headlineLarge,
    headlineMedium: AppTextStyles.headlineMedium,
    headlineSmall: AppTextStyles.headlineSmall,
    titleLarge: AppTextStyles.titleLarge,
    titleMedium: AppTextStyles.titleMedium,
    titleSmall: AppTextStyles.titleSmall,
    labelLarge: AppTextStyles.labelLarge,
    labelMedium: AppTextStyles.labelMedium,
    labelSmall: AppTextStyles.labelSmall,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,
  );
  
  // Helper methods for responsive values
  static double getResponsiveValue({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= breakpointDesktop && desktop != null) {
      return desktop;
    } else if (screenWidth >= breakpointTablet && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }
  
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= breakpointDesktop) {
      return EdgeInsets.symmetric(horizontal: AppSpacing.huge);
    } else if (screenWidth >= breakpointTablet) {
      return EdgeInsets.symmetric(horizontal: AppSpacing.xxl);
    } else {
      return EdgeInsets.symmetric(horizontal: AppSpacing.lg);
    }
  }
}