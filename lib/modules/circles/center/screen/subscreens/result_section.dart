// lib/Screens/SubScreens/result_section.dart

import 'package:calculus_system/modules/circles/center/Theme/centertheme.dart';

import 'package:calculus_system/modules/circles/center/solver/centersolver.dart';
import 'package:flutter/material.dart';

class CenterResultSection extends StatelessWidget {
  final CenterResult? result;

  const CenterResultSection({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    if (result == null) return const SizedBox.shrink();

    final h = result!.h;
    final k = result!.k;
    final showHApprox = !h.isWhole;
    final showKApprox = !k.isWhole;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FindingCenterTheme.teal.withValues(alpha: 0.2),
            FindingCenterTheme.indigo.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: FindingCenterTheme.teal.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'CENTER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: FindingCenterTheme.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // Exact form: C ( 7/2 , 5 )
          Text(
            'C ( ${result!.hExact}, ${result!.kExact} )',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: FindingCenterTheme.indigo,
            ),
          ),

          const SizedBox(height: 16),

          // Approximations when not whole numbers
          if (showHApprox || showKApprox)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: FindingCenterTheme.indigo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showHApprox) ...[
                    Text(
                      'h ≈ ${result!.hApprox}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: FindingCenterTheme.textSecondary,
                      ),
                    ),
                    if (showKApprox)
                      const Text(
                        '    ',
                        style:
                            TextStyle(color: FindingCenterTheme.textSecondary),
                      ),
                  ],
                  if (showKApprox)
                    Text(
                      'k ≈ ${result!.kApprox}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: FindingCenterTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),

          // If both are whole, show simple equals
          if (!showHApprox && !showKApprox)
            Text(
              'h = ${result!.hExact}     k = ${result!.kExact}',
              style: TextStyle(
                fontSize: 14,
                color: FindingCenterTheme.textSecondary.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }
}
