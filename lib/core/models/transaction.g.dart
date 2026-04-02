// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      id: json['id'] as String,
      slotId: json['slotId'] as String,
      chittiId: json['chittiId'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      amountInCents: (json['amountInCents'] as num).toInt(),
      balanceBeforeInCents: (json['balanceBeforeInCents'] as num).toInt(),
      balanceAfterInCents: (json['balanceAfterInCents'] as num).toInt(),
      monthKey: json['monthKey'] as String,
      status:
          $enumDecodeNullable(_$TransactionStatusEnumMap, json['status']) ??
          TransactionStatus.pending,
      paymentMethod:
          $enumDecodeNullable(_$PaymentMethodEnumMap, json['paymentMethod']) ??
          PaymentMethod.cash,
      linkedTransactionId: json['linkedTransactionId'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      notes: json['notes'] as String?,
      receiptNumber: json['receiptNumber'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      verifiedAt: json['verifiedAt'] == null
          ? null
          : DateTime.parse(json['verifiedAt'] as String),
      verifiedBy: json['verifiedBy'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      slotNumber: (json['slotNumber'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slotId': instance.slotId,
      'chittiId': instance.chittiId,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'amountInCents': instance.amountInCents,
      'balanceBeforeInCents': instance.balanceBeforeInCents,
      'balanceAfterInCents': instance.balanceAfterInCents,
      'monthKey': instance.monthKey,
      'status': _$TransactionStatusEnumMap[instance.status]!,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'linkedTransactionId': instance.linkedTransactionId,
      'referenceNumber': instance.referenceNumber,
      'notes': instance.notes,
      'receiptNumber': instance.receiptNumber,
      'createdAt': instance.createdAt.toIso8601String(),
      'verifiedAt': instance.verifiedAt?.toIso8601String(),
      'verifiedBy': instance.verifiedBy,
      'userId': instance.userId,
      'userName': instance.userName,
      'slotNumber': instance.slotNumber,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.payment: 'payment',
  TransactionType.discount: 'discount',
  TransactionType.prizePayout: 'prizePayout',
  TransactionType.reversal: 'reversal',
  TransactionType.adjustment: 'adjustment',
  TransactionType.openingBalance: 'openingBalance',
  TransactionType.goldHandover: 'goldHandover',
  TransactionType.settlementPayment: 'settlementPayment',
  TransactionType.settlementRefund: 'settlementRefund',
};

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'pending',
  TransactionStatus.verified: 'verified',
  TransactionStatus.rejected: 'rejected',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.bankTransfer: 'bankTransfer',
  PaymentMethod.upi: 'upi',
  PaymentMethod.cheque: 'cheque',
  PaymentMethod.card: 'card',
  PaymentMethod.other: 'other',
};
