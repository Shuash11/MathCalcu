// lib/Screens/SubScreens/formula_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class CenterFormulaCard extends StatelessWidget {
  const CenterFormulaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF334155).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF334155).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.functions_rounded,
                color: const Color(0xFF334155).withValues(alpha: 0.8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'FORMULA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155).withValues(alpha: 0.8),
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Math.tex(
            r'h = \frac{x_1 + x_2}{2}',
            textStyle: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE8E8F0),
            ),
          ),
          const SizedBox(height: 4),
          Math.tex(
            r'k = \frac{y_1 + y_2}{2}',
            textStyle: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE8E8F0),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            r'A(x1, y1) and B(x2, y2) are the endpoints of the diameter',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF94A3B8).withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
