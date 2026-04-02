/// Animation duration tokens for consistent motion
abstract class AppDurations {
  // Fast animations (micro-interactions)
  static const Duration fast = Duration(milliseconds: 150);

  // Normal animations (standard transitions)
  static const Duration normal = Duration(milliseconds: 250);

  // Slow animations (complex transitions)
  static const Duration slow = Duration(milliseconds: 400);

  // Page transitions
  static const Duration pageTransition = Duration(milliseconds: 300);

  // Modal animations
  static const Duration modal = Duration(milliseconds: 250);

  // Splash screen minimum display
  static const Duration splash = Duration(milliseconds: 1500);

  // Debounce delay for search
  static const Duration debounce = Duration(milliseconds: 300);

  // Snackbar display duration
  static const Duration snackbar = Duration(seconds: 3);

  // Toast display duration
  static const Duration toast = Duration(seconds: 2);
}
