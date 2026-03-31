import 'package:flutter/material.dart';
import '../../Theme/radiustheme.dart';

class RadiusResultCard extends StatelessWidget {
  const RadiusResultCard({super.key, required this.formattedRadius});

  /// Pre-formatted radius string from [RadiusResult.formattedRadius].
  final String formattedRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FindingRadiusTheme.teal.withValues(alpha: 0.2),
            FindingRadiusTheme.cyan.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: FindingRadiusTheme.teal.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'RADIUS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: FindingRadiusTheme.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'r = ',
                style: TextStyle(
                  fontSize: 20,
                  color: FindingRadiusTheme.textSecondary.withValues(alpha: 0.8),
                ),
              ),
              Text(
                formattedRadius,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: FindingRadiusTheme.cyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}