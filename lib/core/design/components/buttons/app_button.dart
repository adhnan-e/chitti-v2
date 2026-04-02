import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';

/// Button variants
enum AppButtonVariant {
  primary,
  secondary,
  ghost,
  danger,
}

/// Button sizes
enum AppButtonSize {
  sm,
  md,
  lg,
}

/// Reusable button component with consistent styling
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool fullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.fullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  /// Primary button constructor
  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.fullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
  }) : variant = AppButtonVariant.primary;

  /// Secondary button constructor
  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.fullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
  }) : variant = AppButtonVariant.secondary;

  /// Ghost button constructor
  const AppButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.fullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
  }) : variant = AppButtonVariant.ghost;

  /// Danger button constructor
  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.fullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
  }) : variant = AppButtonVariant.danger;

  EdgeInsets get _padding {
    switch (size) {
      case AppButtonSize.sm:
        return Spacing.buttonPaddingSmall;
      case AppButtonSize.md:
        return Spacing.buttonPaddingMedium;
      case AppButtonSize.lg:
        return Spacing.buttonPaddingLarge;
    }
  }

  double get _fontSize {
    switch (size) {
      case AppButtonSize.sm:
        return 12;
      case AppButtonSize.md:
        return 14;
      case AppButtonSize.lg:
        return 16;
    }
  }

  double get _iconSize {
    switch (size) {
      case AppButtonSize.sm:
        return 16;
      case AppButtonSize.md:
        return 18;
      case AppButtonSize.lg:
        return 20;
    }
  }

  Color get _backgroundColor {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.primary;
      case AppButtonVariant.secondary:
        return Colors.transparent;
      case AppButtonVariant.ghost:
        return Colors.transparent;
      case AppButtonVariant.danger:
        return AppColors.error;
    }
  }

  Color get _foregroundColor {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.textInverse;
      case AppButtonVariant.secondary:
        return AppColors.primary;
      case AppButtonVariant.ghost:
        return AppColors.textSecondary;
      case AppButtonVariant.danger:
        return AppColors.textPrimary;
    }
  }

  BorderSide? get _borderSide {
    switch (variant) {
      case AppButtonVariant.secondary:
        return const BorderSide(color: AppColors.primary, width: 1.5);
      case AppButtonVariant.ghost:
        return const BorderSide(color: AppColors.border, width: 1);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    final buttonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _backgroundColor.withOpacity(0.5);
        }
        return _backgroundColor;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _foregroundColor.withOpacity(0.5);
        }
        return _foregroundColor;
      }),
      padding: WidgetStateProperty.all(_padding),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: AppRadius.button,
          side: _borderSide ?? BorderSide.none,
        ),
      ),
      elevation: WidgetStateProperty.all(0),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return _foregroundColor.withOpacity(0.1);
        }
        return null;
      }),
    );

    Widget child;
    if (isLoading) {
      child = SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
        ),
      );
    } else {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: _iconSize),
            const HSpace.sm(),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (trailingIcon != null) ...[
            const HSpace.sm(),
            Icon(trailingIcon, size: _iconSize),
          ],
        ],
      );
    }

    final button = TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: buttonStyle,
      child: child,
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
