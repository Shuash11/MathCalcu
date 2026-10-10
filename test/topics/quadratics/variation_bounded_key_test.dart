// Bounded-key regression tests for VariationEquation (Cycle 17 Phase 1).
//
// `([xyz])\s*=` with no left word boundary also matches the 'x' inside
// "max", so 'max = 40' was silently read as x = 40 (last write wins). Each
// pattern is fixed by prepending `\b`. Negative assertions fail pre-fix
// (pre-fix values noted in comments).
import 'package:calculus_system/topics/quadratics/solvers/quadratics_equations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VariationEquation — bounded x / y / z keys', () {
    test('the "x" inside "max" is not read as a second data point', () {
      // Regressive: pre-fix the "x" in "max = 40" matched `x\s*=`, so
      // xs = [2, 40] -> answer "k = 5, y = 200 when x = 40".
      // Post-fix: only the real x = 2 remains -> single-point k result.
      final r = VariationEquation('direct, x = 2, y = 10, max = 40').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('y = kx'));
      expect(r.answer, isNot(contains('40')));
      expect((r.customData!.first as Map)['x'], isNull);
    });

    test('explicit x = 5 wins over the "x" in "max = 40"', () {
      final r = VariationEquation('direct, x = 2, y = 10, x = 5, max = 40')
          .solve();
      expect(r.hasError, isFalse);
      final cd = r.customData!.first as Map;
      expect((cd['x'] as num).toDouble(), 5.0);
      expect(r.answer, contains('x = 5'));
      expect(r.answer, isNot(contains('40')));
    });

    test('normal variation input still solves', () {
      final eq = VariationEquation('direct, x = 2, y = 10, x = 5');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      final cd = r.customData!.first as Map;
      expect((cd['k'] as num).toDouble(), 5.0);
      expect((cd['y'] as num).toDouble(), 25.0);
    });
  });
}
