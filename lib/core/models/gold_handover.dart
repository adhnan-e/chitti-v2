/// Gold Handover Model - Records gold delivery and settlement details
///
/// Tracks the handover of physical gold to a member, including
/// settlement calculations based on current vs. locked gold rates.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/enums.dart';

part 'gold_handover.freezed.dart';
part 'gold_handover.g.dart';

/// Snapshot of gold option details at time of handover
@freezed
class HandoverGoldSnapshot with _$HandoverGoldSnapshot {
  const factory HandoverGoldSnapshot({
    required String type,
    required String purity,
    required double weight,
  }) = _HandoverGoldSnapshot;

  factory HandoverGoldSnapshot.fromJson(Map<String, dynamic> json) =>
      _$HandoverGoldSnapshotFromJson(json);
}

/// Immutable record of a gold handover and its settlement
@freezed
class GoldHandover with _$GoldHandover {
  const GoldHandover._();

  const factory GoldHandover({
    /// Unique handover identifier
    required String id,

    /// Parent chitty ID
    required String chittiId,

    /// Slot this handover belongs to
    required String slotId,

    /// User ID of the member receiving gold
    required String userId,

    /// Display name of the member
    required String userName,

    /// Gold option details at time of handover
    required HandoverGoldSnapshot goldOption,

    /// Original total price locked at chitti creation
    required double lockedTotalValue,

    /// Total gold cost entered by organizer at handover (current market value)
    required double currentTotalGoldCost,

    /// Total amount the member has actually paid (verified)
    required double totalPaidByMember,

    /// Settlement difference: currentTotalGoldCost - totalPaidByMember
    /// Positive = member owes balance, Negative = organizer owes refund
    required double settlementDifference,

    /// How the settlement was/will be resolved
    @Default(SettlementType.oneTimePayment) SettlementType settlementType,

    /// Current settlement status
    @Default(SlotSettlementStatus.goldHandedOver)
    SlotSettlementStatus settlementStatus,

    /// Number of EMI installments (for revamp option)
    int? revampEMICount,

    /// Per-installment amount (for revamp option)
    double? revampEMIAmount,

    /// When gold was physically handed over
    required DateTime handoverDate,

    /// When full settlement was completed
    DateTime? settlementDate,

    /// List of transaction IDs related to this handover
    @Default([]) List<String> transactionIds,

    /// Optional notes
    String? notes,

    /// Slot number for display
    int? slotNumber,
  }) = _GoldHandover;

  factory GoldHandover.fromJson(Map<String, dynamic> json) =>
      _$GoldHandoverFromJson(json);

  /// Create from Firebase map with type conversions
  factory GoldHandover.fromFirebase(String id, Map<String, dynamic> data) {
    // Parse gold option snapshot
    HandoverGoldSnapshot goldOption;
    if (data['goldOption'] != null) {
      final goData = Map<String, dynamic>.from(data['goldOption'] as Map);
      goldOption = HandoverGoldSnapshot(
        type: goData['type'] as String? ?? '',
        purity: goData['purity'] as String? ?? '',
        weight: (goData['weight'] as num?)?.toDouble() ?? 0,
      );
    } else {
      goldOption = const HandoverGoldSnapshot(
        type: 'Unknown',
        purity: 'Unknown',
        weight: 0,
      );
    }

    // Parse transaction IDs list
    List<String> txnIds = [];
    if (data['transactionIds'] != null) {
      if (data['transactionIds'] is List) {
        txnIds = (data['transactionIds'] as List)
            .map((e) => e.toString())
            .toList();
      } else if (data['transactionIds'] is Map) {
        txnIds = (data['transactionIds'] as Map).values
            .map((e) => e.toString())
            .toList();
      }
    }

    return GoldHandover(
      id: id,
      chittiId: data['chittiId'] as String? ?? '',
      slotId: data['slotId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      goldOption: goldOption,
      lockedTotalValue: (data['lockedTotalValue'] as num?)?.toDouble() ?? 0,
      currentTotalGoldCost:
          (data['currentTotalGoldCost'] as num?)?.toDouble() ?? 0,
      totalPaidByMember: (data['totalPaidByMember'] as num?)?.toDouble() ?? 0,
      settlementDifference:
          (data['settlementDifference'] as num?)?.toDouble() ?? 0,
      settlementType: SettlementTypeX.fromString(
        data['settlementType'] as String? ?? 'oneTimePayment',
      ),
      settlementStatus: SlotSettlementStatusX.fromString(
        data['settlementStatus'] as String? ?? 'goldHandedOver',
      ),
      revampEMICount: data['revampEMICount'] as int?,
      revampEMIAmount: (data['revampEMIAmount'] as num?)?.toDouble(),
      handoverDate: _parseDateTime(data['handoverDate']),
      settlementDate: data['settlementDate'] != null
          ? _parseDateTime(data['settlementDate'])
          : null,
      transactionIds: txnIds,
      notes: data['notes'] as String?,
      slotNumber: data['slotNumber'] as int?,
    );
  }

  /// Convert to Firebase-compatible map
  Map<String, dynamic> toFirebase() {
    return {
      'chittiId': chittiId,
      'slotId': slotId,
      'userId': userId,
      'userName': userName,
      'goldOption': {
        'type': goldOption.type,
        'purity': goldOption.purity,
        'weight': goldOption.weight,
      },
      'lockedTotalValue': lockedTotalValue,
      'currentTotalGoldCost': currentTotalGoldCost,
      'totalPaidByMember': totalPaidByMember,
      'settlementDifference': settlementDifference,
      'settlementType': settlementType.name,
      'settlementStatus': settlementStatus.name,
      if (revampEMICount != null) 'revampEMICount': revampEMICount,
      if (revampEMIAmount != null) 'revampEMIAmount': revampEMIAmount,
      'handoverDate': handoverDate.toIso8601String(),
      if (settlementDate != null)
        'settlementDate': settlementDate!.toIso8601String(),
      'transactionIds': transactionIds,
      if (notes != null) 'notes': notes,
      if (slotNumber != null) 'slotNumber': slotNumber,
    };
  }

  // ============ Convenience Getters ============

  /// Whether member owes money after handover
  bool get memberOwes => settlementDifference > 0;

  /// Whether organizer owes refund after handover
  bool get organizerOwes => settlementDifference < 0;

  /// Whether settlement is exactly zero (no action needed)
  bool get isExactMatch => settlementDifference == 0;

  /// Absolute settlement amount (always positive)
  double get absoluteSettlementAmount => settlementDifference.abs();

  /// Whether settlement is fully completed
  bool get isFullySettled =>
      settlementStatus == SlotSettlementStatus.settledUp ||
      settlementStatus == SlotSettlementStatus.refundCompleted;

  /// Summary for display
  String get summary {
    if (isExactMatch) return '$userName - Exact Match, No Settlement';
    if (memberOwes) {
      return '$userName - Member owes ${absoluteSettlementAmount.toStringAsFixed(2)}';
    }
    return '$userName - Refund ${absoluteSettlementAmount.toStringAsFixed(2)}';
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
