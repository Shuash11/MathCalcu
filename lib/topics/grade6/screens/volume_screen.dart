import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:flutter/material.dart';

class Grade6VolumeScreen extends StatelessWidget {
  const Grade6VolumeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Volume: Cube & Prism',
        subtitle: '3D wireframe, cubic units',
        hint: 'e.g. 5 x 3 x 2',
        helper: 'L x W x H in same units — or cube s=4',
        depedCode: 'M6ME-IVa-95',
        icon: Icons.view_in_ar_rounded,
        graphKind: Grade6GraphKind.wireframe,
        chips: const [
          'cube s=',
          'prism ',
          'cyl r=',
          'cone r=',
          'pyramid ',
          'sphere r=',
        ],
        createEquation: (input) => G6VolumeEquation(input),
      ),
    );
  }
}
