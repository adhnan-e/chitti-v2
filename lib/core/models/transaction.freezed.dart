// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return _Transaction.fromJson(json);
}

/// @nodoc
mixin _$Transaction {
  /// Unique transaction identifier
  String get id => throw _privateConstructorUsedError;

  /// Slot this transaction belongs to
  String get slotId => throw _privateConstructorUsedError;

  /// Parent chitty ID
  String get chittiId => throw _privateConstructorUsedError;

  /// Transaction type determines how it affects balance
  TransactionType get type => throw _privateConstructorUsedError;

  /// Amount in cents (smallest currency unit)
  /// Always positive - type determines credit/debit
  int get amountInCents => throw _privateConstructorUsedError;

  /// Balance in cents before this transaction
  int get balanceBeforeInCents => throw _privateConstructorUsedError;

  /// Balance in cents after this transaction
  int get balanceAfterInCents => throw _privateConstructorUsedError;

  /// Month this transaction applies to (YYYY-MM format)
  String get monthKey => throw _privateConstructorUsedError;

  /// Verification status for dual-state tracking
  TransactionStatus get status => throw _privateConstructorUsedError;

  /// Payment method used
  PaymentMethod get paymentMethod => throw _privateConstructorUsedError;

  /// For reversals: links to the original transaction being reversed
  String? get linkedTransactionId => throw _privateConstructorUsedError;

  /// External reference (bank txn ID, cheque number, etc.)
  String? get referenceNumber => throw _privateConstructorUsedError;

  /// Optional notes for audit trail
  String? get notes => throw _privateConstructorUsedError;

  /// Unique receipt number for this transaction
  String? get receiptNumber => throw _privateConstructorUsedError;

  /// When transaction was created
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// When organizer verified the payment
  DateTime? get verifiedAt => throw _privateConstructorUsedError;

  /// Who verified (organizer ID)
  String? get verifiedBy => throw _privateConstructorUsedError;

  /// User ID for reference (denormalized for queries)
  String? get userId => throw _privateConstructorUsedError;

  /// User name for display (denormalized)
  String? get userName => throw _privateConstructorUsedError;

  /// Slot number for display (denormalized)
  int? get slotNumber => throw _privateConstructorUsedError;

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
    Transaction value,
    $Res Function(Transaction) then,
  ) = _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call({
    String id,
    String slotId,
    String chittiId,
    TransactionType type,
    int amountInCents,
    int balanceBeforeInCents,
    int balanceAfterInCents,
    String monthKey,
    TransactionStatus status,
    PaymentMethod paymentMethod,
    String? linkedTransactionId,
    String? referenceNumber,
    String? notes,
    String? receiptNumber,
    DateTime createdAt,
    DateTime? verifiedAt,
    String? verifiedBy,
    String? userId,
    String? userName,
    int? slotNumber,
  });
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? slotId = null,
    Object? chittiId = null,
    Object? type = null,
    Object? amountInCents = null,
    Object? balanceBeforeInCents = null,
    Object? balanceAfterInCents = null,
    Object? monthKey = null,
    Object? status = null,
    Object? paymentMethod = null,
    Object? linkedTransactionId = freezed,
    Object? referenceNumber = freezed,
    Object? notes = freezed,
    Object? receiptNumber = freezed,
    Object? createdAt = null,
    Object? verifiedAt = freezed,
    Object? verifiedBy = freezed,
    Object? userId = freezed,
    Object? userName = freezed,
    Object? slotNumber = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            slotId: null == slotId
                ? _value.slotId
                : slotId // ignore: cast_nullable_to_non_nullable
                      as String,
            chittiId: null == chittiId
                ? _value.chittiId
                : chittiId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as TransactionType,
            amountInCents: null == amountInCents
                ? _value.amountInCents
                : amountInCents // ignore: cast_nullable_to_non_nullable
                      as int,
            balanceBeforeInCents: null == balanceBeforeInCents
                ? _value.balanceBeforeInCents
                : balanceBeforeInCents // ignore: cast_nullable_to_non_nullable
                      as int,
            balanceAfterInCents: null == balanceAfterInCents
                ? _value.balanceAfterInCents
                : balanceAfterInCents // ignore: cast_nullable_to_non_nullable
                      as int,
            monthKey: null == monthKey
                ? _value.monthKey
                : monthKey // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as TransactionStatus,
            paymentMethod: null == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as PaymentMethod,
            linkedTransactionId: freezed == linkedTransactionId
                ? _value.linkedTransactionId
                : linkedTransactionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            referenceNumber: freezed == referenceNumber
                ? _value.referenceNumber
                : referenceNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            receiptNumber: freezed == receiptNumber
                ? _value.receiptNumber
                : receiptNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            verifiedAt: freezed == verifiedAt
                ? _value.verifiedAt
                : verifiedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            verifiedBy: freezed == verifiedBy
                ? _value.verifiedBy
                : verifiedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            userName: freezed == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String?,
            slotNumber: freezed == slotNumber
                ? _value.slotNumber
                : slotNumber // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
    _$TransactionImpl value,
    $Res Function(_$TransactionImpl) then,
  ) = __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String slotId,
    String chittiId,
    TransactionType type,
    int amountInCents,
    int balanceBeforeInCents,
    int balanceAfterInCents,
    String monthKey,
    TransactionStatus status,
    PaymentMethod paymentMethod,
    String? linkedTransactionId,
    String? referenceNumber,
    String? notes,
    String? receiptNumber,
    DateTime createdAt,
    DateTime? verifiedAt,
    String? verifiedBy,
    String? userId,
    String? userName,
    int? slotNumber,
  });
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
    _$TransactionImpl _value,
    $Res Function(_$TransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? slotId = null,
    Object? chittiId = null,
    Object? type = null,
    Object? amountInCents = null,
    Object? balanceBeforeInCents = null,
    Object? balanceAfterInCents = null,
    Object? monthKey = null,
    Object? status = null,
    Object? paymentMethod = null,
    Object? linkedTransactionId = freezed,
    Object? referenceNumber = freezed,
    Object? notes = freezed,
    Object? receiptNumber = freezed,
    Object? createdAt = null,
    Object? verifiedAt = freezed,
    Object? verifiedBy = freezed,
    Object? userId = freezed,
    Object? userName = freezed,
    Object? slotNumber = freezed,
  }) {
    return _then(
      _$TransactionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        slotId: null == slotId
            ? _value.slotId
            : slotId // ignore: cast_nullable_to_non_nullable
                  as String,
        chittiId: null == chittiId
            ? _value.chittiId
            : chittiId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as TransactionType,
        amountInCents: null == amountInCents
            ? _value.amountInCents
            : amountInCents // ignore: cast_nullable_to_non_nullable
                  as int,
        balanceBeforeInCents: null == balanceBeforeInCents
            ? _value.balanceBeforeInCents
            : balanceBeforeInCents // ignore: cast_nullable_to_non_nullable
                  as int,
        balanceAfterInCents: null == balanceAfterInCents
            ? _value.balanceAfterInCents
            : balanceAfterInCents // ignore: cast_nullable_to_non_nullable
                  as int,
        monthKey: null == monthKey
            ? _value.monthKey
            : monthKey // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as TransactionStatus,
        paymentMethod: null == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as PaymentMethod,
        linkedTransactionId: freezed == linkedTransactionId
            ? _value.linkedTransactionId
            : linkedTransactionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        referenceNumber: freezed == referenceNumber
            ? _value.referenceNumber
            : referenceNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        receiptNumber: freezed == receiptNumber
            ? _value.receiptNumber
            : receiptNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        verifiedAt: freezed == verifiedAt
            ? _value.verifiedAt
            : verifiedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        verifiedBy: freezed == verifiedBy
            ? _value.verifiedBy
            : verifiedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        userName: freezed == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
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
class _$TransactionImpl extends _Transaction {
  const _$TransactionImpl({
    required this.id,
    required this.slotId,
    required this.chittiId,
    required this.type,
    required this.amountInCents,
    required this.balanceBeforeInCents,
    required this.balanceAfterInCents,
    required this.monthKey,
    this.status = TransactionStatus.pending,
    this.paymentMethod = PaymentMethod.cash,
    this.linkedTransactionId,
    this.referenceNumber,
    this.notes,
    this.receiptNumber,
    required this.createdAt,
    this.verifiedAt,
    this.verifiedBy,
    this.userId,
    this.userName,
    this.slotNumber,
  }) : super._();

  factory _$TransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionImplFromJson(json);

  /// Unique transaction identifier
  @override
  final String id;

  /// Slot this transaction belongs to
  @override
  final String slotId;

  /// Parent chitty ID
  @override
  final String chittiId;

  /// Transaction type determines how it affects balance
  @override
  final TransactionType type;

  /// Amount in cents (smallest currency unit)
  /// Always positive - type determines credit/debit
  @override
  final int amountInCents;

  /// Balance in cents before this transaction
  @override
  final int balanceBeforeInCents;

  /// Balance in cents after this transaction
  @override
  final int balanceAfterInCents;

  /// Month this transaction applies to (YYYY-MM format)
  @override
  final String monthKey;

  /// Verification status for dual-state tracking
  @override
  @JsonKey()
  final TransactionStatus status;

  /// Payment method used
  @override
  @JsonKey()
  final PaymentMethod paymentMethod;

  /// For reversals: links to the original transaction being reversed
  @override
  final String? linkedTransactionId;

  /// External reference (bank txn ID, cheque number, etc.)
  @override
  final String? referenceNumber;

  /// Optional notes for audit trail
  @override
  final String? notes;

  /// Unique receipt number for this transaction
  @override
  final String? receiptNumber;

  /// When transaction was created
  @override
  final DateTime createdAt;

  /// When organizer verified the payment
  @override
  final DateTime? verifiedAt;

  /// Who verified (organizer ID)
  @override
  final String? verifiedBy;

  /// User ID for reference (denormalized for queries)
  @override
  final String? userId;

  /// User name for display (denormalized)
  @override
  final String? userName;

  /// Slot number for display (denormalized)
  @override
  final int? slotNumber;

  @override
  String toString() {
    return 'Transaction(id: $id, slotId: $slotId, chittiId: $chittiId, type: $type, amountInCents: $amountInCents, balanceBeforeInCents: $balanceBeforeInCents, balanceAfterInCents: $balanceAfterInCents, monthKey: $monthKey, status: $status, paymentMethod: $paymentMethod, linkedTransactionId: $linkedTransactionId, referenceNumber: $referenceNumber, notes: $notes, receiptNumber: $receiptNumber, createdAt: $createdAt, verifiedAt: $verifiedAt, verifiedBy: $verifiedBy, userId: $userId, userName: $userName, slotNumber: $slotNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.slotId, slotId) || other.slotId == slotId) &&
            (identical(other.chittiId, chittiId) ||
                other.chittiId == chittiId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amountInCents, amountInCents) ||
                other.amountInCents == amountInCents) &&
            (identical(other.balanceBeforeInCents, balanceBeforeInCents) ||
                other.balanceBeforeInCents == balanceBeforeInCents) &&
            (identical(other.balanceAfterInCents, balanceAfterInCents) ||
                other.balanceAfterInCents == balanceAfterInCents) &&
            (identical(other.monthKey, monthKey) ||
                other.monthKey == monthKey) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.linkedTransactionId, linkedTransactionId) ||
                other.linkedTransactionId == linkedTransactionId) &&
            (identical(other.referenceNumber, referenceNumber) ||
                other.referenceNumber == referenceNumber) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.receiptNumber, receiptNumber) ||
                other.receiptNumber == receiptNumber) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.verifiedAt, verifiedAt) ||
                other.verifiedAt == verifiedAt) &&
            (identical(other.verifiedBy, verifiedBy) ||
                other.verifiedBy == verifiedBy) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.slotNumber, slotNumber) ||
                other.slotNumber == slotNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    slotId,
    chittiId,
    type,
    amountInCents,
    balanceBeforeInCents,
    balanceAfterInCents,
    monthKey,
    status,
    paymentMethod,
    linkedTransactionId,
    referenceNumber,
    notes,
    receiptNumber,
    createdAt,
    verifiedAt,
    verifiedBy,
    userId,
    userName,
    slotNumber,
  ]);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionImplToJson(this);
  }
}

abstract class _Transaction extends Transaction {
  const factory _Transaction({
    required final String id,
    required final String slotId,
    required final String chittiId,
    required final TransactionType type,
    required final int amountInCents,
    required final int balanceBeforeInCents,
    required final int balanceAfterInCents,
    required final String monthKey,
    final TransactionStatus status,
    final PaymentMethod paymentMethod,
    final String? linkedTransactionId,
    final String? referenceNumber,
    final String? notes,
    final String? receiptNumber,
    required final DateTime createdAt,
    final DateTime? verifiedAt,
    final String? verifiedBy,
    final String? userId,
    final String? userName,
    final int? slotNumber,
  }) = _$TransactionImpl;
  const _Transaction._() : super._();

  factory _Transaction.fromJson(Map<String, dynamic> json) =
      _$TransactionImpl.fromJson;

  /// Unique transaction identifier
  @override
  String get id;

  /// Slot this transaction belongs to
  @override
  String get slotId;

  /// Parent chitty ID
  @override
  String get chittiId;

  /// Transaction type determines how it affects balance
  @override
  TransactionType get type;

  /// Amount in cents (smallest currency unit)
  /// Always positive - type determines credit/debit
  @override
  int get amountInCents;

  /// Balance in cents before this transaction
  @override
  int get balanceBeforeInCents;

  /// Balance in cents after this transaction
  @override
  int get balanceAfterInCents;

  /// Month this transaction applies to (YYYY-MM format)
  @override
  String get monthKey;

  /// Verification status for dual-state tracking
  @override
  TransactionStatus get status;

  /// Payment method used
  @override
  PaymentMethod get paymentMethod;

  /// For reversals: links to the original transaction being reversed
  @override
  String? get linkedTransactionId;

  /// External reference (bank txn ID, cheque number, etc.)
  @override
  String? get referenceNumber;

  /// Optional notes for audit trail
  @override
  String? get notes;

  /// Unique receipt number for this transaction
  @override
  String? get receiptNumber;

  /// When transaction was created
  @override
  DateTime get createdAt;

  /// When organizer verified the payment
  @override
  DateTime? get verifiedAt;

  /// Who verified (organizer ID)
  @override
  String? get verifiedBy;

  /// User ID for reference (denormalized for queries)
  @override
  String? get userId;

  /// User name for display (denormalized)
  @override
  String? get userName;

  /// Slot number for display (denormalized)
  @override
  int? get slotNumber;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
