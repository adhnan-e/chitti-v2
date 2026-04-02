// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  /// Unique user identifier
  String get id => throw _privateConstructorUsedError;

  /// Display name
  String get name => throw _privateConstructorUsedError;

  /// Phone number (unique)
  String get phone => throw _privateConstructorUsedError;

  /// Email address
  String? get email => throw _privateConstructorUsedError;

  /// Physical address
  String? get address => throw _privateConstructorUsedError;

  /// Username for app login
  String? get username => throw _privateConstructorUsedError;

  /// Profile photo URL
  String? get photoUrl => throw _privateConstructorUsedError;

  /// Whether user has app access
  bool get needsAppAccess => throw _privateConstructorUsedError;

  /// Attached documents
  List<UserDocument>? get documents => throw _privateConstructorUsedError;

  /// Whether user is soft-deleted
  bool get isDeleted => throw _privateConstructorUsedError;

  /// When user was deleted
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// When user was created
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Last updated timestamp
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    String id,
    String name,
    String phone,
    String? email,
    String? address,
    String? username,
    String? photoUrl,
    bool needsAppAccess,
    List<UserDocument>? documents,
    bool isDeleted,
    DateTime? deletedAt,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = null,
    Object? email = freezed,
    Object? address = freezed,
    Object? username = freezed,
    Object? photoUrl = freezed,
    Object? needsAppAccess = null,
    Object? documents = freezed,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
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
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            username: freezed == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            needsAppAccess: null == needsAppAccess
                ? _value.needsAppAccess
                : needsAppAccess // ignore: cast_nullable_to_non_nullable
                      as bool,
            documents: freezed == documents
                ? _value.documents
                : documents // ignore: cast_nullable_to_non_nullable
                      as List<UserDocument>?,
            isDeleted: null == isDeleted
                ? _value.isDeleted
                : isDeleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
    _$UserImpl value,
    $Res Function(_$UserImpl) then,
  ) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String phone,
    String? email,
    String? address,
    String? username,
    String? photoUrl,
    bool needsAppAccess,
    List<UserDocument>? documents,
    bool isDeleted,
    DateTime? deletedAt,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = null,
    Object? email = freezed,
    Object? address = freezed,
    Object? username = freezed,
    Object? photoUrl = freezed,
    Object? needsAppAccess = null,
    Object? documents = freezed,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$UserImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        username: freezed == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        needsAppAccess: null == needsAppAccess
            ? _value.needsAppAccess
            : needsAppAccess // ignore: cast_nullable_to_non_nullable
                  as bool,
        documents: freezed == documents
            ? _value._documents
            : documents // ignore: cast_nullable_to_non_nullable
                  as List<UserDocument>?,
        isDeleted: null == isDeleted
            ? _value.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl extends _User {
  const _$UserImpl({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.username,
    this.photoUrl,
    this.needsAppAccess = false,
    final List<UserDocument>? documents,
    this.isDeleted = false,
    this.deletedAt,
    required this.createdAt,
    this.updatedAt,
  }) : _documents = documents,
       super._();

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  /// Unique user identifier
  @override
  final String id;

  /// Display name
  @override
  final String name;

  /// Phone number (unique)
  @override
  final String phone;

  /// Email address
  @override
  final String? email;

  /// Physical address
  @override
  final String? address;

  /// Username for app login
  @override
  final String? username;

  /// Profile photo URL
  @override
  final String? photoUrl;

  /// Whether user has app access
  @override
  @JsonKey()
  final bool needsAppAccess;

  /// Attached documents
  final List<UserDocument>? _documents;

  /// Attached documents
  @override
  List<UserDocument>? get documents {
    final value = _documents;
    if (value == null) return null;
    if (_documents is EqualUnmodifiableListView) return _documents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Whether user is soft-deleted
  @override
  @JsonKey()
  final bool isDeleted;

  /// When user was deleted
  @override
  final DateTime? deletedAt;

  /// When user was created
  @override
  final DateTime createdAt;

  /// Last updated timestamp
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'User(id: $id, name: $name, phone: $phone, email: $email, address: $address, username: $username, photoUrl: $photoUrl, needsAppAccess: $needsAppAccess, documents: $documents, isDeleted: $isDeleted, deletedAt: $deletedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.needsAppAccess, needsAppAccess) ||
                other.needsAppAccess == needsAppAccess) &&
            const DeepCollectionEquality().equals(
              other._documents,
              _documents,
            ) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    phone,
    email,
    address,
    username,
    photoUrl,
    needsAppAccess,
    const DeepCollectionEquality().hash(_documents),
    isDeleted,
    deletedAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(this);
  }
}

abstract class _User extends User {
  const factory _User({
    required final String id,
    required final String name,
    required final String phone,
    final String? email,
    final String? address,
    final String? username,
    final String? photoUrl,
    final bool needsAppAccess,
    final List<UserDocument>? documents,
    final bool isDeleted,
    final DateTime? deletedAt,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$UserImpl;
  const _User._() : super._();

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  /// Unique user identifier
  @override
  String get id;

  /// Display name
  @override
  String get name;

  /// Phone number (unique)
  @override
  String get phone;

  /// Email address
  @override
  String? get email;

  /// Physical address
  @override
  String? get address;

  /// Username for app login
  @override
  String? get username;

  /// Profile photo URL
  @override
  String? get photoUrl;

  /// Whether user has app access
  @override
  bool get needsAppAccess;

  /// Attached documents
  @override
  List<UserDocument>? get documents;

  /// Whether user is soft-deleted
  @override
  bool get isDeleted;

  /// When user was deleted
  @override
  DateTime? get deletedAt;

  /// When user was created
  @override
  DateTime get createdAt;

  /// Last updated timestamp
  @override
  DateTime? get updatedAt;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserDocument _$UserDocumentFromJson(Map<String, dynamic> json) {
  return _UserDocument.fromJson(json);
}

/// @nodoc
mixin _$UserDocument {
  String get name => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  DateTime? get uploadedAt => throw _privateConstructorUsedError;

  /// Serializes this UserDocument to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserDocumentCopyWith<UserDocument> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDocumentCopyWith<$Res> {
  factory $UserDocumentCopyWith(
    UserDocument value,
    $Res Function(UserDocument) then,
  ) = _$UserDocumentCopyWithImpl<$Res, UserDocument>;
  @useResult
  $Res call({String name, String url, String? type, DateTime? uploadedAt});
}

/// @nodoc
class _$UserDocumentCopyWithImpl<$Res, $Val extends UserDocument>
    implements $UserDocumentCopyWith<$Res> {
  _$UserDocumentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? url = null,
    Object? type = freezed,
    Object? uploadedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
            uploadedAt: freezed == uploadedAt
                ? _value.uploadedAt
                : uploadedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserDocumentImplCopyWith<$Res>
    implements $UserDocumentCopyWith<$Res> {
  factory _$$UserDocumentImplCopyWith(
    _$UserDocumentImpl value,
    $Res Function(_$UserDocumentImpl) then,
  ) = __$$UserDocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String url, String? type, DateTime? uploadedAt});
}

/// @nodoc
class __$$UserDocumentImplCopyWithImpl<$Res>
    extends _$UserDocumentCopyWithImpl<$Res, _$UserDocumentImpl>
    implements _$$UserDocumentImplCopyWith<$Res> {
  __$$UserDocumentImplCopyWithImpl(
    _$UserDocumentImpl _value,
    $Res Function(_$UserDocumentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? url = null,
    Object? type = freezed,
    Object? uploadedAt = freezed,
  }) {
    return _then(
      _$UserDocumentImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        uploadedAt: freezed == uploadedAt
            ? _value.uploadedAt
            : uploadedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserDocumentImpl implements _UserDocument {
  const _$UserDocumentImpl({
    required this.name,
    required this.url,
    this.type,
    this.uploadedAt,
  });

  factory _$UserDocumentImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDocumentImplFromJson(json);

  @override
  final String name;
  @override
  final String url;
  @override
  final String? type;
  @override
  final DateTime? uploadedAt;

  @override
  String toString() {
    return 'UserDocument(name: $name, url: $url, type: $type, uploadedAt: $uploadedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDocumentImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, url, type, uploadedAt);

  /// Create a copy of UserDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDocumentImplCopyWith<_$UserDocumentImpl> get copyWith =>
      __$$UserDocumentImplCopyWithImpl<_$UserDocumentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserDocumentImplToJson(this);
  }
}

abstract class _UserDocument implements UserDocument {
  const factory _UserDocument({
    required final String name,
    required final String url,
    final String? type,
    final DateTime? uploadedAt,
  }) = _$UserDocumentImpl;

  factory _UserDocument.fromJson(Map<String, dynamic> json) =
      _$UserDocumentImpl.fromJson;

  @override
  String get name;
  @override
  String get url;
  @override
  String? get type;
  @override
  DateTime? get uploadedAt;

  /// Create a copy of UserDocument
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDocumentImplCopyWith<_$UserDocumentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
