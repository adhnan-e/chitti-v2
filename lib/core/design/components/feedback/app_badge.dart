import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';

/// Badge variants for semantic coloring
enum AppBadgeVariant {
  primary,
  success,
  warning,
  error,
  info,
  neutral,
}

/// Status badge/chip component
class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final IconData? icon;
  final bool outlined;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
    this.icon,
    this.outlined = false,
  });

  /// Primary badge
  const AppBadge.primary({
    super.key,
    required this.label,
    this.icon,
    this.outlined = false,
  }) : variant = AppBadgeVariant.primary;

  /// Success badge
  const AppBadge.success({
    super.key,
    required this.label,
    this.icon,
    this.outlined = false,
  }) : variant = AppBadgeVariant.success;

  /// Warning badge
  const AppBadge.warning({
    super.key,
    required this.label,
    this.icon,
    this.outlined = false,
  }) : variant = AppBadgeVariant.warning;

  /// Error badge
  const AppBadge.error({
    super.key,
    required this.label,
    this.icon,
    this.outlined = false,
  }) : variant = AppBadgeVariant.error;

  /// Info badge
  const AppBadge.info({
    super.key,
    required this.label,
    this.icon,
    this.outlined = false,
  }) : variant = AppBadgeVariant.info;

  Color get _backgroundColor {
    if (outlined) return Colors.transparent;
    switch (variant) {
      case AppBadgeVariant.primary:
        return AppColors.primary.withOpacity(0.15);
      case AppBadgeVariant.success:
        return AppColors.success.withOpacity(0.15);
      case AppBadgeVariant.warning:
        return AppColors.warning.withOpacity(0.15);
      case AppBadgeVariant.error:
        return AppColors.error.withOpacity(0.15);
      case AppBadgeVariant.info:
        return AppColors.info.withOpacity(0.15);
      case AppBadgeVariant.neutral:
        return AppColors.surfaceElevated;
    }
  }

  Color get _foregroundColor {
    switch (variant) {
      case AppBadgeVariant.primary:
        return AppColors.primary;
      case AppBadgeVariant.success:
        return AppColors.success;
      case AppBadgeVariant.warning:
        return AppColors.warning;
      case AppBadgeVariant.error:
        return AppColors.error;
      case AppBadgeVariant.info:
        return AppColors.info;
      case AppBadgeVariant.neutral:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: AppRadius.chip,
        border: outlined
            ? Border.all(color: _foregroundColor, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: _foregroundColor,
            ),
            const HSpace.xs(),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: _foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
