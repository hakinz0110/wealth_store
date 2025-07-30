class AppSpacing {
  // Base spacing unit (4dp grid system - Material Design 3)
  static const double unit = 4.0;
  
  // Spacing Scale - Comprehensive token system
  static const double none = 0.0;     // 0 units
  static const double xs = 4.0;       // 1 unit
  static const double sm = 8.0;       // 2 units
  static const double md = 12.0;      // 3 units
  static const double lg = 16.0;      // 4 units
  static const double xl = 20.0;      // 5 units
  static const double xxl = 24.0;     // 6 units
  static const double xxxl = 32.0;    // 8 units
  static const double huge = 40.0;    // 10 units
  static const double massive = 48.0; // 12 units
  static const double giant = 64.0;   // 16 units
  static const double colossal = 80.0; // 20 units
  static const double enormous = 96.0; // 24 units
  
  // Micro spacing for fine-tuned layouts
  static const double micro = 2.0;    // 0.5 units
  static const double tiny = 6.0;     // 1.5 units
  static const double compact = 10.0; // 2.5 units
  static const double relaxed = 14.0; // 3.5 units
  static const double loose = 18.0;   // 4.5 units
  
  // Semantic spacing names
  static const double small = sm;
  static const double medium = lg;
  static const double large = xxl;
  static const double extraLarge = huge;
  
  // Component-specific spacing
  static const double cardPadding = lg;
  static const double screenPadding = lg;
  static const double sectionSpacing = xxl;
  static const double listItemSpacing = md;
  static const double buttonPadding = md;
  static const double inputPadding = lg;
  
  // Layout spacing
  static const double headerHeight = 56.0;
  static const double bottomNavHeight = 80.0;
  static const double fabMargin = lg;
  static const double dialogMargin = xxl;
  
  // Touch targets (minimum 44dp for accessibility)
  static const double minTouchTarget = 44.0;
  static const double recommendedTouchTarget = 48.0;
  
  // Border radius values
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusRound = 999.0; // For pill-shaped elements
  
  // Elevation values
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation3 = 3.0;
  static const double elevation4 = 4.0;
  static const double elevation6 = 6.0;
  static const double elevation8 = 8.0;
  static const double elevation12 = 12.0;
  static const double elevation16 = 16.0;
  static const double elevation24 = 24.0;
} 