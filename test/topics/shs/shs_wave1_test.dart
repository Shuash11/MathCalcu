// SHS Wave 1 tests: exp/log, interest, inverse, rational inequality, trig ratio.
// Mirrors test/topics/grade6/ style: validate + solve + steps, never-throw.
import 'package:calculus_system/topics/shs/solvers/shs_equations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpLog (g11-logarithms)', () {
    test('2^x = 32 gives x = 5', () {
      final eq = ExpLogEquation('2^x = 32');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('5'));
      expect(r.points.single, closeTo(5, 1e-9));
      expect(eq.getSteps(), hasLength(4));
    });

    test('log2(x)+log2(x-2)=3 gives x = 4', () {
      final eq = ExpLogEquation('log2(x)+log2(x-2) = 3');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('4'));
    });

    test('missing operator errors, never throws', () {
      final eq = ExpLogEquation('hello world');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
      expect(eq.solve().hasError, isTrue);
    });

    test('empty input errors with example', () {
      final eq = ExpLogEquation('   ');
      expect(eq.validate(), isFalse);
      expect(eq.solve().hasError, isTrue);
    });
  });

  group('Interest (g11-interest)', () {
    test('compound P=10000 r=5% t=2', () {
      final eq = InterestEquation('P = 10000, r = 5%, t = 2, compound');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('11'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('simple interest computes total', () {
      final r = InterestEquation('P = 10000, r = 5%, t = 2, simple').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('Total'));
    });

    test('missing mode errors, never throws', () {
      final eq = InterestEquation('P = 100, r = 5%');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(eq.solve().hasError, isTrue);
    });

    test('empty input errors', () {
      expect(InterestEquation('  ').validate(), isFalse);
    });
  });

  group('Inverse function (g11-inverse-functions)', () {
    test('f(x)=2x+3 inverts', () {
      final eq = InverseFunctionEquation('f(x) = 2x + 3');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('⁻¹'));
      expect(eq.getSteps(), hasLength(4));
    });

    test('constant has no inverse', () {
      final r = InverseFunctionEquation('f(x) = 5').solve();
      expect(r.hasError, isTrue);
    });

    test('garbage never throws', () {
      final eq = InverseFunctionEquation('blah');
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
      expect(eq.solve().hasError, isTrue);
    });
  });

  group('Rational inequality (g11-rational-inequality)', () {
    test('(x-1)/(x+2) > 0 splits intervals', () {
      final eq = RationalInequalityEquation('(x - 1)/(x + 2) > 0');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.intervalNotation, contains('∪'));
      expect(eq.getSteps(), hasLength(4));
    });

    test('missing comparator rejected', () {
      final eq = RationalInequalityEquation('(x-1)/(x+2)');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
    });

    test('empty never throws', () {
      final eq = RationalInequalityEquation('  ');
      expect(eq.validate(), isFalse);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });

  group('Trig ratio (g9-trig-ratios)', () {
    test('sin 30 = 0.5', () {
      final eq = TrigRatioEquation('sin 30');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.points.single, closeTo(0.5, 1e-9));
      expect(eq.getSteps(), hasLength(3));
    });

    test('opp=3 hyp=6 solves triangle', () {
      final r = TrigRatioEquation('opp = 3, hyp = 6').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('30'));
    });

    test('nonsense never throws', () {
      final eq = TrigRatioEquation('xyz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });
}
