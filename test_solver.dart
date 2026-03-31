import 'dart:io';
import 'package:calculus_system/modules/inequalities/core/linear_solver.dart';

void main() {
  final result = LinearSolver.solve('5x+2 <= x-6');
  print('Answer: ' + result.answer);
  print('Interval Notation: ' + (result.intervalNotation ?? ''));
  
  final steps = LinearSolver.getSteps('5x+2 <= x-6');
  for (var step in steps) {
    print('Step ' + step.stepNumber.toString() + ': ' + step.title);
    print('   ' + (step.latex ?? ''));
  }
}
