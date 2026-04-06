import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:chitt/core/domain/repositories/i_auth_repository.dart';

class FirebaseAuthDatasource implements IAuthRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? _currentUser;

  @override
  Map<String, dynamic>? get currentUser => _currentUser;

  @override
  Future<String?> checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final role = prefs.getString('role');
      final userDataString = prefs.getString('userData');

      if (userId != null && role != null && userDataString != null) {
        if (FirebaseAuth.instance.currentUser == null) {
          await FirebaseAuth.instance.signInAnonymously();
        }
        _currentUser = jsonDecode(userDataString);
        return role;
      }
    } catch (e) {
      print('Session check failed: $e');
    }
    return null;
  }

  @override
  Future<String?> login(String username, String password) async {
    try {
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
          await FirebaseAuth.instance.signInAnonymously();
        }
        _currentUser = adminData;
        await _saveSession(adminData);
        return 'organiser';
      }

      final snapshot = await _db
          .child('users')
          .orderByChild('username')
          .equalTo(username)
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final usersMap = Map<String, dynamic>.from(snapshot.value as Map);
        final userId = usersMap.keys.first;
        final userData = Map<String, dynamic>.from(usersMap[userId]);

        if (userData['password'] == password) {
          if (FirebaseAuth.instance.currentUser == null) {
            await FirebaseAuth.instance.signInAnonymously();
          }
          final sessionData = {'id': userId, ...userData};
          _currentUser = sessionData;
          await _saveSession(sessionData);
          return userData['role'] as String?;
        }
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _saveSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userData['id']);
    await prefs.setString('role', userData['role']);
    await prefs.setString('userData', jsonEncode(userData));
  }
}
