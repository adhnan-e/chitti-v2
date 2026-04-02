// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'winner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WinnerImpl _$$WinnerImplFromJson(Map<String, dynamic> json) => _$WinnerImpl(
  id: json['id'] as String,
  chittiId: json['chittiId'] as String,
  slotId: json['slotId'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  slotNumber: (json['slotNumber'] as num?)?.toInt(),
  winnerMonth: json['winnerMonth'] as String,
  discountStartMonth: json['discountStartMonth'] as String,
  prizeAmount: (json['prizeAmount'] as num).toDouble(),
  discountPerMonth: (json['discountPerMonth'] as num).toDouble(),
  totalDiscount: (json['totalDiscount'] as num).toDouble(),
  selectionMethod:
      $enumDecodeNullable(_$DrawAlgorithmEnumMap, json['selectionMethod']) ??
      DrawAlgorithm.random,
  discountApplied: json['discountApplied'] as bool? ?? false,
  declaredAt: DateTime.parse(json['declaredAt'] as String),
  goldOptionLabel: json['goldOptionLabel'] as String?,
);

Map<String, dynamic> _$$WinnerImplToJson(_$WinnerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chittiId': instance.chittiId,
      'slotId': instance.slotId,
      'userId': instance.userId,
      'userName': instance.userName,
      'slotNumber': instance.slotNumber,
      'winnerMonth': instance.winnerMonth,
      'discountStartMonth': instance.discountStartMonth,
      'prizeAmount': instance.prizeAmount,
      'discountPerMonth': instance.discountPerMonth,
      'totalDiscount': instance.totalDiscount,
      'selectionMethod': _$DrawAlgorithmEnumMap[instance.selectionMethod]!,
      'discountApplied': instance.discountApplied,
      'declaredAt': instance.declaredAt.toIso8601String(),
      'goldOptionLabel': instance.goldOptionLabel,
    };

const _$DrawAlgorithmEnumMap = {
  DrawAlgorithm.random: 'random',
  DrawAlgorithm.deterministic: 'deterministic',
  DrawAlgorithm.weighted: 'weighted',
};
