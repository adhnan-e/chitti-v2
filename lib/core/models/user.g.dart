// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String?,
  address: json['address'] as String?,
  username: json['username'] as String?,
  photoUrl: json['photoUrl'] as String?,
  needsAppAccess: json['needsAppAccess'] as bool? ?? false,
  documents: (json['documents'] as List<dynamic>?)
      ?.map((e) => UserDocument.fromJson(e as Map<String, dynamic>))
      .toList(),
  isDeleted: json['isDeleted'] as bool? ?? false,
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'address': instance.address,
      'username': instance.username,
      'photoUrl': instance.photoUrl,
      'needsAppAccess': instance.needsAppAccess,
      'documents': instance.documents,
      'isDeleted': instance.isDeleted,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$UserDocumentImpl _$$UserDocumentImplFromJson(Map<String, dynamic> json) =>
    _$UserDocumentImpl(
      name: json['name'] as String,
      url: json['url'] as String,
      type: json['type'] as String?,
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.parse(json['uploadedAt'] as String),
    );

Map<String, dynamic> _$$UserDocumentImplToJson(_$UserDocumentImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'type': instance.type,
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
    };
