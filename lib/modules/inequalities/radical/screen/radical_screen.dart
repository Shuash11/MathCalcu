import 'package:flutter/material.dart';
import 'package:calculus_system/modules/inequalities/core/base_inequality_screen.dart';
import 'package:calculus_system/modules/inequalities/core/inequality_solver_router.dart';

class RadicalScreen extends StatelessWidget {
  const RadicalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Radical Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. sqrt x + 4 < 3  or  sqrt(x+3)/(x-1) > 0',
      solveFunction: InequalitySolverRouter.solve,
      stepsFunction: InequalitySolverRouter.getSteps,
    );
  }
}
