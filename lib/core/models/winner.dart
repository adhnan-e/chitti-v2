/// Winner Model - Lucky draw winner record
///
/// Tracks winners, their prize details, and the discount cascade applied
/// to their remaining payments.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/enums.dart';

part 'winner.freezed.dart';
part 'winner.g.dart';

/// Immutable winner record with discount tracking.
@freezed
class Winner with _$Winner {
  const Winner._();

  const factory Winner({
    /// Unique winner record identifier
    required String id,

    /// Parent chitty ID
    required String chittiId,

    /// Winning slot ID
    required String slotId,

    /// User ID of winner
    required String userId,

    /// Display name of winner
    required String userName,

    /// Slot number for display
    int? slotNumber,

    /// Month when they won (YYYY-MM format)
    required String winnerMonth,

    /// Month from which discount starts (month after winning)
    required String discountStartMonth,

    /// Prize amount (typically the slot's total value)
    required double prizeAmount,

    /// Discount applied per month to future payments
    required double discountPerMonth,

    /// Total discount over all remaining months
    required double totalDiscount,

    /// How winner was selected
    @Default(DrawAlgorithm.random) DrawAlgorithm selectionMethod,

    /// Whether discount has been applied to slot's balance
    @Default(false) bool discountApplied,

    /// When winner was declared
    required DateTime declaredAt,

    /// Gold option details for display
    String? goldOptionLabel,
  }) = _Winner;

  factory Winner.fromJson(Map<String, dynamic> json) => _$WinnerFromJson(json);

  /// Create from Firebase map with type conversions
  factory Winner.fromFirebase(String id, Map<String, dynamic> data) {
    // Parse selection method
    DrawAlgorithm method = DrawAlgorithm.random;
    final methodStr = data['selectionMethod'] as String?;
    if (methodStr != null) {
      method = DrawAlgorithm.values.firstWhere(
        (e) => e.name == methodStr,
        orElse: () => DrawAlgorithm.random,
      );
    }

    return Winner(
      id: id,
      chittiId: data['chittiId'] as String? ?? '',
      slotId: data['slotId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      slotNumber: data['slotNumber'] as int?,
      winnerMonth:
          data['month'] as String? ?? data['winnerMonth'] as String? ?? '',
      discountStartMonth: data['discountStartMonth'] as String? ?? '',
      prizeAmount:
          (data['prizeAmount'] as num?)?.toDouble() ??
          (data['prize'] as num?)?.toDouble() ??
          0.0,
      discountPerMonth: (data['discountPerMonth'] as num?)?.toDouble() ?? 0.0,
      totalDiscount: (data['totalDiscount'] as num?)?.toDouble() ?? 0.0,
      selectionMethod: method,
      discountApplied: data['discountApplied'] as bool? ?? false,
      declaredAt: _parseDateTime(data['declaredAt']),
      goldOptionLabel: data['goldOptionLabel'] as String?,
    );
  }

  /// Convert to Firebase-compatible map
  Map<String, dynamic> toFirebase() {
    return {
      'chittiId': chittiId,
      'slotId': slotId,
      'userId': userId,
      'userName': userName,
      if (slotNumber != null) 'slotNumber': slotNumber,
      'month': winnerMonth,
      'winnerMonth': winnerMonth,
      'discountStartMonth': discountStartMonth,
      'prizeAmount': prizeAmount,
      'prize': prizeAmount, // Legacy compatibility
      'discountPerMonth': discountPerMonth,
      'totalDiscount': totalDiscount,
      'selectionMethod': selectionMethod.name,
      'discountApplied': discountApplied,
      'declaredAt': declaredAt.toIso8601String(),
      if (goldOptionLabel != null) 'goldOptionLabel': goldOptionLabel,
    };
  }

  /// Summary for display
  String get summary =>
      '$userName (Slot ${slotNumber ?? "?"}) - Prize: $prizeAmount';

  /// Whether discount is being applied this month or later
  bool isDiscountActiveInMonth(String month) {
    return _isMonthOnOrAfter(month, discountStartMonth);
  }
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
