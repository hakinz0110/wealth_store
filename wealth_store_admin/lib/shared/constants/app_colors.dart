import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (matching the UI design)
  static const Color primaryBlue = Color(0xFF4F46E5);
  static const Color primaryBlueDark = Color(0xFF3730A3);
  static const Color primaryBlueLight = Color(0xFF6366F1);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color sidebarBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Additional color aliases for storage widgets
  static const Color errorRed = error;
  static const Color successGreen = success;
  static const Color warningOrange = warning;
  static const Color backgroundDark = Color(0xFF1F2937);
  
  // Chart Colors (for dashboard)
  static const Color chartBlue = Color(0xFF3B82F6);
  static const Color chartOrange = Color(0xFFF97316);
  static const Color chartGreen = Color(0xFF10B981);
  static const Color chartRed = Color(0xFFEF4444);
  static const Color chartPurple = Color(0xFF8B5CF6);
  
  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color border = Color(0xFFE5E7EB); // Alias for borderLight
  
  // Primary alias (for backward compatibility)
  static const Color primary = primaryBlue;
  
  // Hover and Focus States
  static const Color hoverLight = Color(0xFFF3F4F6);
  static const Color focusRing = Color(0xFF93C5FD);
  
  // Order Status Colors
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusProcessing = Color(0xFF3B82F6);
  static const Color statusShipped = Color(0xFF8B5CF6);
  static const Color statusDelivered = Color(0xFF10B981);
  static const Color statusCancelled = Color(0xFFEF4444);
}