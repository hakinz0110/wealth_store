import 'package:flutter/material.dart';

class AppShadows {
  // Material Design 3 Enhanced Shadow System
  // Based on elevation tokens with improved depth perception
  
  // Shadow Color Tokens
  static const Color _shadowColor = Color(0x1A000000);      // 10% black
  static const Color _shadowColorMedium = Color(0x33000000); // 20% black
  static const Color _shadowColorDark = Color(0x4D000000);   // 30% black
  static const Color _shadowColorLight = Color(0x0D000000);  // 5% black
  
  // Elevation Level 0 - No shadow
  static const List<BoxShadow> none = [];
  
  // Elevation Level 1 - Subtle shadow for cards
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      color: _shadowColorLight,
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 1),
      blurRadius: 1,
      spreadRadius: 0,
    ),
  ];
  
  // Elevation Level 2 - Standard card shadow
  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColorLight,
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];
  
  // Elevation Level 3 - Raised elements
  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 1),
      blurRadius: 5,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColorLight,
      offset: Offset(0, 3),
      blurRadius: 9,
      spreadRadius: 0,
    ),
  ];
  
  // Elevation Level 4 - Floating action buttons
  static const List<BoxShadow> elevation4 = [
    BoxShadow(
      color: _shadowColorMedium,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
  
  // Elevation Level 5 - Cards on hover
  static const List<BoxShadow> elevation5 = [
    BoxShadow(
      color: _shadowColorMedium,
      offset: Offset(0, 3),
      blurRadius: 5,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 5),
      blurRadius: 14,
      spreadRadius: 0,
    ),
  ];
  
  // Elevation Level 6 - Snackbars
  static const List<BoxShadow> elevation6 = [
    BoxShadow(
      color: _shadowColorMedium,
      offset: Offset(0, 3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 6),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
  
  // Elevation Level 8 - Drawers, modal bottom sheets
  static const List<BoxShadow> elevation8 = [
    BoxShadow(
      color: _shadowColorMedium,
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 8),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];
  
  // Elevation Level 12 - App bars
  static const List<BoxShadow> elevation12 = [
    BoxShadow(
      color: _shadowColorMedium,
      offset: Offset(0, 6),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 12),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
  
  // Elevation Level 16 - Navigation drawers
  static const List<BoxShadow> elevation16 = [
    BoxShadow(
      color: _shadowColorMedium,
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 16),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];
  
  // Elevation Level 24 - Dialogs, pickers
  static const List<BoxShadow> elevation24 = [
    BoxShadow(
      color: _shadowColorDark,
      offset: Offset(0, 12),
      blurRadius: 24,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColorMedium,
      offset: Offset(0, 24),
      blurRadius: 48,
      spreadRadius: 0,
    ),
  ];
  
  // Specialized shadows for specific components
  
  // Product card shadow - Enhanced for modern cards
  static const List<BoxShadow> productCard = [
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColorLight,
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  // Product card hover shadow - For interactive states
  static const List<BoxShadow> productCardHover = [
    BoxShadow(
      color: _shadowColorMedium,
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
  
  // Button shadow - Modern button elevation
  static const List<BoxShadow> button = [
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];
  
  // Button pressed shadow - Reduced elevation when pressed
  static const List<BoxShadow> buttonPressed = [
    BoxShadow(
      color: _shadowColorMedium,
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];
  
  // Input field shadow - Subtle depth for form fields
  static const List<BoxShadow> input = [
    BoxShadow(
      color: _shadowColorLight,
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  // Input field focused shadow - Enhanced focus state
  static const List<BoxShadow> inputFocused = [
    BoxShadow(
      color: Color(0x1F6366F1), // Primary color with opacity
      offset: Offset(0, 0),
      blurRadius: 4,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  // Bottom navigation shadow - Floating navigation bar
  static const List<BoxShadow> bottomNavigation = [
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, -1),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColorLight,
      offset: Offset(0, -2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
  
  // App bar shadow - Elevated header
  static const List<BoxShadow> appBar = [
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 1),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
  
  // Frosted glass effect shadow - For modern glass morphism
  static const List<BoxShadow> frostedGlass = [
    BoxShadow(
      color: _shadowColorLight,
      offset: Offset(0, 8),
      blurRadius: 32,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  // Helper method to get shadow by elevation level
  static List<BoxShadow> getElevationShadow(double elevation) {
    switch (elevation.toInt()) {
      case 0:
        return none;
      case 1:
        return elevation1;
      case 2:
        return elevation2;
      case 3:
        return elevation3;
      case 4:
        return elevation4;
      case 5:
        return elevation5;
      case 6:
        return elevation6;
      case 8:
        return elevation8;
      case 12:
        return elevation12;
      case 16:
        return elevation16;
      case 24:
        return elevation24;
      default:
        return elevation2; // Default to level 2
    }
  }
}