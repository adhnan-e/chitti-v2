/// Slot Model - The fundamental accounting unit
///
/// A Slot represents a member's participation position in a Chitti.
/// One User can have multiple Slots in the same Chitti.
/// Each Slot has its own independent lifecycle, payments, and balance.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/enums.dart';

part 'slot.freezed.dart';
part 'slot.g.dart';

/// Immutable slot representing a participation position in a Chitti.
@freezed
class Slot with _$Slot {
  const Slot._();

  const factory Slot({
    /// Unique slot identifier
    required String id,

    /// Parent chitti ID
    required String chittiId,

    /// User who owns this slot
    required String userId,

    /// Position number in the chitty (1, 2, 3...)
    required int slotNumber,

    /// Selected gold option ID
    required String goldOptionId,

    /// Gold option details (denormalized for display)
    GoldOptionSnapshot? goldOption,

    /// Opening balance for mid-cycle joiners (catch-up amount)
    @Default(0.0) double openingBalance,

    /// Regular monthly EMI amount (before any discounts)
    required double monthlyEMI,

    /// Total amount due over the chitty duration
    required double totalDue,

    /// Total amount paid so far
    @Default(0.0) double totalPaid,

    /// Current balance (totalPaid - totalDue, negative = owes)
    @Default(0.0) double currentBalance,

    /// Slot lifecycle status
    @Default(SlotStatus.active) SlotStatus status,

    /// Month when member joined (YYYY-MM format)
    required String joinedMonth,

    /// Whether this slot has won the lucky draw
    @Default(false) bool isWinner,

    /// Month when slot won (YYYY-MM format)
    String? winnerMonth,

    /// Month from which discount starts (month after winning)
    String? discountStartMonth,

    /// Discount amount per month after winning
    double? discountPerMonth,

    /// Total discount over remaining months
    double? totalDiscount,

    /// Original EMI before discount (for display)
    double? originalMonthlyEMI,

    /// Prize amount when winner
    double? prizeAmount,

    /// Last payment date
    DateTime? lastPaymentDate,

    /// When slot was created
    required DateTime createdAt,

    /// User name for display (denormalized)
    String? userName,

    /// User phone for display (denormalized)
    String? userPhone,

    /// Settlement status for gold handover
    @Default(SlotSettlementStatus.none) SlotSettlementStatus settlementStatus,

    /// Gold handover record ID (links to gold_handovers node)
    String? goldHandoverId,

    /// Total gold cost at time of handover
    double? currentTotalGoldCost,

    /// Settlement difference: positive = member owes, negative = organizer owes
    double? settlementDifference,
  }) = _Slot;

  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);

  /// Create from Firebase map with type conversions
  factory Slot.fromFirebase(String id, Map<String, dynamic> data) {
    // Parse gold option if present - ensure proper Map conversion
    GoldOptionSnapshot? goldOption;
    if (data['goldOptionV2'] != null) {
      final goData = Map<String, dynamic>.from(data['goldOptionV2'] as Map);
      goldOption = GoldOptionSnapshot(
        id: goData['id'] as String? ?? '',
        type: goData['type'] as String? ?? '',
        purity: goData['purity'] as String? ?? '',
        weight: (goData['weight'] as num?)?.toDouble() ?? 0,
        price: (goData['price'] as num?)?.toDouble() ?? 0,
      );
    }

    // Parse balance data - ensure proper Map conversion
    final balance = data['balance'] != null
        ? Map<String, dynamic>.from(data['balance'] as Map)
        : <String, dynamic>{};

    return Slot(
      id: id,
      chittiId: data['chittiId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      slotNumber: data['slotNumber'] as int? ?? 0,
      goldOptionId:
          data['goldOptionId'] as String? ??
          (data['goldOptionV2'] as Map?)?['id'] as String? ??
          '',
      goldOption: goldOption,
      openingBalance: (data['openingBalance'] as num?)?.toDouble() ?? 0.0,
      monthlyEMI:
          (data['monthlyEMI'] as num?)?.toDouble() ??
          (balance['currentMonthlyAmount'] as num?)?.toDouble() ??
          0.0,
      totalDue:
          (data['totalAmount'] as num?)?.toDouble() ??
          (balance['totalDue'] as num?)?.toDouble() ??
          0.0,
      totalPaid: (balance['totalPaid'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (balance['currentBalance'] as num?)?.toDouble() ?? 0.0,
      status: SlotStatusX.fromString(data['status'] as String? ?? 'active'),
      joinedMonth: data['joinedMonth'] as String? ?? '',
      isWinner: balance['isWinner'] as bool? ?? false,
      winnerMonth: balance['winnerMonth'] as String?,
      discountStartMonth: balance['discountStartMonth'] as String?,
      discountPerMonth: (balance['discountPerMonth'] as num?)?.toDouble(),
      totalDiscount: (balance['totalDiscount'] as num?)?.toDouble(),
      originalMonthlyEMI: (balance['originalMonthlyAmount'] as num?)
          ?.toDouble(),
      prizeAmount: (balance['prizeAmount'] as num?)?.toDouble(),
      lastPaymentDate: data['lastPaymentDate'] != null
          ? DateTime.tryParse(data['lastPaymentDate'] as String)
          : null,
      createdAt: _parseDateTime(data['createdAt']),
      userName: data['userName'] as String?,
      userPhone: data['userPhone'] as String?,
      settlementStatus: SlotSettlementStatusX.fromString(
        data['settlementStatus'] as String? ?? 'none',
      ),
      goldHandoverId: data['goldHandoverId'] as String?,
      currentTotalGoldCost: (data['currentTotalGoldCost'] as num?)?.toDouble(),
      settlementDifference: (data['settlementDifference'] as num?)?.toDouble(),
    );
  }

  /// Convert to Firebase-compatible map
  Map<String, dynamic> toFirebase() {
    return {
      'chittiId': chittiId,
      'userId': userId,
      'slotNumber': slotNumber,
      'goldOptionId': goldOptionId,
      if (goldOption != null)
        'goldOptionV2': {
          'id': goldOption!.id,
          'type': goldOption!.type,
          'purity': goldOption!.purity,
          'weight': goldOption!.weight,
          'price': goldOption!.price,
        },
      'openingBalance': openingBalance,
      'monthlyEMI': monthlyEMI,
      'totalAmount': totalDue,
      'status': status.name,
      'joinedMonth': joinedMonth,
      'createdAt': createdAt.toIso8601String(),
      if (userName != null) 'userName': userName,
      if (userPhone != null) 'userPhone': userPhone,
      'balance': {
        'totalDue': totalDue,
        'totalPaid': totalPaid,
        'currentBalance': currentBalance,
        'currentMonthlyAmount': monthlyEMI,
        'isWinner': isWinner,
        if (winnerMonth != null) 'winnerMonth': winnerMonth,
        if (discountStartMonth != null)
          'discountStartMonth': discountStartMonth,
        if (discountPerMonth != null) 'discountPerMonth': discountPerMonth,
        if (totalDiscount != null) 'totalDiscount': totalDiscount,
        if (originalMonthlyEMI != null)
          'originalMonthlyAmount': originalMonthlyEMI,
        if (prizeAmount != null) 'prizeAmount': prizeAmount,
        if (lastPaymentDate != null)
          'lastPaymentDate': lastPaymentDate!.toIso8601String().split('T')[0],
      },
      'settlementStatus': settlementStatus.name,
      if (goldHandoverId != null) 'goldHandoverId': goldHandoverId,
      if (currentTotalGoldCost != null)
        'currentTotalGoldCost': currentTotalGoldCost,
      if (settlementDifference != null)
        'settlementDifference': settlementDifference,
    };
  }

  /// Get effective EMI for a given month (applies discount if winner)
  double getEffectiveEMI(String month) {
    if (!isWinner || discountStartMonth == null || discountPerMonth == null) {
      return monthlyEMI;
    }
    if (_isMonthOnOrAfter(month, discountStartMonth!)) {
      final discounted = (originalMonthlyEMI ?? monthlyEMI) - discountPerMonth!;
      return discounted > 0 ? discounted : 0;
    }
    return monthlyEMI;
  }

  /// Calculate remaining dues
  double get remainingDues => totalDue - totalPaid;

  /// Check if fully paid
  bool get isFullyPaid => currentBalance >= 0;

  /// Check if in deficit
  bool get isInDeficit => currentBalance < 0;

  /// Display label for gold option
  String get goldOptionLabel {
    if (goldOption == null) return 'Unknown';
    return '${goldOption!.type} • ${goldOption!.purity} • ${goldOption!.weight}g';
  }

  /// Get payment completion percentage
  double get paymentProgress {
    if (totalDue <= 0) return 0;
    return (totalPaid / totalDue * 100).clamp(0, 100);
  }

  /// Number of EMIs paid
  int get paidEMICount {
    final baseEMI = originalMonthlyEMI ?? monthlyEMI;
    if (baseEMI <= 0) return 0;
    return (totalPaid / baseEMI).floor();
  }
}

/// Snapshot of gold option for denormalized storage in Slot
@freezed
class GoldOptionSnapshot with _$GoldOptionSnapshot {
  const factory GoldOptionSnapshot({
    required String id,
    required String type,
    required String purity,
    required double weight,
    required double price,
  }) = _GoldOptionSnapshot;

  factory GoldOptionSnapshot.fromJson(Map<String, dynamic> json) =>
      _$GoldOptionSnapshotFromJson(json);
}

/// Check if month1 is on or after month2 (YYYY-MM format)
bool _isMonthOnOrAfter(String month1, String month2) {
  try {
    final parts1 = month1.split('-');
    final parts2 = month2.split('-');
    final y1 = int.parse(parts1[0]);
    final m1 = int.parse(parts1[1]);
    final y2 = int.parse(parts2[0]);
    final m2 = int.parse(parts2[1]);

    if (y1 > y2) return true;
    if (y1 == y2 && m1 >= m2) return true;
    return false;
  } catch (_) {
    return false;
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
