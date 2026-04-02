import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';

/// Reusable list tile component
class AppListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final bool showDivider;

  const AppListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: padding ?? Spacing.listItemPadding,
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const HSpace.lg(),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.titleMedium,
                        ),
                        if (subtitle != null) ...[
                          const VSpace.xs(),
                          Text(
                            subtitle!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const HSpace.md(),
                    trailing!,
                  ] else if (onTap != null)
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: Spacing.lg,
            endIndent: Spacing.lg,
          ),
      ],
    );
  }
}

/// Icon container for list tile leading
class AppListTileIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final Color? backgroundColor;

  const AppListTileIcon({
    super.key,
    required this.icon,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    final effectiveBgColor =
        backgroundColor ?? effectiveColor.withOpacity(0.15);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: AppRadius.radiusMd,
      ),
      child: Icon(
        icon,
        size: 20,
        color: effectiveColor,
      ),
    );
  }
}
