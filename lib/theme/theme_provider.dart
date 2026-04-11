import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'is_light_mode';
  bool _isLight = false;
  bool get isLight => _isLight;

  SharedPreferences? _prefs;

  ThemeProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _isLight = _prefs?.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  /// Optional: Use this in main.dart to ensure theme is loaded before runApp
  Future<void> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    _isLight = _prefs?.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggle() async {
    _isLight = !_isLight;
    notifyListeners();

    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setBool(_themeKey, _isLight);
  }

  // Quick utility colors that listen to the theme state
  Color get surface =>
      _isLight ? const Color(0xFFF7F7FA) : const Color(0xFF0A0A0F);
  Color get card =>
      _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF12121A);
  Color get cardSecondary =>
      _isLight ? const Color(0xFFF0F0F5) : const Color(0xFF0D0D14);
  Color get textPrimary =>
      _isLight ? const Color(0xFF1E1E28) : const Color(0xFFE8E8F0);
  Color get textSecondary => _isLight
      ? const Color(0xFF1E1E28).withValues(alpha: 0.6)
      : const Color(0xFFE8E8F0).withValues(alpha: 0.4);

  Color get shadowColor => _isLight
      ? Colors.black.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.4);

  Color get accentColor => const Color(0xFF6C63FF);
}
