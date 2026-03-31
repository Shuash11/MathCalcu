// ─────────────────────────────────────────────────────────────
// BASE GRAPH — abstract contract for all graph renderers
// Each module's graph/ folder extends this with fl_chart or
// a CustomPainter specific to their type.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'solve_result.dart';

abstract class BaseGraph extends StatelessWidget {
  final SolveResult result;
  final Color accentColor;

  const BaseGraph({
    super.key,
    required this.result,
    required this.accentColor,
  });

  // Each module renders its own graph widget
  @override
  Widget build(BuildContext context);
}
