/// Premium header component with gradient background
///
/// A reusable header component used across multiple screens
/// with consistent styling and layout.
library;

import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';

/// Premium header with gradient background and consistent styling
class PremiumHeader extends StatelessWidget {
  /// Main title text
  final String title;

  /// Optional subtitle text (displayed below title)
  final String? subtitle;

  /// Optional stats or additional info (displayed in a row)
  final List<Widget>? stats;

  /// Optional action widgets (e.g., buttons, icons)
  final List<Widget>? actions;

  /// Optional leading widget (e.g., back button, menu)
  final Widget? leading;

  /// Custom padding (defaults to standard header padding)
  final EdgeInsetsGeometry? padding;

  /// Gradient colors (defaults to teal-green gradient)
  final List<Color>? gradientColors;

  /// Whether to show safe area padding at top
  final bool includeSafeArea;

  /// Minimum height for the header
  final double? minHeight;

  const PremiumHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.stats,
    this.actions,
    this.leading,
    this.padding,
    this.gradientColors,
    this.includeSafeArea = true,
    this.minHeight,
  });

  /// Create a premium header with just a title
  const PremiumHeader.simple({
    super.key,
    required this.title,
    this.includeSafeArea = true,
  })  : subtitle = null,
        stats = null,
        actions = null,
        leading = null,
        padding = null,
        gradientColors = null,
        minHeight = null;

  @override
  Widget build(BuildContext context) {
    final defaultGradient = gradientColors ?? [
      const Color(0xFF0D9488),
      const Color(0xFF0F766E),
      const Color(0xFF10B981),
    ];

    return Container(
      constraints: minHeight != null ? BoxConstraints(minHeight: minHeight!) : null,
      padding: padding ??
          EdgeInsets.only(
            top: includeSafeArea ? MediaQuery.of(context).padding.top + 20 : 20,
            bottom: 24,
            left: 24,
            right: 24,
          ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: defaultGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Leading + Title + Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (leading != null) ...[
                leading!,
                const HSpace.md(),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const VSpace.xs(),
                      Text(
                        subtitle!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actions != null && actions!.isNotEmpty) ...[
                const HSpace.sm(),
                ...actions!,
              ],
            ],
          ),

          // Stats row (if provided)
          if (stats != null && stats!.isNotEmpty) ...[
            const VSpace.lg(),
            Row(
              children: stats!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Stat item for displaying metrics in the header
class HeaderStat extends StatelessWidget {
  /// The value to display (e.g., "12")
  final String value;

  /// The label for the stat (e.g., "Active")
  final String label;

  /// Optional icon to display before the value
  final IconData? icon;

  /// Whether to use a compact layout
  final bool compact;

  const HeaderStat({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.white.withOpacity(0.8)),
            const HSpace.xs(),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: AppRadius.radiusMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: Colors.white.withOpacity(0.9)),
              const VSpace.xs(),
            ],
            Text(
              value,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Divider for header stats
class HeaderStatDivider extends StatelessWidget {
  const HeaderStatDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: Spacing.md),
    );
  }
}
