import 'package:flutter/material.dart';

/// Design token colors for Chitti Manager
/// Supports both Dark (Fintech) and Light themes
abstract class AppColors {
  // ============================================
  // DARK THEME COLORS (Primary Fintech Theme)
  // ============================================

  // Primary colors
  static const Color primary = Color(0xFF13EC5B);
  static const Color primaryDark = Color(0xFF0BBF47);
  static const Color primaryLight = Color(0xFF1FFF6B);

  // Background colors (Dark)
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceElevated = Color(0xFF21262D);

  // Border colors (Dark)
  static const Color border = Color(0xFF30363D);
  static const Color borderLight = Color(0xFF3D444D);

  // Text colors (Dark)
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF6E7681);
  static const Color textInverse = Color(0xFF0D1117);

  // Semantic colors
  static const Color success = Color(0xFF3FB950);
  static const Color successLight = Color(0xFF2EA043);
  static const Color warning = Color(0xFFD29922);
  static const Color warningLight = Color(0xFFE3B341);
  static const Color error = Color(0xFFF85149);
  static const Color errorLight = Color(0xFFDA3633);
  static const Color info = Color(0xFF58A6FF);
  static const Color infoLight = Color(0xFF388BFD);

  // Overlay colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Shimmer colors (Dark)
  static const Color shimmerBase = Color(0xFF21262D);
  static const Color shimmerHighlight = Color(0xFF30363D);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surface, background],
  );

  // ============================================
  // LIGHT THEME COLORS
  // ============================================

  // Background colors (Light)
  static const Color backgroundLight = Color(0xFFF6F8FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF6F8FA);

  // Border colors (Light)
  static const Color borderLightTheme = Color(0xFFD0D7DE);
  static const Color borderLightThemeLight = Color(0xFFE1E4E8);

  // Text colors (Light)
  static const Color textPrimaryLight = Color(0xFF1F2328);
  static const Color textSecondaryLight = Color(0xFF656D76);
  static const Color textMutedLight = Color(0xFF8C959F);
  static const Color textInverseLight = Color(0xFFFFFFFF);

  // Semantic colors (Light - slightly adjusted for better contrast)
  static const Color successLightTheme = Color(0xFF1A7F37);
  static const Color warningLightTheme = Color(0xFF9A6700);
  static const Color errorLightTheme = Color(0xFFCF222E);
  static const Color infoLightTheme = Color(0xFF0969DA);

  // Shimmer colors (Light)
  static const Color shimmerBaseLight = Color(0xFFE1E4E8);
  static const Color shimmerHighlightLight = Color(0xFFF6F8FA);

  // Gradients (Light)
  static const LinearGradient primaryGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF10C94E)],
  );

  static const LinearGradient surfaceGradientLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surfaceLight, backgroundLight],
  );
}
