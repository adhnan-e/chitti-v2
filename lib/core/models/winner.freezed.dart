// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'winner.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Winner _$WinnerFromJson(Map<String, dynamic> json) {
  return _Winner.fromJson(json);
}

/// @nodoc
mixin _$Winner {
  /// Unique winner record identifier
  String get id => throw _privateConstructorUsedError;

  /// Parent chitty ID
  String get chittiId => throw _privateConstructorUsedError;

  /// Winning slot ID
  String get slotId => throw _privateConstructorUsedError;

  /// User ID of winner
  String get userId => throw _privateConstructorUsedError;

  /// Display name of winner
  String get userName => throw _privateConstructorUsedError;

  /// Slot number for display
  int? get slotNumber => throw _privateConstructorUsedError;

  /// Month when they won (YYYY-MM format)
  String get winnerMonth => throw _privateConstructorUsedError;

  /// Month from which discount starts (month after winning)
  String get discountStartMonth => throw _privateConstructorUsedError;

  /// Prize amount (typically the slot's total value)
  double get prizeAmount => throw _privateConstructorUsedError;

  /// Discount applied per month to future payments
  double get discountPerMonth => throw _privateConstructorUsedError;

  /// Total discount over all remaining months
  double get totalDiscount => throw _privateConstructorUsedError;

  /// How winner was selected
  DrawAlgorithm get selectionMethod => throw _privateConstructorUsedError;

  /// Whether discount has been applied to slot's balance
  bool get discountApplied => throw _privateConstructorUsedError;

  /// When winner was declared
  DateTime get declaredAt => throw _privateConstructorUsedError;

  /// Gold option details for display
  String? get goldOptionLabel => throw _privateConstructorUsedError;

  /// Serializes this Winner to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Winner
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WinnerCopyWith<Winner> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WinnerCopyWith<$Res> {
  factory $WinnerCopyWith(Winner value, $Res Function(Winner) then) =
      _$WinnerCopyWithImpl<$Res, Winner>;
  @useResult
  $Res call({
    String id,
    String chittiId,
    String slotId,
    String userId,
    String userName,
    int? slotNumber,
    String winnerMonth,
    String discountStartMonth,
    double prizeAmount,
    double discountPerMonth,
    double totalDiscount,
    DrawAlgorithm selectionMethod,
    bool discountApplied,
    DateTime declaredAt,
    String? goldOptionLabel,
  });
}

/// @nodoc
class _$WinnerCopyWithImpl<$Res, $Val extends Winner>
    implements $WinnerCopyWith<$Res> {
  _$WinnerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Winner
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chittiId = null,
    Object? slotId = null,
    Object? userId = null,
    Object? userName = null,
    Object? slotNumber = freezed,
    Object? winnerMonth = null,
    Object? discountStartMonth = null,
    Object? prizeAmount = null,
    Object? discountPerMonth = null,
    Object? totalDiscount = null,
    Object? selectionMethod = null,
    Object? discountApplied = null,
    Object? declaredAt = null,
    Object? goldOptionLabel = freezed,
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
            slotNumber: freezed == slotNumber
                ? _value.slotNumber
                : slotNumber // ignore: cast_nullable_to_non_nullable
                      as int?,
            winnerMonth: null == winnerMonth
                ? _value.winnerMonth
                : winnerMonth // ignore: cast_nullable_to_non_nullable
                      as String,
            discountStartMonth: null == discountStartMonth
                ? _value.discountStartMonth
                : discountStartMonth // ignore: cast_nullable_to_non_nullable
                      as String,
            prizeAmount: null == prizeAmount
                ? _value.prizeAmount
                : prizeAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            discountPerMonth: null == discountPerMonth
                ? _value.discountPerMonth
                : discountPerMonth // ignore: cast_nullable_to_non_nullable
                      as double,
            totalDiscount: null == totalDiscount
                ? _value.totalDiscount
                : totalDiscount // ignore: cast_nullable_to_non_nullable
                      as double,
            selectionMethod: null == selectionMethod
                ? _value.selectionMethod
                : selectionMethod // ignore: cast_nullable_to_non_nullable
                      as DrawAlgorithm,
            discountApplied: null == discountApplied
                ? _value.discountApplied
                : discountApplied // ignore: cast_nullable_to_non_nullable
                      as bool,
            declaredAt: null == declaredAt
                ? _value.declaredAt
                : declaredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            goldOptionLabel: freezed == goldOptionLabel
                ? _value.goldOptionLabel
                : goldOptionLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WinnerImplCopyWith<$Res> implements $WinnerCopyWith<$Res> {
  factory _$$WinnerImplCopyWith(
    _$WinnerImpl value,
    $Res Function(_$WinnerImpl) then,
  ) = __$$WinnerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String chittiId,
    String slotId,
    String userId,
    String userName,
    int? slotNumber,
    String winnerMonth,
    String discountStartMonth,
    double prizeAmount,
    double discountPerMonth,
    double totalDiscount,
    DrawAlgorithm selectionMethod,
    bool discountApplied,
    DateTime declaredAt,
    String? goldOptionLabel,
  });
}

/// @nodoc
class __$$WinnerImplCopyWithImpl<$Res>
    extends _$WinnerCopyWithImpl<$Res, _$WinnerImpl>
    implements _$$WinnerImplCopyWith<$Res> {
  __$$WinnerImplCopyWithImpl(
    _$WinnerImpl _value,
    $Res Function(_$WinnerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Winner
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chittiId = null,
    Object? slotId = null,
    Object? userId = null,
    Object? userName = null,
    Object? slotNumber = freezed,
    Object? winnerMonth = null,
    Object? discountStartMonth = null,
    Object? prizeAmount = null,
    Object? discountPerMonth = null,
    Object? totalDiscount = null,
    Object? selectionMethod = null,
    Object? discountApplied = null,
    Object? declaredAt = null,
    Object? goldOptionLabel = freezed,
  }) {
    return _then(
      _$WinnerImpl(
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
        slotNumber: freezed == slotNumber
            ? _value.slotNumber
            : slotNumber // ignore: cast_nullable_to_non_nullable
                  as int?,
        winnerMonth: null == winnerMonth
            ? _value.winnerMonth
            : winnerMonth // ignore: cast_nullable_to_non_nullable
                  as String,
        discountStartMonth: null == discountStartMonth
            ? _value.discountStartMonth
            : discountStartMonth // ignore: cast_nullable_to_non_nullable
                  as String,
        prizeAmount: null == prizeAmount
            ? _value.prizeAmount
            : prizeAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        discountPerMonth: null == discountPerMonth
            ? _value.discountPerMonth
            : discountPerMonth // ignore: cast_nullable_to_non_nullable
                  as double,
        totalDiscount: null == totalDiscount
            ? _value.totalDiscount
            : totalDiscount // ignore: cast_nullable_to_non_nullable
                  as double,
        selectionMethod: null == selectionMethod
            ? _value.selectionMethod
            : selectionMethod // ignore: cast_nullable_to_non_nullable
                  as DrawAlgorithm,
        discountApplied: null == discountApplied
            ? _value.discountApplied
            : discountApplied // ignore: cast_nullable_to_non_nullable
                  as bool,
        declaredAt: null == declaredAt
            ? _value.declaredAt
            : declaredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        goldOptionLabel: freezed == goldOptionLabel
            ? _value.goldOptionLabel
            : goldOptionLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WinnerImpl extends _Winner {
  const _$WinnerImpl({
    required this.id,
    required this.chittiId,
    required this.slotId,
    required this.userId,
    required this.userName,
    this.slotNumber,
    required this.winnerMonth,
    required this.discountStartMonth,
    required this.prizeAmount,
    required this.discountPerMonth,
    required this.totalDiscount,
    this.selectionMethod = DrawAlgorithm.random,
    this.discountApplied = false,
    required this.declaredAt,
    this.goldOptionLabel,
  }) : super._();

  factory _$WinnerImpl.fromJson(Map<String, dynamic> json) =>
      _$$WinnerImplFromJson(json);

  /// Unique winner record identifier
  @override
  final String id;

  /// Parent chitty ID
  @override
  final String chittiId;

  /// Winning slot ID
  @override
  final String slotId;

  /// User ID of winner
  @override
  final String userId;

  /// Display name of winner
  @override
  final String userName;

  /// Slot number for display
  @override
  final int? slotNumber;

  /// Month when they won (YYYY-MM format)
  @override
  final String winnerMonth;

  /// Month from which discount starts (month after winning)
  @override
  final String discountStartMonth;

  /// Prize amount (typically the slot's total value)
  @override
  final double prizeAmount;

  /// Discount applied per month to future payments
  @override
  final double discountPerMonth;

  /// Total discount over all remaining months
  @override
  final double totalDiscount;

  /// How winner was selected
  @override
  @JsonKey()
  final DrawAlgorithm selectionMethod;

  /// Whether discount has been applied to slot's balance
  @override
  @JsonKey()
  final bool discountApplied;

  /// When winner was declared
  @override
  final DateTime declaredAt;

  /// Gold option details for display
  @override
  final String? goldOptionLabel;

  @override
  String toString() {
    return 'Winner(id: $id, chittiId: $chittiId, slotId: $slotId, userId: $userId, userName: $userName, slotNumber: $slotNumber, winnerMonth: $winnerMonth, discountStartMonth: $discountStartMonth, prizeAmount: $prizeAmount, discountPerMonth: $discountPerMonth, totalDiscount: $totalDiscount, selectionMethod: $selectionMethod, discountApplied: $discountApplied, declaredAt: $declaredAt, goldOptionLabel: $goldOptionLabel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WinnerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chittiId, chittiId) ||
                other.chittiId == chittiId) &&
            (identical(other.slotId, slotId) || other.slotId == slotId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.slotNumber, slotNumber) ||
                other.slotNumber == slotNumber) &&
            (identical(other.winnerMonth, winnerMonth) ||
                other.winnerMonth == winnerMonth) &&
            (identical(other.discountStartMonth, discountStartMonth) ||
                other.discountStartMonth == discountStartMonth) &&
            (identical(other.prizeAmount, prizeAmount) ||
                other.prizeAmount == prizeAmount) &&
            (identical(other.discountPerMonth, discountPerMonth) ||
                other.discountPerMonth == discountPerMonth) &&
            (identical(other.totalDiscount, totalDiscount) ||
                other.totalDiscount == totalDiscount) &&
            (identical(other.selectionMethod, selectionMethod) ||
                other.selectionMethod == selectionMethod) &&
            (identical(other.discountApplied, discountApplied) ||
                other.discountApplied == discountApplied) &&
            (identical(other.declaredAt, declaredAt) ||
                other.declaredAt == declaredAt) &&
            (identical(other.goldOptionLabel, goldOptionLabel) ||
                other.goldOptionLabel == goldOptionLabel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    chittiId,
    slotId,
    userId,
    userName,
    slotNumber,
    winnerMonth,
    discountStartMonth,
    prizeAmount,
    discountPerMonth,
    totalDiscount,
    selectionMethod,
    discountApplied,
    declaredAt,
    goldOptionLabel,
  );

  /// Create a copy of Winner
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WinnerImplCopyWith<_$WinnerImpl> get copyWith =>
      __$$WinnerImplCopyWithImpl<_$WinnerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WinnerImplToJson(this);
  }
}

abstract class _Winner extends Winner {
  const factory _Winner({
    required final String id,
    required final String chittiId,
    required final String slotId,
    required final String userId,
    required final String userName,
    final int? slotNumber,
    required final String winnerMonth,
    required final String discountStartMonth,
    required final double prizeAmount,
    required final double discountPerMonth,
    required final double totalDiscount,
    final DrawAlgorithm selectionMethod,
    final bool discountApplied,
    required final DateTime declaredAt,
    final String? goldOptionLabel,
  }) = _$WinnerImpl;
  const _Winner._() : super._();

  factory _Winner.fromJson(Map<String, dynamic> json) = _$WinnerImpl.fromJson;

  /// Unique winner record identifier
  @override
  String get id;

  /// Parent chitty ID
  @override
  String get chittiId;

  /// Winning slot ID
  @override
  String get slotId;

  /// User ID of winner
  @override
  String get userId;

  /// Display name of winner
  @override
  String get userName;

  /// Slot number for display
  @override
  int? get slotNumber;

  /// Month when they won (YYYY-MM format)
  @override
  String get winnerMonth;

  /// Month from which discount starts (month after winning)
  @override
  String get discountStartMonth;

  /// Prize amount (typically the slot's total value)
  @override
  double get prizeAmount;

  /// Discount applied per month to future payments
  @override
  double get discountPerMonth;

  /// Total discount over all remaining months
  @override
  double get totalDiscount;

  /// How winner was selected
  @override
  DrawAlgorithm get selectionMethod;

  /// Whether discount has been applied to slot's balance
  @override
  bool get discountApplied;

  /// When winner was declared
  @override
  DateTime get declaredAt;

  /// Gold option details for display
  @override
  String? get goldOptionLabel;

  /// Create a copy of Winner
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WinnerImplCopyWith<_$WinnerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
