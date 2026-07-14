import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Minimal is light-only — always true
  bool get isLight => true;

  // Minimal design system tokens
  Color get surface => const Color(0xFFF4F4F1);
  Color get card => const Color(0xFFFFFFFF);
  Color get cardSecondary => const Color(0xFFE8E6E2);
  Color get textPrimary => const Color(0xFF0C0C09);
  Color get textSecondary => const Color(0xFF0C0C09).withValues(alpha: 0.6);
  Color get shadowColor => Colors.black.withValues(alpha: 0.08);
  Color get accentColor => const Color(0xFF312C85);
}
