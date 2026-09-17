import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/shs/solvers/trig_ratio_equation.dart';
import 'package:flutter/material.dart';

/// SHS thin solver: Trig Ratios (SOH-CAH-TOA). Route: /shs/trig-ratios.
class ShsTrigRatiosScreen extends StatelessWidget {
  const ShsTrigRatiosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Trig Ratios (SOH-CAH-TOA)',
        subtitle: 'Right triangle — sine, cosine, tangent',
        hint: 'e.g. sin 30°',
        helper: 'Formats: sin/cos/tan + angle in degrees',
        depedCode: 'SHS-PreCalc',
        icon: Icons.change_history_rounded,
        createEquation: (input) => TrigRatioEquation(input),
      ),
    );
  }
}
