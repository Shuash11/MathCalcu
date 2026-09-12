import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:flutter/material.dart';

class Grade6GeometryScreen extends StatelessWidget {
  const Grade6GeometryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Perimeter, Area & Angles',
        subtitle: 'Shape diagram with units',
        hint: 'e.g. rect 6x4',
        helper: 'Tap a shape chip, then type dimensions',
        depedCode: 'M6GE-IIIc-37',
        icon: Icons.crop_square_rounded,
        graphKind: Grade6GraphKind.shape,
        chips: const [
          'rect ',
          'square ',
          'triangle ',
          'circle r=',
          'parallelogram ',
          'trapezoid ',
        ],
        createEquation: (input) => G6GeometryEquation(input),
      ),
    );
  }
}
