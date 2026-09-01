import 'package:flutter/material.dart';
enum appColors{
  primaryColor,
  accentColor,
  appBGColor,
  cardColor,
  expenseColor,
  incomeColor,
  textPrimaryColor,
  textSecondaryColor,
}

class AppColors {

  static const Map<appColors, Color> lightTheme = {
    appColors.primaryColor       : Color(0xFF4F46E5),          // Modern Vibrant Indigo
    appColors.accentColor        : Color(0xFFF59E0B),          // Luminous Amber Gold
    appColors.appBGColor         : Color(0xFFF8FAFC),          // Clean Porcelain Slate
    appColors.cardColor          : Color(0xFFFFFFFF),          // Pure Crisp White
    appColors.expenseColor       : Color(0xFFF43F5E),          // Coral Rose
    appColors.incomeColor        : Color(0xFF10B981),          // Emerald Mint
    appColors.textPrimaryColor   : Color(0xFF0F172A),          // Deep Slate
    appColors.textSecondaryColor : Color(0xFF64748B),          // Cool Slate Grey
  };

  static const Map<appColors, Color> darkTheme = {
    appColors.primaryColor       : Color(0xFF6366F1),          // Electric Indigo
    appColors.accentColor        : Color(0xFFFBBF24),          // Warm Gold
    appColors.appBGColor         : Color(0xFF090D16),          // Deep Obsidian
    appColors.cardColor          : Color(0xFF131B2E),          // Elevated Slate Glass
    appColors.expenseColor       : Color(0xFFFB7185),          // Neon Coral Rose
    appColors.incomeColor        : Color(0xFF34D399),          // Bright Mint
    appColors.textPrimaryColor   : Color(0xFFF8FAFC),          // Porcelain White
    appColors.textSecondaryColor : Color(0xFF94A3B8),          // Muted Silver
  };

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}