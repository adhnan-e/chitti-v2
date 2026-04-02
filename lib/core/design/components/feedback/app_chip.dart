import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';

/// Filter chip / selectable chip component
class AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool showCheckmark;

  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.showCheckmark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withOpacity(0.15)
          : AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.chip,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.chip,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected && showCheckmark) ...[
                Icon(
                  Icons.check,
                  size: 16,
                  color: AppColors.primary,
                ),
                const HSpace.xs(),
              ] else if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                const HSpace.xs(),
              ],
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
