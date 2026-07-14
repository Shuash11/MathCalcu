import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;
  bool get isLight => !_isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  // Dark mode token getters
  Color get surface => _isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF4F4F1);
  Color get card => _isDark ? const Color(0xFF232340) : const Color(0xFFFFFFFF);
  Color get cardSecondary => _isDark ? const Color(0xFF2A2A4A) : const Color(0xFFE8E6E2);
  Color get textPrimary => _isDark ? const Color(0xFFF4F4F1) : const Color(0xFF0C0C09);
  Color get textSecondary => _isDark
      ? const Color(0xFFF4F4F1).withValues(alpha: 0.6)
      : const Color(0xFF0C0C09).withValues(alpha: 0.6);
  Color get shadowColor => _isDark
      ? Colors.black.withValues(alpha: 0.2)
      : Colors.black.withValues(alpha: 0.08);
  Color get accentColor => _isDark ? const Color(0xFF6366F1) : const Color(0xFF312C85);

  // Persistence
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('dark_mode') ?? false;
    notifyListeners();
  }

  Future<void> saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDark);
  }
}
