import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/shs/solvers/trig_identity_equation.dart';
import 'package:flutter/material.dart';

/// SHS thin solver: Trig Identities. Route: /shs/trig-identities.
class ShsTrigIdentitiesScreen extends StatelessWidget {
  const ShsTrigIdentitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Trig Identities',
        subtitle: 'Proof steps — Pythagorean',
        hint: 'e.g. sin^2+cos^2=1',
        helper: 'Formats: identity left=right',
        depedCode: 'SHS-PreCalc',
        icon: Icons.verified_rounded,
        createEquation: (input) => TrigIdentityEquation(input),
      ),
    );
  }
}
