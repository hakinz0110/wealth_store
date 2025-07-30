import 'package:flutter/material.dart';

class AppTextStyles {
  // Font Family - Inter with proper weights
  static const String fontFamily = 'Inter';
  
  // Font Weight Constants
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;
  
  // Material Design 3 Type Scale
  
  // Display Styles - Large, prominent text
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    height: 1.12,
    letterSpacing: -0.25,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    height: 1.16,
    letterSpacing: 0,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    height: 1.22,
    letterSpacing: 0,
  );
  
  // Headline Styles - High-emphasis text
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    height: 1.25,
    letterSpacing: 0,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    height: 1.29,
    letterSpacing: 0,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    height: 1.33,
    letterSpacing: 0,
  );
  
  // Title Styles - Medium-emphasis text
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    height: 1.27,
    letterSpacing: 0,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    height: 1.50,
    letterSpacing: 0.15,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    height: 1.43,
    letterSpacing: 0.1,
  );
  
  // Label Styles - Call-to-action text
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    height: 1.43,
    letterSpacing: 0.1,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    height: 1.33,
    letterSpacing: 0.5,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    height: 1.45,
    letterSpacing: 0.5,
  );
  
  // Body Styles - Plain text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    height: 1.50,
    letterSpacing: 0.15,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    height: 1.43,
    letterSpacing: 0.25,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    height: 1.33,
    letterSpacing: 0.4,
  );
  
  // Legacy styles for backward compatibility
  static const TextStyle h1 = headlineLarge;
  static const TextStyle h2 = headlineMedium;
  static const TextStyle h3 = headlineSmall;
  static const TextStyle body1 = bodyLarge;
  static const TextStyle body2 = bodyMedium;
  static const TextStyle caption = labelSmall;
  
  // Specialized styles for eCommerce with enhanced emphasis
  
  // Price styles with proper emphasis treatment
  static const TextStyle priceLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
    height: 1.20,
    letterSpacing: -0.25,
  );
  
  static const TextStyle priceMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
    height: 1.22,
    letterSpacing: 0,
  );
  
  static const TextStyle priceSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    height: 1.25,
    letterSpacing: 0,
  );
  
  static const TextStyle discountPrice = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    height: 1.43,
    letterSpacing: 0.1,
    decoration: TextDecoration.lineThrough,
  );
  
  // Button text styles with proper emphasis
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    height: 1.25,
    letterSpacing: 0.1,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    height: 1.43,
    letterSpacing: 0.1,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    height: 1.33,
    letterSpacing: 0.5,
  );
  
  // Product-specific styles with clear hierarchy
  static const TextStyle productTitleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    height: 1.30,
    letterSpacing: 0,
  );
  
  static const TextStyle productTitleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    height: 1.50,
    letterSpacing: 0.15,
  );
  
  static const TextStyle productDescription = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    height: 1.57, // Improved line height for readability
    letterSpacing: 0.25,
  );
  
  // Status and badge styles
  static const TextStyle statusSuccess = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    height: 1.33,
    letterSpacing: 0.5,
  );
  
  static const TextStyle statusWarning = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    height: 1.33,
    letterSpacing: 0.5,
  );
  
  static const TextStyle statusError = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    height: 1.33,
    letterSpacing: 0.5,
  );
  
  // Legacy styles for backward compatibility
  static const TextStyle priceText = priceMedium;
  static const TextStyle discountText = discountPrice;
  static const TextStyle buttonText = buttonMedium;
  static const TextStyle productTitle = productTitleMedium;
} 