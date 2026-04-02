/// Balance Calculator - Pure functions for deterministic balance calculations
///
/// All functions are pure (no side effects) and easily testable.
/// Uses integer arithmetic to avoid floating-point errors.
library;

import '../core/models/transaction.dart';
import '../core/models/emi_schedule.dart';
import '../utils/currency_utils.dart';
import 'package:intl/intl.dart';

/// Pure calculation functions for balance and EMI operations
class BalanceCalculator {
  BalanceCalculator._(); // Private constructor

  // ============ EMI Calculations ============

  /// Calculate base EMI and first month extra
  ///
  /// Returns (baseEMI, firstMonthExtra) in cents
  static (int, int) calculateEMI({
    required int totalAmountInCents,
    required int duration,
  }) {
    return CurrencyUtils.calculateEMI(
      totalAmountInCents: totalAmountInCents,
      duration: duration,
    );
  }

  /// Calculate discounted EMI for winners
  ///
  /// Returns the EMI after applying winner discount
  static int calculateDiscountedEMI({
    required int originalEMIInCents,
    required int discountPerMonthInCents,
  }) {
    return (originalEMIInCents - discountPerMonthInCents).clamp(
      0,
      originalEMIInCents,
    );
  }

  // ============ Balance Calculations ============

  /// Calculate verified balance from transactions
  ///
  /// Only counts verified transactions
  static int calculateVerifiedBalance(List<Transaction> transactions) {
    return transactions
        .where((t) => t.isVerified)
        .fold(0, (sum, t) => sum + t.effectiveAmountInCents);
  }

  /// Calculate pending balance from transactions
  ///
  /// Includes all non-rejected transactions
  static int calculatePendingBalance(List<Transaction> transactions) {
    return transactions
        .where((t) => !t.isRejected)
        .fold(0, (sum, t) => sum + t.effectiveAmountInCents);
  }

  /// Calculate total paid amount (verified only)
  static int calculateTotalPaid(List<Transaction> transactions) {
    return transactions
        .where((t) => t.isVerified && t.type == TransactionType.payment)
        .fold(0, (sum, t) => sum + t.amountInCents);
  }

  /// Calculate total due (opening balance + all monthly EMIs - discounts)
  static int calculateTotalDue({
    required int totalAmountInCents,
    required int openingBalanceInCents,
    required int totalDiscountInCents,
  }) {
    return totalAmountInCents + openingBalanceInCents - totalDiscountInCents;
  }

  // ============ EMI Schedule Generation ============

  /// Generate complete EMI schedule for a slot
  static EMISchedule generateSchedule({
    required String slotId,
    required String chittyId,
    required int totalAmountInCents,
    required int duration,
    required String startMonth, // YYYY-MM format
    required int paymentDay,
    String? winnerMonth,
    int? discountPerMonthInCents,
    List<Transaction> transactions = const [],
  }) {
    final entries = <EMIEntry>[];

    // Calculate base EMI
    final (baseEMI, firstMonthExtra) = calculateEMI(
      totalAmountInCents: totalAmountInCents,
      duration: duration,
    );

    // Parse start month
    final startDate = _parseMonthKey(startMonth);

    // Determine discount start month number (1-indexed)
    int? discountStartMonthNumber;
    String? discountStartMonthKey;
    if (winnerMonth != null && discountPerMonthInCents != null) {
      // Discount starts the month after winning
      final winnerDate = _parseMonthKey(winnerMonth);
      final nextMonth = DateTime(winnerDate.year, winnerDate.month + 1, 1);
      discountStartMonthKey = _formatMonthKey(nextMonth);

      // Calculate month number
      final monthsDiff =
          (nextMonth.year - startDate.year) * 12 +
          (nextMonth.month - startDate.month) +
          1;
      discountStartMonthNumber = monthsDiff;
    }

    // Group payments by month
    final paymentsByMonth = <String, int>{};
    final transactionIdsByMonth = <String, List<String>>{};
    for (final txn in transactions.where(
      (t) =>
          t.type == TransactionType.payment &&
          (t.isVerified || t.isPending), // Count both for collection view
    )) {
      paymentsByMonth[txn.monthKey] =
          (paymentsByMonth[txn.monthKey] ?? 0) + txn.amountInCents;
      transactionIdsByMonth.putIfAbsent(txn.monthKey, () => []).add(txn.id);
    }

    // Generate entries for each month
    for (int m = 1; m <= duration; m++) {
      final monthDate = DateTime(startDate.year, startDate.month + m - 1, 1);
      final monthKey = _formatMonthKey(monthDate);
      final monthLabel = DateFormat('MMM yyyy').format(monthDate);
      final dueDate = DateTime(monthDate.year, monthDate.month, paymentDay);

      // Calculate EMI for this month
      int originalAmount = m == 1 ? baseEMI + firstMonthExtra : baseEMI;

      // Apply discount if applicable
      int discountAmount = 0;
      bool hasDiscount = false;
      if (discountStartMonthNumber != null &&
          m >= discountStartMonthNumber &&
          discountPerMonthInCents != null) {
        discountAmount = discountPerMonthInCents;
        hasDiscount = true;
      }

      final netAmount = (originalAmount - discountAmount).clamp(
        0,
        originalAmount,
      );
      final paidAmount = paymentsByMonth[monthKey] ?? 0;

      // Determine status
      final status = _calculateStatus(
        dueDate: dueDate,
        netAmountInCents: netAmount,
        paidAmountInCents: paidAmount,
      );

      entries.add(
        EMIEntry(
          monthNumber: m,
          monthKey: monthKey,
          monthLabel: monthLabel,
          dueDate: dueDate,
          originalAmountInCents: originalAmount,
          discountInCents: discountAmount,
          netAmountInCents: netAmount,
          paidAmountInCents: paidAmount,
          status: status,
          isFirstMonth: m == 1,
          roundingRemainderInCents: m == 1 ? firstMonthExtra : 0,
          hasWinnerDiscount: hasDiscount,
          transactionIds: transactionIdsByMonth[monthKey] ?? [],
        ),
      );
    }

    return EMISchedule(
      slotId: slotId,
      chittyId: chittyId,
      duration: duration,
      totalAmountInCents: totalAmountInCents,
      baseEMIInCents: baseEMI,
      firstMonthEMIInCents: baseEMI + firstMonthExtra,
      winnerDiscountPerMonthInCents: discountPerMonthInCents ?? 0,
      discountStartMonth: discountStartMonthKey,
      entries: entries,
      generatedAt: DateTime.now(),
    );
  }

  /// Calculate EMI status based on payment and due date
  static EMIStatus _calculateStatus({
    required DateTime dueDate,
    required int netAmountInCents,
    required int paidAmountInCents,
  }) {
    final now = DateTime.now();
    final isFullyPaid = paidAmountInCents >= netAmountInCents;
    final isPartiallyPaid = paidAmountInCents > 0 && !isFullyPaid;

    if (isFullyPaid) return EMIStatus.paid;
    if (isPartiallyPaid) return EMIStatus.partial;

    // Check if future
    final startOfMonth = DateTime(now.year, now.month, 1);
    final entryMonth = DateTime(dueDate.year, dueDate.month, 1);

    if (entryMonth.isAfter(startOfMonth)) {
      return EMIStatus.future;
    }

    // Same month
    if (entryMonth.year == now.year && entryMonth.month == now.month) {
      if (now.day < dueDate.day) {
        return EMIStatus.upcoming;
      }
      return EMIStatus.due;
    }

    // Past months - overdue
    return EMIStatus.overdue;
  }

  // ============ Catch-up Calculation ============

  /// Calculate catch-up amount for mid-cycle joiner
  static int calculateCatchUpAmount({
    required int totalAmountInCents,
    required int duration,
    required int joinMonth, // Which month they're joining (1-indexed)
  }) {
    if (joinMonth <= 1 || joinMonth > duration) return 0;

    final (baseEMI, firstMonthExtra) = calculateEMI(
      totalAmountInCents: totalAmountInCents,
      duration: duration,
    );

    // Calculate sum of missed EMIs
    int catchUp = firstMonthExtra + baseEMI; // Month 1
    for (int m = 2; m < joinMonth; m++) {
      catchUp += baseEMI;
    }

    return catchUp;
  }

  // ============ Helper Functions ============

  /// Parse month key (YYYY-MM) or "Month YYYY" to DateTime
  static DateTime _parseMonthKey(String monthKey) {
    return CurrencyUtils.parseMonth(monthKey) ?? DateTime.now();
  }

  /// Format DateTime to month key (YYYY-MM)
  static String _formatMonthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  /// Get month key for a specific month number
  static String getMonthKey(String startMonth, int monthNumber) {
    final start = _parseMonthKey(startMonth);
    final target = DateTime(start.year, start.month + monthNumber - 1, 1);
    return _formatMonthKey(target);
  }

  /// Calculate remaining months after a specific month
  static int calculateRemainingMonths({
    required int duration,
    required String startMonth,
    required String fromMonth,
  }) {
    final start = _parseMonthKey(startMonth);
    final from = _parseMonthKey(fromMonth);

    final monthsPassed =
        (from.year - start.year) * 12 + (from.month - start.month);

    return (duration - monthsPassed).clamp(0, duration);
  }
}
