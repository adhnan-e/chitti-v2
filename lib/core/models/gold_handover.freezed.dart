// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gold_handover.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HandoverGoldSnapshot _$HandoverGoldSnapshotFromJson(Map<String, dynamic> json) {
  return _HandoverGoldSnapshot.fromJson(json);
}

/// @nodoc
mixin _$HandoverGoldSnapshot {
  String get type => throw _privateConstructorUsedError;
  String get purity => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;

  /// Serializes this HandoverGoldSnapshot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HandoverGoldSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HandoverGoldSnapshotCopyWith<HandoverGoldSnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HandoverGoldSnapshotCopyWith<$Res> {
  factory $HandoverGoldSnapshotCopyWith(
    HandoverGoldSnapshot value,
    $Res Function(HandoverGoldSnapshot) then,
  ) = _$HandoverGoldSnapshotCopyWithImpl<$Res, HandoverGoldSnapshot>;
  @useResult
  $Res call({String type, String purity, double weight});
}

/// @nodoc
class _$HandoverGoldSnapshotCopyWithImpl<
  $Res,
  $Val extends HandoverGoldSnapshot
>
    implements $HandoverGoldSnapshotCopyWith<$Res> {
  _$HandoverGoldSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HandoverGoldSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? purity = null,
    Object? weight = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            purity: null == purity
                ? _value.purity
                : purity // ignore: cast_nullable_to_non_nullable
                      as String,
            weight: null == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HandoverGoldSnapshotImplCopyWith<$Res>
    implements $HandoverGoldSnapshotCopyWith<$Res> {
  factory _$$HandoverGoldSnapshotImplCopyWith(
    _$HandoverGoldSnapshotImpl value,
    $Res Function(_$HandoverGoldSnapshotImpl) then,
  ) = __$$HandoverGoldSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String type, String purity, double weight});
}

/// @nodoc
class __$$HandoverGoldSnapshotImplCopyWithImpl<$Res>
    extends _$HandoverGoldSnapshotCopyWithImpl<$Res, _$HandoverGoldSnapshotImpl>
    implements _$$HandoverGoldSnapshotImplCopyWith<$Res> {
  __$$HandoverGoldSnapshotImplCopyWithImpl(
    _$HandoverGoldSnapshotImpl _value,
    $Res Function(_$HandoverGoldSnapshotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HandoverGoldSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? purity = null,
    Object? weight = null,
  }) {
    return _then(
      _$HandoverGoldSnapshotImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        purity: null == purity
            ? _value.purity
            : purity // ignore: cast_nullable_to_non_nullable
                  as String,
        weight: null == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HandoverGoldSnapshotImpl implements _HandoverGoldSnapshot {
  const _$HandoverGoldSnapshotImpl({
    required this.type,
    required this.purity,
    required this.weight,
  });

  factory _$HandoverGoldSnapshotImpl.fromJson(Map<String, dynamic> json) =>
      _$$HandoverGoldSnapshotImplFromJson(json);

  @override
  final String type;
  @override
  final String purity;
  @override
  final double weight;

  @override
  String toString() {
    return 'HandoverGoldSnapshot(type: $type, purity: $purity, weight: $weight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HandoverGoldSnapshotImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.purity, purity) || other.purity == purity) &&
            (identical(other.weight, weight) || other.weight == weight));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, purity, weight);

  /// Create a copy of HandoverGoldSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HandoverGoldSnapshotImplCopyWith<_$HandoverGoldSnapshotImpl>
  get copyWith =>
      __$$HandoverGoldSnapshotImplCopyWithImpl<_$HandoverGoldSnapshotImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HandoverGoldSnapshotImplToJson(this);
  }
}

abstract class _HandoverGoldSnapshot implements HandoverGoldSnapshot {
  const factory _HandoverGoldSnapshot({
    required final String type,
    required final String purity,
    required final double weight,
  }) = _$HandoverGoldSnapshotImpl;

  factory _HandoverGoldSnapshot.fromJson(Map<String, dynamic> json) =
      _$HandoverGoldSnapshotImpl.fromJson;

  @override
  String get type;
  @override
  String get purity;
  @override
  double get weight;

  /// Create a copy of HandoverGoldSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HandoverGoldSnapshotImplCopyWith<_$HandoverGoldSnapshotImpl>
  get copyWith => throw _privateConstructorUsedError;
}

GoldHandover _$GoldHandoverFromJson(Map<String, dynamic> json) {
  return _GoldHandover.fromJson(json);
}

/// @nodoc
mixin _$GoldHandover {
  /// Unique handover identifier
  String get id => throw _privateConstructorUsedError;

  /// Parent chitty ID
  String get chittiId => throw _privateConstructorUsedError;

  /// Slot this handover belongs to
  String get slotId => throw _privateConstructorUsedError;

  /// User ID of the member receiving gold
  String get userId => throw _privateConstructorUsedError;

  /// Display name of the member
  String get userName => throw _privateConstructorUsedError;

  /// Gold option details at time of handover
  HandoverGoldSnapshot get goldOption => throw _privateConstructorUsedError;

  /// Original total price locked at chitti creation
  double get lockedTotalValue => throw _privateConstructorUsedError;

  /// Total gold cost entered by organizer at handover (current market value)
  double get currentTotalGoldCost => throw _privateConstructorUsedError;

  /// Total amount the member has actually paid (verified)
  double get totalPaidByMember => throw _privateConstructorUsedError;

  /// Settlement difference: currentTotalGoldCost - totalPaidByMember
  /// Positive = member owes balance, Negative = organizer owes refund
  double get settlementDifference => throw _privateConstructorUsedError;

  /// How the settlement was/will be resolved
  SettlementType get settlementType => throw _privateConstructorUsedError;

  /// Current settlement status
  SlotSettlementStatus get settlementStatus =>
      throw _privateConstructorUsedError;

  /// Number of EMI installments (for revamp option)
  int? get revampEMICount => throw _privateConstructorUsedError;

  /// Per-installment amount (for revamp option)
  double? get revampEMIAmount => throw _privateConstructorUsedError;

  /// When gold was physically handed over
  DateTime get handoverDate => throw _privateConstructorUsedError;

  /// When full settlement was completed
  DateTime? get settlementDate => throw _privateConstructorUsedError;

  /// List of transaction IDs related to this handover
  List<String> get transactionIds => throw _privateConstructorUsedError;

  /// Optional notes
  String? get notes => throw _privateConstructorUsedError;

  /// Slot number for display
  int? get slotNumber => throw _privateConstructorUsedError;

  /// Serializes this GoldHandover to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GoldHandover
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoldHandoverCopyWith<GoldHandover> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoldHandoverCopyWith<$Res> {
  factory $GoldHandoverCopyWith(
    GoldHandover value,
    $Res Function(GoldHandover) then,
  ) = _$GoldHandoverCopyWithImpl<$Res, GoldHandover>;
  @useResult
  $Res call({
    String id,
    String chittiId,
    String slotId,
    String userId,
    String userName,
    HandoverGoldSnapshot goldOption,
    double lockedTotalValue,
    double currentTotalGoldCost,
    double totalPaidByMember,
    double settlementDifference,
    SettlementType settlementType,
    SlotSettlementStatus settlementStatus,
    int? revampEMICount,
    double? revampEMIAmount,
    DateTime handoverDate,
    DateTime? settlementDate,
    List<String> transactionIds,
    String? notes,
    int? slotNumber,
  });

  $HandoverGoldSnapshotCopyWith<$Res> get goldOption;
}

/// @nodoc
class _$GoldHandoverCopyWithImpl<$Res, $Val extends GoldHandover>
    implements $GoldHandoverCopyWith<$Res> {
  _$GoldHandoverCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoldHandover
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chittiId = null,
    Object? slotId = null,
    Object? userId = null,
    Object? userName = null,
    Object? goldOption = null,
    Object? lockedTotalValue = null,
    Object? currentTotalGoldCost = null,
    Object? totalPaidByMember = null,
    Object? settlementDifference = null,
    Object? settlementType = null,
    Object? settlementStatus = null,
    Object? revampEMICount = freezed,
    Object? revampEMIAmount = freezed,
    Object? handoverDate = null,
    Object? settlementDate = freezed,
    Object? transactionIds = null,
    Object? notes = freezed,
    Object? slotNumber = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            chittiId: null == chittiId
                ? _value.chittiId
                : chittiId // ignore: cast_nullable_to_non_nullable
                      as String,
            slotId: null == slotId
                ? _value.slotId
                : slotId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            goldOption: null == goldOption
                ? _value.goldOption
                : goldOption // ignore: cast_nullable_to_non_nullable
                      as HandoverGoldSnapshot,
            lockedTotalValue: null == lockedTotalValue
                ? _value.lockedTotalValue
                : lockedTotalValue // ignore: cast_nullable_to_non_nullable
                      as double,
            currentTotalGoldCost: null == currentTotalGoldCost
                ? _value.currentTotalGoldCost
                : currentTotalGoldCost // ignore: cast_nullable_to_non_nullable
                      as double,
            totalPaidByMember: null == totalPaidByMember
                ? _value.totalPaidByMember
                : totalPaidByMember // ignore: cast_nullable_to_non_nullable
                      as double,
            settlementDifference: null == settlementDifference
                ? _value.settlementDifference
                : settlementDifference // ignore: cast_nullable_to_non_nullable
                      as double,
            settlementType: null == settlementType
                ? _value.settlementType
                : settlementType // ignore: cast_nullable_to_non_nullable
                      as SettlementType,
            settlementStatus: null == settlementStatus
                ? _value.settlementStatus
                : settlementStatus // ignore: cast_nullable_to_non_nullable
                      as SlotSettlementStatus,
            revampEMICount: freezed == revampEMICount
                ? _value.revampEMICount
                : revampEMICount // ignore: cast_nullable_to_non_nullable
                      as int?,
            revampEMIAmount: freezed == revampEMIAmount
                ? _value.revampEMIAmount
                : revampEMIAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            handoverDate: null == handoverDate
                ? _value.handoverDate
                : handoverDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            settlementDate: freezed == settlementDate
                ? _value.settlementDate
                : settlementDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            transactionIds: null == transactionIds
                ? _value.transactionIds
                : transactionIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            slotNumber: freezed == slotNumber
                ? _value.slotNumber
                : slotNumber // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }

  /// Create a copy of GoldHandover
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HandoverGoldSnapshotCopyWith<$Res> get goldOption {
    return $HandoverGoldSnapshotCopyWith<$Res>(_value.goldOption, (value) {
      return _then(_value.copyWith(goldOption: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GoldHandoverImplCopyWith<$Res>
    implements $GoldHandoverCopyWith<$Res> {
  factory _$$GoldHandoverImplCopyWith(
    _$GoldHandoverImpl value,
    $Res Function(_$GoldHandoverImpl) then,
  ) = __$$GoldHandoverImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String chittiId,
    String slotId,
    String userId,
    String userName,
    HandoverGoldSnapshot goldOption,
    double lockedTotalValue,
    double currentTotalGoldCost,
    double totalPaidByMember,
    double settlementDifference,
    SettlementType settlementType,
    SlotSettlementStatus settlementStatus,
    int? revampEMICount,
    double? revampEMIAmount,
    DateTime handoverDate,
    DateTime? settlementDate,
    List<String> transactionIds,
    String? notes,
    int? slotNumber,
  });

  @override
  $HandoverGoldSnapshotCopyWith<$Res> get goldOption;
}

/// @nodoc
class __$$GoldHandoverImplCopyWithImpl<$Res>
    extends _$GoldHandoverCopyWithImpl<$Res, _$GoldHandoverImpl>
    implements _$$GoldHandoverImplCopyWith<$Res> {
  __$$GoldHandoverImplCopyWithImpl(
    _$GoldHandoverImpl _value,
    $Res Function(_$GoldHandoverImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GoldHandover
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chittiId = null,
    Object? slotId = null,
    Object? userId = null,
    Object? userName = null,
    Object? goldOption = null,
    Object? lockedTotalValue = null,
    Object? currentTotalGoldCost = null,
    Object? totalPaidByMember = null,
    Object? settlementDifference = null,
    Object? settlementType = null,
    Object? settlementStatus = null,
    Object? revampEMICount = freezed,
    Object? revampEMIAmount = freezed,
    Object? handoverDate = null,
    Object? settlementDate = freezed,
    Object? transactionIds = null,
    Object? notes = freezed,
    Object? slotNumber = freezed,
  }) {
    return _then(
      _$GoldHandoverImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        chittiId: null == chittiId
            ? _value.chittiId
            : chittiId // ignore: cast_nullable_to_non_nullable
                  as String,
        slotId: null == slotId
            ? _value.slotId
            : slotId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        goldOption: null == goldOption
            ? _value.goldOption
            : goldOption // ignore: cast_nullable_to_non_nullable
                  as HandoverGoldSnapshot,
        lockedTotalValue: null == lockedTotalValue
            ? _value.lockedTotalValue
            : lockedTotalValue // ignore: cast_nullable_to_non_nullable
                  as double,
        currentTotalGoldCost: null == currentTotalGoldCost
            ? _value.currentTotalGoldCost
            : currentTotalGoldCost // ignore: cast_nullable_to_non_nullable
                  as double,
        totalPaidByMember: null == totalPaidByMember
            ? _value.totalPaidByMember
            : totalPaidByMember // ignore: cast_nullable_to_non_nullable
                  as double,
        settlementDifference: null == settlementDifference
            ? _value.settlementDifference
            : settlementDifference // ignore: cast_nullable_to_non_nullable
                  as double,
        settlementType: null == settlementType
            ? _value.settlementType
            : settlementType // ignore: cast_nullable_to_non_nullable
                  as SettlementType,
        settlementStatus: null == settlementStatus
            ? _value.settlementStatus
            : settlementStatus // ignore: cast_nullable_to_non_nullable
                  as SlotSettlementStatus,
        revampEMICount: freezed == revampEMICount
            ? _value.revampEMICount
            : revampEMICount // ignore: cast_nullable_to_non_nullable
                  as int?,
        revampEMIAmount: freezed == revampEMIAmount
            ? _value.revampEMIAmount
            : revampEMIAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        handoverDate: null == handoverDate
            ? _value.handoverDate
            : handoverDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        settlementDate: freezed == settlementDate
            ? _value.settlementDate
            : settlementDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        transactionIds: null == transactionIds
            ? _value._transactionIds
            : transactionIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        slotNumber: freezed == slotNumber
            ? _value.slotNumber
            : slotNumber // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GoldHandoverImpl extends _GoldHandover {
  const _$GoldHandoverImpl({
    required this.id,
    required this.chittiId,
    required this.slotId,
    required this.userId,
    required this.userName,
    required this.goldOption,
    required this.lockedTotalValue,
    required this.currentTotalGoldCost,
    required this.totalPaidByMember,
    required this.settlementDifference,
    this.settlementType = SettlementType.oneTimePayment,
    this.settlementStatus = SlotSettlementStatus.goldHandedOver,
    this.revampEMICount,
    this.revampEMIAmount,
    required this.handoverDate,
    this.settlementDate,
    final List<String> transactionIds = const [],
    this.notes,
    this.slotNumber,
  }) : _transactionIds = transactionIds,
       super._();

  factory _$GoldHandoverImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoldHandoverImplFromJson(json);

  /// Unique handover identifier
  @override
  final String id;

  /// Parent chitty ID
  @override
  final String chittiId;

  /// Slot this handover belongs to
  @override
  final String slotId;

  /// User ID of the member receiving gold
  @override
  final String userId;

  /// Display name of the member
  @override
  final String userName;

  /// Gold option details at time of handover
  @override
  final HandoverGoldSnapshot goldOption;

  /// Original total price locked at chitti creation
  @override
  final double lockedTotalValue;

  /// Total gold cost entered by organizer at handover (current market value)
  @override
  final double currentTotalGoldCost;

  /// Total amount the member has actually paid (verified)
  @override
  final double totalPaidByMember;

  /// Settlement difference: currentTotalGoldCost - totalPaidByMember
  /// Positive = member owes balance, Negative = organizer owes refund
  @override
  final double settlementDifference;

  /// How the settlement was/will be resolved
  @override
  @JsonKey()
  final SettlementType settlementType;

  /// Current settlement status
  @override
  @JsonKey()
  final SlotSettlementStatus settlementStatus;

  /// Number of EMI installments (for revamp option)
  @override
  final int? revampEMICount;

  /// Per-installment amount (for revamp option)
  @override
  final double? revampEMIAmount;

  /// When gold was physically handed over
  @override
  final DateTime handoverDate;

  /// When full settlement was completed
  @override
  final DateTime? settlementDate;

  /// List of transaction IDs related to this handover
  final List<String> _transactionIds;

  /// List of transaction IDs related to this handover
  @override
  @JsonKey()
  List<String> get transactionIds {
    if (_transactionIds is EqualUnmodifiableListView) return _transactionIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transactionIds);
  }

  /// Optional notes
  @override
  final String? notes;

  /// Slot number for display
  @override
  final int? slotNumber;

  @override
  String toString() {
    return 'GoldHandover(id: $id, chittiId: $chittiId, slotId: $slotId, userId: $userId, userName: $userName, goldOption: $goldOption, lockedTotalValue: $lockedTotalValue, currentTotalGoldCost: $currentTotalGoldCost, totalPaidByMember: $totalPaidByMember, settlementDifference: $settlementDifference, settlementType: $settlementType, settlementStatus: $settlementStatus, revampEMICount: $revampEMICount, revampEMIAmount: $revampEMIAmount, handoverDate: $handoverDate, settlementDate: $settlementDate, transactionIds: $transactionIds, notes: $notes, slotNumber: $slotNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoldHandoverImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chittiId, chittiId) ||
                other.chittiId == chittiId) &&
            (identical(other.slotId, slotId) || other.slotId == slotId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.goldOption, goldOption) ||
                other.goldOption == goldOption) &&
            (identical(other.lockedTotalValue, lockedTotalValue) ||
                other.lockedTotalValue == lockedTotalValue) &&
            (identical(other.currentTotalGoldCost, currentTotalGoldCost) ||
                other.currentTotalGoldCost == currentTotalGoldCost) &&
            (identical(other.totalPaidByMember, totalPaidByMember) ||
                other.totalPaidByMember == totalPaidByMember) &&
            (identical(other.settlementDifference, settlementDifference) ||
                other.settlementDifference == settlementDifference) &&
            (identical(other.settlementType, settlementType) ||
                other.settlementType == settlementType) &&
            (identical(other.settlementStatus, settlementStatus) ||
                other.settlementStatus == settlementStatus) &&
            (identical(other.revampEMICount, revampEMICount) ||
                other.revampEMICount == revampEMICount) &&
            (identical(other.revampEMIAmount, revampEMIAmount) ||
                other.revampEMIAmount == revampEMIAmount) &&
            (identical(other.handoverDate, handoverDate) ||
                other.handoverDate == handoverDate) &&
            (identical(other.settlementDate, settlementDate) ||
                other.settlementDate == settlementDate) &&
            const DeepCollectionEquality().equals(
              other._transactionIds,
              _transactionIds,
            ) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.slotNumber, slotNumber) ||
                other.slotNumber == slotNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    chittiId,
    slotId,
    userId,
    userName,
    goldOption,
    lockedTotalValue,
    currentTotalGoldCost,
    totalPaidByMember,
    settlementDifference,
    settlementType,
    settlementStatus,
    revampEMICount,
    revampEMIAmount,
    handoverDate,
    settlementDate,
    const DeepCollectionEquality().hash(_transactionIds),
    notes,
    slotNumber,
  ]);

  /// Create a copy of GoldHandover
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoldHandoverImplCopyWith<_$GoldHandoverImpl> get copyWith =>
      __$$GoldHandoverImplCopyWithImpl<_$GoldHandoverImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GoldHandoverImplToJson(this);
  }
}

abstract class _GoldHandover extends GoldHandover {
  const factory _GoldHandover({
    required final String id,
    required final String chittiId,
    required final String slotId,
    required final String userId,
    required final String userName,
    required final HandoverGoldSnapshot goldOption,
    required final double lockedTotalValue,
    required final double currentTotalGoldCost,
    required final double totalPaidByMember,
    required final double settlementDifference,
    final SettlementType settlementType,
    final SlotSettlementStatus settlementStatus,
    final int? revampEMICount,
    final double? revampEMIAmount,
    required final DateTime handoverDate,
    final DateTime? settlementDate,
    final List<String> transactionIds,
    final String? notes,
    final int? slotNumber,
  }) = _$GoldHandoverImpl;
  const _GoldHandover._() : super._();

  factory _GoldHandover.fromJson(Map<String, dynamic> json) =
      _$GoldHandoverImpl.fromJson;

  /// Unique handover identifier
  @override
  String get id;

  /// Parent chitty ID
  @override
  String get chittiId;

  /// Slot this handover belongs to
  @override
  String get slotId;

  /// User ID of the member receiving gold
  @override
  String get userId;

  /// Display name of the member
  @override
  String get userName;

  /// Gold option details at time of handover
  @override
  HandoverGoldSnapshot get goldOption;

  /// Original total price locked at chitti creation
  @override
  double get lockedTotalValue;

  /// Total gold cost entered by organizer at handover (current market value)
  @override
  double get currentTotalGoldCost;

  /// Total amount the member has actually paid (verified)
  @override
  double get totalPaidByMember;

  /// Settlement difference: currentTotalGoldCost - totalPaidByMember
  /// Positive = member owes balance, Negative = organizer owes refund
  @override
  double get settlementDifference;

  /// How the settlement was/will be resolved
  @override
  SettlementType get settlementType;

  /// Current settlement status
  @override
  SlotSettlementStatus get settlementStatus;

  /// Number of EMI installments (for revamp option)
  @override
  int? get revampEMICount;

  /// Per-installment amount (for revamp option)
  @override
  double? get revampEMIAmount;

  /// When gold was physically handed over
  @override
  DateTime get handoverDate;

  /// When full settlement was completed
  @override
  DateTime? get settlementDate;

  /// List of transaction IDs related to this handover
  @override
  List<String> get transactionIds;

  /// Optional notes
  @override
  String? get notes;

  /// Slot number for display
  @override
  int? get slotNumber;

  /// Create a copy of GoldHandover
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoldHandoverImplCopyWith<_$GoldHandoverImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
