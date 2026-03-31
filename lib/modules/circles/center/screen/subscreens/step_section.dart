// lib/Screens/SubScreens/steps_section.dart
import 'package:calculus_system/modules/circles/center/Theme/centertheme.dart';
import 'package:flutter/material.dart';

class CenterStepsSection extends StatelessWidget {
  final String? steps;

  const CenterStepsSection({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    if (steps == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FindingCenterTheme.indigo.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: FindingCenterTheme.indigo.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list_alt_rounded,
                color: FindingCenterTheme.indigo.withValues(alpha: 0.8),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'SOLUTION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: FindingCenterTheme.indigo.withValues(alpha: 0.8),
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...steps!.split('\n').map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    line,
                    style: const TextStyle(
                      fontSize: 13,
                      color: FindingCenterTheme.textPrimary,
                      height: 1.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
