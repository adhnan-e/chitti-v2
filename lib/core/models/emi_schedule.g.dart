// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emi_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EMIEntryImpl _$$EMIEntryImplFromJson(Map<String, dynamic> json) =>
    _$EMIEntryImpl(
      monthNumber: (json['monthNumber'] as num).toInt(),
      monthKey: json['monthKey'] as String,
      monthLabel: json['monthLabel'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      originalAmountInCents: (json['originalAmountInCents'] as num).toInt(),
      discountInCents: (json['discountInCents'] as num?)?.toInt() ?? 0,
      netAmountInCents: (json['netAmountInCents'] as num).toInt(),
      paidAmountInCents: (json['paidAmountInCents'] as num?)?.toInt() ?? 0,
      status: $enumDecode(_$EMIStatusEnumMap, json['status']),
      isFirstMonth: json['isFirstMonth'] as bool? ?? false,
      roundingRemainderInCents:
          (json['roundingRemainderInCents'] as num?)?.toInt() ?? 0,
      hasWinnerDiscount: json['hasWinnerDiscount'] as bool? ?? false,
      transactionIds:
          (json['transactionIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$EMIEntryImplToJson(_$EMIEntryImpl instance) =>
    <String, dynamic>{
      'monthNumber': instance.monthNumber,
      'monthKey': instance.monthKey,
      'monthLabel': instance.monthLabel,
      'dueDate': instance.dueDate.toIso8601String(),
      'originalAmountInCents': instance.originalAmountInCents,
      'discountInCents': instance.discountInCents,
      'netAmountInCents': instance.netAmountInCents,
      'paidAmountInCents': instance.paidAmountInCents,
      'status': _$EMIStatusEnumMap[instance.status]!,
      'isFirstMonth': instance.isFirstMonth,
      'roundingRemainderInCents': instance.roundingRemainderInCents,
      'hasWinnerDiscount': instance.hasWinnerDiscount,
      'transactionIds': instance.transactionIds,
    };

const _$EMIStatusEnumMap = {
  EMIStatus.future: 'future',
  EMIStatus.upcoming: 'upcoming',
  EMIStatus.due: 'due',
  EMIStatus.overdue: 'overdue',
  EMIStatus.partial: 'partial',
  EMIStatus.paid: 'paid',
};

_$EMIScheduleImpl _$$EMIScheduleImplFromJson(Map<String, dynamic> json) =>
    _$EMIScheduleImpl(
      slotId: json['slotId'] as String,
      chittyId: json['chittyId'] as String,
      duration: (json['duration'] as num).toInt(),
      totalAmountInCents: (json['totalAmountInCents'] as num).toInt(),
      baseEMIInCents: (json['baseEMIInCents'] as num).toInt(),
      firstMonthEMIInCents: (json['firstMonthEMIInCents'] as num).toInt(),
      winnerDiscountPerMonthInCents:
          (json['winnerDiscountPerMonthInCents'] as num?)?.toInt() ?? 0,
      discountStartMonth: json['discountStartMonth'] as String?,
      entries: (json['entries'] as List<dynamic>)
          .map((e) => EMIEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$$EMIScheduleImplToJson(_$EMIScheduleImpl instance) =>
    <String, dynamic>{
      'slotId': instance.slotId,
      'chittyId': instance.chittyId,
      'duration': instance.duration,
      'totalAmountInCents': instance.totalAmountInCents,
      'baseEMIInCents': instance.baseEMIInCents,
      'firstMonthEMIInCents': instance.firstMonthEMIInCents,
      'winnerDiscountPerMonthInCents': instance.winnerDiscountPerMonthInCents,
      'discountStartMonth': instance.discountStartMonth,
      'entries': instance.entries,
      'generatedAt': instance.generatedAt.toIso8601String(),
    };
