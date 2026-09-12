import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:flutter/material.dart';

class Grade6GemdasScreen extends StatelessWidget {
  const Grade6GemdasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Order of Operations (GEMDAS)',
        subtitle: 'Grouping first, left to right',
        hint: 'e.g. 8 + 2 × (5-3)^2',
        helper: 'G E M D A S — use ( ) ^ * / + -',
        depedCode: 'M6NS-IIa-148',
        icon: Icons.format_list_numbered_rounded,
        // CalculatorEngine.evaluate stops at the first space —
        // strip spaces before evaluation.
        createEquation: (input) =>
            G6GemdasEquation(input.replaceAll(' ', '')),
      ),
    );
  }
}
