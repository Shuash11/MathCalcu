// Cycle 10 Item 6: regression tests for LimitSolver (limits at infinity).
// Written BEFORE the solver fix to prove the bugs:
//  - no preprocessing: 'x² − 1' (unicode superscript + minus) threw
//    FormatException('Unexpected "²"'),
//  - dispatch on contains('/') + first-slash split: 'x + 2/x' was split
//    as (x + 2)/x (equal degrees -> 1 instead of oo), and
//    '(1/x)/(2/x)' split at the first inner slash -> tokenizer throw.
import 'package:calculus_system/topics/calculus/finals/solvers/limits_infinity_solver/limits_infinity_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cycle 10 Item 6: preprocessing + depth-aware split', () {
    test('unicode superscript + minus: x² − 1 -> oo', () {
      final s = LimitSolver.solve('x² − 1', double.infinity);
      expect(s.finalValue, double.infinity);
      expect(s.resultString, '∞');
    });

    test('plain ascii still works: x^2 + 1 -> oo', () {
      final s = LimitSolver.solve('x^2 + 1', double.infinity);
      expect(s.finalValue, double.infinity);
      expect(s.resultString, '∞');
    });

    test('÷ maps to division: x² ÷ 2 -> oo', () {
      final s = LimitSolver.solve('x² ÷ 2', double.infinity);
      expect(s.finalValue, double.infinity);
    });

    test('x + 2/x is not a top-level division -> oo', () {
      final s = LimitSolver.solve('x + 2/x', double.infinity);
      expect(s.finalValue, double.infinity);
      expect(s.resultString, '∞');
    });

    test('sum of proper fractions: 2/x + 1/x -> 0', () {
      final s = LimitSolver.solve('2/x + 1/x', double.infinity);
      expect(s.finalValue, 0);
      expect(s.resultString, '0');
    });

    test('(1/x)/(2/x) splits at top level -> 1/2', () {
      final s = LimitSolver.solve('(1/x)/(2/x)', double.infinity);
      expect(s.finalValue, closeTo(0.5, 1e-9));
      expect(s.resultString, '0.5');
    });

    test('unicode minus leading: −x² + 1 -> -oo', () {
      final s = LimitSolver.solve('−x² + 1', double.infinity);
      expect(s.finalValue, double.negativeInfinity);
      expect(s.resultString, '-∞');
    });

    test('plain rational unchanged: (2x+1)/(x+3) -> 2', () {
      final s = LimitSolver.solve('(2x+1)/(x+3)', double.infinity);
      expect(s.finalValue, 2);
      expect(s.resultString, '2');
    });
  });
}
