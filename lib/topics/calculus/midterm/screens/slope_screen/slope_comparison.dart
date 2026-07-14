import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/topics/calculus/midterm/graph/slope_graph/slopegraph.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/slope_solver/slope_solver.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:flutter/material.dart';
import 'slope_steps.dart';

/// Opens the slope-comparison steps modal (parallel / perpendicular / neither).
Future<void> showSlopeComparisonModal({
  required BuildContext context,
  required SlopeComparisonResult comparisonResult,
  required SlopeSolverResult result1,
  required SlopeSolverResult result2,
}) {
  final color = comparisonResult.isParallel
      ? const Color(0xFF4ECDC4)
      : comparisonResult.isPerpendicular
          ? const Color(0xFFFFB347)
          : const Color(0xFF95E1D3);

  final relationshipLabel = comparisonResult.isParallel
      ? 'PARALLEL'
      : comparisonResult.isPerpendicular
          ? 'PERPENDICULAR'
          : 'NEITHER';

  return showSolutionStepsModal(
    context: context,
    title: 'Line Relationship',
    design: AppDesign.calculus,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Relationship badge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            relationshipLabel,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),

        // Steps
        SlopeComparisonSteps(
          comparison: comparisonResult,
          result1: result1,
          result2: result2,
        ),

        const SizedBox(height: 12),

        // View graph button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SlopeGraphScreen(
                    result1: result1,
                    result2: result2,
                    comparison: comparisonResult,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FinalsTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.show_chart_rounded,
                size: 18, color: Colors.white),
            label: const Text(
              'View Graph',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
