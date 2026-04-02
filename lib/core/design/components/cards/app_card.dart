import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';

/// Card elevation levels
enum AppCardElevation { flat, raised, elevated }

/// Reusable card component with consistent styling
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final AppCardElevation elevation;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool showBorder;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation = AppCardElevation.flat,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.showBorder = true,
  });

  /// Flat card (no shadow)
  const AppCard.flat({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.showBorder = true,
  }) : elevation = AppCardElevation.flat;

  /// Raised card (subtle shadow)
  const AppCard.raised({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.showBorder = true,
  }) : elevation = AppCardElevation.raised;

  /// Elevated card (prominent shadow)
  const AppCard.elevated({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.showBorder = false,
  }) : elevation = AppCardElevation.elevated;

  List<BoxShadow> get _shadows {
    switch (elevation) {
      case AppCardElevation.flat:
        return AppShadows.none;
      case AppCardElevation.raised:
        return AppShadows.md;
      case AppCardElevation.elevated:
        return AppShadows.lg;
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    if (backgroundColor != null) return backgroundColor!;

    switch (elevation) {
      case AppCardElevation.flat:
      case AppCardElevation.raised:
        return Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface;
      case AppCardElevation.elevated:
        return Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surfaceContainerHigh;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? AppRadius.card;

    Widget content = Container(
      padding: padding ?? Spacing.cardPadding,
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: effectiveBorderRadius,
        border: showBorder
            ? Border.all(color: Theme.of(context).dividerColor, width: 1)
            : null,
        boxShadow: _shadows,
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          child: content,
        ),
      );
    }

    return content;
  }
}
