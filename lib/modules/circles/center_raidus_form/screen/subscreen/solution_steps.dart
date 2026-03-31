import 'package:calculus_system/modules/circles/center_raidus_form/Theme/center_radius_theme.dart';
import 'package:calculus_system/modules/circles/center_raidus_form/solver/center_radius_solver.dart';
import 'package:flutter/material.dart';

import 'step_tile.dart';

class SolutionSteps extends StatelessWidget {
  final List<SolverStep> steps;

  const SolutionSteps({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Solution',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: FindingCenterRadiusTheme.textPrimary.withValues(alpha: 0.9),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(steps.length, (i) => StepTile(
              step: steps[i],
              index: i,
              isLast: i == steps.length - 1,
            )),
      ],
    );
  }
}