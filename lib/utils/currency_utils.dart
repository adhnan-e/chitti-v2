/// Currency Utilities - Helper functions for money handling
///
/// All internal calculations use cents (smallest currency unit).
/// This utility provides conversion and formatting functions.
library;

import 'package:intl/intl.dart';

/// Currency utility class for consistent money handling
class CurrencyUtils {
  CurrencyUtils._(); // Private constructor

  /// Default currency symbol
  static String _currencySymbol = 'AED';

  /// Set the currency symbol
  static void setCurrencySymbol(String symbol) {
    _currencySymbol = symbol;
  }

  /// Get the current currency symbol
  static String get currencySymbol => _currencySymbol;

  // ============ Conversion Functions ============

  /// Convert decimal amount to cents
  ///
  /// Example: 100.50 -> 10050
  static int toCents(double amount) {
    return (amount * 100).round();
  }

  /// Convert cents to decimal amount
  ///
  /// Example: 10050 -> 100.50
  static double fromCents(int cents) {
    return cents / 100;
  }

  // ============ EMI Calculation ============

  /// Calculate base EMI and first month extra
  ///
  /// Returns (baseEMI, firstMonthExtra) in cents
  /// Example: 10000 cents / 12 months = (833, 4)
  /// Month 1: 837 cents, Months 2-12: 833 cents each
  /// Total: 837 + (833 * 11) = 10000 cents ✓
  static (int baseEMI, int firstMonthExtra) calculateEMI({
    required int totalAmountInCents,
    required int duration,
  }) {
    if (duration <= 0) return (0, 0);

    // Chitti logic usually prefers whole unit EMIs for easy collection.
    // Example: 1000 / 12 = 83 with remainder 4.
    // Month 1: 83+4, Months 2-12: 83.

    int totalUnits = totalAmountInCents ~/ 100;
    int decimalCents = totalAmountInCents % 100;

    int baseUnit = totalUnits ~/ duration;
    int unitRemainder = totalUnits % duration;

    int baseEMIcents = baseUnit * 100;
    int firstMonthExtraCents = (unitRemainder * 100) + decimalCents;

    return (baseEMIcents, firstMonthExtraCents);
  }

  /// Get EMI for a specific month (1-indexed)
  ///
  /// First month gets the remainder to avoid rounding loss
  static int getEMIForMonth({
    required int totalAmountInCents,
    required int duration,
    required int monthNumber,
  }) {
    if (duration <= 0 || monthNumber < 1 || monthNumber > duration) return 0;

    final (base, remainder) = calculateEMI(
      totalAmountInCents: totalAmountInCents,
      duration: duration,
    );

    return monthNumber == 1 ? base + remainder : base;
  }

  /// Get EMI breakdown (backward compatible with old ChittiPaymentUtils)
  ///
  /// Returns a Map with:
  /// - 'regularEMI': double (normal monthly EMI)
  /// - 'firstMonth': double (first month EMI with remainder)
  /// - 'regularMonths': double (same as regularEMI)
  /// - 'remainder': double (the extra amount in first month)
  /// - 'hasRemainder': bool (whether there's a remainder)
  static Map<String, dynamic> getEMIBreakdown(
    double totalAmount,
    int duration,
  ) {
    if (duration <= 0) {
      return {
        'regularEMI': 0.0,
        'firstMonth': 0.0,
        'regularMonths': 0.0,
        'remainder': 0.0,
        'hasRemainder': false,
      };
    }

    final totalCents = toCents(totalAmount);
    final (baseCents, remainderCents) = calculateEMI(
      totalAmountInCents: totalCents,
      duration: duration,
    );

    final regularEMI = fromCents(baseCents);
    final remainder = fromCents(remainderCents);
    final firstMonth = regularEMI + remainder;

    return {
      'regularEMI': regularEMI,
      'firstMonth': firstMonth,
      'regularMonths': regularEMI,
      'remainder': remainder,
      'hasRemainder': remainderCents > 0,
    };
  }

  /// Safely parse a month string into a DateTime
  ///
  /// Supports "YYYY-MM", "MMMM yyyy", and "MMM yyyy"
  static DateTime? parseMonth(String month) {
    if (month.isEmpty) return null;

    // Try YYYY-MM format first
    if (month.contains('-')) {
      final parts = month.split('-');
      if (parts.length >= 2) {
        final year = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (year != null && m != null) {
          return DateTime(year, m, 1);
        }
      }
    }

    // Try "MMMM yyyy" format
    try {
      return DateFormat('MMMM yyyy').parse(month);
    } catch (_) {
      // Try "MMM yyyy" format
      try {
        return DateFormat('MMM yyyy').parse(month);
      } catch (_) {
        return null;
      }
    }
  }

  /// Generate month dates and names for a chitti schedule
  ///
  /// Returns tuple of (List<DateTime> dates, List<String> names)
  static (List<DateTime>, List<String>) generateMonthDates(
    String startMonth, // Supports YYYY-MM or "Month YYYY"
    int duration,
  ) {
    final dates = <DateTime>[];
    final names = <String>[];

    final startDate = parseMonth(startMonth);
    if (startDate != null) {
      for (int i = 0; i < duration; i++) {
        final date = DateTime(startDate.year, startDate.month + i, 1);
        dates.add(date);
        names.add(DateFormat('MMM yyyy').format(date));
      }
    }

    return (dates, names);
  }

  // ============ Formatting Functions ============

  /// Format cents as currency string
  ///
  /// Example: 10050 -> "AED 100.50"
  static String formatCents(int cents, {String? symbol}) {
    final formatter = NumberFormat('#,##0.00');
    return '${symbol ?? _currencySymbol} ${formatter.format(fromCents(cents))}';
  }

  /// Format cents as compact currency (no decimal if whole number)
  ///
  /// Example: 10000 -> "AED 100", 10050 -> "AED 100.50"
  static String formatCentsCompact(int cents, {String? symbol}) {
    final amount = fromCents(cents);
    final hasDecimal = cents % 100 != 0;

    if (hasDecimal) {
      return '${symbol ?? _currencySymbol} ${NumberFormat('#,##0.00').format(amount)}';
    } else {
      return '${symbol ?? _currencySymbol} ${NumberFormat('#,##0').format(amount)}';
    }
  }

  /// Format decimal amount as currency string
  ///
  /// Example: 100.50 -> "AED 100.50"
  static String format(double amount, {String? symbol}) {
    final formatter = NumberFormat('#,##0.00');
    return '${symbol ?? _currencySymbol} ${formatter.format(amount)}';
  }

  /// Format amount without currency symbol
  ///
  /// Example: 100.50 -> "100.50"
  static String formatAmountOnly(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }

  /// Format cents without currency symbol
  static String formatCentsAmountOnly(int cents) {
    return formatAmountOnly(fromCents(cents));
  }

  // ============ Validation Functions ============

  /// Parse a currency string to cents
  ///
  /// Handles various formats: "100", "100.50", "1,000.00"
  static int? parseToCents(String value) {
    try {
      // Remove currency symbols and whitespace
      final cleaned = value
          .replaceAll(RegExp(r'[^\d.,\-]'), '')
          .replaceAll(',', '');

      final amount = double.tryParse(cleaned);
      if (amount == null) return null;

      return toCents(amount);
    } catch (_) {
      return null;
    }
  }

  /// Validate amount string
  static bool isValidAmount(String value) {
    return parseToCents(value) != null;
  }

  // ============ Display Helpers ============

  /// Format as difference (e.g., "+100.00" or "-50.00")
  static String formatDifference(int cents, {String? symbol}) {
    final prefix = cents >= 0 ? '+' : '';
    return '$prefix${formatCents(cents, symbol: symbol)}';
  }

  /// Format percentage
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }
}
