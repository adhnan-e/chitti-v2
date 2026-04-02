/// EMI Schedule Model - Represents the payment schedule for a slot
///
/// Contains all monthly EMI entries with their status, amounts, and due dates.
/// Uses integer arithmetic (cents) to avoid floating-point errors.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'emi_schedule.freezed.dart';
part 'emi_schedule.g.dart';

/// EMI status for each month
enum EMIStatus {
  /// Not yet due (future month)
  future,

  /// Due this month, payment window open
  upcoming,

  /// Past due date but within grace period
  due,

  /// Significantly overdue (past grace period)
  overdue,

  /// Partially paid
  partial,

  /// Fully paid
  paid,
}

/// Extension for EMIStatus utilities
extension EMIStatusX on EMIStatus {
  /// Parse from string with fallback
  static EMIStatus fromString(String? value) {
    return EMIStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => EMIStatus.future,
    );
  }

  /// Display label for UI
  String get displayLabel {
    switch (this) {
      case EMIStatus.future:
        return 'Upcoming';
      case EMIStatus.upcoming:
        return 'Due Soon';
      case EMIStatus.due:
        return 'Due';
      case EMIStatus.overdue:
        return 'Overdue';
      case EMIStatus.partial:
        return 'Partial';
      case EMIStatus.paid:
        return 'Paid';
    }
  }

  /// Color code for UI (hex string)
  String get colorHex {
    switch (this) {
      case EMIStatus.future:
        return '#9E9E9E'; // Gray
      case EMIStatus.upcoming:
        return '#FFC107'; // Amber
      case EMIStatus.due:
        return '#FF9800'; // Orange
      case EMIStatus.overdue:
        return '#F44336'; // Red
      case EMIStatus.partial:
        return '#2196F3'; // Blue
      case EMIStatus.paid:
        return '#4CAF50'; // Green
    }
  }

  /// Whether this status needs attention
  bool get needsAttention =>
      this == EMIStatus.due ||
      this == EMIStatus.overdue ||
      this == EMIStatus.partial;
}

/// Immutable EMI schedule entry for a single month
@freezed
class EMIEntry with _$EMIEntry {
  const EMIEntry._();

  const factory EMIEntry({
    /// Month number (1-indexed)
    required int monthNumber,

    /// Month key in YYYY-MM format
    required String monthKey,

    /// Human-readable month label (e.g., "Feb 2026")
    required String monthLabel,

    /// Due date for this EMI
    required DateTime dueDate,

    /// Original EMI amount in cents (before any discounts)
    required int originalAmountInCents,

    /// Discount applied in cents (winner discount)
    @Default(0) int discountInCents,

    /// Net amount due in cents (original - discount)
    required int netAmountInCents,

    /// Amount already paid in cents
    @Default(0) int paidAmountInCents,

    /// Current status
    required EMIStatus status,

    /// Whether this is the first month (may have rounding remainder)
    @Default(false) bool isFirstMonth,

    /// Extra amount in first month due to rounding
    @Default(0) int roundingRemainderInCents,

    /// Whether winner discount is applied to this month
    @Default(false) bool hasWinnerDiscount,

    /// Transaction IDs for payments made against this month
    @Default([]) List<String> transactionIds,
  }) = _EMIEntry;

  factory EMIEntry.fromJson(Map<String, dynamic> json) =>
      _$EMIEntryFromJson(json);

  // ============ Convenience Getters ============

  /// Original amount in decimal
  double get originalAmount => originalAmountInCents / 100;

  /// Discount amount in decimal
  double get discount => discountInCents / 100;

  /// Net amount due in decimal
  double get netAmount => netAmountInCents / 100;

  /// Paid amount in decimal
  double get paidAmount => paidAmountInCents / 100;

  /// Rounding remainder in decimal
  double get roundingRemainder => roundingRemainderInCents / 100;

  /// Remaining amount due in cents
  int get remainingInCents => netAmountInCents - paidAmountInCents;

  /// Remaining amount due in decimal
  double get remaining => remainingInCents / 100;

  /// Whether fully paid
  bool get isFullyPaid => paidAmountInCents >= netAmountInCents;

  /// Whether partially paid
  bool get isPartiallyPaid =>
      paidAmountInCents > 0 && paidAmountInCents < netAmountInCents;

  /// Payment progress percentage (0-100)
  double get paymentProgress {
    if (netAmountInCents <= 0) return 100;
    return (paidAmountInCents / netAmountInCents * 100).clamp(0, 100);
  }

  /// Days until due (negative if overdue)
  int get daysUntilDue {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  /// Whether overdue
  bool get isOverdue => daysUntilDue < 0 && !isFullyPaid;

  /// Formatted due date
  String get formattedDueDate => DateFormat('d MMM yyyy').format(dueDate);
}

/// Complete EMI schedule for a slot
@freezed
class EMISchedule with _$EMISchedule {
  const EMISchedule._();

  const factory EMISchedule({
    /// Slot ID this schedule belongs to
    required String slotId,

    /// Chitti ID
    required String chittyId,

    /// Total duration in months
    required int duration,

    /// Total amount in cents
    required int totalAmountInCents,

    /// Base EMI in cents (before first month adjustment)
    required int baseEMIInCents,

    /// First month EMI in cents (includes rounding remainder)
    required int firstMonthEMIInCents,

    /// Monthly discount for winners in cents
    @Default(0) int winnerDiscountPerMonthInCents,

    /// Month from which discount starts (null if not a winner)
    String? discountStartMonth,

    /// All EMI entries
    required List<EMIEntry> entries,

    /// When schedule was generated
    required DateTime generatedAt,
  }) = _EMISchedule;

  factory EMISchedule.fromJson(Map<String, dynamic> json) =>
      _$EMIScheduleFromJson(json);

  // ============ Convenience Getters ============

  /// Total amount in decimal
  double get totalAmount => totalAmountInCents / 100;

  /// Base EMI in decimal
  double get baseEMI => baseEMIInCents / 100;

  /// Total paid amount in cents
  int get totalPaidInCents =>
      entries.fold(0, (sum, e) => sum + e.paidAmountInCents);

  /// Total paid amount in decimal
  double get totalPaid => totalPaidInCents / 100;

  /// Total remaining in cents
  int get totalRemainingInCents => totalAmountInCents - totalPaidInCents;

  /// Total remaining in decimal
  double get totalRemaining => totalRemainingInCents / 100;

  /// Overall payment progress (0-100)
  double get overallProgress {
    if (totalAmountInCents <= 0) return 100;
    return (totalPaidInCents / totalAmountInCents * 100).clamp(0, 100);
  }

  /// Number of fully paid months
  int get paidMonthsCount => entries.where((e) => e.isFullyPaid).length;

  /// Number of overdue months
  int get overdueMonthsCount =>
      entries.where((e) => e.status == EMIStatus.overdue).length;

  /// Current month entry (first unpaid or due)
  EMIEntry? get currentMonthEntry {
    return entries.firstWhere(
      (e) => !e.isFullyPaid && e.status != EMIStatus.future,
      orElse: () => entries.isEmpty ? entries.first : entries.last,
    );
  }

  /// Overdue entries
  List<EMIEntry> get overdueEntries =>
      entries.where((e) => e.status == EMIStatus.overdue).toList();

  /// Pending entries (not fully paid, not future)
  List<EMIEntry> get pendingEntries => entries
      .where((e) => !e.isFullyPaid && e.status != EMIStatus.future)
      .toList();

  /// Whether slot is a winner
  bool get isWinner => discountStartMonth != null;
}
