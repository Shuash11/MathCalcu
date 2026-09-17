import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/modmat/solvers/m7_predicate_equation.dart';
import 'package:flutter/material.dart';

/// ModMat thin solver: Predicate Logic. Route: /modmat/foundations/predicate_logic.
class ModmatPredicateScreen extends StatelessWidget {
  const ModmatPredicateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Predicate Logic',
        subtitle: 'Modern Math — Foundations',
        hint: 'e.g. forall x in {1,2,3}: x > 0',
        helper: 'Forall / exists over finite domains — witnesses first.',
        depedCode: 'MODMAT-Foundations',
        icon: Icons.code_rounded,
        createEquation: (input) => M7PredicateEquation(input),
      ),
    );
  }
}
