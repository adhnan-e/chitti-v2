/// Core domain enums for the Chitti Financial System
/// These enums define the fundamental types used throughout the application
library;

/// Transaction types - the ONLY way money moves in the system
/// Rule of One: Every financial change MUST originate from a Transaction
enum TransactionType {
  /// Member pays EMI or catch-up amount
  payment,

  /// Winner discount applied to reduce future dues
  discount,

  /// Prize disbursement to winner
  prizePayout,

  /// Undo a previous transaction (creates counter-entry)
  reversal,

  /// Mid-cycle joiner catch-up balance
  openingBalance,

  /// Admin corrections (rare, fully audited)
  adjustment,
}

/// Transaction verification status for dual-state payment tracking
enum TransactionStatus {
  /// Recorded but organizer hasn't verified funds
  pending,

  /// Organizer confirmed funds received
  verified,

  /// Payment bounced or was cancelled
  rejected,
}

/// Slot lifecycle status
enum SlotStatus {
  /// Normal active participation
  active,

  /// Has received prize but continues paying (reduced EMI)
  won,

  /// Missed multiple payments, flagged for follow-up
  defaulted,

  /// Completed participation or terminated early
  closed,
}

/// Chitti lifecycle status
enum ChittiStatus {
  /// Being configured, not yet started
  draft,

  /// Active and accepting payments
  active,

  /// All months completed successfully
  completed,

  /// Temporarily paused (admin action)
  suspended,

  /// Permanently closed before completion
  terminated,
}

/// Asset class for multi-currency support
enum AssetClass {
  /// Fiat currency (AED, INR, etc.)
  currency,

  /// Weight-based gold
  gold,
}

/// Gold types supported
enum GoldType { coin, bar, biscuit, jewelry }

/// Gold purity levels
enum GoldPurity { karat24, karat22, karat18 }

/// Payment method for tracking
enum PaymentMethod { cash, bankTransfer, upi, cheque, online, other }

/// Lucky draw selection algorithms
enum DrawAlgorithm {
  /// Pure random selection
  random,

  /// Reproducible hash-based selection
  deterministic,

  /// Higher payment compliance = higher chance
  weighted,
}

// Extension methods for enum serialization
extension TransactionTypeX on TransactionType {
  String get value => name;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionType.payment,
    );
  }

  /// Returns true if this transaction type adds to the member's balance (credit)
  bool get isCredit =>
      this == TransactionType.payment ||
      this == TransactionType.discount;

  /// Returns true if this transaction type reduces the member's balance (debit)
  /// FIX: openingBalance is a debit because it represents money the member OWES
  /// (mid-cycle joiner catch-up amount), not money they've paid in.
  bool get isDebit =>
      this == TransactionType.prizePayout ||
      this == TransactionType.openingBalance;
}

extension TransactionStatusX on TransactionStatus {
  String get value => name;

  static TransactionStatus fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionStatus.pending,
    );
  }
}

extension SlotStatusX on SlotStatus {
  String get value => name;

  static SlotStatus fromString(String value) {
    return SlotStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SlotStatus.active,
    );
  }
}

extension ChittiStatusX on ChittiStatus {
  String get value => name;

  static ChittiStatus fromString(String value) {
    return ChittiStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ChittiStatus.draft,
    );
  }
}

extension GoldTypeX on GoldType {
  String get displayName {
    switch (this) {
      case GoldType.coin:
        return 'Coin';
      case GoldType.bar:
        return 'Bar';
      case GoldType.biscuit:
        return 'Biscuit';
      case GoldType.jewelry:
        return 'Jewelry';
    }
  }

  String get emoji {
    switch (this) {
      case GoldType.coin:
        return '🪙';
      case GoldType.bar:
        return '📦';
      case GoldType.biscuit:
        return '🧱';
      case GoldType.jewelry:
        return '💍';
    }
  }

  static GoldType fromString(String value) {
    return GoldType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => GoldType.coin,
    );
  }
}

extension GoldPurityX on GoldPurity {
  String get displayName {
    switch (this) {
      case GoldPurity.karat24:
        return '24 Karat';
      case GoldPurity.karat22:
        return '22 Karat';
      case GoldPurity.karat18:
        return '18 Karat';
    }
  }

  double get purityFactor {
    switch (this) {
      case GoldPurity.karat24:
        return 1.0;
      case GoldPurity.karat22:
        return 22 / 24;
      case GoldPurity.karat18:
        return 18 / 24;
    }
  }

  static GoldPurity fromString(String value) {
    final normalized = value.toLowerCase().replaceAll(' ', '');
    if (normalized.contains('24')) return GoldPurity.karat24;
    if (normalized.contains('22')) return GoldPurity.karat22;
    if (normalized.contains('18')) return GoldPurity.karat18;
    return GoldPurity.karat24;
  }
}

extension PaymentMethodX on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.cheque:
        return 'Cheque';
      case PaymentMethod.online:
        return 'Online';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => PaymentMethod.cash,
    );
  }
}

/// Settlement status for a slot during gold handover
enum SlotSettlementStatus {
  /// No handover initiated
  none,

  /// Gold physically handed over, settlement pending
  goldHandedOver,

  /// Settlement payment pending from member
  settlementPending,

  /// Member has fully settled the remaining amount
  settledUp,

  /// Organizer owes refund to member (gold rate dropped)
  refundPending,

  /// Organizer has refunded the overpayment
  refundCompleted,
}

extension SlotSettlementStatusX on SlotSettlementStatus {
  String get value => name;

  String get displayLabel {
    switch (this) {
      case SlotSettlementStatus.none:
        return 'Active';
      case SlotSettlementStatus.goldHandedOver:
        return 'Gold Handed Over';
      case SlotSettlementStatus.settlementPending:
        return 'Settlement Pending';
      case SlotSettlementStatus.settledUp:
        return 'Settled';
      case SlotSettlementStatus.refundPending:
        return 'Refund Pending';
      case SlotSettlementStatus.refundCompleted:
        return 'Refund Completed';
    }
  }

  String get emoji {
    switch (this) {
      case SlotSettlementStatus.none:
        return '🟢';
      case SlotSettlementStatus.goldHandedOver:
        return '🪙';
      case SlotSettlementStatus.settlementPending:
        return '⏳';
      case SlotSettlementStatus.settledUp:
        return '✅';
      case SlotSettlementStatus.refundPending:
        return '🔴';
      case SlotSettlementStatus.refundCompleted:
        return '✅';
    }
  }

  static SlotSettlementStatus fromString(String value) {
    return SlotSettlementStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SlotSettlementStatus.none,
    );
  }
}

/// How the settlement was resolved
enum SettlementType {
  /// Full one-time payment of remaining balance
  oneTimePayment,

  /// Remaining balance split into new EMI installments
  revampEMI,

  /// Manually recorded transaction
  manualTransaction,

  /// Refund to member (organizer owes)
  refund,
}

extension SettlementTypeX on SettlementType {
  String get value => name;

  String get displayLabel {
    switch (this) {
      case SettlementType.oneTimePayment:
        return 'One-Time Payment';
      case SettlementType.revampEMI:
        return 'Revamp EMI';
      case SettlementType.manualTransaction:
        return 'Manual Transaction';
      case SettlementType.refund:
        return 'Refund';
    }
  }

  static SettlementType fromString(String value) {
    return SettlementType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SettlementType.manualTransaction,
    );
  }
}
