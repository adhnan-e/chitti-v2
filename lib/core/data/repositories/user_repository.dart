/// Repository interface for User data operations
library;

import 'package:chitt/core/models/models.dart';
import 'package:chitt/core/models/user.dart';

/// Repository interface for User operations
abstract class UserRepository {
  /// Create a new user
  ///
  /// Returns the ID of the created user
  Future<String> createUser(User user);

  /// Get a user by ID
  ///
  /// Returns null if not found
  Future<User?> getUser(String id);

  /// Get user by username
  ///
  /// Returns null if not found
  Future<User?> getUserByUsername(String username);

  /// Get user by phone number
  ///
  /// Returns null if not found
  Future<User?> getUserByPhone(String phone);

  /// Get all users
  ///
  /// Optional filter for role
  Future<List<User>> getAllUsers({String? role});

  /// Search users by username
  ///
  /// Returns up to [limit] users matching the query
  Future<List<User>> searchUsers(String query, {int limit = 20});

  /// Update a user
  ///
  /// Performs partial update with provided fields
  Future<void> updateUser(String id, Map<String, dynamic> data);

  /// Delete a user (soft delete - marks as deleted)
  Future<void> deleteUser(String id);

  /// Authenticate user with username and password
  ///
  /// Returns user role if successful, null otherwise
  Future<String?> authenticate(String username, String password);

  /// Check if username is available
  Future<bool> isUsernameAvailable(String username);

  /// Stream user updates
  Stream<User?> watchUser(String id);
}
