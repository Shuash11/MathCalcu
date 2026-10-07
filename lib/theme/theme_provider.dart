import 'package:material_ui/material_ui.dart';
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
  Color get surface =>
      _isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF4F4F1);
  Color get card => _isDark ? const Color(0xFF232340) : const Color(0xFFFFFFFF);
  Color get cardSecondary =>
      _isDark ? const Color(0xFF2A2A4A) : const Color(0xFFE8E6E2);
  Color get textPrimary =>
      _isDark ? const Color(0xFFF4F4F1) : const Color(0xFF0C0C09);
  Color get textSecondary => _isDark
      ? const Color(0xFFF4F4F1).withValues(alpha: 0.6)
      : const Color(0xFF0C0C09).withValues(alpha: 0.6);
  Color get shadowColor => _isDark
      ? Colors.black.withValues(alpha: 0.2)
      : Colors.black.withValues(alpha: 0.08);
  Color get accentColor =>
      _isDark ? const Color(0xFFE9ECEF) : const Color(0xFF334155);

  /// Theme-aware ModMat teal for icons and text on [card].
  /// Static teals cannot pass in both modes (0D9488 fails light,
  /// 14B8A6 fails light, 0F766E fails dark) — this flips instead:
  /// dark-teal on light surfaces, light-mint on dark surfaces.
  Color get modmatAccent =>
      _isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0F766E);

  /// Semantic error color with WCAG-AA contrast on [card] in both modes.
  /// Material3 error tokens: dark-red on light surfaces, light-salmon on
  /// dark surfaces — never a single static red for both themes.
  Color get errorColor =>
      _isDark ? const Color(0xFFFFB4AB) : const Color(0xFFB3261E);

  /// Semantic tertiary/success accent with WCAG-AA contrast on [card] in
  /// both modes. Keeps the brand green hue; green-600 failed light mode
  /// (3.30:1 vs light card), green-700 passes.
  Color get tertiaryColor =>
      _isDark ? const Color(0xFF16A34A) : const Color(0xFF15803D);

  /// Color of content shown on [errorColor] (M3 error/onError pairing:
  /// white on dark-red in light mode, dark-red on light-salmon in dark).
  Color get onErrorColor =>
      _isDark ? const Color(0xFF601410) : const Color(0xFFFFFFFF);

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
