// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chitti.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Chitti _$ChittiFromJson(Map<String, dynamic> json) {
  return _Chitti.fromJson(json);
}

/// @nodoc
mixin _$Chitti {
  /// Unique chitti identifier
  String get id => throw _privateConstructorUsedError;

  /// Display name for the chitti
  String get name => throw _privateConstructorUsedError;

  /// Total duration in months
  int get duration => throw _privateConstructorUsedError;

  /// Start month (YYYY-MM format)
  String get startMonth => throw _privateConstructorUsedError;

  /// Current active month (1-indexed)
  int get currentMonth => throw _privateConstructorUsedError;

  /// Maximum number of slots allowed
  int get maxSlots => throw _privateConstructorUsedError;

  /// Current count of filled slots
  int get filledSlots => throw _privateConstructorUsedError;

  /// Day of month for EMI payments (1-28)
  int get paymentDay => throw _privateConstructorUsedError;

  /// Day of month for lucky draw (1-28)
  int get luckyDrawDay => throw _privateConstructorUsedError;

  /// Chitti lifecycle status
  ChittiStatus get status => throw _privateConstructorUsedError;

  /// Available gold options for this chitti
  List<ChittiGoldOption> get goldOptions => throw _privateConstructorUsedError;

  /// Per-option reward configurations
  Map<String, RewardConfig>? get goldOptionRewards =>
      throw _privateConstructorUsedError;

  /// When chitty was created
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// When chitti was started (status -> active)
  DateTime? get startedAt => throw _privateConstructorUsedError;

  /// When chitti was completed
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Total collected amount
  double get totalCollected => throw _privateConstructorUsedError;

  /// Total pending amount
  double get totalPending => throw _privateConstructorUsedError;

  /// Whether lucky draw is in progress (soft lock)
  bool get drawInProgress => throw _privateConstructorUsedError;

  /// Creator user ID
  String? get createdBy => throw _privateConstructorUsedError;

  /// Serializes this Chitti to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Chitti
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChittiCopyWith<Chitti> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChittiCopyWith<$Res> {
  factory $ChittiCopyWith(Chitti value, $Res Function(Chitti) then) =
      _$ChittiCopyWithImpl<$Res, Chitti>;
  @useResult
  $Res call({
    String id,
    String name,
    int duration,
    String startMonth,
    int currentMonth,
    int maxSlots,
    int filledSlots,
    int paymentDay,
    int luckyDrawDay,
    ChittiStatus status,
    List<ChittiGoldOption> goldOptions,
    Map<String, RewardConfig>? goldOptionRewards,
    DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    double totalCollected,
    double totalPending,
    bool drawInProgress,
    String? createdBy,
  });
}

/// @nodoc
class _$ChittiCopyWithImpl<$Res, $Val extends Chitti>
    implements $ChittiCopyWith<$Res> {
  _$ChittiCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Chitti
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? duration = null,
    Object? startMonth = null,
    Object? currentMonth = null,
    Object? maxSlots = null,
    Object? filledSlots = null,
    Object? paymentDay = null,
    Object? luckyDrawDay = null,
    Object? status = null,
    Object? goldOptions = null,
    Object? goldOptionRewards = freezed,
    Object? createdAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? totalCollected = null,
    Object? totalPending = null,
    Object? drawInProgress = null,
    Object? createdBy = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int,
            startMonth: null == startMonth
                ? _value.startMonth
                : startMonth // ignore: cast_nullable_to_non_nullable
                      as String,
            currentMonth: null == currentMonth
                ? _value.currentMonth
                : currentMonth // ignore: cast_nullable_to_non_nullable
                      as int,
            maxSlots: null == maxSlots
                ? _value.maxSlots
                : maxSlots // ignore: cast_nullable_to_non_nullable
                      as int,
            filledSlots: null == filledSlots
                ? _value.filledSlots
                : filledSlots // ignore: cast_nullable_to_non_nullable
                      as int,
            paymentDay: null == paymentDay
                ? _value.paymentDay
                : paymentDay // ignore: cast_nullable_to_non_nullable
                      as int,
            luckyDrawDay: null == luckyDrawDay
                ? _value.luckyDrawDay
                : luckyDrawDay // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ChittiStatus,
            goldOptions: null == goldOptions
                ? _value.goldOptions
                : goldOptions // ignore: cast_nullable_to_non_nullable
                      as List<ChittiGoldOption>,
            goldOptionRewards: freezed == goldOptionRewards
                ? _value.goldOptionRewards
                : goldOptionRewards // ignore: cast_nullable_to_non_nullable
                      as Map<String, RewardConfig>?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            totalCollected: null == totalCollected
                ? _value.totalCollected
                : totalCollected // ignore: cast_nullable_to_non_nullable
                      as double,
            totalPending: null == totalPending
                ? _value.totalPending
                : totalPending // ignore: cast_nullable_to_non_nullable
                      as double,
            drawInProgress: null == drawInProgress
                ? _value.drawInProgress
                : drawInProgress // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdBy: freezed == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChittiImplCopyWith<$Res> implements $ChittiCopyWith<$Res> {
  factory _$$ChittiImplCopyWith(
    _$ChittiImpl value,
    $Res Function(_$ChittiImpl) then,
  ) = __$$ChittiImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    int duration,
    String startMonth,
    int currentMonth,
    int maxSlots,
    int filledSlots,
    int paymentDay,
    int luckyDrawDay,
    ChittiStatus status,
    List<ChittiGoldOption> goldOptions,
    Map<String, RewardConfig>? goldOptionRewards,
    DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    double totalCollected,
    double totalPending,
    bool drawInProgress,
    String? createdBy,
  });
}

/// @nodoc
class __$$ChittiImplCopyWithImpl<$Res>
    extends _$ChittiCopyWithImpl<$Res, _$ChittiImpl>
    implements _$$ChittiImplCopyWith<$Res> {
  __$$ChittiImplCopyWithImpl(
    _$ChittiImpl _value,
    $Res Function(_$ChittiImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Chitti
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? duration = null,
    Object? startMonth = null,
    Object? currentMonth = null,
    Object? maxSlots = null,
    Object? filledSlots = null,
    Object? paymentDay = null,
    Object? luckyDrawDay = null,
    Object? status = null,
    Object? goldOptions = null,
    Object? goldOptionRewards = freezed,
    Object? createdAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? totalCollected = null,
    Object? totalPending = null,
    Object? drawInProgress = null,
    Object? createdBy = freezed,
  }) {
    return _then(
      _$ChittiImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int,
        startMonth: null == startMonth
            ? _value.startMonth
            : startMonth // ignore: cast_nullable_to_non_nullable
                  as String,
        currentMonth: null == currentMonth
            ? _value.currentMonth
            : currentMonth // ignore: cast_nullable_to_non_nullable
                  as int,
        maxSlots: null == maxSlots
            ? _value.maxSlots
            : maxSlots // ignore: cast_nullable_to_non_nullable
                  as int,
        filledSlots: null == filledSlots
            ? _value.filledSlots
            : filledSlots // ignore: cast_nullable_to_non_nullable
                  as int,
        paymentDay: null == paymentDay
            ? _value.paymentDay
            : paymentDay // ignore: cast_nullable_to_non_nullable
                  as int,
        luckyDrawDay: null == luckyDrawDay
            ? _value.luckyDrawDay
            : luckyDrawDay // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ChittiStatus,
        goldOptions: null == goldOptions
            ? _value._goldOptions
            : goldOptions // ignore: cast_nullable_to_non_nullable
                  as List<ChittiGoldOption>,
        goldOptionRewards: freezed == goldOptionRewards
            ? _value._goldOptionRewards
            : goldOptionRewards // ignore: cast_nullable_to_non_nullable
                  as Map<String, RewardConfig>?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        totalCollected: null == totalCollected
            ? _value.totalCollected
            : totalCollected // ignore: cast_nullable_to_non_nullable
                  as double,
        totalPending: null == totalPending
            ? _value.totalPending
            : totalPending // ignore: cast_nullable_to_non_nullable
                  as double,
        drawInProgress: null == drawInProgress
            ? _value.drawInProgress
            : drawInProgress // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdBy: freezed == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChittiImpl extends _Chitti {
  const _$ChittiImpl({
    required this.id,
    required this.name,
    required this.duration,
    required this.startMonth,
    this.currentMonth = 1,
    required this.maxSlots,
    this.filledSlots = 0,
    required this.paymentDay,
    required this.luckyDrawDay,
    this.status = ChittiStatus.draft,
    required final List<ChittiGoldOption> goldOptions,
    final Map<String, RewardConfig>? goldOptionRewards,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.totalCollected = 0.0,
    this.totalPending = 0.0,
    this.drawInProgress = false,
    this.createdBy,
  }) : _goldOptions = goldOptions,
       _goldOptionRewards = goldOptionRewards,
       super._();

  factory _$ChittiImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChittiImplFromJson(json);

  /// Unique chitti identifier
  @override
  final String id;

  /// Display name for the chitti
  @override
  final String name;

  /// Total duration in months
  @override
  final int duration;

  /// Start month (YYYY-MM format)
  @override
  final String startMonth;

  /// Current active month (1-indexed)
  @override
  @JsonKey()
  final int currentMonth;

  /// Maximum number of slots allowed
  @override
  final int maxSlots;

  /// Current count of filled slots
  @override
  @JsonKey()
  final int filledSlots;

  /// Day of month for EMI payments (1-28)
  @override
  final int paymentDay;

  /// Day of month for lucky draw (1-28)
  @override
  final int luckyDrawDay;

  /// Chitti lifecycle status
  @override
  @JsonKey()
  final ChittiStatus status;

  /// Available gold options for this chitti
  final List<ChittiGoldOption> _goldOptions;

  /// Available gold options for this chitti
  @override
  List<ChittiGoldOption> get goldOptions {
    if (_goldOptions is EqualUnmodifiableListView) return _goldOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_goldOptions);
  }

  /// Per-option reward configurations
  final Map<String, RewardConfig>? _goldOptionRewards;

  /// Per-option reward configurations
  @override
  Map<String, RewardConfig>? get goldOptionRewards {
    final value = _goldOptionRewards;
    if (value == null) return null;
    if (_goldOptionRewards is EqualUnmodifiableMapView)
      return _goldOptionRewards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// When chitty was created
  @override
  final DateTime createdAt;

  /// When chitti was started (status -> active)
  @override
  final DateTime? startedAt;

  /// When chitti was completed
  @override
  final DateTime? completedAt;

  /// Total collected amount
  @override
  @JsonKey()
  final double totalCollected;

  /// Total pending amount
  @override
  @JsonKey()
  final double totalPending;

  /// Whether lucky draw is in progress (soft lock)
  @override
  @JsonKey()
  final bool drawInProgress;

  /// Creator user ID
  @override
  final String? createdBy;

  @override
  String toString() {
    return 'Chitti(id: $id, name: $name, duration: $duration, startMonth: $startMonth, currentMonth: $currentMonth, maxSlots: $maxSlots, filledSlots: $filledSlots, paymentDay: $paymentDay, luckyDrawDay: $luckyDrawDay, status: $status, goldOptions: $goldOptions, goldOptionRewards: $goldOptionRewards, createdAt: $createdAt, startedAt: $startedAt, completedAt: $completedAt, totalCollected: $totalCollected, totalPending: $totalPending, drawInProgress: $drawInProgress, createdBy: $createdBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChittiImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.startMonth, startMonth) ||
                other.startMonth == startMonth) &&
            (identical(other.currentMonth, currentMonth) ||
                other.currentMonth == currentMonth) &&
            (identical(other.maxSlots, maxSlots) ||
                other.maxSlots == maxSlots) &&
            (identical(other.filledSlots, filledSlots) ||
                other.filledSlots == filledSlots) &&
            (identical(other.paymentDay, paymentDay) ||
                other.paymentDay == paymentDay) &&
            (identical(other.luckyDrawDay, luckyDrawDay) ||
                other.luckyDrawDay == luckyDrawDay) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._goldOptions,
              _goldOptions,
            ) &&
            const DeepCollectionEquality().equals(
              other._goldOptionRewards,
              _goldOptionRewards,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.totalCollected, totalCollected) ||
                other.totalCollected == totalCollected) &&
            (identical(other.totalPending, totalPending) ||
                other.totalPending == totalPending) &&
            (identical(other.drawInProgress, drawInProgress) ||
                other.drawInProgress == drawInProgress) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    name,
    duration,
    startMonth,
    currentMonth,
    maxSlots,
    filledSlots,
    paymentDay,
    luckyDrawDay,
    status,
    const DeepCollectionEquality().hash(_goldOptions),
    const DeepCollectionEquality().hash(_goldOptionRewards),
    createdAt,
    startedAt,
    completedAt,
    totalCollected,
    totalPending,
    drawInProgress,
    createdBy,
  ]);

  /// Create a copy of Chitti
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChittiImplCopyWith<_$ChittiImpl> get copyWith =>
      __$$ChittiImplCopyWithImpl<_$ChittiImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChittiImplToJson(this);
  }
}

abstract class _Chitti extends Chitti {
  const factory _Chitti({
    required final String id,
    required final String name,
    required final int duration,
    required final String startMonth,
    final int currentMonth,
    required final int maxSlots,
    final int filledSlots,
    required final int paymentDay,
    required final int luckyDrawDay,
    final ChittiStatus status,
    required final List<ChittiGoldOption> goldOptions,
    final Map<String, RewardConfig>? goldOptionRewards,
    required final DateTime createdAt,
    final DateTime? startedAt,
    final DateTime? completedAt,
    final double totalCollected,
    final double totalPending,
    final bool drawInProgress,
    final String? createdBy,
  }) = _$ChittiImpl;
  const _Chitti._() : super._();

  factory _Chitti.fromJson(Map<String, dynamic> json) = _$ChittiImpl.fromJson;

  /// Unique chitti identifier
  @override
  String get id;

  /// Display name for the chitti
  @override
  String get name;

  /// Total duration in months
  @override
  int get duration;

  /// Start month (YYYY-MM format)
  @override
  String get startMonth;

  /// Current active month (1-indexed)
  @override
  int get currentMonth;

  /// Maximum number of slots allowed
  @override
  int get maxSlots;

  /// Current count of filled slots
  @override
  int get filledSlots;

  /// Day of month for EMI payments (1-28)
  @override
  int get paymentDay;

  /// Day of month for lucky draw (1-28)
  @override
  int get luckyDrawDay;

  /// Chitti lifecycle status
  @override
  ChittiStatus get status;

  /// Available gold options for this chitti
  @override
  List<ChittiGoldOption> get goldOptions;

  /// Per-option reward configurations
  @override
  Map<String, RewardConfig>? get goldOptionRewards;

  /// When chitty was created
  @override
  DateTime get createdAt;

  /// When chitti was started (status -> active)
  @override
  DateTime? get startedAt;

  /// When chitti was completed
  @override
  DateTime? get completedAt;

  /// Total collected amount
  @override
  double get totalCollected;

  /// Total pending amount
  @override
  double get totalPending;

  /// Whether lucky draw is in progress (soft lock)
  @override
  bool get drawInProgress;

  /// Creator user ID
  @override
  String? get createdBy;

  /// Create a copy of Chitti
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChittiImplCopyWith<_$ChittiImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChittiGoldOption _$ChittiGoldOptionFromJson(Map<String, dynamic> json) {
  return _ChittiGoldOption.fromJson(json);
}

/// @nodoc
mixin _$ChittiGoldOption {
  /// Unique option identifier
  String get id => throw _privateConstructorUsedError;

  /// Type of gold (coin, bar, etc.)
  GoldType get type => throw _privateConstructorUsedError;

  /// Purity level
  GoldPurity get purity => throw _privateConstructorUsedError;

  /// Weight in grams
  double get weight => throw _privateConstructorUsedError;

  /// Price per gram (locked at chitty creation)
  double get pricePerUnit => throw _privateConstructorUsedError;

  /// Total price (weight × pricePerUnit)
  double get totalPrice => throw _privateConstructorUsedError;

  /// Monthly EMI amount (totalPrice / duration)
  double get emiAmount => throw _privateConstructorUsedError;

  /// Serializes this ChittiGoldOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChittiGoldOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChittiGoldOptionCopyWith<ChittiGoldOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChittiGoldOptionCopyWith<$Res> {
  factory $ChittiGoldOptionCopyWith(
    ChittiGoldOption value,
    $Res Function(ChittiGoldOption) then,
  ) = _$ChittiGoldOptionCopyWithImpl<$Res, ChittiGoldOption>;
  @useResult
  $Res call({
    String id,
    GoldType type,
    GoldPurity purity,
    double weight,
    double pricePerUnit,
    double totalPrice,
    double emiAmount,
  });
}

/// @nodoc
class _$ChittiGoldOptionCopyWithImpl<$Res, $Val extends ChittiGoldOption>
    implements $ChittiGoldOptionCopyWith<$Res> {
  _$ChittiGoldOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChittiGoldOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? purity = null,
    Object? weight = null,
    Object? pricePerUnit = null,
    Object? totalPrice = null,
    Object? emiAmount = null,
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
                      as GoldType,
            purity: null == purity
                ? _value.purity
                : purity // ignore: cast_nullable_to_non_nullable
                      as GoldPurity,
            weight: null == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as double,
            pricePerUnit: null == pricePerUnit
                ? _value.pricePerUnit
                : pricePerUnit // ignore: cast_nullable_to_non_nullable
                      as double,
            totalPrice: null == totalPrice
                ? _value.totalPrice
                : totalPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            emiAmount: null == emiAmount
                ? _value.emiAmount
                : emiAmount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChittiGoldOptionImplCopyWith<$Res>
    implements $ChittiGoldOptionCopyWith<$Res> {
  factory _$$ChittiGoldOptionImplCopyWith(
    _$ChittiGoldOptionImpl value,
    $Res Function(_$ChittiGoldOptionImpl) then,
  ) = __$$ChittiGoldOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    GoldType type,
    GoldPurity purity,
    double weight,
    double pricePerUnit,
    double totalPrice,
    double emiAmount,
  });
}

/// @nodoc
class __$$ChittiGoldOptionImplCopyWithImpl<$Res>
    extends _$ChittiGoldOptionCopyWithImpl<$Res, _$ChittiGoldOptionImpl>
    implements _$$ChittiGoldOptionImplCopyWith<$Res> {
  __$$ChittiGoldOptionImplCopyWithImpl(
    _$ChittiGoldOptionImpl _value,
    $Res Function(_$ChittiGoldOptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChittiGoldOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? purity = null,
    Object? weight = null,
    Object? pricePerUnit = null,
    Object? totalPrice = null,
    Object? emiAmount = null,
  }) {
    return _then(
      _$ChittiGoldOptionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as GoldType,
        purity: null == purity
            ? _value.purity
            : purity // ignore: cast_nullable_to_non_nullable
                  as GoldPurity,
        weight: null == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double,
        pricePerUnit: null == pricePerUnit
            ? _value.pricePerUnit
            : pricePerUnit // ignore: cast_nullable_to_non_nullable
                  as double,
        totalPrice: null == totalPrice
            ? _value.totalPrice
            : totalPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        emiAmount: null == emiAmount
            ? _value.emiAmount
            : emiAmount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChittiGoldOptionImpl extends _ChittiGoldOption {
  const _$ChittiGoldOptionImpl({
    required this.id,
    required this.type,
    required this.purity,
    required this.weight,
    required this.pricePerUnit,
    required this.totalPrice,
    required this.emiAmount,
  }) : super._();

  factory _$ChittiGoldOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChittiGoldOptionImplFromJson(json);

  /// Unique option identifier
  @override
  final String id;

  /// Type of gold (coin, bar, etc.)
  @override
  final GoldType type;

  /// Purity level
  @override
  final GoldPurity purity;

  /// Weight in grams
  @override
  final double weight;

  /// Price per gram (locked at chitty creation)
  @override
  final double pricePerUnit;

  /// Total price (weight × pricePerUnit)
  @override
  final double totalPrice;

  /// Monthly EMI amount (totalPrice / duration)
  @override
  final double emiAmount;

  @override
  String toString() {
    return 'ChittiGoldOption(id: $id, type: $type, purity: $purity, weight: $weight, pricePerUnit: $pricePerUnit, totalPrice: $totalPrice, emiAmount: $emiAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChittiGoldOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.purity, purity) || other.purity == purity) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.pricePerUnit, pricePerUnit) ||
                other.pricePerUnit == pricePerUnit) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.emiAmount, emiAmount) ||
                other.emiAmount == emiAmount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    purity,
    weight,
    pricePerUnit,
    totalPrice,
    emiAmount,
  );

  /// Create a copy of ChittiGoldOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChittiGoldOptionImplCopyWith<_$ChittiGoldOptionImpl> get copyWith =>
      __$$ChittiGoldOptionImplCopyWithImpl<_$ChittiGoldOptionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChittiGoldOptionImplToJson(this);
  }
}

abstract class _ChittiGoldOption extends ChittiGoldOption {
  const factory _ChittiGoldOption({
    required final String id,
    required final GoldType type,
    required final GoldPurity purity,
    required final double weight,
    required final double pricePerUnit,
    required final double totalPrice,
    required final double emiAmount,
  }) = _$ChittiGoldOptionImpl;
  const _ChittiGoldOption._() : super._();

  factory _ChittiGoldOption.fromJson(Map<String, dynamic> json) =
      _$ChittiGoldOptionImpl.fromJson;

  /// Unique option identifier
  @override
  String get id;

  /// Type of gold (coin, bar, etc.)
  @override
  GoldType get type;

  /// Purity level
  @override
  GoldPurity get purity;

  /// Weight in grams
  @override
  double get weight;

  /// Price per gram (locked at chitty creation)
  @override
  double get pricePerUnit;

  /// Total price (weight × pricePerUnit)
  @override
  double get totalPrice;

  /// Monthly EMI amount (totalPrice / duration)
  @override
  double get emiAmount;

  /// Create a copy of ChittiGoldOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChittiGoldOptionImplCopyWith<_$ChittiGoldOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RewardConfig _$RewardConfigFromJson(Map<String, dynamic> json) {
  return _RewardConfig.fromJson(json);
}

/// @nodoc
mixin _$RewardConfig {
  /// Whether rewards are enabled for this option
  bool get enabled => throw _privateConstructorUsedError;

  /// Reward type: 'Percentage' or 'Fixed Amount'
  String get type => throw _privateConstructorUsedError;

  /// Value (percentage or fixed amount)
  double get value => throw _privateConstructorUsedError;

  /// Pre-computed discount amount per month
  double? get calculatedAmount => throw _privateConstructorUsedError;

  /// Serializes this RewardConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RewardConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RewardConfigCopyWith<RewardConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RewardConfigCopyWith<$Res> {
  factory $RewardConfigCopyWith(
    RewardConfig value,
    $Res Function(RewardConfig) then,
  ) = _$RewardConfigCopyWithImpl<$Res, RewardConfig>;
  @useResult
  $Res call({
    bool enabled,
    String type,
    double value,
    double? calculatedAmount,
  });
}

/// @nodoc
class _$RewardConfigCopyWithImpl<$Res, $Val extends RewardConfig>
    implements $RewardConfigCopyWith<$Res> {
  _$RewardConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RewardConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? type = null,
    Object? value = null,
    Object? calculatedAmount = freezed,
  }) {
    return _then(
      _value.copyWith(
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as double,
            calculatedAmount: freezed == calculatedAmount
                ? _value.calculatedAmount
                : calculatedAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RewardConfigImplCopyWith<$Res>
    implements $RewardConfigCopyWith<$Res> {
  factory _$$RewardConfigImplCopyWith(
    _$RewardConfigImpl value,
    $Res Function(_$RewardConfigImpl) then,
  ) = __$$RewardConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool enabled,
    String type,
    double value,
    double? calculatedAmount,
  });
}

/// @nodoc
class __$$RewardConfigImplCopyWithImpl<$Res>
    extends _$RewardConfigCopyWithImpl<$Res, _$RewardConfigImpl>
    implements _$$RewardConfigImplCopyWith<$Res> {
  __$$RewardConfigImplCopyWithImpl(
    _$RewardConfigImpl _value,
    $Res Function(_$RewardConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RewardConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? type = null,
    Object? value = null,
    Object? calculatedAmount = freezed,
  }) {
    return _then(
      _$RewardConfigImpl(
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as double,
        calculatedAmount: freezed == calculatedAmount
            ? _value.calculatedAmount
            : calculatedAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RewardConfigImpl extends _RewardConfig {
  const _$RewardConfigImpl({
    this.enabled = true,
    required this.type,
    required this.value,
    this.calculatedAmount,
  }) : super._();

  factory _$RewardConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$RewardConfigImplFromJson(json);

  /// Whether rewards are enabled for this option
  @override
  @JsonKey()
  final bool enabled;

  /// Reward type: 'Percentage' or 'Fixed Amount'
  @override
  final String type;

  /// Value (percentage or fixed amount)
  @override
  final double value;

  /// Pre-computed discount amount per month
  @override
  final double? calculatedAmount;

  @override
  String toString() {
    return 'RewardConfig(enabled: $enabled, type: $type, value: $value, calculatedAmount: $calculatedAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RewardConfigImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.calculatedAmount, calculatedAmount) ||
                other.calculatedAmount == calculatedAmount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, enabled, type, value, calculatedAmount);

  /// Create a copy of RewardConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RewardConfigImplCopyWith<_$RewardConfigImpl> get copyWith =>
      __$$RewardConfigImplCopyWithImpl<_$RewardConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RewardConfigImplToJson(this);
  }
}

abstract class _RewardConfig extends RewardConfig {
  const factory _RewardConfig({
    final bool enabled,
    required final String type,
    required final double value,
    final double? calculatedAmount,
  }) = _$RewardConfigImpl;
  const _RewardConfig._() : super._();

  factory _RewardConfig.fromJson(Map<String, dynamic> json) =
      _$RewardConfigImpl.fromJson;

  /// Whether rewards are enabled for this option
  @override
  bool get enabled;

  /// Reward type: 'Percentage' or 'Fixed Amount'
  @override
  String get type;

  /// Value (percentage or fixed amount)
  @override
  double get value;

  /// Pre-computed discount amount per month
  @override
  double? get calculatedAmount;

  /// Create a copy of RewardConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RewardConfigImplCopyWith<_$RewardConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
