import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class AuthService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;

  /// Check for existing session
  Future<String?> checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final role = prefs.getString('role');
      final userDataString = prefs.getString('userData');

      if (userId != null && role != null && userDataString != null) {
        // Ensure Firebase Auth is signed in (anonymously or otherwise)
        if (FirebaseAuth.instance.currentUser == null) {
          try {
            await FirebaseAuth.instance.signInAnonymously();
            print('Signed in to Firebase Auth anonymously (session restore)');
          } catch (e) {
            print('Error signing in anonymously during session restore: $e');
          }
        }

        _currentUser = jsonDecode(userDataString);
        return role;
      }
    } catch (e) {
      print('Session check failed: $e');
    }
    return null;
  }

  /// Login with username and password (RAW - No encryption)
  /// Returns the user role ('organiser' or 'user') if successful, or null if failed.
  Future<String?> login(String username, String password) async {
    try {
      // DEV BACKDOOR
      if (username == 'admin' && password == 'admin') {
        final adminData = {
          'id': 'admin_001',
          'username': 'admin',
          'role': 'organiser',
          'firstName': 'Admin',
          'lastName': 'User',
          'email': 'admin@chitti.com',
          'flags': {'is_verified': true},
        };
        if (FirebaseAuth.instance.currentUser == null) {
          try {
            await FirebaseAuth.instance.signInAnonymously();
          } catch (e) {
            print('Auth Error: $e');
          }
        }
        _currentUser = adminData;
        await _saveSession(adminData);
        return 'organiser';
      }
      if (username == 'user' && password == 'user') {
        final userData = {
          'id': 'user_001',
          'username': 'user',
          'role': 'user',
          'firstName': 'Demo',
          'lastName': 'User',
          'email': 'user@chitti.com',
          'flags': {'is_verified': true},
        };
        if (FirebaseAuth.instance.currentUser == null) {
          try {
            await FirebaseAuth.instance.signInAnonymously();
          } catch (e) {
            print('Auth Error: $e');
          }
        }
        _currentUser = userData;
        await _saveSession(userData);
        return 'user';
      }

      // implementing simple query: fetch all users and filter locally for MVP simplicity
      // In production, use query ordered by child 'username'
      final snapshot = await _db
          .child('users')
          .orderByChild('username')
          .equalTo(username)
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final usersMap = Map<String, dynamic>.from(snapshot.value as Map);
        // Since username should be unique, we take the first match
        final userId = usersMap.keys.first;
        final userData = Map<String, dynamic>.from(usersMap[userId]);

        if (userData['password'] == password) {
          // Sign in to Firebase Auth for storage/rules access
          if (FirebaseAuth.instance.currentUser == null) {
            try {
              await FirebaseAuth.instance.signInAnonymously();
            } catch (e) {
              print('Auth Error (Realtime Login): $e');
            }
          }
          final sessionData = {'id': userId, ...userData};
          _currentUser = sessionData;
          await _saveSession(sessionData); // Save to prefs
          return userData['role'] as String?;
        }
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<void> _saveSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userData['id']);
    await prefs.setString('role', userData['role']);
    await prefs.setString('userData', jsonEncode(userData));
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
  }
}
