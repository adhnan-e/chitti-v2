import 'package:firebase_database/firebase_database.dart';

/// User Service - Handles user CRUD operations
class UserService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Singleton
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  /// Create a new user
  Future<String> createUser({
    required String name,
    required String phone,
    String? email,
    String? address,
    String? username,
    String? password,
    bool needsAppAccess = false,
  }) async {
    final newUserRef = _db.child('users').push();

    final userData = <String, dynamic>{
      'firstName': name,
      'lastname': '',
      'phone': phone,
      'email': email ?? '',
      'address': address ?? '',
      'role': 'user',
      'createdAt': ServerValue.timestamp,
      'hasAppAccess': needsAppAccess,
    };

    if (needsAppAccess && username != null && password != null) {
      // Check username uniqueness
      final existing = await searchUsers(username);
      if (existing.any((u) => u['username'] == username)) {
        throw Exception('Username already taken');
      }
      userData['username'] = username;
      userData['password'] = password;
      userData['hasAppAccess'] = true;
    }

    await newUserRef.set(userData);
    return newUserRef.key!;
  }

  /// Update existing user
  Future<void> updateUser({
    required String userId,
    required String name,
    required String phone,
    String? email,
    String? address,
    bool needsAppAccess = false,
    String? username,
    String? password,
  }) async {
    final updates = <String, dynamic>{
      'firstName': name,
      'phone': phone,
      'email': email ?? '',
      'address': address ?? '',
    };

    if (needsAppAccess && username != null && password != null) {
      updates['username'] = username;
      updates['password'] = password;
      updates['hasAppAccess'] = true;
    } else {
      updates['hasAppAccess'] = false;
      updates['username'] = null;
      updates['password'] = null;
    }

    try {
      await _db.child('users/$userId').update(updates);
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  /// Get user profile by ID
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final snapshot = await _db.child('users/$userId').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data['id'] = userId;
        return data;
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.child('users/$userId').update(data);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final snapshot = await _db.child('users').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data.entries.map((e) {
          final map = Map<String, dynamic>.from(e.value as Map);
          map['id'] = e.key;
          return map;
        }).toList();
      }
    } catch (e) {
      print('Error getting users: $e');
    }
    return [];
  }

  /// Search users by username
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    try {
      final snapshot = await _db
          .child('users')
          .orderByChild('username')
          .startAt(query)
          .endAt('$query\uf8ff')
          .limitToFirst(20)
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data.entries.map((e) {
          final map = Map<String, dynamic>.from(e.value as Map);
          map['id'] = e.key;
          return map;
        }).toList();
      }
    } catch (e) {
      print('Error searching users: $e');
    }
    return [];
  }
}
