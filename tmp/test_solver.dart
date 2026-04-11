import 'package:calculus_system/modules/inequalities/absolute/solver/absolute_solver.dart';

void main() {
  final inputs = [
    '|2x - 1| < 5',
    '|2x - 1| > 5',
    '|-3x + 2| <= 8',
  ];

  for (final input in inputs) {
    print('\n--- Testing: $input ---');
    final steps = AbsoluteSolver.getSteps(input);
    for (final step in steps) {
      print('Step ${step.stepNumber}: ${step.title}');
      print('Exp: ${step.explanation}');
      print('LaTeX: ${step.latex}');
      print('-----------------');
    }
  }
}
