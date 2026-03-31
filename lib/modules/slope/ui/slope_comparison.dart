import 'package:calculus_system/modules/slope/graph/slopegraph.dart';
import 'package:calculus_system/modules/slope/theme/slope_theme.dart';
import 'package:calculus_system/modules/slope/types/slope_solver.dart';
import 'package:flutter/material.dart';
import 'slope_step.dart';

class SlopeComparisonDialog extends StatelessWidget {
  final SlopeComparisonResult comparisonResult;
  final SlopeSolverResult result1;
  final SlopeSolverResult result2;

  const SlopeComparisonDialog({
    super.key,
    required this.comparisonResult,
    required this.result1,
    required this.result2,
  });

  Color get _relationshipColor => comparisonResult.isParallel
      ? const Color(0xFF4ECDC4)
      : comparisonResult.isPerpendicular
          ? const Color(0xFFFFB347)
          : const Color(0xFF95E1D3);

  String get _relationshipLabel => comparisonResult.isParallel
      ? 'PARALLEL'
      : comparisonResult.isPerpendicular
          ? 'PERPENDICULAR'
          : 'NEITHER';

  @override
  Widget build(BuildContext context) {
    final steps = SlopeSolver.getComparisonSteps(comparisonResult);
    final color = _relationshipColor;

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
                          'Line Relationship',
                          style: SlopeTheme.titleStyle(context)
                              .copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'How we determined if lines are parallel or perpendicular',
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

              // ── Relationship badge ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _relationshipLabel,
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

              // ── Steps ──
              ...List.generate(
                  steps.length,
                  (i) => Padding(
                        padding: EdgeInsets.only(
                          bottom: i < steps.length - 1 ? 10 : 0,
                        ),
                        child: SlopeStepItem(
                          number: i + 1,
                          step: steps[i],
                          isFinal: i == steps.length - 1,
                        ),
                      )),

              const SizedBox(height: 24),

              // ── Action buttons ──
              if (comparisonResult.isParallel ||
                  comparisonResult.isPerpendicular) ...[
                Row(
                  children: [
                    Expanded(
                      child: _outlineButton(
                        context: context,
                        label: 'View Graph',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SlopeGraphScreen(
                                x1: result1.x1,
                                y1: result1.y1,
                                x2: result1.x2,
                                y2: result1.y2,
                                x3: result2.x1,
                                y3: result2.y1,
                                x4: result2.x2,
                                y4: result2.y2,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _solidButton(
                        context: context,
                        label: 'Close',
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: _solidButton(
                    context: context,
                    label: 'Close',
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _outlineButton(
          {required BuildContext context,
          required String label,
          required VoidCallback onTap}) =>
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

  Widget _solidButton(
          {required BuildContext context,
          required String label,
          required VoidCallback onTap}) =>
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
