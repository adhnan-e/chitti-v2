import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';

/// Section header with optional action
class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.titleLarge,
        ),
        if (actionLabel != null || actionIcon != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (actionLabel != null)
                  Text(
                    actionLabel!,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                if (actionIcon != null) ...[
                  if (actionLabel != null) const HSpace.xs(),
                  Icon(
                    actionIcon,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
