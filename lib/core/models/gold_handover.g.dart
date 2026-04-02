// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gold_handover.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HandoverGoldSnapshotImpl _$$HandoverGoldSnapshotImplFromJson(
  Map<String, dynamic> json,
) => _$HandoverGoldSnapshotImpl(
  type: json['type'] as String,
  purity: json['purity'] as String,
  weight: (json['weight'] as num).toDouble(),
);

Map<String, dynamic> _$$HandoverGoldSnapshotImplToJson(
  _$HandoverGoldSnapshotImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'purity': instance.purity,
  'weight': instance.weight,
};

_$GoldHandoverImpl _$$GoldHandoverImplFromJson(Map<String, dynamic> json) =>
    _$GoldHandoverImpl(
      id: json['id'] as String,
      chittiId: json['chittiId'] as String,
      slotId: json['slotId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      goldOption: HandoverGoldSnapshot.fromJson(
        json['goldOption'] as Map<String, dynamic>,
      ),
      lockedTotalValue: (json['lockedTotalValue'] as num).toDouble(),
      currentTotalGoldCost: (json['currentTotalGoldCost'] as num).toDouble(),
      totalPaidByMember: (json['totalPaidByMember'] as num).toDouble(),
      settlementDifference: (json['settlementDifference'] as num).toDouble(),
      settlementType:
          $enumDecodeNullable(
            _$SettlementTypeEnumMap,
            json['settlementType'],
          ) ??
          SettlementType.oneTimePayment,
      settlementStatus:
          $enumDecodeNullable(
            _$SlotSettlementStatusEnumMap,
            json['settlementStatus'],
          ) ??
          SlotSettlementStatus.goldHandedOver,
      revampEMICount: (json['revampEMICount'] as num?)?.toInt(),
      revampEMIAmount: (json['revampEMIAmount'] as num?)?.toDouble(),
      handoverDate: DateTime.parse(json['handoverDate'] as String),
      settlementDate: json['settlementDate'] == null
          ? null
          : DateTime.parse(json['settlementDate'] as String),
      transactionIds:
          (json['transactionIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      notes: json['notes'] as String?,
      slotNumber: (json['slotNumber'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$GoldHandoverImplToJson(
  _$GoldHandoverImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'chittiId': instance.chittiId,
  'slotId': instance.slotId,
  'userId': instance.userId,
  'userName': instance.userName,
  'goldOption': instance.goldOption,
  'lockedTotalValue': instance.lockedTotalValue,
  'currentTotalGoldCost': instance.currentTotalGoldCost,
  'totalPaidByMember': instance.totalPaidByMember,
  'settlementDifference': instance.settlementDifference,
  'settlementType': _$SettlementTypeEnumMap[instance.settlementType]!,
  'settlementStatus': _$SlotSettlementStatusEnumMap[instance.settlementStatus]!,
  'revampEMICount': instance.revampEMICount,
  'revampEMIAmount': instance.revampEMIAmount,
  'handoverDate': instance.handoverDate.toIso8601String(),
  'settlementDate': instance.settlementDate?.toIso8601String(),
  'transactionIds': instance.transactionIds,
  'notes': instance.notes,
  'slotNumber': instance.slotNumber,
};

const _$SettlementTypeEnumMap = {
  SettlementType.oneTimePayment: 'oneTimePayment',
  SettlementType.revampEMI: 'revampEMI',
  SettlementType.manualTransaction: 'manualTransaction',
  SettlementType.refund: 'refund',
};

const _$SlotSettlementStatusEnumMap = {
  SlotSettlementStatus.none: 'none',
  SlotSettlementStatus.goldHandedOver: 'goldHandedOver',
  SlotSettlementStatus.settlementPending: 'settlementPending',
  SlotSettlementStatus.settledUp: 'settledUp',
  SlotSettlementStatus.refundPending: 'refundPending',
  SlotSettlementStatus.refundCompleted: 'refundCompleted',
};
