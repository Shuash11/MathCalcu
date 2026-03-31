// lib/Screens/SubScreens/result_section.dart
import 'package:calculus_system/modules/circles/center/solver/centersolver.dart';
import 'package:flutter/material.dart';
import '../../Theme/centertheme.dart';

class CenterResultSection extends StatelessWidget {
  final CenterResult? result;

  const CenterResultSection({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    if (result == null) return const SizedBox.shrink();

    final h = result!.h;
    final k = result!.k;

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
          Text(
            'C ( ${CenterSolver.fmt(h)}, ${CenterSolver.fmt(k)} )',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: FindingCenterTheme.indigo,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'h = ${CenterSolver.fmt(h)}     k = ${CenterSolver.fmt(k)}',
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