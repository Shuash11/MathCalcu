import 'package:flutter/material.dart';

class FindingCenterTheme {
  // Background
  static const Color bgDark = Color(0xFF0F172A);
  static const Color bgCard = Color(0xFF1E293B);
  
  // Accents - Using Indigo as primary for this screen
  static const Color indigo = Color(0xFF6366F1);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color teal = Color(0xFF14B8A6);
  static const Color softIndigo = Color(0xFFA5B4FC);
  
  // Text
  static const Color textPrimary = Color(0xFFE8E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  
  // Input
  static const Color inputBg = Color(0xFF334155);
  static const Color inputBorder = Color(0xFF475569);
  
  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [indigo, purple],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgDark, Color(0xFF1E1B4B)],
  );
}