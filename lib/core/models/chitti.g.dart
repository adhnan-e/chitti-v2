// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chitti.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChittiImpl _$$ChittiImplFromJson(Map<String, dynamic> json) => _$ChittiImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  duration: (json['duration'] as num).toInt(),
  startMonth: json['startMonth'] as String,
  currentMonth: (json['currentMonth'] as num?)?.toInt() ?? 1,
  maxSlots: (json['maxSlots'] as num).toInt(),
  filledSlots: (json['filledSlots'] as num?)?.toInt() ?? 0,
  paymentDay: (json['paymentDay'] as num).toInt(),
  luckyDrawDay: (json['luckyDrawDay'] as num).toInt(),
  status:
      $enumDecodeNullable(_$ChittiStatusEnumMap, json['status']) ??
      ChittiStatus.draft,
  goldOptions: (json['goldOptions'] as List<dynamic>)
      .map((e) => ChittiGoldOption.fromJson(e as Map<String, dynamic>))
      .toList(),
  goldOptionRewards: (json['goldOptionRewards'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, RewardConfig.fromJson(e as Map<String, dynamic>)),
  ),
  createdAt: DateTime.parse(json['createdAt'] as String),
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  totalCollected: (json['totalCollected'] as num?)?.toDouble() ?? 0.0,
  totalPending: (json['totalPending'] as num?)?.toDouble() ?? 0.0,
  drawInProgress: json['drawInProgress'] as bool? ?? false,
  createdBy: json['createdBy'] as String?,
);

Map<String, dynamic> _$$ChittiImplToJson(_$ChittiImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'duration': instance.duration,
      'startMonth': instance.startMonth,
      'currentMonth': instance.currentMonth,
      'maxSlots': instance.maxSlots,
      'filledSlots': instance.filledSlots,
      'paymentDay': instance.paymentDay,
      'luckyDrawDay': instance.luckyDrawDay,
      'status': _$ChittiStatusEnumMap[instance.status]!,
      'goldOptions': instance.goldOptions,
      'goldOptionRewards': instance.goldOptionRewards,
      'createdAt': instance.createdAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'totalCollected': instance.totalCollected,
      'totalPending': instance.totalPending,
      'drawInProgress': instance.drawInProgress,
      'createdBy': instance.createdBy,
    };

const _$ChittiStatusEnumMap = {
  ChittiStatus.draft: 'draft',
  ChittiStatus.active: 'active',
  ChittiStatus.completed: 'completed',
  ChittiStatus.suspended: 'suspended',
  ChittiStatus.terminated: 'terminated',
};

_$ChittiGoldOptionImpl _$$ChittiGoldOptionImplFromJson(
  Map<String, dynamic> json,
) => _$ChittiGoldOptionImpl(
  id: json['id'] as String,
  type: $enumDecode(_$GoldTypeEnumMap, json['type']),
  purity: $enumDecode(_$GoldPurityEnumMap, json['purity']),
  weight: (json['weight'] as num).toDouble(),
  pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
  emiAmount: (json['emiAmount'] as num).toDouble(),
);

Map<String, dynamic> _$$ChittiGoldOptionImplToJson(
  _$ChittiGoldOptionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$GoldTypeEnumMap[instance.type]!,
  'purity': _$GoldPurityEnumMap[instance.purity]!,
  'weight': instance.weight,
  'pricePerUnit': instance.pricePerUnit,
  'totalPrice': instance.totalPrice,
  'emiAmount': instance.emiAmount,
};

const _$GoldTypeEnumMap = {
  GoldType.coin: 'coin',
  GoldType.bar: 'bar',
  GoldType.biscuit: 'biscuit',
  GoldType.jewelry: 'jewelry',
};

const _$GoldPurityEnumMap = {
  GoldPurity.karat24: 'karat24',
  GoldPurity.karat22: 'karat22',
  GoldPurity.karat18: 'karat18',
};

_$RewardConfigImpl _$$RewardConfigImplFromJson(Map<String, dynamic> json) =>
    _$RewardConfigImpl(
      enabled: json['enabled'] as bool? ?? true,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      calculatedAmount: (json['calculatedAmount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$RewardConfigImplToJson(_$RewardConfigImpl instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'type': instance.type,
      'value': instance.value,
      'calculatedAmount': instance.calculatedAmount,
    };
