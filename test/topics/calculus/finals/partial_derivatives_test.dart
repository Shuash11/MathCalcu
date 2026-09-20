// Cycle 11 Slice 3b: partial derivatives regression test — the thin
// DerivativesSolver wrap. Verifies the variable token selects the
// differentiation variable and the expression delegates to the CAS.
import 'package:calculus_system/topics/calculus/finals/solvers/partial_derivatives/partial_derivatives_equation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Partial derivatives (finals, thin DerivativesSolver wrap)', () {
    test('d/dx x^2*y gives 2xy (y treated as constant)', () {
      final eq = PartialDerivativesEquation('d/dx x^2*y');
      expect(eq.validate(), isTrue);
      expect(eq.variable, 'x');
      expect(eq.expression, 'x^2*y');
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('∂f/∂x'));
      expect(r.answer, contains('2 * x * y'));
      expect(eq.getSteps(), isNotEmpty);
      expect(eq.getSteps().first.explanation, contains('∂f/∂x'));
    });

    test('d/dy x^2*y gives x^2 (x treated as constant)', () {
      final eq = PartialDerivativesEquation('d/dy x^2*y');
      expect(eq.validate(), isTrue);
      expect(eq.variable, 'y');
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('∂f/∂y'));
      expect(r.answer, contains('x ^ 2'));
    });

    test('d/dx sin(x)*y gives cos(x)*y (chain + product)', () {
      final r = PartialDerivativesEquation('d/dx sin(x)*y').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('∂f/∂x'));
      expect(r.answer, contains('cos(x) * y'));
    });

    test('garbage never throws', () {
      final eq = PartialDerivativesEquation('zzz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(eq.solve().hasError, isTrue);
      expect(eq.getSteps(), isEmpty);
    });
  });
}
