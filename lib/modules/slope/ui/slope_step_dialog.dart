import 'package:calculus_system/modules/slope/graph/slopegraph.dart';
import 'package:calculus_system/modules/slope/theme/slope_theme.dart';
import 'package:calculus_system/modules/slope/types/slope_solver.dart';
import 'package:flutter/material.dart';

import 'slope_step.dart';

class SlopeStepDialog extends StatelessWidget {
  final SlopeSolverResult result;

  const SlopeStepDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final steps = SlopeSolver.getSteps(
      result.x1,
      result.y1,
      result.x2,
      result.y2,
    );

    return Dialog(
      backgroundColor: SlopeTheme.cardColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calculation Steps',
                          style: SlopeTheme.titleStyle(context)
                              .copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'How to find the slope',
                          style: SlopeTheme.subtitleStyle(context)
                              .copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close_rounded,
                      color: SlopeTheme.accentColor,
                      size: 24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Steps ──
              ...List.generate(
                  steps.length,
                  (i) => SlopeStepItem(
                        number: i + 1,
                        step: steps[i],
                        isFinal: i == steps.length - 1,
                        isLast: i == steps.length - 1,
                      )),
              const SizedBox(height: 24),

              // ── Action buttons ──
              Row(
                children: [
                  Expanded(
                    child: _outlineButton(
                      label: 'View Graph',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SlopeGraphScreen(
                              x1: result.x1,
                              y1: result.y1,
                              x2: result.x2,
                              y2: result.y2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _solidButton(
                      context,
                      label: 'Close',
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _outlineButton({required String label, required VoidCallback onTap}) =>
      ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: SlopeTheme.accentColor.withValues(alpha: 0.2),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          side:
              BorderSide(color: SlopeTheme.accentColor.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: SlopeTheme.accentColor,
          ),
        ),
      );

  Widget _solidButton(BuildContext context,
          {required String label, required VoidCallback onTap}) =>
      ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: SlopeTheme.accentColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: SlopeTheme.surface(context),
          ),
        ),
      );
}
