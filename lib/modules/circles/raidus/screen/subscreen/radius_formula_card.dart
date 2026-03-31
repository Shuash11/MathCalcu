import 'package:flutter/material.dart';
import '../../Theme/radiustheme.dart';

class RadiusFormulaCard extends StatelessWidget {
  const RadiusFormulaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: FindingRadiusTheme.indigo.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FindingRadiusTheme.indigo.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.functions_rounded,
                color: FindingRadiusTheme.indigo.withValues(alpha: 0.8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Formula',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: FindingRadiusTheme.indigo.withValues(alpha: 0.8),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'r = √( (x − h)² + (y − k)² )',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: FindingRadiusTheme.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '(x, y) = point on the circle     (h, k) = center',
            style: TextStyle(
              fontSize: 12,
              color: FindingRadiusTheme.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}