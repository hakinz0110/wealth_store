import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Primary brand color
  static const Color primaryColor = Color(
    0xFF4B69FF,
  ); // Blue color from the profile screenshot
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color accentColor = Color(
    0xFFAB8DF2,
  ); // Purple accent for dark mode
  static const Color errorColor = Color(0xFFB00020);

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData getTheme() {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  // Light theme
  final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      shadowColor: Colors.black.withAlpha(13),
    ),
    cardColor: Colors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey.shade600,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontWeight: FontWeight.w600),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
      space: 24,
    ),
  );

  // Dark theme - elegant dark theme similar to admin app
  final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212), // Deep dark background
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Color(0xFF1A1A1A), // Slightly lighter than background
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardColor: const Color(0xFF1E1E1E), // Slightly lighter than background
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        side: const BorderSide(color: accentColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A1A1A),
      selectedItemColor: accentColor, // Use accent color for selection
      unselectedItemColor: Colors.grey,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontWeight: FontWeight.w600),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A2A2A),
      thickness: 1,
      space: 24,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return accentColor;
        }
        return Colors.grey;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return accentColor.withOpacity(0.5);
        }
        return Colors.grey.withOpacity(0.5);
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return accentColor;
        }
        return Colors.grey;
      }),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return accentColor;
        }
        return Colors.grey;
      }),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF2A2A2A),
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(color: Colors.white70),
    ),
  );
}
