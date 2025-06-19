import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeToggle extends StatelessWidget {
  final bool compact;
  
  const ThemeToggle({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    
    if (compact) {
      return IconButton(
        icon: Icon(
          isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: isDarkMode ? Colors.white70 : Colors.amber,
        ),
        onPressed: () => themeProvider.toggleTheme(),
        tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      );
    }
    
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => themeProvider.toggleTheme(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDarkMode 
              ? Colors.grey.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
          border: Border.all(
            color: isDarkMode ? Colors.white10 : Colors.black12,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: isDarkMode ? Colors.white70 : Colors.amber,
              size: isSmallScreen ? 16 : 20,
            ),
            const SizedBox(width: 6),
            Text(
              isDarkMode ? 'Dark' : 'Light',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 