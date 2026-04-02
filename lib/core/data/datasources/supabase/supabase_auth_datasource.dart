import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:chitt/core/domain/repositories/i_auth_repository.dart';

class SupabaseAuthDatasource implements IAuthRepository {
  final SupabaseClient _client = Supabase.instance.client;
  Map<String, dynamic>? _currentUser;

  @override
  Map<String, dynamic>? get currentUser => _currentUser;

  @override
  Future<String?> checkSession() async {
    try {
      final session = _client.auth.currentSession;
      if (session != null) {
        final prefs = await SharedPreferences.getInstance();
        final userDataString = prefs.getString('userData');
        if (userDataString != null) {
          _currentUser = jsonDecode(userDataString);
          return _currentUser?['role'];
        }
      }
    } catch (e) {
      print('Supabase session check failed: $e');
    }
    return null;
  }

  @override
  Future<String?> login(String username, String password) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      if (response != null) {
        _currentUser = Map<String, dynamic>.from(response);
        await _saveSession(_currentUser!);
        return _currentUser?['role'];
      }
      return null;
    } catch (e) {
      print('Supabase login error: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _client.auth.signOut();
  }

  Future<void> _saveSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(userData));
  }
}
