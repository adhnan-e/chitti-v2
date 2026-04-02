/// User Model - Member/Participant
///
/// Represents a user who can participate in multiple chitties
/// through multiple slots.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Immutable user model.
@freezed
class User with _$User {
  const User._();

  const factory User({
    /// Unique user identifier
    required String id,

    /// Display name
    required String name,

    /// Phone number (unique)
    required String phone,

    /// Email address
    String? email,

    /// Physical address
    String? address,

    /// Username for app login
    String? username,

    /// Profile photo URL
    String? photoUrl,

    /// Whether user has app access
    @Default(false) bool needsAppAccess,

    /// Attached documents
    List<UserDocument>? documents,

    /// Whether user is soft-deleted
    @Default(false) bool isDeleted,

    /// When user was deleted
    DateTime? deletedAt,

    /// When user was created
    required DateTime createdAt,

    /// Last updated timestamp
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Create from Firebase map with type conversions
  factory User.fromFirebase(String id, Map<String, dynamic> data) {
    // Parse documents
    List<UserDocument>? documents;
    if (data['documents'] != null) {
      final docsList = data['documents'] as List;
      documents = docsList
          .map(
            (d) => UserDocument(
              name: (d as Map)['name'] as String? ?? '',
              url: d['url'] as String? ?? '',
              type: d['type'] as String?,
              uploadedAt: d['uploadedAt'] != null
                  ? DateTime.tryParse(d['uploadedAt'] as String)
                  : null,
            ),
          )
          .toList();
    }

    // Handle name from firstName/lastname or name field
    String name = data['name'] as String? ?? '';
    if (name.isEmpty) {
      final first = data['firstName'] as String? ?? '';
      final last = data['lastname'] as String? ?? '';
      name = '$first $last'.trim();
    }

    return User(
      id: id,
      name: name,
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String?,
      address: data['address'] as String?,
      username: data['username'] as String?,
      photoUrl: data['photoUrl'] as String?,
      needsAppAccess: data['needsAppAccess'] as bool? ?? false,
      documents: documents,
      isDeleted: data['isDeleted'] as bool? ?? false,
      deletedAt: data['deletedAt'] != null
          ? _parseDateTime(data['deletedAt'])
          : null,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: data['updatedAt'] != null
          ? _parseDateTime(data['updatedAt'])
          : null,
    );
  }

  /// Convert to Firebase-compatible map
  Map<String, dynamic> toFirebase() {
    // Split name back to firstName/lastname if possible for consistency with existing data
    final parts = name.split(' ');
    final firstName = parts.first;
    final lastname = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return {
      'name': name,
      'firstName': firstName,
      'lastname': lastname,
      'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (username != null) 'username': username,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'needsAppAccess': needsAppAccess,
      if (documents != null)
        'documents': documents!
            .map(
              (d) => {
                'name': d.name,
                'url': d.url,
                if (d.type != null) 'type': d.type,
                if (d.uploadedAt != null)
                  'uploadedAt': d.uploadedAt!.toIso8601String(),
              },
            )
            .toList(),
      'isDeleted': isDeleted,
      if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Display name with phone fallback
  String get displayName => name.isNotEmpty ? name : phone;

  /// Initials for avatar
  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

/// Document attached to user
@freezed
class UserDocument with _$UserDocument {
  const factory UserDocument({
    required String name,
    required String url,
    String? type,
    DateTime? uploadedAt,
  }) = _UserDocument;

  factory UserDocument.fromJson(Map<String, dynamic> json) =>
      _$UserDocumentFromJson(json);
}

/// Helper to parse DateTime from various formats
DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return DateTime.now();
}
