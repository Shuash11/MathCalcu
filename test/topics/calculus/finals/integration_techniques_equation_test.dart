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

  group('Integration by parts (LIATE, finals layer)', () {
    test('int x*ln(x) dx gives x^2/2 ln(x) - x^2/4 + C', () {
      final r = IntegrationTechniquesEquation('int x*ln(x) dx').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('x^2/2 ln(x)'));
      expect(r.answer, contains('x^2/4'));
      expect(r.answer, contains('+ C'));
      final data = r.customData!.first as Map;
      expect(data['rule'], contains('by parts'));
      expect(data['antiderivative'], contains('ln(x)'));
    });

    test('int x*e^x dx gives (x - 1)e^x + C', () {
      final r = IntegrationTechniquesEquation('int x*e^x dx').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('(x - 1)e^x'));
      expect(r.answer, contains('+ C'));
    });

    test('int x*sin(x) dx gives -x cos(x) + sin(x) + C', () {
      final r = IntegrationTechniquesEquation('int x*sin(x) dx').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('-x cos(x)'));
      expect(r.answer, contains('sin(x)'));
      expect(r.answer, contains('+ C'));
    });

    test('int x*cos(x) dx gives x sin(x) + cos(x) + C', () {
      final r = IntegrationTechniquesEquation('int x*cos(x) dx').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('x sin(x)'));
      expect(r.answer, contains('cos(x)'));
      expect(r.answer, contains('+ C'));
    });

    test('by-parts steps mention LIATE and stay at 3 steps', () {
      final eq = IntegrationTechniquesEquation('int x*ln(x) dx');
      expect(eq.validate(), isTrue);
      expect(eq.solve().hasError, isFalse);
      final steps = eq.getSteps();
      expect(steps, hasLength(3));
      expect(steps.first.title, contains('LIATE'));
    });

    test('coefficient-1 chain: int x*(x^2+1)^3 dx no longer fails', () {
      final eq = IntegrationTechniquesEquation('int x*(x^2+1)^3 dx');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('(x^2+1)^4'));
      expect(r.answer, contains('0.125'));
      expect(r.answer, contains('+ C'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('fallback: 2x*(x^2+1)^3 still solved as u-sub', () {
      final r = IntegrationTechniquesEquation('int 2x*(x^2+1)^3 dx').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('(x^2+1)^4'));
      expect(r.answer, contains('0.25'));
    });

    test('definite path untouched: def with non-u-sub f stays numeric', () {
      final eq = IntegrationTechniquesEquation('def a = 0, b = 2, f = x*ln(x)');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      final data = r.customData!.first as Map;
      expect(data['kind'], 'definite');
      expect(data['antiderivative'], isNull);
    });
  });
}
