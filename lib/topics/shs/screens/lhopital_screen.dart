import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/shs/solvers/lhopital_equation.dart';
import 'package:flutter/material.dart';

/// SHS thin solver: L'Hôpital's Rule. Route: /shs/lhopital.
class ShsLHopitalScreen extends StatelessWidget {
  const ShsLHopitalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: "L'Hôpital's Rule",
        subtitle: '0/0 indeterminate — limit curve',
        hint: 'e.g. lim x→0 sin(x)/x',
        helper: 'Formats: 0/0 or ∞/∞ limit',
        depedCode: 'College-Calc',
        icon: Icons.functions_rounded,
        createEquation: (input) => LHopitalEquation(input),
      ),
    );
  }
}
