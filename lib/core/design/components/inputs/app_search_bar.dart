/// Search bar component with clear button
///
/// A reusable search input with consistent styling,
/// clear button, and debounced search functionality.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';

/// Search bar with clear button and optional debouncing
class AppSearchBar extends StatefulWidget {
  /// Hint text displayed when empty
  final String hintText;

  /// Callback when search text changes
  final ValueChanged<String>? onChanged;

  /// Callback when clear button is pressed (optional, defaults to clearing)
  final VoidCallback? onClear;

  /// Callback when search is submitted (Enter key)
  final ValueChanged<String>? onSubmitted;

  /// Debounce duration in milliseconds (0 = no debounce)
  final int debounceMs;

  /// Whether to show the clear button
  final bool showClearButton;

  /// Whether the search field is enabled
  final bool enabled;

  /// Focus node for the search field
  final FocusNode? focusNode;

  /// Text editing controller
  final TextEditingController? controller;

  /// Custom padding for the search field
  final EdgeInsetsGeometry? contentPadding;

  /// Background color for the search field
  final Color? fillColor;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
    this.onSubmitted,
    this.debounceMs = 300,
    this.showClearButton = true,
    this.enabled = true,
    this.focusNode,
    this.controller,
    this.contentPadding,
    this.fillColor,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  TextEditingController? _internalController;
  Timer? _debounceTimer;
  String _lastValue = '';

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _lastValue = _controller.text;
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _internalController?.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final newValue = _controller.text;
    if (newValue != _lastValue) {
      _lastValue = newValue;

      // Cancel previous timer
      _debounceTimer?.cancel();

      if (widget.debounceMs > 0) {
        // Start new debounce timer
        _debounceTimer = Timer(
          Duration(milliseconds: widget.debounceMs),
          () => _notifyChange(newValue),
        );
      } else {
        // No debounce, notify immediately
        _notifyChange(newValue);
      }
    }
  }

  void _notifyChange(String value) {
    if (widget.onChanged != null && value != _lastValue) {
      widget.onChanged!(value);
    }
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: widget.fillColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.radiusXl, // Use BorderRadius, not double
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        enabled: widget.enabled,
        textInputAction: TextInputAction.search,
        style: AppTypography.bodyLarge,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTypography.bodyLarge.copyWith(
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          prefixIcon: const Icon(Icons.search, size: 20),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          suffixIcon: widget.showClearButton && hasText
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 20,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  onPressed: widget.enabled ? _handleClear : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                )
              : null,
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.md,
              ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
        onChanged: (_) {
          // Handled by listener for debounce
        },
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}

/// Compact search bar variant for constrained spaces
class AppSearchBarCompact extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;

  const AppSearchBarCompact({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
    this.controller,
    this.focusNode,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller?.text.isNotEmpty ?? false;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.radiusLg, // Use BorderRadius, not double
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        textInputAction: TextInputAction.search,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          prefixIcon: const Icon(Icons.search, size: 18),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 40,
          ),
          suffixIcon: hasText
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 18,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  onPressed: onClear,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 40,
                  ),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
