import '../../solvers/taylor_series/taylor_series_equation.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:flutter/material.dart';

/// Finals thin solver: Taylor & Maclaurin Series.
class TaylorSeriesScreen extends StatelessWidget {
  const TaylorSeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Taylor & Maclaurin Series',
        subtitle: 'taylor series • Maclaurin • successive derivatives',
        hint: 'e.g. taylor exp(x) at 0',
        helper: 'Formats: taylor f at a [n=k], maclaurin f [n=k]',
        depedCode: 'FINALS-Taylor',
        icon: Icons.stacked_line_chart_rounded,
        createEquation: (input) => TaylorSeriesEquation(input),
      ),
    );
  }
}
