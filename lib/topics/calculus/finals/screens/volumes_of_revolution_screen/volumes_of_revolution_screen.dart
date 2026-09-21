import '../../solvers/volumes_of_revolution/volumes_of_revolution_equation.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:flutter/material.dart';

/// Finals thin solver: Volumes of Revolution.
class VolumesOfRevolutionScreen extends StatelessWidget {
  const VolumesOfRevolutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Volumes of Revolution',
        subtitle: 'disk • washer • shell methods',
        hint: 'e.g. volume x^2 about x-axis from 0 to 1',
        helper: 'Formats: volume f about x-axis from a to b, '
            'volume washer f g about x-axis from a to b, '
            'volume shell f about y-axis from a to b',
        depedCode: 'FINALS-Volumes',
        icon: Icons.donut_large_rounded,
        createEquation: (input) => VolumesOfRevolutionEquation(input),
      ),
    );
  }
}
