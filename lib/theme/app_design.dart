import 'package:flutter/material.dart';

class AppDesign {
  final Color accent;
  final Color accentLight;
  final Gradient headerGradient;
  final Gradient cardGradient;
  final Gradient cardGradientHover;

  const AppDesign({
    required this.accent,
    required this.accentLight,
    required this.headerGradient,
    required this.cardGradient,
    required this.cardGradientHover,
  });

  // Shared constants
  static const double cardRadius = 20;
  static const double borderWidth = 1.5;
  static const double shadowBlur = 12;
  static const double iconCircleSize = 52;
  static const double stepCircleSize = 28;

  // Glassmorphism constants
  static const double glassBorderRadius = 20.0;
  static const double glassBorderOpacity = 0.15;
  static const double glassShadowOpacity = 0.10;
  static const double glassShadowBlur = 20.0;

  // App theme — Slate Gray
  static const app = AppDesign(
    accent: Color(0xFF334155),
    accentLight: Color(0xFF3D4F6A),
    headerGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF334155), Color(0xFF222E3D)],
    ),
    cardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x1A334155), Color(0x0A334155)],
    ),
    cardGradientHover: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x2E334155), Color(0x14334155)],
    ),
  );
}
