import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// Custom theme extension for app-specific colors
/// Usage: Theme.of(context).extension<AppColorsExtension>()!
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color borderLight;
  final Color textMuted;
  final Color success;
  final Color successLight;
  final Color warning;
  final Color warningLight;
  final Color error;
  final Color errorLight;
  final Color info;
  final Color infoLight;

  const AppColorsExtension({
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.borderLight,
    required this.textMuted,
    required this.success,
    required this.successLight,
    required this.warning,
    required this.warningLight,
    required this.error,
    required this.errorLight,
    required this.info,
    required this.infoLight,
  });

  /// Dark theme colors
  static const dark = AppColorsExtension(
    surface: AppColors.surface,
    surfaceElevated: AppColors.surfaceElevated,
    border: AppColors.border,
    borderLight: AppColors.borderLight,
    textMuted: AppColors.textMuted,
    success: AppColors.success,
    successLight: AppColors.successLight,
    warning: AppColors.warning,
    warningLight: AppColors.warningLight,
    error: AppColors.error,
    errorLight: AppColors.errorLight,
    info: AppColors.info,
    infoLight: AppColors.infoLight,
  );

  /// Light theme colors (for future use)
  static const light = AppColorsExtension(
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF6F8FA),
    border: Color(0xFFD0D7DE),
    borderLight: Color(0xFFE1E4E8),
    textMuted: Color(0xFF6E7781),
    success: Color(0xFF1A7F37),
    successLight: Color(0xFF2DA44E),
    warning: Color(0xFF9A6700),
    warningLight: Color(0xFFBF8700),
    error: Color(0xFFCF222E),
    errorLight: Color(0xFFF85149),
    info: Color(0xFF0969DA),
    infoLight: Color(0xFF218BFF),
  );

  @override
  AppColorsExtension copyWith({
    Color? surface,
    Color? surfaceElevated,
    Color? border,
    Color? borderLight,
    Color? textMuted,
    Color? success,
    Color? successLight,
    Color? warning,
    Color? warningLight,
    Color? error,
    Color? errorLight,
    Color? info,
    Color? infoLight,
  }) {
    return AppColorsExtension(
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      successLight: successLight ?? this.successLight,
      warning: warning ?? this.warning,
      warningLight: warningLight ?? this.warningLight,
      error: error ?? this.error,
      errorLight: errorLight ?? this.errorLight,
      info: info ?? this.info,
      infoLight: infoLight ?? this.infoLight,
    );
  }

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningLight: Color.lerp(warningLight, other.warningLight, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorLight: Color.lerp(errorLight, other.errorLight, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoLight: Color.lerp(infoLight, other.infoLight, t)!,
    );
  }
}

/// Extension method to easily access app colors from context
extension AppColorsContext on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}
