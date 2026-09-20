// Finals Integration Techniques regression test: the promoted SHS u-sub
// engine subclass. Mirrors test/topics/shs/shs_wave2_test.dart lines 54-70.
import 'package:calculus_system/topics/calculus/finals/solvers/integration_techniques/integration_techniques_equation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Integration techniques (finals, promoted IntegralSubEquation)', () {
    test('u-sub: int 2x(x^2+1)^3 dx gives antiderivative + steps', () {
      final eq = IntegrationTechniquesEquation('int 2x(x^2+1)^3 dx');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('(x^2+1)^4'));
      expect(r.answer, contains('+ C'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('power fallback: int x^2 dx gives x^3/3 + C', () {
      final r = IntegrationTechniquesEquation('int x^2 dx').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('x^3'));
      expect(r.answer, contains('+ C'));
    });

    test('definite + FTC: def a=0 b=2 f=x^2 area ~2.67', () {
      final eq = IntegrationTechniquesEquation('def a = 0, b = 2, f = x^2');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      final area = (r.customData!.first as Map)['area'] as double;
      expect(area, closeTo(8 / 3, 1e-2));
      expect(eq.getSteps(), hasLength(3));
    });

    test('garbage never throws', () {
      final eq = IntegrationTechniquesEquation('zzz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });
}
