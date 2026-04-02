import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';

/// Icon button variants
enum AppIconButtonVariant { filled, outlined, ghost }

/// Icon button sizes
enum AppIconButtonSize { sm, md, lg }

/// Reusable icon button component
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final AppIconButtonSize size;
  final Color? color;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = AppIconButtonVariant.ghost,
    this.size = AppIconButtonSize.md,
    this.color,
    this.tooltip,
  });

  double get _size {
    switch (size) {
      case AppIconButtonSize.sm:
        return 32;
      case AppIconButtonSize.md:
        return 40;
      case AppIconButtonSize.lg:
        return 48;
    }
  }

  double get _iconSize {
    switch (size) {
      case AppIconButtonSize.sm:
        return 16;
      case AppIconButtonSize.md:
        return 20;
      case AppIconButtonSize.lg:
        return 24;
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (variant) {
      case AppIconButtonVariant.filled:
        return color ?? Theme.of(context).colorScheme.primary;
      case AppIconButtonVariant.outlined:
      case AppIconButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (variant) {
      case AppIconButtonVariant.filled:
        return Theme.of(context).colorScheme.onPrimary;
      case AppIconButtonVariant.outlined:
      case AppIconButtonVariant.ghost:
        return color ?? Theme.of(context).colorScheme.onSurface;
    }
  }

  BorderSide _getBorderSide(BuildContext context) {
    switch (variant) {
      case AppIconButtonVariant.outlined:
        return BorderSide(
          color: color ?? Theme.of(context).dividerColor,
          width: 1,
        );
      default:
        return BorderSide.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget button = Material(
      color: _getBackgroundColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMd,
        side: _getBorderSide(context),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.radiusMd,
        child: SizedBox(
          width: _size,
          height: _size,
          child: Icon(
            icon,
            size: _iconSize,
            color: onPressed == null
                ? _getIconColor(context).withValues(alpha: 0.5)
                : _getIconColor(context),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
