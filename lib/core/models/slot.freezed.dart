// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Slot _$SlotFromJson(Map<String, dynamic> json) {
  return _Slot.fromJson(json);
}

/// @nodoc
mixin _$Slot {
  /// Unique slot identifier
  String get id => throw _privateConstructorUsedError;

  /// Parent chitti ID
  String get chittiId => throw _privateConstructorUsedError;

  /// User who owns this slot
  String get userId => throw _privateConstructorUsedError;

  /// Position number in the chitty (1, 2, 3...)
  int get slotNumber => throw _privateConstructorUsedError;

  /// Selected gold option ID
  String get goldOptionId => throw _privateConstructorUsedError;

  /// Gold option details (denormalized for display)
  GoldOptionSnapshot? get goldOption => throw _privateConstructorUsedError;

  /// Opening balance for mid-cycle joiners (catch-up amount)
  double get openingBalance => throw _privateConstructorUsedError;

  /// Regular monthly EMI amount (before any discounts)
  double get monthlyEMI => throw _privateConstructorUsedError;

  /// Total amount due over the chitty duration
  double get totalDue => throw _privateConstructorUsedError;

  /// Total amount paid so far
  double get totalPaid => throw _privateConstructorUsedError;

  /// Current balance (totalPaid - totalDue, negative = owes)
  double get currentBalance => throw _privateConstructorUsedError;

  /// Slot lifecycle status
  SlotStatus get status => throw _privateConstructorUsedError;

  /// Month when member joined (YYYY-MM format)
  String get joinedMonth => throw _privateConstructorUsedError;

  /// Whether this slot has won the lucky draw
  bool get isWinner => throw _privateConstructorUsedError;

  /// Month when slot won (YYYY-MM format)
  String? get winnerMonth => throw _privateConstructorUsedError;

  /// Month from which discount starts (month after winning)
  String? get discountStartMonth => throw _privateConstructorUsedError;

  /// Discount amount per month after winning
  double? get discountPerMonth => throw _privateConstructorUsedError;

  /// Total discount over remaining months
  double? get totalDiscount => throw _privateConstructorUsedError;

  /// Original EMI before discount (for display)
  double? get originalMonthlyEMI => throw _privateConstructorUsedError;

  /// Prize amount when winner
  double? get prizeAmount => throw _privateConstructorUsedError;

  /// Last payment date
  DateTime? get lastPaymentDate => throw _privateConstructorUsedError;

  /// When slot was created
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// User name for display (denormalized)
  String? get userName => throw _privateConstructorUsedError;

  /// User phone for display (denormalized)
  String? get userPhone => throw _privateConstructorUsedError;

  /// Settlement status for gold handover
  SlotSettlementStatus get settlementStatus =>
      throw _privateConstructorUsedError;

  /// Gold handover record ID (links to gold_handovers node)
  String? get goldHandoverId => throw _privateConstructorUsedError;

  /// Total gold cost at time of handover
  double? get currentTotalGoldCost => throw _privateConstructorUsedError;

  /// Settlement difference: positive = member owes, negative = organizer owes
  double? get settlementDifference => throw _privateConstructorUsedError;

  /// Serializes this Slot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SlotCopyWith<Slot> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SlotCopyWith<$Res> {
  factory $SlotCopyWith(Slot value, $Res Function(Slot) then) =
      _$SlotCopyWithImpl<$Res, Slot>;
  @useResult
  $Res call({
    String id,
    String chittiId,
    String userId,
    int slotNumber,
    String goldOptionId,
    GoldOptionSnapshot? goldOption,
    double openingBalance,
    double monthlyEMI,
    double totalDue,
    double totalPaid,
    double currentBalance,
    SlotStatus status,
    String joinedMonth,
    bool isWinner,
    String? winnerMonth,
    String? discountStartMonth,
    double? discountPerMonth,
    double? totalDiscount,
    double? originalMonthlyEMI,
    double? prizeAmount,
    DateTime? lastPaymentDate,
    DateTime createdAt,
    String? userName,
    String? userPhone,
    SlotSettlementStatus settlementStatus,
    String? goldHandoverId,
    double? currentTotalGoldCost,
    double? settlementDifference,
  });

  $GoldOptionSnapshotCopyWith<$Res>? get goldOption;
}

/// @nodoc
class _$SlotCopyWithImpl<$Res, $Val extends Slot>
    implements $SlotCopyWith<$Res> {
  _$SlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chittiId = null,
    Object? userId = null,
    Object? slotNumber = null,
    Object? goldOptionId = null,
    Object? goldOption = freezed,
    Object? openingBalance = null,
    Object? monthlyEMI = null,
    Object? totalDue = null,
    Object? totalPaid = null,
    Object? currentBalance = null,
    Object? status = null,
    Object? joinedMonth = null,
    Object? isWinner = null,
    Object? winnerMonth = freezed,
    Object? discountStartMonth = freezed,
    Object? discountPerMonth = freezed,
    Object? totalDiscount = freezed,
    Object? originalMonthlyEMI = freezed,
    Object? prizeAmount = freezed,
    Object? lastPaymentDate = freezed,
    Object? createdAt = null,
    Object? userName = freezed,
    Object? userPhone = freezed,
    Object? settlementStatus = null,
    Object? goldHandoverId = freezed,
    Object? currentTotalGoldCost = freezed,
    Object? settlementDifference = freezed,
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
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            slotNumber: null == slotNumber
                ? _value.slotNumber
                : slotNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            goldOptionId: null == goldOptionId
                ? _value.goldOptionId
                : goldOptionId // ignore: cast_nullable_to_non_nullable
                      as String,
            goldOption: freezed == goldOption
                ? _value.goldOption
                : goldOption // ignore: cast_nullable_to_non_nullable
                      as GoldOptionSnapshot?,
            openingBalance: null == openingBalance
                ? _value.openingBalance
                : openingBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            monthlyEMI: null == monthlyEMI
                ? _value.monthlyEMI
                : monthlyEMI // ignore: cast_nullable_to_non_nullable
                      as double,
            totalDue: null == totalDue
                ? _value.totalDue
                : totalDue // ignore: cast_nullable_to_non_nullable
                      as double,
            totalPaid: null == totalPaid
                ? _value.totalPaid
                : totalPaid // ignore: cast_nullable_to_non_nullable
                      as double,
            currentBalance: null == currentBalance
                ? _value.currentBalance
                : currentBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SlotStatus,
            joinedMonth: null == joinedMonth
                ? _value.joinedMonth
                : joinedMonth // ignore: cast_nullable_to_non_nullable
                      as String,
            isWinner: null == isWinner
                ? _value.isWinner
                : isWinner // ignore: cast_nullable_to_non_nullable
                      as bool,
            winnerMonth: freezed == winnerMonth
                ? _value.winnerMonth
                : winnerMonth // ignore: cast_nullable_to_non_nullable
                      as String?,
            discountStartMonth: freezed == discountStartMonth
                ? _value.discountStartMonth
                : discountStartMonth // ignore: cast_nullable_to_non_nullable
                      as String?,
            discountPerMonth: freezed == discountPerMonth
                ? _value.discountPerMonth
                : discountPerMonth // ignore: cast_nullable_to_non_nullable
                      as double?,
            totalDiscount: freezed == totalDiscount
                ? _value.totalDiscount
                : totalDiscount // ignore: cast_nullable_to_non_nullable
                      as double?,
            originalMonthlyEMI: freezed == originalMonthlyEMI
                ? _value.originalMonthlyEMI
                : originalMonthlyEMI // ignore: cast_nullable_to_non_nullable
                      as double?,
            prizeAmount: freezed == prizeAmount
                ? _value.prizeAmount
                : prizeAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            lastPaymentDate: freezed == lastPaymentDate
                ? _value.lastPaymentDate
                : lastPaymentDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            userName: freezed == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String?,
            userPhone: freezed == userPhone
                ? _value.userPhone
                : userPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            settlementStatus: null == settlementStatus
                ? _value.settlementStatus
                : settlementStatus // ignore: cast_nullable_to_non_nullable
                      as SlotSettlementStatus,
            goldHandoverId: freezed == goldHandoverId
                ? _value.goldHandoverId
                : goldHandoverId // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentTotalGoldCost: freezed == currentTotalGoldCost
                ? _value.currentTotalGoldCost
                : currentTotalGoldCost // ignore: cast_nullable_to_non_nullable
                      as double?,
            settlementDifference: freezed == settlementDifference
                ? _value.settlementDifference
                : settlementDifference // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GoldOptionSnapshotCopyWith<$Res>? get goldOption {
    if (_value.goldOption == null) {
      return null;
    }

    return $GoldOptionSnapshotCopyWith<$Res>(_value.goldOption!, (value) {
      return _then(_value.copyWith(goldOption: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SlotImplCopyWith<$Res> implements $SlotCopyWith<$Res> {
  factory _$$SlotImplCopyWith(
    _$SlotImpl value,
    $Res Function(_$SlotImpl) then,
  ) = __$$SlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String chittiId,
    String userId,
    int slotNumber,
    String goldOptionId,
    GoldOptionSnapshot? goldOption,
    double openingBalance,
    double monthlyEMI,
    double totalDue,
    double totalPaid,
    double currentBalance,
    SlotStatus status,
    String joinedMonth,
    bool isWinner,
    String? winnerMonth,
    String? discountStartMonth,
    double? discountPerMonth,
    double? totalDiscount,
    double? originalMonthlyEMI,
    double? prizeAmount,
    DateTime? lastPaymentDate,
    DateTime createdAt,
    String? userName,
    String? userPhone,
    SlotSettlementStatus settlementStatus,
    String? goldHandoverId,
    double? currentTotalGoldCost,
    double? settlementDifference,
  });

  @override
  $GoldOptionSnapshotCopyWith<$Res>? get goldOption;
}

/// @nodoc
class __$$SlotImplCopyWithImpl<$Res>
    extends _$SlotCopyWithImpl<$Res, _$SlotImpl>
    implements _$$SlotImplCopyWith<$Res> {
  __$$SlotImplCopyWithImpl(_$SlotImpl _value, $Res Function(_$SlotImpl) _then)
    : super(_value, _then);

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chittiId = null,
    Object? userId = null,
    Object? slotNumber = null,
    Object? goldOptionId = null,
    Object? goldOption = freezed,
    Object? openingBalance = null,
    Object? monthlyEMI = null,
    Object? totalDue = null,
    Object? totalPaid = null,
    Object? currentBalance = null,
    Object? status = null,
    Object? joinedMonth = null,
    Object? isWinner = null,
    Object? winnerMonth = freezed,
    Object? discountStartMonth = freezed,
    Object? discountPerMonth = freezed,
    Object? totalDiscount = freezed,
    Object? originalMonthlyEMI = freezed,
    Object? prizeAmount = freezed,
    Object? lastPaymentDate = freezed,
    Object? createdAt = null,
    Object? userName = freezed,
    Object? userPhone = freezed,
    Object? settlementStatus = null,
    Object? goldHandoverId = freezed,
    Object? currentTotalGoldCost = freezed,
    Object? settlementDifference = freezed,
  }) {
    return _then(
      _$SlotImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        chittiId: null == chittiId
            ? _value.chittiId
            : chittiId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        slotNumber: null == slotNumber
            ? _value.slotNumber
            : slotNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        goldOptionId: null == goldOptionId
            ? _value.goldOptionId
            : goldOptionId // ignore: cast_nullable_to_non_nullable
                  as String,
        goldOption: freezed == goldOption
            ? _value.goldOption
            : goldOption // ignore: cast_nullable_to_non_nullable
                  as GoldOptionSnapshot?,
        openingBalance: null == openingBalance
            ? _value.openingBalance
            : openingBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        monthlyEMI: null == monthlyEMI
            ? _value.monthlyEMI
            : monthlyEMI // ignore: cast_nullable_to_non_nullable
                  as double,
        totalDue: null == totalDue
            ? _value.totalDue
            : totalDue // ignore: cast_nullable_to_non_nullable
                  as double,
        totalPaid: null == totalPaid
            ? _value.totalPaid
            : totalPaid // ignore: cast_nullable_to_non_nullable
                  as double,
        currentBalance: null == currentBalance
            ? _value.currentBalance
            : currentBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SlotStatus,
        joinedMonth: null == joinedMonth
            ? _value.joinedMonth
            : joinedMonth // ignore: cast_nullable_to_non_nullable
                  as String,
        isWinner: null == isWinner
            ? _value.isWinner
            : isWinner // ignore: cast_nullable_to_non_nullable
                  as bool,
        winnerMonth: freezed == winnerMonth
            ? _value.winnerMonth
            : winnerMonth // ignore: cast_nullable_to_non_nullable
                  as String?,
        discountStartMonth: freezed == discountStartMonth
            ? _value.discountStartMonth
            : discountStartMonth // ignore: cast_nullable_to_non_nullable
                  as String?,
        discountPerMonth: freezed == discountPerMonth
            ? _value.discountPerMonth
            : discountPerMonth // ignore: cast_nullable_to_non_nullable
                  as double?,
        totalDiscount: freezed == totalDiscount
            ? _value.totalDiscount
            : totalDiscount // ignore: cast_nullable_to_non_nullable
                  as double?,
        originalMonthlyEMI: freezed == originalMonthlyEMI
            ? _value.originalMonthlyEMI
            : originalMonthlyEMI // ignore: cast_nullable_to_non_nullable
                  as double?,
        prizeAmount: freezed == prizeAmount
            ? _value.prizeAmount
            : prizeAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        lastPaymentDate: freezed == lastPaymentDate
            ? _value.lastPaymentDate
            : lastPaymentDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        userName: freezed == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String?,
        userPhone: freezed == userPhone
            ? _value.userPhone
            : userPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        settlementStatus: null == settlementStatus
            ? _value.settlementStatus
            : settlementStatus // ignore: cast_nullable_to_non_nullable
                  as SlotSettlementStatus,
        goldHandoverId: freezed == goldHandoverId
            ? _value.goldHandoverId
            : goldHandoverId // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentTotalGoldCost: freezed == currentTotalGoldCost
            ? _value.currentTotalGoldCost
            : currentTotalGoldCost // ignore: cast_nullable_to_non_nullable
                  as double?,
        settlementDifference: freezed == settlementDifference
            ? _value.settlementDifference
            : settlementDifference // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SlotImpl extends _Slot {
  const _$SlotImpl({
    required this.id,
    required this.chittiId,
    required this.userId,
    required this.slotNumber,
    required this.goldOptionId,
    this.goldOption,
    this.openingBalance = 0.0,
    required this.monthlyEMI,
    required this.totalDue,
    this.totalPaid = 0.0,
    this.currentBalance = 0.0,
    this.status = SlotStatus.active,
    required this.joinedMonth,
    this.isWinner = false,
    this.winnerMonth,
    this.discountStartMonth,
    this.discountPerMonth,
    this.totalDiscount,
    this.originalMonthlyEMI,
    this.prizeAmount,
    this.lastPaymentDate,
    required this.createdAt,
    this.userName,
    this.userPhone,
    this.settlementStatus = SlotSettlementStatus.none,
    this.goldHandoverId,
    this.currentTotalGoldCost,
    this.settlementDifference,
  }) : super._();

  factory _$SlotImpl.fromJson(Map<String, dynamic> json) =>
      _$$SlotImplFromJson(json);

  /// Unique slot identifier
  @override
  final String id;

  /// Parent chitti ID
  @override
  final String chittiId;

  /// User who owns this slot
  @override
  final String userId;

  /// Position number in the chitty (1, 2, 3...)
  @override
  final int slotNumber;

  /// Selected gold option ID
  @override
  final String goldOptionId;

  /// Gold option details (denormalized for display)
  @override
  final GoldOptionSnapshot? goldOption;

  /// Opening balance for mid-cycle joiners (catch-up amount)
  @override
  @JsonKey()
  final double openingBalance;

  /// Regular monthly EMI amount (before any discounts)
  @override
  final double monthlyEMI;

  /// Total amount due over the chitty duration
  @override
  final double totalDue;

  /// Total amount paid so far
  @override
  @JsonKey()
  final double totalPaid;

  /// Current balance (totalPaid - totalDue, negative = owes)
  @override
  @JsonKey()
  final double currentBalance;

  /// Slot lifecycle status
  @override
  @JsonKey()
  final SlotStatus status;

  /// Month when member joined (YYYY-MM format)
  @override
  final String joinedMonth;

  /// Whether this slot has won the lucky draw
  @override
  @JsonKey()
  final bool isWinner;

  /// Month when slot won (YYYY-MM format)
  @override
  final String? winnerMonth;

  /// Month from which discount starts (month after winning)
  @override
  final String? discountStartMonth;

  /// Discount amount per month after winning
  @override
  final double? discountPerMonth;

  /// Total discount over remaining months
  @override
  final double? totalDiscount;

  /// Original EMI before discount (for display)
  @override
  final double? originalMonthlyEMI;

  /// Prize amount when winner
  @override
  final double? prizeAmount;

  /// Last payment date
  @override
  final DateTime? lastPaymentDate;

  /// When slot was created
  @override
  final DateTime createdAt;

  /// User name for display (denormalized)
  @override
  final String? userName;

  /// User phone for display (denormalized)
  @override
  final String? userPhone;

  /// Settlement status for gold handover
  @override
  @JsonKey()
  final SlotSettlementStatus settlementStatus;

  /// Gold handover record ID (links to gold_handovers node)
  @override
  final String? goldHandoverId;

  /// Total gold cost at time of handover
  @override
  final double? currentTotalGoldCost;

  /// Settlement difference: positive = member owes, negative = organizer owes
  @override
  final double? settlementDifference;

  @override
  String toString() {
    return 'Slot(id: $id, chittiId: $chittiId, userId: $userId, slotNumber: $slotNumber, goldOptionId: $goldOptionId, goldOption: $goldOption, openingBalance: $openingBalance, monthlyEMI: $monthlyEMI, totalDue: $totalDue, totalPaid: $totalPaid, currentBalance: $currentBalance, status: $status, joinedMonth: $joinedMonth, isWinner: $isWinner, winnerMonth: $winnerMonth, discountStartMonth: $discountStartMonth, discountPerMonth: $discountPerMonth, totalDiscount: $totalDiscount, originalMonthlyEMI: $originalMonthlyEMI, prizeAmount: $prizeAmount, lastPaymentDate: $lastPaymentDate, createdAt: $createdAt, userName: $userName, userPhone: $userPhone, settlementStatus: $settlementStatus, goldHandoverId: $goldHandoverId, currentTotalGoldCost: $currentTotalGoldCost, settlementDifference: $settlementDifference)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SlotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chittiId, chittiId) ||
                other.chittiId == chittiId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.slotNumber, slotNumber) ||
                other.slotNumber == slotNumber) &&
            (identical(other.goldOptionId, goldOptionId) ||
                other.goldOptionId == goldOptionId) &&
            (identical(other.goldOption, goldOption) ||
                other.goldOption == goldOption) &&
            (identical(other.openingBalance, openingBalance) ||
                other.openingBalance == openingBalance) &&
            (identical(other.monthlyEMI, monthlyEMI) ||
                other.monthlyEMI == monthlyEMI) &&
            (identical(other.totalDue, totalDue) ||
                other.totalDue == totalDue) &&
            (identical(other.totalPaid, totalPaid) ||
                other.totalPaid == totalPaid) &&
            (identical(other.currentBalance, currentBalance) ||
                other.currentBalance == currentBalance) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.joinedMonth, joinedMonth) ||
                other.joinedMonth == joinedMonth) &&
            (identical(other.isWinner, isWinner) ||
                other.isWinner == isWinner) &&
            (identical(other.winnerMonth, winnerMonth) ||
                other.winnerMonth == winnerMonth) &&
            (identical(other.discountStartMonth, discountStartMonth) ||
                other.discountStartMonth == discountStartMonth) &&
            (identical(other.discountPerMonth, discountPerMonth) ||
                other.discountPerMonth == discountPerMonth) &&
            (identical(other.totalDiscount, totalDiscount) ||
                other.totalDiscount == totalDiscount) &&
            (identical(other.originalMonthlyEMI, originalMonthlyEMI) ||
                other.originalMonthlyEMI == originalMonthlyEMI) &&
            (identical(other.prizeAmount, prizeAmount) ||
                other.prizeAmount == prizeAmount) &&
            (identical(other.lastPaymentDate, lastPaymentDate) ||
                other.lastPaymentDate == lastPaymentDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userPhone, userPhone) ||
                other.userPhone == userPhone) &&
            (identical(other.settlementStatus, settlementStatus) ||
                other.settlementStatus == settlementStatus) &&
            (identical(other.goldHandoverId, goldHandoverId) ||
                other.goldHandoverId == goldHandoverId) &&
            (identical(other.currentTotalGoldCost, currentTotalGoldCost) ||
                other.currentTotalGoldCost == currentTotalGoldCost) &&
            (identical(other.settlementDifference, settlementDifference) ||
                other.settlementDifference == settlementDifference));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    chittiId,
    userId,
    slotNumber,
    goldOptionId,
    goldOption,
    openingBalance,
    monthlyEMI,
    totalDue,
    totalPaid,
    currentBalance,
    status,
    joinedMonth,
    isWinner,
    winnerMonth,
    discountStartMonth,
    discountPerMonth,
    totalDiscount,
    originalMonthlyEMI,
    prizeAmount,
    lastPaymentDate,
    createdAt,
    userName,
    userPhone,
    settlementStatus,
    goldHandoverId,
    currentTotalGoldCost,
    settlementDifference,
  ]);

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SlotImplCopyWith<_$SlotImpl> get copyWith =>
      __$$SlotImplCopyWithImpl<_$SlotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SlotImplToJson(this);
  }
}

abstract class _Slot extends Slot {
  const factory _Slot({
    required final String id,
    required final String chittiId,
    required final String userId,
    required final int slotNumber,
    required final String goldOptionId,
    final GoldOptionSnapshot? goldOption,
    final double openingBalance,
    required final double monthlyEMI,
    required final double totalDue,
    final double totalPaid,
    final double currentBalance,
    final SlotStatus status,
    required final String joinedMonth,
    final bool isWinner,
    final String? winnerMonth,
    final String? discountStartMonth,
    final double? discountPerMonth,
    final double? totalDiscount,
    final double? originalMonthlyEMI,
    final double? prizeAmount,
    final DateTime? lastPaymentDate,
    required final DateTime createdAt,
    final String? userName,
    final String? userPhone,
    final SlotSettlementStatus settlementStatus,
    final String? goldHandoverId,
    final double? currentTotalGoldCost,
    final double? settlementDifference,
  }) = _$SlotImpl;
  const _Slot._() : super._();

  factory _Slot.fromJson(Map<String, dynamic> json) = _$SlotImpl.fromJson;

  /// Unique slot identifier
  @override
  String get id;

  /// Parent chitti ID
  @override
  String get chittiId;

  /// User who owns this slot
  @override
  String get userId;

  /// Position number in the chitty (1, 2, 3...)
  @override
  int get slotNumber;

  /// Selected gold option ID
  @override
  String get goldOptionId;

  /// Gold option details (denormalized for display)
  @override
  GoldOptionSnapshot? get goldOption;

  /// Opening balance for mid-cycle joiners (catch-up amount)
  @override
  double get openingBalance;

  /// Regular monthly EMI amount (before any discounts)
  @override
  double get monthlyEMI;

  /// Total amount due over the chitty duration
  @override
  double get totalDue;

  /// Total amount paid so far
  @override
  double get totalPaid;

  /// Current balance (totalPaid - totalDue, negative = owes)
  @override
  double get currentBalance;

  /// Slot lifecycle status
  @override
  SlotStatus get status;

  /// Month when member joined (YYYY-MM format)
  @override
  String get joinedMonth;

  /// Whether this slot has won the lucky draw
  @override
  bool get isWinner;

  /// Month when slot won (YYYY-MM format)
  @override
  String? get winnerMonth;

  /// Month from which discount starts (month after winning)
  @override
  String? get discountStartMonth;

  /// Discount amount per month after winning
  @override
  double? get discountPerMonth;

  /// Total discount over remaining months
  @override
  double? get totalDiscount;

  /// Original EMI before discount (for display)
  @override
  double? get originalMonthlyEMI;

  /// Prize amount when winner
  @override
  double? get prizeAmount;

  /// Last payment date
  @override
  DateTime? get lastPaymentDate;

  /// When slot was created
  @override
  DateTime get createdAt;

  /// User name for display (denormalized)
  @override
  String? get userName;

  /// User phone for display (denormalized)
  @override
  String? get userPhone;

  /// Settlement status for gold handover
  @override
  SlotSettlementStatus get settlementStatus;

  /// Gold handover record ID (links to gold_handovers node)
  @override
  String? get goldHandoverId;

  /// Total gold cost at time of handover
  @override
  double? get currentTotalGoldCost;

  /// Settlement difference: positive = member owes, negative = organizer owes
  @override
  double? get settlementDifference;

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SlotImplCopyWith<_$SlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GoldOptionSnapshot _$GoldOptionSnapshotFromJson(Map<String, dynamic> json) {
  return _GoldOptionSnapshot.fromJson(json);
}

/// @nodoc
mixin _$GoldOptionSnapshot {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get purity => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;

  /// Serializes this GoldOptionSnapshot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GoldOptionSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoldOptionSnapshotCopyWith<GoldOptionSnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoldOptionSnapshotCopyWith<$Res> {
  factory $GoldOptionSnapshotCopyWith(
    GoldOptionSnapshot value,
    $Res Function(GoldOptionSnapshot) then,
  ) = _$GoldOptionSnapshotCopyWithImpl<$Res, GoldOptionSnapshot>;
  @useResult
  $Res call({
    String id,
    String type,
    String purity,
    double weight,
    double price,
  });
}

/// @nodoc
class _$GoldOptionSnapshotCopyWithImpl<$Res, $Val extends GoldOptionSnapshot>
    implements $GoldOptionSnapshotCopyWith<$Res> {
  _$GoldOptionSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoldOptionSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? purity = null,
    Object? weight = null,
    Object? price = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
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
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GoldOptionSnapshotImplCopyWith<$Res>
    implements $GoldOptionSnapshotCopyWith<$Res> {
  factory _$$GoldOptionSnapshotImplCopyWith(
    _$GoldOptionSnapshotImpl value,
    $Res Function(_$GoldOptionSnapshotImpl) then,
  ) = __$$GoldOptionSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String type,
    String purity,
    double weight,
    double price,
  });
}

/// @nodoc
class __$$GoldOptionSnapshotImplCopyWithImpl<$Res>
    extends _$GoldOptionSnapshotCopyWithImpl<$Res, _$GoldOptionSnapshotImpl>
    implements _$$GoldOptionSnapshotImplCopyWith<$Res> {
  __$$GoldOptionSnapshotImplCopyWithImpl(
    _$GoldOptionSnapshotImpl _value,
    $Res Function(_$GoldOptionSnapshotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GoldOptionSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? purity = null,
    Object? weight = null,
    Object? price = null,
  }) {
    return _then(
      _$GoldOptionSnapshotImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
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
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GoldOptionSnapshotImpl implements _GoldOptionSnapshot {
  const _$GoldOptionSnapshotImpl({
    required this.id,
    required this.type,
    required this.purity,
    required this.weight,
    required this.price,
  });

  factory _$GoldOptionSnapshotImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoldOptionSnapshotImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final String purity;
  @override
  final double weight;
  @override
  final double price;

  @override
  String toString() {
    return 'GoldOptionSnapshot(id: $id, type: $type, purity: $purity, weight: $weight, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoldOptionSnapshotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.purity, purity) || other.purity == purity) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.price, price) || other.price == price));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, purity, weight, price);

  /// Create a copy of GoldOptionSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoldOptionSnapshotImplCopyWith<_$GoldOptionSnapshotImpl> get copyWith =>
      __$$GoldOptionSnapshotImplCopyWithImpl<_$GoldOptionSnapshotImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GoldOptionSnapshotImplToJson(this);
  }
}

abstract class _GoldOptionSnapshot implements GoldOptionSnapshot {
  const factory _GoldOptionSnapshot({
    required final String id,
    required final String type,
    required final String purity,
    required final double weight,
    required final double price,
  }) = _$GoldOptionSnapshotImpl;

  factory _GoldOptionSnapshot.fromJson(Map<String, dynamic> json) =
      _$GoldOptionSnapshotImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  String get purity;
  @override
  double get weight;
  @override
  double get price;

  /// Create a copy of GoldOptionSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoldOptionSnapshotImplCopyWith<_$GoldOptionSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
