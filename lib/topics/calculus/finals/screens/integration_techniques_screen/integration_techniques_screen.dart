import '../../solvers/integration_techniques/integration_techniques_equation.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:flutter/material.dart';

/// Finals thin solver: Integration Techniques (u-substitution).
class IntegrationTechniquesScreen extends StatelessWidget {
  const IntegrationTechniquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Integration Techniques',
        subtitle: 'u-substitution • by-parts • definite area & FTC',
        hint: 'e.g. ∫ 2x·(x²+1)³ dx',
        helper: 'Formats: integral a^b f(x) dx',
        depedCode: 'FINALS-Integration',
        icon: Icons.area_chart_outlined,
        createEquation: (input) => IntegrationTechniquesEquation(input),
      ),
    );
  }
}
