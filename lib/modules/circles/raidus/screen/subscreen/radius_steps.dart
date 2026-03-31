import 'package:calculus_system/modules/circles/raidus/Theme/radiustheme.dart';
import 'package:flutter/material.dart';

class RadiusStepsCard extends StatelessWidget {
  const RadiusStepsCard({super.key, required this.steps});

  /// Pre-formatted multiline solution string from [RadiusResult.steps].
  final String steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FindingRadiusTheme.indigo.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: FindingRadiusTheme.indigo.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Row(
            children: [
              Icon(
                Icons.list_alt_rounded,
                color: FindingRadiusTheme.indigo.withValues(alpha: 0.8),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'SOLUTION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: FindingRadiusTheme.indigo.withValues(alpha: 0.8),
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // One Text widget per line
          ...steps.split('\n').map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    line,
                    style: const TextStyle(
                      fontSize: 14,
                      color: FindingRadiusTheme.textPrimary,
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
