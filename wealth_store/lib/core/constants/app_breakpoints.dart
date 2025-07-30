class AppBreakpoints {
  // Material Design 3 breakpoint system
  static const double compact = 600;      // Mobile phones (portrait)
  static const double medium = 840;       // Tablets (portrait), large phones (landscape)
  static const double expanded = 1200;    // Tablets (landscape), desktop
  static const double large = 1600;       // Large desktop screens
  static const double extraLarge = 2400;  // Ultra-wide screens
  
  // Legacy breakpoints for backward compatibility
  static const double mobile = compact;
  static const double tablet = medium;
  static const double desktop = expanded;
  
  // Touch target sizes
  static const double minTouchTarget = 44.0;
  static const double recommendedTouchTarget = 48.0;
  static const double largeTouchTarget = 56.0;
  
  // Grid system
  static const int mobileColumns = 4;
  static const int tabletColumns = 8;
  static const int desktopColumns = 12;
  
  // Content width constraints
  static const double maxContentWidth = 1200.0;
  static const double maxReadingWidth = 720.0;
  
  // Sidebar widths
  static const double navigationRailWidth = 80.0;
  static const double navigationDrawerWidth = 280.0;
  static const double sidebarWidth = 320.0;
}

enum ScreenSize {
  compact,
  medium,
  expanded,
  large,
  extraLarge;
  
  static ScreenSize fromWidth(double width) {
    if (width < AppBreakpoints.compact) return ScreenSize.compact;
    if (width < AppBreakpoints.medium) return ScreenSize.medium;
    if (width < AppBreakpoints.expanded) return ScreenSize.expanded;
    if (width < AppBreakpoints.large) return ScreenSize.large;
    return ScreenSize.extraLarge;
  }
  
  bool get isCompact => this == ScreenSize.compact;
  bool get isMedium => this == ScreenSize.medium;
  bool get isExpanded => this == ScreenSize.expanded;
  bool get isLarge => this == ScreenSize.large;
  bool get isExtraLarge => this == ScreenSize.extraLarge;
  
  bool get isMobile => this == ScreenSize.compact;
  bool get isTablet => this == ScreenSize.medium;
  bool get isDesktop => index >= ScreenSize.expanded.index;
  
  int get columns {
    switch (this) {
      case ScreenSize.compact:
        return AppBreakpoints.mobileColumns;
      case ScreenSize.medium:
        return AppBreakpoints.tabletColumns;
      case ScreenSize.expanded:
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return AppBreakpoints.desktopColumns;
    }
  }
  
  double get touchTargetSize {
    switch (this) {
      case ScreenSize.compact:
        return AppBreakpoints.recommendedTouchTarget;
      case ScreenSize.medium:
        return AppBreakpoints.largeTouchTarget;
      case ScreenSize.expanded:
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return AppBreakpoints.largeTouchTarget;
    }
  }
}