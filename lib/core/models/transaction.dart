/// Transaction Model - THE SINGLE SOURCE OF TRUTH
///
/// "Rule of One": Every financial change MUST originate from a single Transaction.
/// Transactions are IMMUTABLE - never edited, only reversed with counter-transactions.
///
/// This is the core of the zero-failure accounting system.
/// All amounts are stored in cents (smallest currency unit) to avoid floating-point errors.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

/// Transaction types - each affects balance differently
enum TransactionType {
  /// Payment from member (CREDIT - increases balance)
  payment,

  /// Winner discount applied (CREDIT - reduces dues)
  discount,

  /// Prize payout to winner (DEBIT - reduces balance)
  prizePayout,

  /// Reversal of another transaction (opposite effect)
  reversal,

  /// Admin adjustment (can be credit or debit)
  adjustment,

  /// Opening balance for mid-cycle joiners (DEBIT - establishes dues)
  openingBalance,

  /// Gold handover record (DEBIT - marks gold delivery)
  goldHandover,

  /// Settlement payment from member after handover (CREDIT)
  settlementPayment,

  /// Refund to member when gold value dropped (DEBIT)
  settlementRefund,
}

/// Extension for TransactionType utilities
extension TransactionTypeX on TransactionType {
  /// Whether this type adds to the balance (credit)
  bool get isCredit =>
      this == TransactionType.payment ||
      this == TransactionType.discount ||
      this == TransactionType.settlementPayment;

  /// Whether this type reduces the balance (debit)
  bool get isDebit =>
      this == TransactionType.prizePayout ||
      this == TransactionType.openingBalance ||
      this == TransactionType.goldHandover ||
      this == TransactionType.settlementRefund;

  /// Parse from string with fallback
  static TransactionType fromString(String? value) {
    return TransactionType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => TransactionType.payment,
    );
  }

  /// Display label for UI
  String get displayLabel {
    switch (this) {
      case TransactionType.payment:
        return 'Payment';
      case TransactionType.discount:
        return 'Discount';
      case TransactionType.prizePayout:
        return 'Prize Payout';
      case TransactionType.reversal:
        return 'Reversal';
      case TransactionType.adjustment:
        return 'Adjustment';
      case TransactionType.openingBalance:
        return 'Opening Balance';
      case TransactionType.goldHandover:
        return 'Gold Handover';
      case TransactionType.settlementPayment:
        return 'Settlement Payment';
      case TransactionType.settlementRefund:
        return 'Settlement Refund';
    }
  }
}

/// Transaction status - dual-state payment flow
enum TransactionStatus {
  /// Recorded but not confirmed by organizer
  pending,

  /// Organizer confirmed receipt of funds
  verified,

  /// Payment was rejected/bounced
  rejected,
}

/// Extension for TransactionStatus utilities
extension TransactionStatusX on TransactionStatus {
  /// Parse from string with fallback
  static TransactionStatus fromString(String? value) {
    return TransactionStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => TransactionStatus.pending,
    );
  }

  /// Display label for UI
  String get displayLabel {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.verified:
        return 'Verified';
      case TransactionStatus.rejected:
        return 'Rejected';
    }
  }
}

/// Payment method options
enum PaymentMethod { cash, bankTransfer, upi, cheque, card, other }

/// Extension for PaymentMethod utilities
extension PaymentMethodX on PaymentMethod {
  /// Parse from string with fallback
  static PaymentMethod fromString(String? value) {
    return PaymentMethod.values.firstWhere(
      (m) => m.name == value,
      orElse: () => PaymentMethod.cash,
    );
  }

  /// Display label for UI
  String get displayLabel {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.cheque:
        return 'Cheque';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  /// Icon for UI
  String get iconName {
    switch (this) {
      case PaymentMethod.cash:
        return 'payments';
      case PaymentMethod.bankTransfer:
        return 'account_balance';
      case PaymentMethod.upi:
        return 'qr_code';
      case PaymentMethod.cheque:
        return 'receipt_long';
      case PaymentMethod.card:
        return 'credit_card';
      case PaymentMethod.other:
        return 'more_horiz';
    }
  }
}

/// Immutable transaction record for all financial changes.
///
/// Every payment, discount, payout, or reversal creates exactly one Transaction.
/// The sum of all transactions for a slot equals the slot's current balance.
///
/// All amounts are stored in CENTS (smallest currency unit) to avoid
/// floating-point errors. Use helper methods for display formatting.
@freezed
class Transaction with _$Transaction {
  const Transaction._();

  const factory Transaction({
    /// Unique transaction identifier
    required String id,

    /// Slot this transaction belongs to
    required String slotId,

    /// Parent chitty ID
    required String chittiId,

    /// Transaction type determines how it affects balance
    required TransactionType type,

    /// Amount in cents (smallest currency unit)
    /// Always positive - type determines credit/debit
    required int amountInCents,

    /// Balance in cents before this transaction
    required int balanceBeforeInCents,

    /// Balance in cents after this transaction
    required int balanceAfterInCents,

    /// Month this transaction applies to (YYYY-MM format)
    required String monthKey,

    /// Verification status for dual-state tracking
    @Default(TransactionStatus.pending) TransactionStatus status,

    /// Payment method used
    @Default(PaymentMethod.cash) PaymentMethod paymentMethod,

    /// For reversals: links to the original transaction being reversed
    String? linkedTransactionId,

    /// External reference (bank txn ID, cheque number, etc.)
    String? referenceNumber,

    /// Optional notes for audit trail
    String? notes,

    /// Unique receipt number for this transaction
    String? receiptNumber,

    /// When transaction was created
    required DateTime createdAt,

    /// When organizer verified the payment
    DateTime? verifiedAt,

    /// Who verified (organizer ID)
    String? verifiedBy,

    /// User ID for reference (denormalized for queries)
    String? userId,

    /// User name for display (denormalized)
    String? userName,

    /// Slot number for display (denormalized)
    int? slotNumber,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  /// Create from Firebase map with type conversions
  factory Transaction.fromFirebase(String id, Map<String, dynamic> data) {
    return Transaction(
      id: id,
      slotId: data['slotId'] as String? ?? '',
      chittiId: data['chittiId'] as String? ?? '',
      type: TransactionTypeX.fromString(data['type'] as String?),
      amountInCents: data['amountInCents'] as int? ?? 0,
      balanceBeforeInCents: data['balanceBeforeInCents'] as int? ?? 0,
      balanceAfterInCents: data['balanceAfterInCents'] as int? ?? 0,
      monthKey: data['monthKey'] as String? ?? '',
      status: TransactionStatusX.fromString(data['status'] as String?),
      paymentMethod: PaymentMethodX.fromString(
        data['paymentMethod'] as String?,
      ),
      linkedTransactionId: data['linkedTransactionId'] as String?,
      referenceNumber: data['referenceNumber'] as String?,
      notes: data['notes'] as String?,
      receiptNumber: data['receiptNumber'] as String?,
      createdAt: _parseDateTime(data['createdAt']),
      verifiedAt: data['verifiedAt'] != null
          ? _parseDateTime(data['verifiedAt'])
          : null,
      verifiedBy: data['verifiedBy'] as String?,
      userId: data['userId'] as String?,
      userName: data['userName'] as String?,
      slotNumber: data['slotNumber'] as int?,
    );
  }

  /// Convert to Firebase-compatible map
  Map<String, dynamic> toFirebase() {
    return {
      'slotId': slotId,
      'chittiId': chittiId,
      'type': type.name,
      'amountInCents': amountInCents,
      'balanceBeforeInCents': balanceBeforeInCents,
      'balanceAfterInCents': balanceAfterInCents,
      'monthKey': monthKey,
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      if (linkedTransactionId != null)
        'linkedTransactionId': linkedTransactionId,
      if (referenceNumber != null) 'referenceNumber': referenceNumber,
      if (notes != null) 'notes': notes,
      if (receiptNumber != null) 'receiptNumber': receiptNumber,
      'createdAt': createdAt.toIso8601String(),
      if (verifiedAt != null) 'verifiedAt': verifiedAt!.toIso8601String(),
      if (verifiedBy != null) 'verifiedBy': verifiedBy,
      if (userId != null) 'userId': userId,
      if (userName != null) 'userName': userName,
      if (slotNumber != null) 'slotNumber': slotNumber,
    };
  }

  // ============ Convenience Getters ============

  /// Amount in decimal (for display only)
  double get amount => amountInCents / 100;

  /// Balance before in decimal (for display only)
  double get balanceBefore => balanceBeforeInCents / 100;

  /// Balance after in decimal (for display only)
  double get balanceAfter => balanceAfterInCents / 100;

  /// Whether this transaction adds to the balance
  bool get isCredit => type.isCredit;

  /// Whether this transaction reduces the balance
  bool get isDebit => type.isDebit;

  /// Whether this is a reversal transaction
  bool get isReversal => type == TransactionType.reversal;

  /// Whether still pending verification
  bool get isPending => status == TransactionStatus.pending;

  /// Whether verified by organizer
  bool get isVerified => status == TransactionStatus.verified;

  /// Whether rejected
  bool get isRejected => status == TransactionStatus.rejected;

  /// Effective amount in cents (positive for credits, negative for debits)
  int get effectiveAmountInCents {
    if (isReversal) return -amountInCents; // Reversals negate
    return isCredit ? amountInCents : -amountInCents;
  }

  /// Effective amount in decimal
  double get effectiveAmount => effectiveAmountInCents / 100;

  /// Human-readable description
  String get description {
    switch (type) {
      case TransactionType.payment:
        return 'EMI Payment for $monthKey';
      case TransactionType.discount:
        return 'Winner Discount Applied';
      case TransactionType.prizePayout:
        return 'Prize Payout';
      case TransactionType.reversal:
        return 'Reversal: ${notes ?? "Transaction reversed"}';
      case TransactionType.openingBalance:
        return 'Opening Balance (Mid-cycle Join)';
      case TransactionType.adjustment:
        return 'Admin Adjustment: ${notes ?? ""}';
      case TransactionType.goldHandover:
        return 'Gold Handover - $monthKey';
      case TransactionType.settlementPayment:
        return 'Settlement Payment: ${notes ?? "Balance paid"}';
      case TransactionType.settlementRefund:
        return 'Settlement Refund: ${notes ?? "Refund issued"}';
    }
  }

  /// Short description for receipts
  String get shortDescription {
    switch (type) {
      case TransactionType.payment:
        return 'EMI - $monthKey';
      case TransactionType.discount:
        return 'Discount';
      case TransactionType.prizePayout:
        return 'Prize';
      case TransactionType.reversal:
        return 'Reversal';
      case TransactionType.openingBalance:
        return 'Opening Bal.';
      case TransactionType.adjustment:
        return 'Adjustment';
      case TransactionType.goldHandover:
        return 'Gold Handover';
      case TransactionType.settlementPayment:
        return 'Settlement';
      case TransactionType.settlementRefund:
        return 'Refund';
    }
  }
}

/// Helper to parse DateTime from various formats
DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return DateTime.now();
}
