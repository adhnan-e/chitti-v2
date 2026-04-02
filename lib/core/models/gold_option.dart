/// Model representing a gold option configuration
/// Combines type (coin, biscuit, etc.), purity (24k, 22k, etc.), and weight
class GoldOption {
  final String id;
  final String type; // e.g., 'Coin', 'Biscuit', 'Bar', 'Jewelry'
  final String purity; // e.g., '24 Karat', '22 Karat', '18 Karat'
  final num weight; // Weight in grams (supports decimals)

  const GoldOption({
    required this.id,
    required this.type,
    required this.purity,
    required this.weight,
  });

  /// Create from Firebase map
  factory GoldOption.fromMap(Map<String, dynamic> map) {
    return GoldOption(
      id: map['id'] as String? ?? '',
      type: map['type'] as String? ?? '',
      purity: map['purity'] as String? ?? '',
      weight: (map['weight'] as num?) ?? 0,
    );
  }

  /// Convert to Firebase map
  Map<String, dynamic> toMap() {
    return {'id': id, 'type': type, 'purity': purity, 'weight': weight};
  }

  /// Display label for UI (e.g., "Coin • 22 Karat • 10g")
  String get displayLabel => '$type • $purity • ${weight}g';

  /// Short label (e.g., "10g")
  String get weightLabel => '${weight}g';

  /// Get icon data based on type
  String get typeIcon {
    switch (type.toLowerCase()) {
      case 'coin':
        return '🪙';
      case 'biscuit':
        return '🧱';
      case 'bar':
        return '📦';
      case 'jewelry':
        return '💍';
      default:
        return '✨';
    }
  }

  /// Generate unique ID for a new option
  static String generateId() {
    return 'opt_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GoldOption && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'GoldOption($displayLabel)';

  /// Copy with modifications
  GoldOption copyWith({String? id, String? type, String? purity, num? weight}) {
    return GoldOption(
      id: id ?? this.id,
      type: type ?? this.type,
      purity: purity ?? this.purity,
      weight: weight ?? this.weight,
    );
  }
}
