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

    test(
      'C2: true double-angle identities now verify (sin + cos families)',
      () {
        // Pre-fix (HEAD fcfeeee) the numeric evaluator dropped the `x` variable
        // and the implicit product, so every one of these errored with
        // 'Not an identity — sides differ at sample angles (0/5 match).'
        final sinEq = TrigIdentityEquation('prove: sin 2x = 2 sin x cos x');
        expect(sinEq.validate(), isTrue);
        final sin = sinEq.solve();
        expect(sin.hasError, isFalse);
        expect(sin.answer, 'Identity holds — sin 2θ = 2 sin θ cos θ. ∎');
        expect((sin.customData!.first as Map)['template'], 'double-angle-sin');

        final cosPyth = TrigIdentityEquation('prove: cos 2x = 1 - 2 sin^2 x');
        final cosDiff = TrigIdentityEquation(
          'prove: cos 2x = cos^2 x - sin^2 x',
        );
        final cosTwice = TrigIdentityEquation('prove: cos 2x = 2 cos^2 x - 1');
        for (final eq in [cosPyth, cosDiff, cosTwice]) {
          final r = eq.solve();
          expect(r.hasError, isFalse, reason: eq.rawInput);
          expect(
            r.answer,
            'Identity holds — Forms: 2cos²θ − 1, or 1 − 2sin²θ. ∎',
          );
          expect((r.customData!.first as Map)['template'], 'double-angle-cos');
        }

        // Same truth in θ-spelling and with no spaces around the factor.
        for (final input in const [
          'prove: sin 2θ = 2 sin θ cos θ',
          'prove: sin2x = 2 sin x cos x',
          'prove: cos 2θ = cos^2 θ - sin^2 θ',
        ]) {
          expect(
            TrigIdentityEquation(input).solve().hasError,
            isFalse,
            reason: input,
          );
        }
      },
    );

    test('C2: FALSE double-angle identities are NEVER accepted', () {
      // The first three were WRONGLY accepted by the old evaluator (it read
      // `sin2x` as `sin x` and `2 sin x cos x` as the constant 2), so they are
      // the soundness half of the fix. The rest guard the new evaluator.
      const falseBattery = <String>[
        'prove: sin 2x = sin x cos x', // baseline: bogus 5/5
        'prove: sin2x = sinx', // baseline: bogus 5/5
        'prove: 2 sin x cos x = 2', // baseline: bogus 5/5
        'prove: sin 2x = 2 sin x', // no cos factor
        'prove: sin 2x = 2 sin 2x', // double-counted argument
        'prove: sin 2x = 3 sin x cos x', // wrong coefficient
        'prove: sin x = cos x',
        'prove: sin 2x = 0',
        'prove: cos 2x = 1 - 2 sin^2 x + 1', // extra +1
        'prove: cos 2x = cos^2 x + sin^2 x', // wrong sign
        'prove: cos 2x = 1 + 2 sin^2 x', // wrong sign
        'prove: cos 2x = 1 - 2 cos^2 x', // sin/cos swapped
        'prove: cos 2x = 2 cos^2 x + 1', // wrong sign
      ];
      for (final input in falseBattery) {
        final r = TrigIdentityEquation(input).solve();
        expect(r.hasError, isTrue, reason: input);
        expect(r.customData, isNull, reason: input);
        // Assert the BEHAVIOUR (rejected as a non-identity), not the sample
        // arithmetic: the sample count changes if the sampler changes (it is
        // 12 angles now: 10 input-derived + 2 pi-zone), and pinning '0/5'
        // exactly would couple this test to that implementation detail.
        expect(
          r.errorMessage,
          startsWith('Not an identity — sides differ at sample angles ('),
          reason: input,
        );
      }
    });

    test('C2c: spike / high-power false accepts are NEVER verified (cap)', () {
      // Adversarial-review regression (9 reproduced false-accepts): a bounded
      // spike like (sin x - 0.6)^40 stays below the 1e-6 tolerance at EVERY
      // safe-zone angle, so numeric sampling alone cannot reject it; a
      // fractional power like (sin x)^41.5 is NaN exactly where sin x < 0;
      // and (sin x)^100*(cos x)^100 has sup-norm 2^-100 < 1e-6 everywhere.
      // The exponent cap (evaluated power > 19 -> Unsupported BEFORE sampling)
      // is the grammar-level defense. The tan-mention factor used to
      // additionally disable the pi-zone samples via a raw substring match on
      // the input — the zone-skip is now decided from the parsed token stream,
      // and these inputs are rejected at the gate either way.
      const attacks = <String>[
        // The three mandated spikes.
        'prove: 0 = (sin x - 0.6)^40',
        'prove: sin 2x = 2 sin x cos x + (sin x - 0.3)^40',
        'prove: cos 2x = cos^2 x - sin^2 x + (cos x - 0.7)^40',
        // Tan-mention attack (substring zone-skip disarm attempt).
        'prove: 0 = (sin x - 0.6)^40 * tan x * 0',
        // Fractional-power NaN attack.
        'prove: 0 = (sin x - 0.6)^40 * (sin x)^41.5',
        // Sup-norm attack: |(sin x cos x)^100| < 1e-6 for every x.
        'prove: 0 = (sin x)^100 * (cos x)^100',
      ];
      for (final input in attacks) {
        final r = TrigIdentityEquation(input).solve();
        expect(r.hasError, isTrue, reason: input);
        expect(r.customData, isNull, reason: input);
        // The honest verdict is a rejection, never a success: with the cap in
        // place these all surface as Unsupported; the sampler's honest
        // rejections are equally acceptable should gate routing change.
        expect(
          r.errorMessage,
          anyOf(
            startsWith('Unsupported — only trig expressions in one angle'),
            startsWith('Not an identity — sides differ at sample angles ('),
            'Could not verify — keep to sin/cos/tan/sec/csc/cot with numeric angles.',
          ),
          reason: input,
        );
      }
    });

    test('C2c: one-sided NaN sample counts as a mismatch, never a skip', () {
      // Root-cause-2 regression: the sample loop used to `continue` when
      // EITHER side was non-finite, so a term that is NaN precisely at the
      // pi-zone angles (where sin x < 0) silenced the zone defense for
      // exactly the crafted inputs. These exponents are <= 19, so the cap
      // leaves them in scope and the NaN must count as a MISMATCH.
      const nanPoison = <String>[
        'prove: 0 = (sin x)^2.5 * 0', // NaN where sin x < 0 (3pi/2 zone)
        'prove: 0 = (sin x)^0.5 * 0', // sqrt of a negative -> NaN at 3pi/2
        'prove: sin 2x = 2 sin x cos x + (sin x)^2.5 * 0',
      ];
      for (final input in nanPoison) {
        final r = TrigIdentityEquation(input).solve();
        expect(r.hasError, isTrue, reason: input);
        expect(r.customData, isNull, reason: input);
        expect(
          r.errorMessage,
          startsWith('Not an identity — sides differ at sample angles ('),
          reason: input,
        );
      }
    });

    test('C2b: malformed / trailing-token input is REJECTED, never proved', () {
      // Regression for Failure 1: solve() only guarded `checked == 0` inside
      // the key==null branch, so a template match on a completely
      // non-evaluable side fell through to a bogus 'Identity holds'. The new
      // evaluator's `if (!atEnd()) return null;` (trailing tokens) made this
      // reachable. Each of these scored a top-level template name yet no side
      // parses, so all must error — never a proof.
      const malformed = <String>[
        'prove: cos2) = 1',
        'prove: sin 2x = 2 sin x cos x + 1)',
        'prove: sin 2x = 2 sin x cos x/',
      ];
      for (final input in malformed) {
        final r = TrigIdentityEquation(input).solve();
        expect(r.hasError, isTrue, reason: input);
        expect(r.customData, isNull, reason: input);
        expect(
          r.errorMessage,
          'Could not verify — keep to sin/cos/tan/sec/csc/cot with numeric angles.',
          reason: input,
        );
      }
    });

    test('C2b: bare-variable polynomial terms are REJECTED by the scope gate', () {
      // Regression for Failure 2: the verifier's five sample angles used to be
      // the FIXED set {0.3, 0.7, 1.1, 2.0, 2.6}, so a degree-5 polynomial whose
      // roots were exactly those points was accepted as an identity. Merely
      // re-seeding the sampler would leave the evasion CLASS open (a polynomial
      // crafted against the new angles), so any variable occurrence outside a
      // trig argument — i.e. a polynomial/rational term in x — is now rejected
      // BEFORE sampling with an honest unsupported message.
      const evasion = <String>[
        'prove: sin 2x = 2 sin x cos x + (x-0.3)(x-0.7)(x-1.1)(x-2.0)(x-2.6)',
        'prove: 0 = (x-0.3)(x-0.7)(x-1.1)(x-2.0)(x-2.6)',
      ];
      for (final input in evasion) {
        final r = TrigIdentityEquation(input).solve();
        expect(r.hasError, isTrue, reason: input);
        expect(r.customData, isNull, reason: input);
        expect(
          r.errorMessage,
          startsWith('Unsupported — only trig expressions in one angle'),
          reason: input,
        );
      }
      // The gate is a pure function of the input: the same input yields the
      // same verdict on repeat (no flaky hash race).
      for (final input in evasion) {
        expect(
          TrigIdentityEquation(input).solve().hasError,
          TrigIdentityEquation(input).solve().hasError,
          reason: input,
        );
      }
      // The gate must NOT over-reach: trig of the angle, integer multiples,
      // powers and parenthesised arguments all stay inside its scope.
      for (final input in const [
        'prove: sin 2x = 2 sin x cos x',
        'prove: sin^2 x + cos^2 x = 1',
        'prove: sin(2x) = 2 sin x cos x',
        'prove: cos(2x) = cos^2 x - sin^2 x',
      ]) {
        expect(
          TrigIdentityEquation(input).solve().hasError,
          isFalse,
          reason: input,
        );
      }
    });

    test('C2: previously-working template families are unchanged', () {
      // Collateral guards for the evaluator rewrite.
      const expected = <String, String>{
        'prove: sin^2 + cos^2 = 1': 'pythagorean',
        'prove: tan^2 + 1 = sec^2': 'tangent',
        'prove: sec = 1/cos': 'reciprocal',
        'prove: tan = sin/cos': 'quotient',
      };
      for (final e in expected.entries) {
        final r = TrigIdentityEquation(e.key).solve();
        expect(r.hasError, isFalse, reason: e.key);
        expect(
          (r.customData!.first as Map)['template'],
          e.value,
          reason: e.key,
        );
      }
      expect(
        TrigIdentityEquation('prove: sin^2 + cos^2 = 2').solve().hasError,
        isTrue,
      );
      final numeric = TrigIdentityEquation('prove: sin + 0 = sin').solve();
      expect(numeric.hasError, isFalse);
      expect((numeric.customData!.first as Map)['template'], 'numeric');
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

      final sph = RelatedRatesEquation('sphere r = 3, dr/dt = 0.5').getSteps();
      expect(sph[2].latex, contains(r'\frac{dV}{dt}'));
    });

    test('validate() agrees with solve() — the sphere defect input', () {
      final eq = RelatedRatesEquation('sphere r = 3, dr/dt = 0.5');
      expect(eq.validate(), isTrue); // pre-fix: false (no max/min/rate keyword)
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('56.548668')); // dV/dt = 4*pi*r^2*dr
      expect(r.answer, contains('37.699112')); // dA/dt = 8*pi*r*dr
    });

    test(
      'validate() is TRUE exactly when solve() is non-error (both directions)',
      () {
        const expected = {
          // solvable -> validate TRUE
          'max xy, x + y = 20': true,
          'min xy, x+y=20': true,
          'rect P = 40 max area': true,
          'rect P = 40': true, // solvable without a max/rate keyword
          'sphere r = 3, dr/dt = 0.5': true,
          'sphere r=3, dr=0.5': true,
          'balloon r = 2, dr/dt = 1': true,
          'sphere r = 3, dr/dt=0.5 max': true,
          // not solvable -> validate FALSE
          'hello': false,
          '   ': false,
          'p=40': false,
          'x+y=20': false,
          'rate x+y=20': false, // keyword present but solve() cannot do it
          'max x+y=abc': false, // no numeric S
          'rect P = -5 max area': false, // P must be > 0
          'rect step=40 max area': false, // no bounded p=
          'rect shape=40 max area': false, // no bounded p=
          'ladder rate': false, // ladder not implemented -> solve errors
          'ladder L=10 rate': false,
          'ladder L = 10, x = 6, dx/dt = 2': false,
          'sphere r = 0, dr/dt = 1': false, // r must be > 0
          'sphere r = 3, dr/dt = x': false, // no numeric dr
          'sphere r = 3': false, // missing dr
        };
        for (final entry in expected.entries) {
          final eq = RelatedRatesEquation(entry.key);
          final valid = eq.validate();
          final err = eq.solve().hasError;
          expect(valid, entry.value, reason: entry.key);
          expect(
            valid,
            !err,
            reason: 'validate() must equal !solve().hasError for ${entry.key}',
          );
        }
      },
    );
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
        final topic = CurriculumRegistry.allTopics().firstWhere(
          (t) => t.id == id,
        );
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
      // C2: the double-angle templates are reachable now, so their TeX lines
      // (previously never emitted) are checked ASCII + parsed.
      TrigIdentityEquation('prove: sin 2x = 2 sin x cos x'),
      TrigIdentityEquation('prove: cos 2x = 1 - 2 sin^2 x'),
      TrigIdentityEquation('prove: cos 2x = cos^2 x - sin^2 x'),
      TrigIdentityEquation('prove: cos 2x = 2 cos^2 x - 1'),
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
            expect(
              tex.codeUnits.every((c) => c >= 0x20 && c <= 0x7e),
              isTrue,
              reason: '$tex (${s.title})',
            );
            checked++;
          }
        }
      }
      expect(checked, greaterThan(0));
    });

    testWidgets('every emitted wave2 TeX line parses (recording fallback)', (
      tester,
    ) async {
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
