// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SlotImpl _$$SlotImplFromJson(Map<String, dynamic> json) => _$SlotImpl(
  id: json['id'] as String,
  chittiId: json['chittiId'] as String,
  userId: json['userId'] as String,
  slotNumber: (json['slotNumber'] as num).toInt(),
  goldOptionId: json['goldOptionId'] as String,
  goldOption: json['goldOption'] == null
      ? null
      : GoldOptionSnapshot.fromJson(json['goldOption'] as Map<String, dynamic>),
  openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
  monthlyEMI: (json['monthlyEMI'] as num).toDouble(),
  totalDue: (json['totalDue'] as num).toDouble(),
  totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
  currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
  status:
      $enumDecodeNullable(_$SlotStatusEnumMap, json['status']) ??
      SlotStatus.active,
  joinedMonth: json['joinedMonth'] as String,
  isWinner: json['isWinner'] as bool? ?? false,
  winnerMonth: json['winnerMonth'] as String?,
  discountStartMonth: json['discountStartMonth'] as String?,
  discountPerMonth: (json['discountPerMonth'] as num?)?.toDouble(),
  totalDiscount: (json['totalDiscount'] as num?)?.toDouble(),
  originalMonthlyEMI: (json['originalMonthlyEMI'] as num?)?.toDouble(),
  prizeAmount: (json['prizeAmount'] as num?)?.toDouble(),
  lastPaymentDate: json['lastPaymentDate'] == null
      ? null
      : DateTime.parse(json['lastPaymentDate'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  userName: json['userName'] as String?,
  userPhone: json['userPhone'] as String?,
  settlementStatus:
      $enumDecodeNullable(
        _$SlotSettlementStatusEnumMap,
        json['settlementStatus'],
      ) ??
      SlotSettlementStatus.none,
  goldHandoverId: json['goldHandoverId'] as String?,
  currentTotalGoldCost: (json['currentTotalGoldCost'] as num?)?.toDouble(),
  settlementDifference: (json['settlementDifference'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$SlotImplToJson(
  _$SlotImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'chittiId': instance.chittiId,
  'userId': instance.userId,
  'slotNumber': instance.slotNumber,
  'goldOptionId': instance.goldOptionId,
  'goldOption': instance.goldOption,
  'openingBalance': instance.openingBalance,
  'monthlyEMI': instance.monthlyEMI,
  'totalDue': instance.totalDue,
  'totalPaid': instance.totalPaid,
  'currentBalance': instance.currentBalance,
  'status': _$SlotStatusEnumMap[instance.status]!,
  'joinedMonth': instance.joinedMonth,
  'isWinner': instance.isWinner,
  'winnerMonth': instance.winnerMonth,
  'discountStartMonth': instance.discountStartMonth,
  'discountPerMonth': instance.discountPerMonth,
  'totalDiscount': instance.totalDiscount,
  'originalMonthlyEMI': instance.originalMonthlyEMI,
  'prizeAmount': instance.prizeAmount,
  'lastPaymentDate': instance.lastPaymentDate?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'userName': instance.userName,
  'userPhone': instance.userPhone,
  'settlementStatus': _$SlotSettlementStatusEnumMap[instance.settlementStatus]!,
  'goldHandoverId': instance.goldHandoverId,
  'currentTotalGoldCost': instance.currentTotalGoldCost,
  'settlementDifference': instance.settlementDifference,
};

const _$SlotStatusEnumMap = {
  SlotStatus.active: 'active',
  SlotStatus.won: 'won',
  SlotStatus.defaulted: 'defaulted',
  SlotStatus.closed: 'closed',
};

const _$SlotSettlementStatusEnumMap = {
  SlotSettlementStatus.none: 'none',
  SlotSettlementStatus.goldHandedOver: 'goldHandedOver',
  SlotSettlementStatus.settlementPending: 'settlementPending',
  SlotSettlementStatus.settledUp: 'settledUp',
  SlotSettlementStatus.refundPending: 'refundPending',
  SlotSettlementStatus.refundCompleted: 'refundCompleted',
};

_$GoldOptionSnapshotImpl _$$GoldOptionSnapshotImplFromJson(
  Map<String, dynamic> json,
) => _$GoldOptionSnapshotImpl(
  id: json['id'] as String,
  type: json['type'] as String,
  purity: json['purity'] as String,
  weight: (json['weight'] as num).toDouble(),
  price: (json['price'] as num).toDouble(),
);

Map<String, dynamic> _$$GoldOptionSnapshotImplToJson(
  _$GoldOptionSnapshotImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'purity': instance.purity,
  'weight': instance.weight,
  'price': instance.price,
};
