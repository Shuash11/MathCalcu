// Cycle 12 Item 2: radical solver right sides with x-terms.
// Gap proof: 'sqrt(x) = x' and 'sqrt(x + 5) = x' must solve with the
// existing extraneous-root verification; the plain-number right-side
// path (sqrt(x + 5) = 3 -> x = 4) must stay unchanged.
import 'package:calculus_system/topics/quadratics/solvers/radical_equation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RadicalEquation — right side with x (Cycle 12 Item 2)', () {
    test('sqrt(x) = x -> both roots 0 and 1 verify (sqrt(1) = 1)', () {
      final eq = RadicalEquation('sqrt(x) = x');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.points, hasLength(2));
      expect(r.points[0], closeTo(0, 1e-9));
      expect(r.points[1], closeTo(1, 1e-9));
      expect(r.answer, contains('0'));
      expect(r.answer, contains('1'));
    });

    test('sqrt(x + 5) = x -> root (1+sqrt(21))/2, negative one extraneous', () {
      final eq = RadicalEquation('sqrt(x + 5) = x');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.points, hasLength(1));
      expect(r.points[0], closeTo(2.791288, 1e-5));
      // The squared equation x^2 - x - 5 = 0 also gives (1-sqrt(21))/2,
      // but it fails verification — must not appear in the answer.
      expect(r.answer, isNot(contains('-1.791')));
      expect(eq.getSteps().last.explanation, r.answer);
    });

    test('sqrt(x + 5) = -x -> root -(1+sqrt(21))/2, positive one extraneous',
        () {
      final eq = RadicalEquation('sqrt(x + 5) = -x');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.points, hasLength(1));
      expect(r.points[0], closeTo(-1.791288, 1e-5));
      expect(r.answer, isNot(contains('2.791')));
    });

    test(
        'sqrt(-x) = x - 0.2 -> both squaring candidates extraneous -> rejected',
        () {
      final eq = RadicalEquation('sqrt(-x) = x - 0.2');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('extraneous'));
    });

    test('plain-number right side unchanged: sqrt(x + 5) = 3 -> x = 4', () {
      final eq = RadicalEquation('sqrt(x + 5) = 3');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('x = 4'));
      expect(r.points, [4]);
    });

    test('steps for x-form inputs: 4 steps incl. square + verify, no throw',
        () {
      final eq = RadicalEquation('sqrt(x + 5) = x');
      expect(eq.validate(), isTrue);
      final steps = eq.getSteps();
      expect(steps, hasLength(4));
      expect(steps.map((s) => s.title), contains('Square both sides'));
      expect(steps.map((s) => s.title), contains('Verify (extraneous check)'));
    });

    test('nonlinear right side stays unsupported', () {
      final eq = RadicalEquation('sqrt(x + 5) = x^2');
      expect(eq.validate(), isFalse);
    });
  });
}
