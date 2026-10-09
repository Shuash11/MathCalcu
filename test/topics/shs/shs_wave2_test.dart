// SHS Wave 2 tests: trig equation, trig identity, integral, related rates,
// L'Hopital + curriculum registry wiring. Mirrors grade6 style.
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/curriculum_registry.dart';
import 'package:calculus_system/topics/shs/solvers/shs_equations.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Render [tex] with an explicit recording `onErrorFallback`; assert it was NOT
/// invoked, i.e. the TeX parses. A count/presence check cannot catch a parse
/// failure, so every emitted LaTeX line is rendered for real.
Future<void> _expectTexParses(WidgetTester tester, String tex) async {
  var fellBack = false;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Math.tex(
          tex,
          textStyle: const TextStyle(fontSize: 14),
          onErrorFallback: (e) {
            fellBack = true;
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  await tester.pump();
  expect(fellBack, isFalse, reason: 'TeX failed to parse: $tex');
}

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

    test('solutions carry LaTeX; method steps prose', () {
      final s = TrigEquationSolver('sin x = 1/2').getSteps();
      expect(s, hasLength(3));
      expect(s[0].latex, isNull);
      expect(s[1].latex, isNull);
      expect(s[2].latex, r'x = \frac{\pi}{6}, \frac{5\pi}{6}');
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

    test('pythagorean proof steps carry LaTeX', () {
      final s = TrigIdentityEquation('prove: sin^2 + cos^2 = 1').getSteps();
      expect(s, hasLength(3));
      expect(s[0].latex, r'x = \cos\theta,\quad y = \sin\theta');
      expect(s[1].latex, r'x^{2} + y^{2} = 1');
      expect(s[2].latex, r'\sin^{2}\theta + \cos^{2}\theta = 1');
    });

    test('reciprocal proof leaves prose steps null', () {
      final s = TrigIdentityEquation('prove: sec = 1/cos').getSteps();
      expect(s, hasLength(3));
      expect(s[0].latex, isNotNull);
      expect(s[1].latex, isNull); // 'Substitute and simplify each side.'
      expect(s[2].latex, isNull); // 'Both sides match. ∎'
    });

    test('numeric-only verification step is prose', () {
      final s = TrigIdentityEquation('prove: sin + 0 = sin').getSteps();
      expect(s, hasLength(1));
      expect(s[0].latex, isNull);
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

    test('definite/indefinite carry LaTeX; prose steps null', () {
      final d = IntegralSubEquation('def a = 0, b = 2, f = x^2').getSteps();
      expect(d, hasLength(3));
      expect(d[0].latex, isNull); // FTC-setup guidance
      expect(d[1].latex, startsWith(r'\text{Area} = '));
      expect(d[2].latex, isNull); // Simpson-check prose

      final i = IntegralSubEquation('int x^2 dx').getSteps();
      expect(i, hasLength(3));
      expect(i[0].latex, isNull); // 'Choose u' guidance
      expect(i[1].latex, r'\int u^{n}\,du = \frac{u^{n+1}}{n+1}');
      expect(i[2].latex, r'\int x^2\,dx = 0.333333x^3 + C');
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

    test('word-embedded "p" is not read as the perimeter', () {
      // Pre-fix: `p\s*=` had no left word boundary, so the "p=40" inside
      // "step=40" was read as P=40 and this solved to a bogus
      // Square 10 x 10, max area = 100. Post-fix: no bounded 'p' -> error.
      final r = RelatedRatesEquation('rect step=40 max area').solve();
      expect(r.hasError, isTrue);
      expect(r.customData, isNull);
    });

    test('Adviser example "rect shape=40" never reads p = 40', () {
      // Guard: in "shape" the p is followed by 'e', not '=', so this
      // input actually errored pre-fix too; kept to lock in that no 40
      // is ever read from the word.
      final r = RelatedRatesEquation('rect shape=40 max area').solve();
      expect(r.hasError, isTrue);
      expect(r.customData, isNull);
    });

    test('genuine rect P = 40 still solves', () {
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

    test('optimum result carries LaTeX; guidance steps prose', () {
      final s = RelatedRatesEquation('max xy, x + y = 20').getSteps();
      expect(s, hasLength(4));
      expect(s[0].latex, isNull);
      expect(s[1].latex, isNull);
      expect(s[2].latex, r'x = 10,\quad y = 10,\quad xy = 100');
      expect(s[3].latex, isNull);

      final rect = RelatedRatesEquation('rect P = 40 max area').getSteps();
      expect(rect[2].latex, r'\text{Square } 10 \times 10,\quad A = 100');

      final sph =
          RelatedRatesEquation('sphere r = 3, dr/dt = 0.5').getSteps();
      expect(sph[2].latex, contains(r'\frac{dV}{dt}'));
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

    test('derivative + limit steps carry LaTeX; guidance prose', () {
      final s = LHopitalEquation('lim x->0 sin(x)/x').getSteps();
      expect(s, hasLength(4));
      expect(s[0].latex, isNull);
      expect(s[1].latex, contains("f'(a)"));
      expect(s[2].latex, r'\lim_{x \to 0} \frac{f(x)}{g(x)} = 1');
      expect(s[3].latex, isNull);
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

  group('SHS wave2 LaTeX contract', () {
    final cases = <BaseEquation>[
      TrigEquationSolver('sin x = 1/2'),
      TrigEquationSolver('cos x = 1/2'),
      TrigEquationSolver('tan x = 1'),
      TrigEquationSolver('sin x = -1'),
      TrigIdentityEquation('prove: sin^2 + cos^2 = 1'),
      TrigIdentityEquation('prove: tan^2 + 1 = sec^2'),
      TrigIdentityEquation('prove: sec = 1/cos'),
      TrigIdentityEquation('prove: tan = sin/cos'),
      IntegralSubEquation('def a = 0, b = 2, f = x^2'),
      IntegralSubEquation('int x^2 dx'),
      IntegralSubEquation('int 2x(x^2+1)^3 dx'),
      RelatedRatesEquation('max xy, x + y = 20'),
      RelatedRatesEquation('rect P = 40 max area'),
      RelatedRatesEquation('sphere r = 3, dr/dt = 0.5'),
      LHopitalEquation('lim x->0 sin(x)/x'),
      LHopitalEquation('lim x->1 (x^2-1)/(x-1)'),
    ];

    test('every emitted wave2 TeX line is ASCII', () {
      var checked = 0;
      for (final eq in cases) {
        for (final s in eq.getSteps()) {
          for (final tex in <String?>[s.latex, ...?s.subLatex]) {
            if (tex == null) continue;
            expect(tex.codeUnits.every((c) => c >= 0x20 && c <= 0x7e), isTrue,
                reason: '$tex (${s.title})');
            checked++;
          }
        }
      }
      expect(checked, greaterThan(0));
    });

    testWidgets(
        'every emitted wave2 TeX line parses (recording fallback)',
        (tester) async {
      var checked = 0;
      for (final eq in cases) {
        for (final s in eq.getSteps()) {
          if (s.latex != null && s.latex!.isNotEmpty) {
            await _expectTexParses(tester, s.latex!);
            checked++;
          }
          for (final line in s.subLatex ?? const <String>[]) {
            if (line.trim().isNotEmpty) {
              await _expectTexParses(tester, line);
              checked++;
            }
          }
        }
      }
      expect(checked, greaterThan(0));
    });
  });
}
