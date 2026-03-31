// lib/Screens/SubScreens/formula_card.dart
import 'package:flutter/material.dart';
import '../../Theme/centertheme.dart';

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
          const Text(
            'h = (x₁ + x₂) / 2',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: FindingCenterTheme.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'k = (y₁ + y₂) / 2',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: FindingCenterTheme.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'A(x₁, y₁) and B(x₂, y₂) are the endpoints of the diameter',
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