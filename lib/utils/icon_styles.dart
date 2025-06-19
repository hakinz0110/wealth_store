import 'package:flutter/material.dart';

/// Modern icon styles utility class
/// This provides consistent styling for icons and buttons throughout the app
class ModernIconStyles {
  /// Creates a modern gradient icon with a container
  static Widget gradientIcon({
    required IconData icon,
    required BuildContext context,
    double size = 24.0,
    List<Color>? gradientColors,
    bool isDark = false,
  }) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // Default gradient colors based on theme
    final defaultGradient = isDarkMode
        ? [theme.primaryColor.withOpacity(0.7), theme.primaryColor]
        : [theme.primaryColor.withOpacity(0.7), theme.primaryColor];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? defaultGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (gradientColors ?? defaultGradient)[1].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size),
    );
  }

  /// Creates a modern outlined icon with container
  static Widget outlinedIcon({
    required IconData icon,
    required BuildContext context,
    Color? iconColor,
    double size = 24.0,
    Color? borderColor,
    Color? backgroundColor,
  }) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    final defaultIconColor =
        iconColor ?? (isDarkMode ? Colors.white : theme.primaryColor);
    final defaultBorderColor =
        borderColor ??
        (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300);
    final defaultBackgroundColor =
        backgroundColor ??
        (isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.white);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: defaultBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: defaultBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: defaultIconColor, size: size),
    );
  }

  /// Creates a modern floating action button style
  static Widget floatingActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required BuildContext context,
    List<Color>? gradientColors,
    double iconSize = 24.0,
  }) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    final defaultGradient = isDarkMode
        ? [theme.primaryColor.withOpacity(0.7), theme.primaryColor]
        : [theme.primaryColor.withOpacity(0.7), theme.primaryColor];

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors ?? defaultGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (gradientColors ?? defaultGradient)[1].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }

  /// Creates a modern circular button
  static Widget circularButton({
    required IconData icon,
    required VoidCallback onPressed,
    required BuildContext context,
    double size = 40.0,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    final defaultBackgroundColor =
        backgroundColor ?? (isDarkMode ? Colors.grey.shade800 : Colors.white);
    final defaultIconColor = iconColor ?? theme.primaryColor;

    return Material(
      color: defaultBackgroundColor,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: Center(
            child: Icon(icon, color: defaultIconColor, size: size * 0.5),
          ),
        ),
      ),
    );
  }

  /// Creates a modern quantity control for cart items
  static Widget quantityControl({
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required int quantity,
    required BuildContext context,
  }) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            onTap: onDecrement,
            context: context,
            disabled: quantity <= 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              quantity.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onTap: onIncrement,
            context: context,
          ),
        ],
      ),
    );
  }

  // Helper method for quantity control buttons
  static Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required BuildContext context,
    bool disabled = false,
  }) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: disabled ? Colors.grey.withOpacity(0.2) : theme.primaryColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 16,
            color: disabled ? Colors.grey : Colors.white,
          ),
        ),
      ),
    );
  }
}
