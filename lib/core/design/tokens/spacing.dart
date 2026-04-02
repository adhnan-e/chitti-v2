import 'package:flutter/material.dart';

/// Spacing tokens for consistent padding and margins
abstract class Spacing {
  // Base spacing values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // Common EdgeInsets shortcuts
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);
  static const EdgeInsets allXxl = EdgeInsets.all(xxl);

  // Horizontal padding
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);

  // Screen padding (standard content padding)
  static const EdgeInsets screenPadding = EdgeInsets.all(lg);
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(horizontal: lg);

  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(md);

  // List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  // Button padding
  static const EdgeInsets buttonPaddingLarge = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: lg,
  );
  static const EdgeInsets buttonPaddingMedium = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  // Input padding
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  // Chip padding
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: xs,
  );
}

/// Vertical spacing widgets for consistent gaps
class VSpace extends StatelessWidget {
  final double height;

  const VSpace.xs({super.key}) : height = Spacing.xs;
  const VSpace.sm({super.key}) : height = Spacing.sm;
  const VSpace.md({super.key}) : height = Spacing.md;
  const VSpace.lg({super.key}) : height = Spacing.lg;
  const VSpace.xl({super.key}) : height = Spacing.xl;
  const VSpace.xxl({super.key}) : height = Spacing.xxl;
  const VSpace.xxxl({super.key}) : height = Spacing.xxxl;
  const VSpace(this.height, {super.key});

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

/// Horizontal spacing widgets for consistent gaps
class HSpace extends StatelessWidget {
  final double width;

  const HSpace.xs({super.key}) : width = Spacing.xs;
  const HSpace.sm({super.key}) : width = Spacing.sm;
  const HSpace.md({super.key}) : width = Spacing.md;
  const HSpace.lg({super.key}) : width = Spacing.lg;
  const HSpace.xl({super.key}) : width = Spacing.xl;
  const HSpace.xxl({super.key}) : width = Spacing.xxl;
  const HSpace.xxxl({super.key}) : width = Spacing.xxxl;
  const HSpace(this.width, {super.key});

  @override
  Widget build(BuildContext context) => SizedBox(width: width);
}
