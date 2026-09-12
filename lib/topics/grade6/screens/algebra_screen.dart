import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:flutter/material.dart';

class Grade6AlgebraScreen extends StatelessWidget {
  const Grade6AlgebraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Simple Algebra (One Step)',
        subtitle: 'Inverse operations, check by substitution',
        hint: 'e.g. x + 7 = 15',
        helper: 'One variable, one = sign',
        depedCode: 'M6AL-IIIa-28',
        icon: Icons.functions_rounded,
        createEquation: (input) => G6AlgebraEquation(input),
      ),
    );
  }
}
