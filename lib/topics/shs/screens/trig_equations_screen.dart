import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/shs/solvers/trig_equation_solver.dart';
import 'package:flutter/material.dart';

/// SHS thin solver: Trig Equations. Route: /shs/trig-equations.
class ShsTrigEquationsScreen extends StatelessWidget {
  const ShsTrigEquationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Trig Equations',
        subtitle: 'Solutions on [0, 2π)',
        hint: 'e.g. sin x=1/2',
        helper: 'Formats: sin/cos/tan x = value',
        depedCode: 'SHS-PreCalc',
        icon: Icons.show_chart_rounded,
        createEquation: (input) => TrigEquationSolver(input),
      ),
    );
  }
}
