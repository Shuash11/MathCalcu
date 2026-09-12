import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:flutter/material.dart';

class Grade6IntegersScreen extends StatelessWidget {
  const Grade6IntegersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Integers & Number Line',
        subtitle: 'Compare, add, subtract on the line',
        hint: 'e.g. -5 + 8',
        helper: 'Integers only — use - sign, + - < >',
        depedCode: 'M6NS-IIIb-150',
        icon: Icons.straighten_rounded,
        graphKind: Grade6GraphKind.numberLine,
        createEquation: (input) => G6IntegerEquation(input),
      ),
    );
  }
}
