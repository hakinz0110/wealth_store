import 'package:flutter/material.dart';

class AppColors {
  // Material Design 3 Color Tokens - Enhanced Palette
  
  // Primary Brand Colors - Indigo-based palette
  static const primary = Color(0xFF6366F1);        // Primary 500
  static const primary50 = Color(0xFFF0F9FF);      // Lightest tint
  static const primary100 = Color(0xFFE0F2FE);     // Very light
  static const primary200 = Color(0xFFBAE6FD);     // Light
  static const primary300 = Color(0xFF7DD3FC);     // Medium light
  static const primary400 = Color(0xFF38BDF8);     // Medium
  static const primary500 = Color(0xFF6366F1);     // Base primary
  static const primary600 = Color(0xFF4F46E5);     // Medium dark
  static const primary700 = Color(0xFF4338CA);     // Dark
  static const primary800 = Color(0xFF3730A3);     // Very dark
  static const primary900 = Color(0xFF312E81);     // Darkest shade
  
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFE0E7FF);
  static const onPrimaryContainer = Color(0xFF1E1B16);
  
  // Secondary Colors - Pink-based palette
  static const secondary = Color(0xFFEC4899);       // Secondary 500
  static const secondary50 = Color(0xFFFDF2F8);     // Lightest tint
  static const secondary100 = Color(0xFFFCE7F3);    // Very light
  static const secondary200 = Color(0xFFFBCFE8);    // Light
  static const secondary300 = Color(0xFFF9A8D4);    // Medium light
  static const secondary400 = Color(0xFFF472B6);    // Medium
  static const secondary500 = Color(0xFFEC4899);    // Base secondary
  static const secondary600 = Color(0xFFDB2777);    // Medium dark
  static const secondary700 = Color(0xFFBE185D);    // Dark
  static const secondary800 = Color(0xFF9D174D);    // Very dark
  static const secondary900 = Color(0xFF831843);    // Darkest shade
  
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFFFD6E7);
  static const onSecondaryContainer = Color(0xFF31111D);
  
  // Tertiary Colors - Purple-based palette
  static const tertiary = Color(0xFF7C3AED);        // Tertiary 500
  static const tertiary50 = Color(0xFFF5F3FF);      // Lightest tint
  static const tertiary100 = Color(0xFFEDE9FE);     // Very light
  static const tertiary200 = Color(0xFFDDD6FE);     // Light
  static const tertiary300 = Color(0xFFC4B5FD);     // Medium light
  static const tertiary400 = Color(0xFFA78BFA);     // Medium
  static const tertiary500 = Color(0xFF7C3AED);     // Base tertiary
  static const tertiary600 = Color(0xFF7C2D12);     // Medium dark
  static const tertiary700 = Color(0xFF6D28D9);     // Dark
  static const tertiary800 = Color(0xFF5B21B6);     // Very dark
  static const tertiary900 = Color(0xFF4C1D95);     // Darkest shade
  
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFEDE9FE);
  static const onTertiaryContainer = Color(0xFF2D1B69);
  
  // Neutral Colors - Gray-based palette
  static const neutral50 = Color(0xFFFAFAFA);       // Lightest gray
  static const neutral100 = Color(0xFFF5F5F5);      // Very light gray
  static const neutral200 = Color(0xFFEEEEEE);      // Light gray
  static const neutral300 = Color(0xFFE0E0E0);      // Medium light gray
  static const neutral400 = Color(0xFFBDBDBD);      // Medium gray
  static const neutral500 = Color(0xFF9E9E9E);      // Base neutral
  static const neutral600 = Color(0xFF757575);      // Medium dark gray
  static const neutral700 = Color(0xFF616161);      // Dark gray
  static const neutral800 = Color(0xFF424242);      // Very dark gray
  static const neutral900 = Color(0xFF212121);      // Darkest gray
  
  // Neutral Variant Colors - Warm gray palette
  static const neutralVariant50 = Color(0xFFFAF9F7);
  static const neutralVariant100 = Color(0xFFF5F4F2);
  static const neutralVariant200 = Color(0xFFE8E6E1);
  static const neutralVariant300 = Color(0xFFD3CFC4);
  static const neutralVariant400 = Color(0xFFB8B5A7);
  static const neutralVariant500 = Color(0xFF9C9A8B);
  static const neutralVariant600 = Color(0xFF807F70);
  static const neutralVariant700 = Color(0xFF656556);
  static const neutralVariant800 = Color(0xFF4C4B3D);
  static const neutralVariant900 = Color(0xFF343225);
  
  // Semantic Colors
  static const success = Color(0xFF10B981);
  static const onSuccess = Color(0xFFFFFFFF);
  static const successContainer = Color(0xFFD1FAE5);
  static const onSuccessContainer = Color(0xFF064E3B);
  
  static const warning = Color(0xFFF59E0B);
  static const onWarning = Color(0xFFFFFFFF);
  static const warningContainer = Color(0xFFFEF3C7);
  static const onWarningContainer = Color(0xFF92400E);
  
  static const error = Color(0xFFEF4444);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFEE2E2);
  static const onErrorContainer = Color(0xFF991B1B);
  
  // Surface Colors - Light Theme
  static const surfaceLight = Color(0xFFFFFBFE);
  static const onSurfaceLight = Color(0xFF1C1B1F);
  static const surfaceVariantLight = Color(0xFFE7E0EC);
  static const onSurfaceVariantLight = Color(0xFF49454F);
  static const backgroundLight = Color(0xFFFFFBFE);
  static const onBackgroundLight = Color(0xFF1C1B1F);
  
  // Surface Colors - Dark Theme
  static const surfaceDark = Color(0xFF1C1B1F);
  static const onSurfaceDark = Color(0xFFE6E1E5);
  static const surfaceVariantDark = Color(0xFF49454F);
  static const onSurfaceVariantDark = Color(0xFFCAC4D0);
  static const backgroundDark = Color(0xFF1C1B1F);
  static const onBackgroundDark = Color(0xFFE6E1E5);
  
  // Outline Colors
  static const outline = Color(0xFF79747E);
  static const outlineVariant = Color(0xFFCAC4D0);
  
  // Legacy colors for backward compatibility
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  
  // Gradient Colors
  static const gradientStart = Color(0xFF6366F1);
  static const gradientEnd = Color(0xFF8B5CF6);
  
  // Shadow Colors
  static const shadowLight = Color(0x1A000000);
  static const shadowMedium = Color(0x33000000);
  static const shadowDark = Color(0x4D000000);
  
  // Interactive States
  static const hoverOverlay = Color(0x0F000000);
  static const pressedOverlay = Color(0x1F000000);
  static const focusOverlay = Color(0x1F6366F1);
  static const selectedOverlay = Color(0x1F6366F1);
  
  // Brand Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFFFFFBFE), Color(0xFFF8F9FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
} 