/// Date and time utilities for consistent date handling
///
/// Provides reusable functions for date parsing, formatting,
/// and calculations used throughout the application.
library;

import 'package:intl/intl.dart';

/// Date utility functions for parsing, formatting, and calculations
class DateUtils {
  DateUtils._(); // Private constructor - utility class

  /// Parse dynamic value to DateTime safely
  ///
  /// Supports: DateTime, String (ISO 8601), int (milliseconds since epoch)
  /// Returns null if parsing fails or value is null
  static DateTime? parse(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Parse date and format for display
  ///
  /// [value] - Dynamic date value to parse
  /// [pattern] - DateFormat pattern (default: 'MMM d, yyyy')
  /// [fallback] - String to return if parsing fails (default: 'N/A')
  ///
  /// Returns formatted date string or fallback if parsing fails
  static String? format(dynamic value, {String pattern = 'MMM d, yyyy', String? fallback}) {
    final date = parse(value);
    if (date == null) return fallback ?? 'N/A';
    return DateFormat(pattern).format(date);
  }

  /// Parse month key (YYYY-MM or "Month YYYY") to DateTime
  ///
  /// Supports formats:
  /// - "2024-01" (YYYY-MM)
  /// - "January 2024" (Month YYYY)
  /// - "Jan 2024" (Mon YYYY)
  ///
  /// Returns first day of the month
  static DateTime? parseMonth(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return DateTime(value.year, value.month, 1);
    if (value is String) {
      final trimmed = value.trim();

      // Try YYYY-MM format
      if (trimmed.contains('-')) {
        final parts = trimmed.split('-');
        if (parts.length >= 2) {
          final year = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          if (year != null && month != null && month >= 1 && month <= 12) {
            return DateTime(year, month, 1);
          }
        }
      }

      // Try "Month YYYY" or "Mon YYYY" format
      final months = [
        'january', 'february', 'march', 'april', 'may', 'june',
        'july', 'august', 'september', 'october', 'november', 'december'
      ];
      final parts = trimmed.toLowerCase().split(' ');
      if (parts.length >= 2) {
        final monthName = parts[0];
        final yearStr = parts[1];
        final monthIndex = months.indexWhere((m) => m.startsWith(monthName));
        final year = int.tryParse(yearStr);

        if (monthIndex >= 0 && year != null) {
          return DateTime(year, monthIndex + 1, 1);
        }
      }
    }
    return null;
  }

  /// Format DateTime to month key (YYYY-MM)
  static String formatMonthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  /// Format DateTime to month label (e.g., "Jan 2024")
  static String formatMonthLabel(DateTime date, {String pattern = 'MMM yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  /// Get month key for a specific month number from start date
  ///
  /// [startMonth] - Starting month (YYYY-MM or "Month YYYY")
  /// [monthNumber] - Month number (1-indexed, 1 = first month)
  ///
  /// Returns month key in YYYY-MM format
  static String getMonthKey(dynamic startMonth, int monthNumber) {
    final start = parseMonth(startMonth);
    if (start == null || monthNumber < 1) {
      return startMonth is String ? startMonth : formatMonthKey(DateTime.now());
    }
    final target = DateTime(start.year, start.month + monthNumber - 1, 1);
    return formatMonthKey(target);
  }

  /// Get month label for a specific month number from start date
  static String getMonthLabel(dynamic startMonth, int monthNumber, {String pattern = 'MMM yyyy'}) {
    final start = parseMonth(startMonth);
    if (start == null || monthNumber < 1) {
      return startMonth is String ? startMonth : formatMonthLabel(DateTime.now());
    }
    final target = DateTime(start.year, start.month + monthNumber - 1, 1);
    return formatMonthLabel(target, pattern: pattern);
  }

  /// Calculate days remaining from now until the target date
  ///
  /// Returns 0 if date is null or in the past
  static int daysRemaining(dynamic dateValue) {
    final date = parse(dateValue);
    if (date == null) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    return target.difference(today).inDays;
  }

  /// Calculate days since the given date
  ///
  /// Returns 0 if date is null or in the future
  static int daysSince(dynamic dateValue) {
    final date = parse(dateValue);
    if (date == null) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target.isAfter(today)) return 0;
    return today.difference(target).inDays;
  }

  /// Check if date is today
  static bool isToday(dynamic dateValue) {
    final date = parse(dateValue);
    if (date == null) return false;

    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  /// Check if date is in the past
  static bool isPast(dynamic dateValue) {
    final date = parse(dateValue);
    if (date == null) return false;

    final now = DateTime.now();
    return date.isBefore(now);
  }

  /// Check if date is in the future
  static bool isFuture(dynamic dateValue) {
    final date = parse(dateValue);
    if (date == null) return false;

    final now = DateTime.now();
    return date.isAfter(now);
  }

  /// Get relative time description (e.g., "2 days ago", "in 3 days")
  static String relativeTime(dynamic dateValue, {String? prefix}) {
    final date = parse(dateValue);
    if (date == null) return 'Unknown';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final diff = target.difference(today).inDays;

    if (diff == 0) return '${prefix ?? ''}Today';
    if (diff == 1) return '${prefix ?? ''}Tomorrow';
    if (diff == -1) return '${prefix ?? ''}Yesterday';

    if (diff > 0) {
      return '${prefix ?? ''}in $diff days';
    } else {
      return '${prefix ?? ''}${-diff} days ago';
    }
  }

  /// Calculate remaining months between two dates
  ///
  /// [from] - Start date
  /// [to] - End date
  ///
  /// Returns number of complete months between dates
  static int monthsBetween(dynamic from, dynamic to) {
    final fromDate = parse(from);
    final toDate = parse(to);

    if (fromDate == null || toDate == null) return 0;

    return (toDate.year - fromDate.year) * 12 +
           (toDate.month - fromDate.month);
  }

  /// Add months to a date
  static DateTime? addMonths(dynamic dateValue, int months) {
    final date = parse(dateValue);
    if (date == null) return null;

    return DateTime(date.year, date.month + months, date.day);
  }

  /// Get the next occurrence of a day in the current month
  ///
  /// [day] - Day of month (1-28 to avoid invalid dates)
  ///
  /// Returns DateTime for the next occurrence of this day
  static DateTime getNextDayInMonth(int day) {
    final now = DateTime.now();
    final targetDay = day.clamp(1, 28);

    var target = DateTime(now.year, now.month, targetDay);

    // If already passed this month, go to next month
    if (target.isBefore(now)) {
      target = DateTime(now.year, now.month + 1, targetDay);
    }

    return target;
  }

  /// Format date range (e.g., "Jan 2024 - Dec 2024")
  static String formatRange(dynamic from, dynamic to, {String pattern = 'MMM yyyy'}) {
    final fromStr = format(from, pattern: pattern, fallback: 'N/A');
    final toStr = format(to, pattern: pattern, fallback: 'N/A');
    return '$fromStr - $toStr';
  }
}

/// Extension methods for convenient date operations
extension DateTimeExtensions on DateTime {
  /// Format this date using the given pattern
  String format({String pattern = 'MMM d, yyyy'}) {
    return DateFormat(pattern).format(this);
  }

  /// Format as month key (YYYY-MM)
  String get monthKey => DateUtils.formatMonthKey(this);

  /// Format as month label (MMM yyyy)
  String get monthLabel => DateUtils.formatMonthLabel(this);

  /// Get days remaining from now until this date
  int get daysRemaining => DateUtils.daysRemaining(this);

  /// Get days since this date
  int get daysSince => DateUtils.daysSince(this);

  /// Check if this date is today
  bool get isToday => DateUtils.isToday(this);

  /// Check if this date is in the past
  bool get isPast => DateUtils.isPast(this);

  /// Check if this date is in the future
  bool get isFuture => DateUtils.isFuture(this);

  /// Add months to this date
  DateTime addMonths(int months) => DateTime(year, month + months, day);

  /// Get relative time description
  String get relativeTime => DateUtils.relativeTime(this);
}

/// Extension methods for convenient String-to-DateTime conversion
extension StringDateExtensions on String {
  /// Parse this string as DateTime (ISO 8601)
  DateTime? toDateTime() => DateUtils.parse(this);

  /// Parse this string as month DateTime
  DateTime? toMonth() => DateUtils.parseMonth(this);
}
