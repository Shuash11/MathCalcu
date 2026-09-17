// SHS Wave 2 tests: trig equation, trig identity, integral, related rates,
// L'Hopital + curriculum registry wiring. Mirrors grade6 style.
import 'package:calculus_system/core/curriculum_registry.dart';
import 'package:calculus_system/topics/shs/solvers/shs_equations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Trig equation (g11-trig-equations)', () {
    test('sin x = 1/2 gives pi/6 pair', () {
      final eq = TrigEquationSolver('sin x = 1/2');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.points, hasLength(2));
      expect(eq.getSteps(), hasLength(3));
    });

    test('|k| > 1 errors', () {
      expect(TrigEquationSolver('sin x = 2').solve().hasError, isTrue);
    });

    test('garbage never throws', () {
      final eq = TrigEquationSolver('nope');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });

  group('Trig identity (g11-trig-identities)', () {
    test('pythagorean verifies', () {
      final eq = TrigIdentityEquation('prove: sin^2 + cos^2 = 1');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(eq.getSteps().length, greaterThanOrEqualTo(1));
    });

    test('false identity rejected', () {
      final r = TrigIdentityEquation('prove: sin^2 + cos^2 = 2').solve();
      expect(r.hasError, isTrue);
    });

    test('missing = never throws', () {
      final eq = TrigIdentityEquation('sin x');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });

  group('Integral sub (g12-definite-integral)', () {
    test('def a=0 b=2 f=x^2 area ~2.67', () {
      final eq = IntegralSubEquation('def a = 0, b = 2, f = x^2');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      final area = (r.customData!.first as Map)['area'] as double;
      expect(area, closeTo(8 / 3, 1e-2));
      expect(eq.getSteps(), hasLength(3));
    });

    test('indefinite int x^2 dx', () {
      final r = IntegralSubEquation('int x^2 dx').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('x^3'));
    });

    test('garbage never throws', () {
      final eq = IntegralSubEquation('zzz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });

  group('Related rates (g12-optimization)', () {
    test('max xy with x+y=20', () {
      final eq = RelatedRatesEquation('max xy, x + y = 20');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('100'));
      expect(eq.getSteps(), hasLength(4));
    });

    test('rect P=40 max area', () {
      final r = RelatedRatesEquation('rect P = 40 max area').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('100'));
    });

    test('unsupported never throws', () {
      final eq = RelatedRatesEquation('hello');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });

  group("L'Hopital (college-lhopital)", () {
    test('lim x->0 sin(x)/x = 1', () {
      final eq = LHopitalEquation('lim x->0 sin(x)/x');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.points.single, closeTo(1, 1e-3));
      expect(eq.getSteps(), hasLength(4));
    });

    test('bad form never throws', () {
      final eq = LHopitalEquation('zzz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });

  group('SHS registry wiring (Cycle 8: engines + screens + routes)', () {
    test('solver-backed SHS ids are available with /shs routes', () {
      for (final id in [
        'g11-logarithms',
        'g11-interest',
        'g11-inverse-functions',
        'g11-rational-inequality',
        'g11-trig-equations',
        'g11-trig-identities',
        'g9-trig-ratios',
        'g12-definite-integral',
        'g12-optimization',
        'college-lhopital',
      ]) {
        final topic =
            CurriculumRegistry.allTopics().firstWhere((t) => t.id == id);
        // P1-2: backend engine (waves 1-3) + frontend screen
        // (topics/shs/screens) + GoRoute (/shs/*) all landed.
        expect(topic.solverAvailable, isTrue, reason: id);
        expect(topic.route.startsWith('/shs/'), isTrue, reason: id);
      }
    });

    test('search indexes SHS (logarithm, lhopital)', () {
      final hits = CurriculumRegistry.search('logarithm');
      expect(hits.any((h) => h.topic.id == 'g11-logarithms'), isTrue);
      final lh = CurriculumRegistry.search('lhosp');
      expect(lh.any((h) => h.topic.id == 'college-lhopital'), isTrue);
    });
  });
}
