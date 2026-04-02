// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emi_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EMIEntry _$EMIEntryFromJson(Map<String, dynamic> json) {
  return _EMIEntry.fromJson(json);
}

/// @nodoc
mixin _$EMIEntry {
  /// Month number (1-indexed)
  int get monthNumber => throw _privateConstructorUsedError;

  /// Month key in YYYY-MM format
  String get monthKey => throw _privateConstructorUsedError;

  /// Human-readable month label (e.g., "Feb 2026")
  String get monthLabel => throw _privateConstructorUsedError;

  /// Due date for this EMI
  DateTime get dueDate => throw _privateConstructorUsedError;

  /// Original EMI amount in cents (before any discounts)
  int get originalAmountInCents => throw _privateConstructorUsedError;

  /// Discount applied in cents (winner discount)
  int get discountInCents => throw _privateConstructorUsedError;

  /// Net amount due in cents (original - discount)
  int get netAmountInCents => throw _privateConstructorUsedError;

  /// Amount already paid in cents
  int get paidAmountInCents => throw _privateConstructorUsedError;

  /// Current status
  EMIStatus get status => throw _privateConstructorUsedError;

  /// Whether this is the first month (may have rounding remainder)
  bool get isFirstMonth => throw _privateConstructorUsedError;

  /// Extra amount in first month due to rounding
  int get roundingRemainderInCents => throw _privateConstructorUsedError;

  /// Whether winner discount is applied to this month
  bool get hasWinnerDiscount => throw _privateConstructorUsedError;

  /// Transaction IDs for payments made against this month
  List<String> get transactionIds => throw _privateConstructorUsedError;

  /// Serializes this EMIEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EMIEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EMIEntryCopyWith<EMIEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EMIEntryCopyWith<$Res> {
  factory $EMIEntryCopyWith(EMIEntry value, $Res Function(EMIEntry) then) =
      _$EMIEntryCopyWithImpl<$Res, EMIEntry>;
  @useResult
  $Res call({
    int monthNumber,
    String monthKey,
    String monthLabel,
    DateTime dueDate,
    int originalAmountInCents,
    int discountInCents,
    int netAmountInCents,
    int paidAmountInCents,
    EMIStatus status,
    bool isFirstMonth,
    int roundingRemainderInCents,
    bool hasWinnerDiscount,
    List<String> transactionIds,
  });
}

/// @nodoc
class _$EMIEntryCopyWithImpl<$Res, $Val extends EMIEntry>
    implements $EMIEntryCopyWith<$Res> {
  _$EMIEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EMIEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthNumber = null,
    Object? monthKey = null,
    Object? monthLabel = null,
    Object? dueDate = null,
    Object? originalAmountInCents = null,
    Object? discountInCents = null,
    Object? netAmountInCents = null,
    Object? paidAmountInCents = null,
    Object? status = null,
    Object? isFirstMonth = null,
    Object? roundingRemainderInCents = null,
    Object? hasWinnerDiscount = null,
    Object? transactionIds = null,
  }) {
    return _then(
      _value.copyWith(
            monthNumber: null == monthNumber
                ? _value.monthNumber
                : monthNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            monthKey: null == monthKey
                ? _value.monthKey
                : monthKey // ignore: cast_nullable_to_non_nullable
                      as String,
            monthLabel: null == monthLabel
                ? _value.monthLabel
                : monthLabel // ignore: cast_nullable_to_non_nullable
                      as String,
            dueDate: null == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            originalAmountInCents: null == originalAmountInCents
                ? _value.originalAmountInCents
                : originalAmountInCents // ignore: cast_nullable_to_non_nullable
                      as int,
            discountInCents: null == discountInCents
                ? _value.discountInCents
                : discountInCents // ignore: cast_nullable_to_non_nullable
                      as int,
            netAmountInCents: null == netAmountInCents
                ? _value.netAmountInCents
                : netAmountInCents // ignore: cast_nullable_to_non_nullable
                      as int,
            paidAmountInCents: null == paidAmountInCents
                ? _value.paidAmountInCents
                : paidAmountInCents // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EMIStatus,
            isFirstMonth: null == isFirstMonth
                ? _value.isFirstMonth
                : isFirstMonth // ignore: cast_nullable_to_non_nullable
                      as bool,
            roundingRemainderInCents: null == roundingRemainderInCents
                ? _value.roundingRemainderInCents
                : roundingRemainderInCents // ignore: cast_nullable_to_non_nullable
                      as int,
            hasWinnerDiscount: null == hasWinnerDiscount
                ? _value.hasWinnerDiscount
                : hasWinnerDiscount // ignore: cast_nullable_to_non_nullable
                      as bool,
            transactionIds: null == transactionIds
                ? _value.transactionIds
                : transactionIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EMIEntryImplCopyWith<$Res>
    implements $EMIEntryCopyWith<$Res> {
  factory _$$EMIEntryImplCopyWith(
    _$EMIEntryImpl value,
    $Res Function(_$EMIEntryImpl) then,
  ) = __$$EMIEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int monthNumber,
    String monthKey,
    String monthLabel,
    DateTime dueDate,
    int originalAmountInCents,
    int discountInCents,
    int netAmountInCents,
    int paidAmountInCents,
    EMIStatus status,
    bool isFirstMonth,
    int roundingRemainderInCents,
    bool hasWinnerDiscount,
    List<String> transactionIds,
  });
}

/// @nodoc
class __$$EMIEntryImplCopyWithImpl<$Res>
    extends _$EMIEntryCopyWithImpl<$Res, _$EMIEntryImpl>
    implements _$$EMIEntryImplCopyWith<$Res> {
  __$$EMIEntryImplCopyWithImpl(
    _$EMIEntryImpl _value,
    $Res Function(_$EMIEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EMIEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthNumber = null,
    Object? monthKey = null,
    Object? monthLabel = null,
    Object? dueDate = null,
    Object? originalAmountInCents = null,
    Object? discountInCents = null,
    Object? netAmountInCents = null,
    Object? paidAmountInCents = null,
    Object? status = null,
    Object? isFirstMonth = null,
    Object? roundingRemainderInCents = null,
    Object? hasWinnerDiscount = null,
    Object? transactionIds = null,
  }) {
    return _then(
      _$EMIEntryImpl(
        monthNumber: null == monthNumber
            ? _value.monthNumber
            : monthNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        monthKey: null == monthKey
            ? _value.monthKey
            : monthKey // ignore: cast_nullable_to_non_nullable
                  as String,
        monthLabel: null == monthLabel
            ? _value.monthLabel
            : monthLabel // ignore: cast_nullable_to_non_nullable
                  as String,
        dueDate: null == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        originalAmountInCents: null == originalAmountInCents
            ? _value.originalAmountInCents
            : originalAmountInCents // ignore: cast_nullable_to_non_nullable
                  as int,
        discountInCents: null == discountInCents
            ? _value.discountInCents
            : discountInCents // ignore: cast_nullable_to_non_nullable
                  as int,
        netAmountInCents: null == netAmountInCents
            ? _value.netAmountInCents
            : netAmountInCents // ignore: cast_nullable_to_non_nullable
                  as int,
        paidAmountInCents: null == paidAmountInCents
            ? _value.paidAmountInCents
            : paidAmountInCents // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EMIStatus,
        isFirstMonth: null == isFirstMonth
            ? _value.isFirstMonth
            : isFirstMonth // ignore: cast_nullable_to_non_nullable
                  as bool,
        roundingRemainderInCents: null == roundingRemainderInCents
            ? _value.roundingRemainderInCents
            : roundingRemainderInCents // ignore: cast_nullable_to_non_nullable
                  as int,
        hasWinnerDiscount: null == hasWinnerDiscount
            ? _value.hasWinnerDiscount
            : hasWinnerDiscount // ignore: cast_nullable_to_non_nullable
                  as bool,
        transactionIds: null == transactionIds
            ? _value._transactionIds
            : transactionIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EMIEntryImpl extends _EMIEntry {
  const _$EMIEntryImpl({
    required this.monthNumber,
    required this.monthKey,
    required this.monthLabel,
    required this.dueDate,
    required this.originalAmountInCents,
    this.discountInCents = 0,
    required this.netAmountInCents,
    this.paidAmountInCents = 0,
    required this.status,
    this.isFirstMonth = false,
    this.roundingRemainderInCents = 0,
    this.hasWinnerDiscount = false,
    final List<String> transactionIds = const [],
  }) : _transactionIds = transactionIds,
       super._();

  factory _$EMIEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$EMIEntryImplFromJson(json);

  /// Month number (1-indexed)
  @override
  final int monthNumber;

  /// Month key in YYYY-MM format
  @override
  final String monthKey;

  /// Human-readable month label (e.g., "Feb 2026")
  @override
  final String monthLabel;

  /// Due date for this EMI
  @override
  final DateTime dueDate;

  /// Original EMI amount in cents (before any discounts)
  @override
  final int originalAmountInCents;

  /// Discount applied in cents (winner discount)
  @override
  @JsonKey()
  final int discountInCents;

  /// Net amount due in cents (original - discount)
  @override
  final int netAmountInCents;

  /// Amount already paid in cents
  @override
  @JsonKey()
  final int paidAmountInCents;

  /// Current status
  @override
  final EMIStatus status;

  /// Whether this is the first month (may have rounding remainder)
  @override
  @JsonKey()
  final bool isFirstMonth;

  /// Extra amount in first month due to rounding
  @override
  @JsonKey()
  final int roundingRemainderInCents;

  /// Whether winner discount is applied to this month
  @override
  @JsonKey()
  final bool hasWinnerDiscount;

  /// Transaction IDs for payments made against this month
  final List<String> _transactionIds;

  /// Transaction IDs for payments made against this month
  @override
  @JsonKey()
  List<String> get transactionIds {
    if (_transactionIds is EqualUnmodifiableListView) return _transactionIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transactionIds);
  }

  @override
  String toString() {
    return 'EMIEntry(monthNumber: $monthNumber, monthKey: $monthKey, monthLabel: $monthLabel, dueDate: $dueDate, originalAmountInCents: $originalAmountInCents, discountInCents: $discountInCents, netAmountInCents: $netAmountInCents, paidAmountInCents: $paidAmountInCents, status: $status, isFirstMonth: $isFirstMonth, roundingRemainderInCents: $roundingRemainderInCents, hasWinnerDiscount: $hasWinnerDiscount, transactionIds: $transactionIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EMIEntryImpl &&
            (identical(other.monthNumber, monthNumber) ||
                other.monthNumber == monthNumber) &&
            (identical(other.monthKey, monthKey) ||
                other.monthKey == monthKey) &&
            (identical(other.monthLabel, monthLabel) ||
                other.monthLabel == monthLabel) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.originalAmountInCents, originalAmountInCents) ||
                other.originalAmountInCents == originalAmountInCents) &&
            (identical(other.discountInCents, discountInCents) ||
                other.discountInCents == discountInCents) &&
            (identical(other.netAmountInCents, netAmountInCents) ||
                other.netAmountInCents == netAmountInCents) &&
            (identical(other.paidAmountInCents, paidAmountInCents) ||
                other.paidAmountInCents == paidAmountInCents) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isFirstMonth, isFirstMonth) ||
                other.isFirstMonth == isFirstMonth) &&
            (identical(
                  other.roundingRemainderInCents,
                  roundingRemainderInCents,
                ) ||
                other.roundingRemainderInCents == roundingRemainderInCents) &&
            (identical(other.hasWinnerDiscount, hasWinnerDiscount) ||
                other.hasWinnerDiscount == hasWinnerDiscount) &&
            const DeepCollectionEquality().equals(
              other._transactionIds,
              _transactionIds,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    monthNumber,
    monthKey,
    monthLabel,
    dueDate,
    originalAmountInCents,
    discountInCents,
    netAmountInCents,
    paidAmountInCents,
    status,
    isFirstMonth,
    roundingRemainderInCents,
    hasWinnerDiscount,
    const DeepCollectionEquality().hash(_transactionIds),
  );

  /// Create a copy of EMIEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EMIEntryImplCopyWith<_$EMIEntryImpl> get copyWith =>
      __$$EMIEntryImplCopyWithImpl<_$EMIEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EMIEntryImplToJson(this);
  }
}

abstract class _EMIEntry extends EMIEntry {
  const factory _EMIEntry({
    required final int monthNumber,
    required final String monthKey,
    required final String monthLabel,
    required final DateTime dueDate,
    required final int originalAmountInCents,
    final int discountInCents,
    required final int netAmountInCents,
    final int paidAmountInCents,
    required final EMIStatus status,
    final bool isFirstMonth,
    final int roundingRemainderInCents,
    final bool hasWinnerDiscount,
    final List<String> transactionIds,
  }) = _$EMIEntryImpl;
  const _EMIEntry._() : super._();

  factory _EMIEntry.fromJson(Map<String, dynamic> json) =
      _$EMIEntryImpl.fromJson;

  /// Month number (1-indexed)
  @override
  int get monthNumber;

  /// Month key in YYYY-MM format
  @override
  String get monthKey;

  /// Human-readable month label (e.g., "Feb 2026")
  @override
  String get monthLabel;

  /// Due date for this EMI
  @override
  DateTime get dueDate;

  /// Original EMI amount in cents (before any discounts)
  @override
  int get originalAmountInCents;

  /// Discount applied in cents (winner discount)
  @override
  int get discountInCents;

  /// Net amount due in cents (original - discount)
  @override
  int get netAmountInCents;

  /// Amount already paid in cents
  @override
  int get paidAmountInCents;

  /// Current status
  @override
  EMIStatus get status;

  /// Whether this is the first month (may have rounding remainder)
  @override
  bool get isFirstMonth;

  /// Extra amount in first month due to rounding
  @override
  int get roundingRemainderInCents;

  /// Whether winner discount is applied to this month
  @override
  bool get hasWinnerDiscount;

  /// Transaction IDs for payments made against this month
  @override
  List<String> get transactionIds;

  /// Create a copy of EMIEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EMIEntryImplCopyWith<_$EMIEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EMISchedule _$EMIScheduleFromJson(Map<String, dynamic> json) {
  return _EMISchedule.fromJson(json);
}

/// @nodoc
mixin _$EMISchedule {
  /// Slot ID this schedule belongs to
  String get slotId => throw _privateConstructorUsedError;

  /// Chitti ID
  String get chittyId => throw _privateConstructorUsedError;

  /// Total duration in months
  int get duration => throw _privateConstructorUsedError;

  /// Total amount in cents
  int get totalAmountInCents => throw _privateConstructorUsedError;

  /// Base EMI in cents (before first month adjustment)
  int get baseEMIInCents => throw _privateConstructorUsedError;

  /// First month EMI in cents (includes rounding remainder)
  int get firstMonthEMIInCents => throw _privateConstructorUsedError;

  /// Monthly discount for winners in cents
  int get winnerDiscountPerMonthInCents => throw _privateConstructorUsedError;

  /// Month from which discount starts (null if not a winner)
  String? get discountStartMonth => throw _privateConstructorUsedError;

  /// All EMI entries
  List<EMIEntry> get entries => throw _privateConstructorUsedError;

  /// When schedule was generated
  DateTime get generatedAt => throw _privateConstructorUsedError;

  /// Serializes this EMISchedule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EMISchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EMIScheduleCopyWith<EMISchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EMIScheduleCopyWith<$Res> {
  factory $EMIScheduleCopyWith(
    EMISchedule value,
    $Res Function(EMISchedule) then,
  ) = _$EMIScheduleCopyWithImpl<$Res, EMISchedule>;
  @useResult
  $Res call({
    String slotId,
    String chittyId,
    int duration,
    int totalAmountInCents,
    int baseEMIInCents,
    int firstMonthEMIInCents,
    int winnerDiscountPerMonthInCents,
    String? discountStartMonth,
    List<EMIEntry> entries,
    DateTime generatedAt,
  });
}

/// @nodoc
class _$EMIScheduleCopyWithImpl<$Res, $Val extends EMISchedule>
    implements $EMIScheduleCopyWith<$Res> {
  _$EMIScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EMISchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slotId = null,
    Object? chittyId = null,
    Object? duration = null,
    Object? totalAmountInCents = null,
    Object? baseEMIInCents = null,
    Object? firstMonthEMIInCents = null,
    Object? winnerDiscountPerMonthInCents = null,
    Object? discountStartMonth = freezed,
    Object? entries = null,
    Object? generatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            slotId: null == slotId
                ? _value.slotId
                : slotId // ignore: cast_nullable_to_non_nullable
                      as String,
            chittyId: null == chittyId
                ? _value.chittyId
                : chittyId // ignore: cast_nullable_to_non_nullable
                      as String,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int,
            totalAmountInCents: null == totalAmountInCents
                ? _value.totalAmountInCents
                : totalAmountInCents // ignore: cast_nullable_to_non_nullable
                      as int,
            baseEMIInCents: null == baseEMIInCents
                ? _value.baseEMIInCents
                : baseEMIInCents // ignore: cast_nullable_to_non_nullable
                      as int,
            firstMonthEMIInCents: null == firstMonthEMIInCents
                ? _value.firstMonthEMIInCents
                : firstMonthEMIInCents // ignore: cast_nullable_to_non_nullable
                      as int,
            winnerDiscountPerMonthInCents: null == winnerDiscountPerMonthInCents
                ? _value.winnerDiscountPerMonthInCents
                : winnerDiscountPerMonthInCents // ignore: cast_nullable_to_non_nullable
                      as int,
            discountStartMonth: freezed == discountStartMonth
                ? _value.discountStartMonth
                : discountStartMonth // ignore: cast_nullable_to_non_nullable
                      as String?,
            entries: null == entries
                ? _value.entries
                : entries // ignore: cast_nullable_to_non_nullable
                      as List<EMIEntry>,
            generatedAt: null == generatedAt
                ? _value.generatedAt
                : generatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EMIScheduleImplCopyWith<$Res>
    implements $EMIScheduleCopyWith<$Res> {
  factory _$$EMIScheduleImplCopyWith(
    _$EMIScheduleImpl value,
    $Res Function(_$EMIScheduleImpl) then,
  ) = __$$EMIScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String slotId,
    String chittyId,
    int duration,
    int totalAmountInCents,
    int baseEMIInCents,
    int firstMonthEMIInCents,
    int winnerDiscountPerMonthInCents,
    String? discountStartMonth,
    List<EMIEntry> entries,
    DateTime generatedAt,
  });
}

/// @nodoc
class __$$EMIScheduleImplCopyWithImpl<$Res>
    extends _$EMIScheduleCopyWithImpl<$Res, _$EMIScheduleImpl>
    implements _$$EMIScheduleImplCopyWith<$Res> {
  __$$EMIScheduleImplCopyWithImpl(
    _$EMIScheduleImpl _value,
    $Res Function(_$EMIScheduleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EMISchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slotId = null,
    Object? chittyId = null,
    Object? duration = null,
    Object? totalAmountInCents = null,
    Object? baseEMIInCents = null,
    Object? firstMonthEMIInCents = null,
    Object? winnerDiscountPerMonthInCents = null,
    Object? discountStartMonth = freezed,
    Object? entries = null,
    Object? generatedAt = null,
  }) {
    return _then(
      _$EMIScheduleImpl(
        slotId: null == slotId
            ? _value.slotId
            : slotId // ignore: cast_nullable_to_non_nullable
                  as String,
        chittyId: null == chittyId
            ? _value.chittyId
            : chittyId // ignore: cast_nullable_to_non_nullable
                  as String,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int,
        totalAmountInCents: null == totalAmountInCents
            ? _value.totalAmountInCents
            : totalAmountInCents // ignore: cast_nullable_to_non_nullable
                  as int,
        baseEMIInCents: null == baseEMIInCents
            ? _value.baseEMIInCents
            : baseEMIInCents // ignore: cast_nullable_to_non_nullable
                  as int,
        firstMonthEMIInCents: null == firstMonthEMIInCents
            ? _value.firstMonthEMIInCents
            : firstMonthEMIInCents // ignore: cast_nullable_to_non_nullable
                  as int,
        winnerDiscountPerMonthInCents: null == winnerDiscountPerMonthInCents
            ? _value.winnerDiscountPerMonthInCents
            : winnerDiscountPerMonthInCents // ignore: cast_nullable_to_non_nullable
                  as int,
        discountStartMonth: freezed == discountStartMonth
            ? _value.discountStartMonth
            : discountStartMonth // ignore: cast_nullable_to_non_nullable
                  as String?,
        entries: null == entries
            ? _value._entries
            : entries // ignore: cast_nullable_to_non_nullable
                  as List<EMIEntry>,
        generatedAt: null == generatedAt
            ? _value.generatedAt
            : generatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EMIScheduleImpl extends _EMISchedule {
  const _$EMIScheduleImpl({
    required this.slotId,
    required this.chittyId,
    required this.duration,
    required this.totalAmountInCents,
    required this.baseEMIInCents,
    required this.firstMonthEMIInCents,
    this.winnerDiscountPerMonthInCents = 0,
    this.discountStartMonth,
    required final List<EMIEntry> entries,
    required this.generatedAt,
  }) : _entries = entries,
       super._();

  factory _$EMIScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$EMIScheduleImplFromJson(json);

  /// Slot ID this schedule belongs to
  @override
  final String slotId;

  /// Chitti ID
  @override
  final String chittyId;

  /// Total duration in months
  @override
  final int duration;

  /// Total amount in cents
  @override
  final int totalAmountInCents;

  /// Base EMI in cents (before first month adjustment)
  @override
  final int baseEMIInCents;

  /// First month EMI in cents (includes rounding remainder)
  @override
  final int firstMonthEMIInCents;

  /// Monthly discount for winners in cents
  @override
  @JsonKey()
  final int winnerDiscountPerMonthInCents;

  /// Month from which discount starts (null if not a winner)
  @override
  final String? discountStartMonth;

  /// All EMI entries
  final List<EMIEntry> _entries;

  /// All EMI entries
  @override
  List<EMIEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  /// When schedule was generated
  @override
  final DateTime generatedAt;

  @override
  String toString() {
    return 'EMISchedule(slotId: $slotId, chittyId: $chittyId, duration: $duration, totalAmountInCents: $totalAmountInCents, baseEMIInCents: $baseEMIInCents, firstMonthEMIInCents: $firstMonthEMIInCents, winnerDiscountPerMonthInCents: $winnerDiscountPerMonthInCents, discountStartMonth: $discountStartMonth, entries: $entries, generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EMIScheduleImpl &&
            (identical(other.slotId, slotId) || other.slotId == slotId) &&
            (identical(other.chittyId, chittyId) ||
                other.chittyId == chittyId) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.totalAmountInCents, totalAmountInCents) ||
                other.totalAmountInCents == totalAmountInCents) &&
            (identical(other.baseEMIInCents, baseEMIInCents) ||
                other.baseEMIInCents == baseEMIInCents) &&
            (identical(other.firstMonthEMIInCents, firstMonthEMIInCents) ||
                other.firstMonthEMIInCents == firstMonthEMIInCents) &&
            (identical(
                  other.winnerDiscountPerMonthInCents,
                  winnerDiscountPerMonthInCents,
                ) ||
                other.winnerDiscountPerMonthInCents ==
                    winnerDiscountPerMonthInCents) &&
            (identical(other.discountStartMonth, discountStartMonth) ||
                other.discountStartMonth == discountStartMonth) &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    slotId,
    chittyId,
    duration,
    totalAmountInCents,
    baseEMIInCents,
    firstMonthEMIInCents,
    winnerDiscountPerMonthInCents,
    discountStartMonth,
    const DeepCollectionEquality().hash(_entries),
    generatedAt,
  );

  /// Create a copy of EMISchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EMIScheduleImplCopyWith<_$EMIScheduleImpl> get copyWith =>
      __$$EMIScheduleImplCopyWithImpl<_$EMIScheduleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EMIScheduleImplToJson(this);
  }
}

abstract class _EMISchedule extends EMISchedule {
  const factory _EMISchedule({
    required final String slotId,
    required final String chittyId,
    required final int duration,
    required final int totalAmountInCents,
    required final int baseEMIInCents,
    required final int firstMonthEMIInCents,
    final int winnerDiscountPerMonthInCents,
    final String? discountStartMonth,
    required final List<EMIEntry> entries,
    required final DateTime generatedAt,
  }) = _$EMIScheduleImpl;
  const _EMISchedule._() : super._();

  factory _EMISchedule.fromJson(Map<String, dynamic> json) =
      _$EMIScheduleImpl.fromJson;

  /// Slot ID this schedule belongs to
  @override
  String get slotId;

  /// Chitti ID
  @override
  String get chittyId;

  /// Total duration in months
  @override
  int get duration;

  /// Total amount in cents
  @override
  int get totalAmountInCents;

  /// Base EMI in cents (before first month adjustment)
  @override
  int get baseEMIInCents;

  /// First month EMI in cents (includes rounding remainder)
  @override
  int get firstMonthEMIInCents;

  /// Monthly discount for winners in cents
  @override
  int get winnerDiscountPerMonthInCents;

  /// Month from which discount starts (null if not a winner)
  @override
  String? get discountStartMonth;

  /// All EMI entries
  @override
  List<EMIEntry> get entries;

  /// When schedule was generated
  @override
  DateTime get generatedAt;

  /// Create a copy of EMISchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EMIScheduleImplCopyWith<_$EMIScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
