// lib/Screens/SubScreens/formula_card.dart
import 'package:calculus_system/topics/calculus/midterm/theme/circles_theme/centertheme.dart';
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
        color: FindingCenterTheme.indigo.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FindingCenterTheme.indigo.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.functions_rounded,
                color: FindingCenterTheme.indigo.withValues(alpha: 0.8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'FORMULA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: FindingCenterTheme.indigo.withValues(alpha: 0.8),
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
              color: FindingCenterTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Math.tex(
            r'k = \frac{y_1 + y_2}{2}',
            textStyle: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: FindingCenterTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            r'A(x₁, y₁) and B(x₂, y₂) are the endpoints of the diameter',
            style: TextStyle(
              fontSize: 12,
              color: FindingCenterTheme.textSecondary.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
