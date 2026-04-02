import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme provider for managing dark/light mode switching
/// Persists theme preference to SharedPreferences
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isInitialized => _isInitialized;

  ThemeProvider() {
    _loadThemeMode();
  }

  /// Load saved theme preference from SharedPreferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themeKey);

      // Only update if we have a saved preference
      if (savedMode != null) {
        _themeMode = savedMode == 'light' ? ThemeMode.light : ThemeMode.dark;
      }
      // Otherwise keep the default (light)
    } catch (e) {
      // Keep default on error
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// Toggle between dark and light mode
  Future<void> toggleTheme() async {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await _saveThemeMode();
    notifyListeners();
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    print('Setting theme mode to: $mode'); // Debug
    _themeMode = mode;
    await _saveThemeMode();
    notifyListeners();
  }

  /// Persist theme preference to SharedPreferences
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final valueToSave = _themeMode == ThemeMode.dark ? 'dark' : 'light';
      await prefs.setString(_themeKey, valueToSave);
      print('Theme saved: $valueToSave'); // Debug log
    } catch (e) {
      print('Failed to save theme preference: $e'); // Debug log
    }
  }
}
