import 'package:flutter/material.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';
import 'package:wealth_app/core/constants/app_design_tokens.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/utils/accessibility_utils.dart';
import 'package:wealth_app/core/utils/accessibility_validator.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,
      
      // Enhanced color scheme using Material Design 3 tokens
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.onSurfaceLight,
        surfaceContainerHighest: AppColors.surfaceVariantLight,
        onSurfaceVariant: AppColors.onSurfaceVariantLight,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      
      // Enhanced text theme using Material Design 3 typography scale
      textTheme: AppDesignTokens.textTheme,
      
      // Modern app bar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.onSurfaceLight,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.onSurfaceLight,
        ),
      ),
      
      // Enhanced card theme with modern shadows
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesignTokens.cardRadius,
        ),
        color: AppColors.surfaceLight,
        margin: EdgeInsets.all(AppSpacing.sm),
      ),
      
      // Modern elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.primary),
          foregroundColor: WidgetStatePropertyAll(AppColors.onPrimary),
          elevation: WidgetStateProperty.resolveWith<double>((states) {
            if (states.contains(WidgetState.pressed)) return 1;
            if (states.contains(WidgetState.hovered)) return 3;
            return 2;
          }),
          padding: WidgetStatePropertyAll(AppDesignTokens.buttonPadding),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: AppDesignTokens.buttonRadius,
          )),
          textStyle: WidgetStatePropertyAll(AppTextStyles.labelLarge),
          minimumSize: WidgetStatePropertyAll(
            Size(0, AppDesignTokens.buttonHeightMd),
          ),
        ),
      ),
      
      // Modern input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantLight,
        contentPadding: AppDesignTokens.inputPadding,
        border: OutlineInputBorder(
          borderRadius: AppDesignTokens.inputRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDesignTokens.inputRadius,
          borderSide: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDesignTokens.inputRadius,
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDesignTokens.inputRadius,
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDesignTokens.inputRadius,
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurfaceVariantLight,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurfaceVariantLight.withValues(alpha: 0.6),
        ),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariantLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,
      
      // Enhanced dark color scheme using Material Design 3 tokens
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primary700,
        onPrimaryContainer: AppColors.primary100,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondary700,
        onSecondaryContainer: AppColors.secondary100,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiary700,
        onTertiaryContainer: AppColors.tertiary100,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: Color(0x33EF4444), // AppColors.error with 20% opacity
        onErrorContainer: AppColors.error,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.onSurfaceDark,
        surfaceContainerHighest: AppColors.surfaceVariantDark,
        onSurfaceVariant: AppColors.onSurfaceVariantDark,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      
      // Enhanced text theme for dark mode
      textTheme: AppDesignTokens.textTheme.apply(
        bodyColor: AppColors.onSurfaceDark,
        displayColor: AppColors.onSurfaceDark,
      ),
      
      // Modern dark app bar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.onSurfaceDark,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.onSurfaceDark,
        ),
      ),
      
      // Enhanced dark card theme
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesignTokens.cardRadius,
        ),
        color: AppColors.surfaceDark,
        margin: EdgeInsets.all(AppSpacing.sm),
      ),
      
      // Modern dark elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.primary),
          foregroundColor: WidgetStatePropertyAll(AppColors.onPrimary),
          elevation: WidgetStateProperty.resolveWith<double>((states) {
            if (states.contains(WidgetState.pressed)) return 1;
            if (states.contains(WidgetState.hovered)) return 3;
            return 2;
          }),
          padding: WidgetStatePropertyAll(AppDesignTokens.buttonPadding),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: AppDesignTokens.buttonRadius,
          )),
          textStyle: WidgetStatePropertyAll(AppTextStyles.labelLarge),
          minimumSize: WidgetStatePropertyAll(
            Size(0, AppDesignTokens.buttonHeightMd),
          ),
        ),
      ),
      
      // Modern dark input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantDark,
        contentPadding: AppDesignTokens.inputPadding,
        border: OutlineInputBorder(
          borderRadius: AppDesignTokens.inputRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDesignTokens.inputRadius,
          borderSide: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDesignTokens.inputRadius,
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDesignTokens.inputRadius,
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDesignTokens.inputRadius,
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurfaceVariantDark,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurfaceVariantDark.withValues(alpha: 0.6),
        ),
      ),
      
      // Dark bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariantDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),
    );
  }

  /// Validate accessibility compliance for light theme
  static AccessibilityValidationResult validateLightThemeAccessibility() {
    final theme = lightTheme();
    return AccessibilityValidator.validateThemeAccessibility(theme);
  }

  /// Validate accessibility compliance for dark theme
  static AccessibilityValidationResult validateDarkThemeAccessibility() {
    final theme = darkTheme();
    return AccessibilityValidator.validateThemeAccessibility(theme);
  }

  /// Get accessibility-compliant color for given background
  static Color getAccessibleTextColor(Color backgroundColor, {bool isLargeText = false}) {
    return AccessibilityUtils.getAccessibleColor(
      AppColors.onSurfaceLight,
      backgroundColor,
      isLargeText: isLargeText,
    );
  }

  /// Get accessibility-compliant text style for given background
  static TextStyle getAccessibleTextStyle(
    TextStyle baseStyle,
    Color backgroundColor, {
    bool isLargeText = false,
  }) {
    return AccessibilityUtils.getAccessibleTextStyle(
      baseStyle,
      backgroundColor,
      isLargeText: isLargeText,
    );
  }

  /// Generate comprehensive accessibility report for both themes
  static AccessibilityReport generateAccessibilityReport() {
    final lightThemeReport = AccessibilityValidator.generateAccessibilityReport(lightTheme());
    final darkThemeReport = AccessibilityValidator.generateAccessibilityReport(darkTheme());
    
    // Combine reports
    final allIssues = <AccessibilityIssue>[];
    allIssues.addAll(lightThemeReport.issues);
    allIssues.addAll(darkThemeReport.issues);

    final criticalIssues = allIssues.where((i) => i.severity == AccessibilityIssueSeverity.critical).length;
    final highIssues = allIssues.where((i) => i.severity == AccessibilityIssueSeverity.high).length;
    final mediumIssues = allIssues.where((i) => i.severity == AccessibilityIssueSeverity.medium).length;
    final lowIssues = allIssues.where((i) => i.severity == AccessibilityIssueSeverity.low).length;

    return AccessibilityReport(
      isCompliant: allIssues.isEmpty,
      totalIssues: allIssues.length,
      criticalIssues: criticalIssues,
      highIssues: highIssues,
      mediumIssues: mediumIssues,
      lowIssues: lowIssues,
      issues: allIssues,
      themeValidation: lightThemeReport.themeValidation,
      recommendations: [
        'Light Theme Issues: ${lightThemeReport.issues.length}',
        'Dark Theme Issues: ${darkThemeReport.issues.length}',
        ...lightThemeReport.recommendations,
        ...darkThemeReport.recommendations,
      ],
      complianceScore: (lightThemeReport.complianceScore + darkThemeReport.complianceScore) / 2,
    );
  }
} 