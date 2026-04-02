/// Chitti Model - The main fund configuration
///
/// A Chitti represents a chit fund with configurable duration, gold options,
/// and reward configurations. It manages the lifecycle and rules.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/enums.dart';

part 'chitti.freezed.dart';
part 'chitti.g.dart';

/// Immutable Chitti (Chit Fund) configuration and state.
@freezed
class Chitti with _$Chitti {
  const Chitti._();

  const factory Chitti({
    /// Unique chitti identifier
    required String id,

    /// Display name for the chitti
    required String name,

    /// Total duration in months
    required int duration,

    /// Start month (YYYY-MM format)
    required String startMonth,

    /// Current active month (1-indexed)
    @Default(1) int currentMonth,

    /// Maximum number of slots allowed
    required int maxSlots,

    /// Current count of filled slots
    @Default(0) int filledSlots,

    /// Day of month for EMI payments (1-28)
    required int paymentDay,

    /// Day of month for lucky draw (1-28)
    required int luckyDrawDay,

    /// Chitti lifecycle status
    @Default(ChittiStatus.draft) ChittiStatus status,

    /// Available gold options for this chitti
    required List<ChittiGoldOption> goldOptions,

    /// Per-option reward configurations
    Map<String, RewardConfig>? goldOptionRewards,

    /// When chitty was created
    required DateTime createdAt,

    /// When chitti was started (status -> active)
    DateTime? startedAt,

    /// When chitti was completed
    DateTime? completedAt,

    /// Total collected amount
    @Default(0.0) double totalCollected,

    /// Total pending amount
    @Default(0.0) double totalPending,

    /// Whether lucky draw is in progress (soft lock)
    @Default(false) bool drawInProgress,

    /// Creator user ID
    String? createdBy,
  }) = _Chitti;

  factory Chitti.fromJson(Map<String, dynamic> json) => _$ChittiFromJson(json);

  /// Create from Firebase map with type conversions
  factory Chitti.fromFirebase(String id, Map<String, dynamic> data) {
    // Parse gold options - ensure proper type conversion
    final goldOptionsData = data['goldOptions'] as List? ?? [];
    final goldOptions = goldOptionsData.map((item) {
      final goMap = Map<String, dynamic>.from(item as Map);
      return ChittiGoldOption(
        id: goMap['id'] as String? ?? '',
        type: GoldTypeX.fromString(goMap['type'] as String? ?? 'coin'),
        purity: GoldPurityX.fromString(
          goMap['purity'] as String? ?? '24 Karat',
        ),
        weight: (goMap['weight'] as num?)?.toDouble() ?? 0,
        pricePerUnit:
            (goMap['pricePerUnit'] as num?)?.toDouble() ??
            (goMap['price'] as num?)?.toDouble() ??
            0,
        totalPrice:
            (goMap['totalPrice'] as num?)?.toDouble() ??
            (goMap['price'] as num?)?.toDouble() ??
            0,
        emiAmount: (goMap['emiAmount'] as num?)?.toDouble() ?? 0,
      );
    }).toList();

    // Parse reward configs - ensure proper type conversion
    Map<String, RewardConfig>? goldOptionRewards;
    if (data['goldOptionRewards'] != null) {
      final rewardsMap = Map<String, dynamic>.from(
        data['goldOptionRewards'] as Map,
      );
      goldOptionRewards = {};
      rewardsMap.forEach((key, value) {
        final rcMap = Map<String, dynamic>.from(value as Map);
        goldOptionRewards![key] = RewardConfig(
          enabled: rcMap['enabled'] as bool? ?? false,
          type: rcMap['type'] as String? ?? 'Fixed Amount',
          value: (rcMap['value'] as num?)?.toDouble() ?? 0,
          calculatedAmount: (rcMap['calculatedAmount'] as num?)?.toDouble(),
        );
      });
    }

    return Chitti(
      id: id,
      name: data['name'] as String? ?? '',
      duration: data['duration'] as int? ?? 12,
      startMonth: data['startMonth'] as String? ?? '',
      currentMonth: data['currentMonth'] as int? ?? 1,
      maxSlots: data['maxSlots'] as int? ?? 20,
      filledSlots: data['filledSlots'] as int? ?? 0,
      paymentDay: data['paymentDay'] as int? ?? 1,
      luckyDrawDay: data['luckyDrawDay'] as int? ?? 15,
      status: ChittiStatusX.fromString(data['status'] as String? ?? 'draft'),
      goldOptions: goldOptions,
      goldOptionRewards: goldOptionRewards,
      createdAt: _parseDateTime(data['createdAt']),
      startedAt: data['startedAt'] != null
          ? _parseDateTime(data['startedAt'])
          : null,
      completedAt: data['completedAt'] != null
          ? _parseDateTime(data['completedAt'])
          : null,
      totalCollected: (data['totalCollected'] as num?)?.toDouble() ?? 0.0,
      totalPending: (data['totalPending'] as num?)?.toDouble() ?? 0.0,
      drawInProgress: data['drawInProgress'] as bool? ?? false,
      createdBy: data['createdBy'] as String?,
    );
  }

  /// Convert to Firebase-compatible map
  Map<String, dynamic> toFirebase() {
    return {
      'name': name,
      'duration': duration,
      'startMonth': startMonth,
      'currentMonth': currentMonth,
      'maxSlots': maxSlots,
      'filledSlots': filledSlots,
      'paymentDay': paymentDay,
      'luckyDrawDay': luckyDrawDay,
      'status': status.name,
      'goldOptions': goldOptions
          .map(
            (go) => {
              'id': go.id,
              'type': go.type.name,
              'purity': go.purity.displayName,
              'weight': go.weight,
              'pricePerUnit': go.pricePerUnit,
              'totalPrice': go.totalPrice,
              'emiAmount': go.emiAmount,
            },
          )
          .toList(),
      if (goldOptionRewards != null)
        'goldOptionRewards': goldOptionRewards!.map(
          (k, v) => MapEntry(k, {
            'enabled': v.enabled,
            'type': v.type,
            'value': v.value,
            if (v.calculatedAmount != null)
              'calculatedAmount': v.calculatedAmount,
          }),
        ),
      'createdAt': createdAt.toIso8601String(),
      if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      'totalCollected': totalCollected,
      'totalPending': totalPending,
      'drawInProgress': drawInProgress,
      if (createdBy != null) 'createdBy': createdBy,
    };
  }

  /// Whether the chitti is active and accepting payments
  bool get isActive => status == ChittiStatus.active;

  /// Whether the chitti has available slots
  bool get hasAvailableSlots => filledSlots < maxSlots;

  /// Available slots count
  int get availableSlots => maxSlots - filledSlots;

  /// Whether in final month
  bool get isInFinalMonth => currentMonth >= duration;

  /// Progress percentage
  double get monthProgress => (currentMonth / duration * 100).clamp(0, 100);

  /// Get month key for a given month number (1-indexed)
  String getMonthKey(int monthNumber) {
    try {
      final parts = startMonth.split('-');
      final startYear = int.parse(parts[0]);
      final startMonthNum = int.parse(parts[1]);

      final totalMonths = startMonthNum + monthNumber - 2;
      final year = startYear + (totalMonths ~/ 12);
      final month = (totalMonths % 12) + 1;

      return '$year-${month.toString().padLeft(2, '0')}';
    } catch (_) {
      return startMonth;
    }
  }

  /// Get current month key
  String get currentMonthKey => getMonthKey(currentMonth);
}

/// Gold option configuration for a Chitti
@freezed
class ChittiGoldOption with _$ChittiGoldOption {
  const ChittiGoldOption._();

  const factory ChittiGoldOption({
    /// Unique option identifier
    required String id,

    /// Type of gold (coin, bar, etc.)
    required GoldType type,

    /// Purity level
    required GoldPurity purity,

    /// Weight in grams
    required double weight,

    /// Price per gram (locked at chitty creation)
    required double pricePerUnit,

    /// Total price (weight × pricePerUnit)
    required double totalPrice,

    /// Monthly EMI amount (totalPrice / duration)
    required double emiAmount,
  }) = _ChittiGoldOption;

  factory ChittiGoldOption.fromJson(Map<String, dynamic> json) =>
      _$ChittiGoldOptionFromJson(json);


  /// Display label
  String get displayLabel =>
      '${type.displayName} • ${purity.displayName} • ${weight}g';

  /// Short label
  String get shortLabel => '${weight}g ${type.displayName}';
}

/// Reward/Discount configuration per gold option
@freezed
class RewardConfig with _$RewardConfig {
  const RewardConfig._();

  const factory RewardConfig({
    /// Whether rewards are enabled for this option
    @Default(true) bool enabled,

    /// Reward type: 'Percentage' or 'Fixed Amount'
    required String type,

    /// Value (percentage or fixed amount)
    required double value,

    /// Pre-computed discount amount per month
    double? calculatedAmount,
  }) = _RewardConfig;

  factory RewardConfig.fromJson(Map<String, dynamic> json) =>
      _$RewardConfigFromJson(json);

  /// Calculate monthly discount for a given total amount and duration
  double calculateMonthlyDiscount(double totalAmount, int remainingMonths) {
    if (!enabled || remainingMonths <= 0) return 0;
    if (type == 'Percentage') {
      return totalAmount * (value / 100) / remainingMonths;
    }
    return value; // Fixed amount per month
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
