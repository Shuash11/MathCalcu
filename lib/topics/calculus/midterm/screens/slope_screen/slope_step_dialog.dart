import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/topics/calculus/midterm/graph/slope_graph/slopegraph.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/slope_solver/slope_solver.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:flutter/material.dart';
import 'slope_steps.dart';

/// Opens the slope steps modal for a single-line calculation result.
Future<void> showSlopeStepsModal({
  required BuildContext context,
  required SlopeSolverResult result,
}) {
  return showSolutionStepsModal(
    context: context,
    title: 'Calculation Steps',
    accentColor: FinalsTheme.primary,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SlopeSteps(result: result),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SlopeGraphScreen(
                    result1: result,
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
