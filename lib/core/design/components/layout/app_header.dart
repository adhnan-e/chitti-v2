import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';

/// Unified app header component to replace duplicate AppBar patterns
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final bool showBorder;

  const AppHeader({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackButton = true,
    this.onBack,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.showBorder = true,
  });

  /// Simple header with just a title
  const AppHeader.simple({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBack,
    this.backgroundColor,
  })  : titleWidget = null,
        actions = null,
        leading = null,
        centerTitle = true,
        showBorder = true;

  /// Header with actions
  const AppHeader.withActions({
    super.key,
    required this.title,
    required this.actions,
    this.showBackButton = true,
    this.onBack,
    this.backgroundColor,
  })  : titleWidget = null,
        leading = null,
        centerTitle = true,
        showBorder = true;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final effectiveShowBack = showBackButton && canPop;

    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        border: showBorder
            ? const Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Leading / Back button
            if (leading != null)
              leading!
            else if (effectiveShowBack)
              GestureDetector(
                onTap: onBack ?? () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(Spacing.sm),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
              )
            else
              const SizedBox(width: 36),

            // Title
            Expanded(
              child: centerTitle
                  ? Center(
                      child: titleWidget ??
                          Text(
                            title ?? '',
                            style: AppTypography.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                    )
                  : (titleWidget ??
                      Text(
                        title ?? '',
                        style: AppTypography.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      )),
            ),

            // Actions
            if (actions != null && actions!.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              )
            else
              const SizedBox(width: 36),
          ],
        ),
      ),
    );
  }
}
