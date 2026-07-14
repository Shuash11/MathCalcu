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

  // App theme — Deep Maroon
  static const app = AppDesign(
    accent: Color(0xFF7F1D1D),
    accentLight: Color(0xFF9F2333),
    headerGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF7F1D1D), Color(0xFF4A0E1A)],
    ),
    cardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x1A7F1D1D), Color(0x0A7F1D1D)],
    ),
    cardGradientHover: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x2E7F1D1D), Color(0x147F1D1D)],
    ),
  );

  // Calculus theme — Deep Blue
  static const calculus = AppDesign(
    accent: Color(0xFF1E3A5F),
    accentLight: Color(0xFF2D5A8E),
    headerGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1E3A5F), Color(0xFF0F1F33)],
    ),
    cardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x1A1E3A5F), Color(0x0A1E3A5F)],
    ),
    cardGradientHover: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x2E1E3A5F), Color(0x141E3A5F)],
    ),
  );
}
