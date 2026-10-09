// Quadratics wave tests (Cycle 8 P1-2): registry wiring + solve smoke.
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/topics/quadratics/solvers/polynomial_division_equation.dart';
import 'package:calculus_system/topics/quadratics/solvers/quadratic_equation.dart';
import 'package:calculus_system/topics/quadratics/solvers/quadratics_solver_registry.dart';
import 'package:calculus_system/topics/quadratics/solvers/radical_equation.dart';
import 'package:calculus_system/topics/quadratics/solvers/sequence_equation.dart';
import 'package:calculus_system/topics/quadratics/solvers/variation_equation.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Render [tex] with a recording `onErrorFallback`; true when it parsed.
Future<bool> _parses(WidgetTester tester, String tex) async {
  var fellBack = false;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Math.tex(
          tex,
          onErrorFallback: (e) {
            fellBack = true;
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  await tester.pump();
  return !fellBack;
}

void main() {
  group('QuadraticsSolverRegistry wiring', () {
    test('5 specs, unique ids, byId round-trip', () {
      expect(QuadraticsSolverRegistry.specs, hasLength(5));
      final ids = QuadraticsSolverRegistry.specs.map((s) => s.id).toList();
      expect(ids.toSet(), hasLength(5));
      for (final s in QuadraticsSolverRegistry.specs) {
        expect(QuadraticsSolverRegistry.byId(s.id), isNotNull);
      }
      expect(QuadraticsSolverRegistry.byId('nope'), isNull);
    });

    test('each spec creates a working equation', () {
      const inputs = {
        'g9-quadratic-formula': 'x^2 - 5x + 6 = 0',
        'g9-radical-equations': 'sqrt(x + 5) = 3',
        'g9-variation': 'direct, x = 2, y = 10, x = 5',
        'g10-sequences': 'arith a1 = 2, d = 3, n = 5',
        'g10-polynomial-division': '(x^3 + 2x^2 - 5x + 1)/(x - 1)',
      };
      for (final spec in QuadraticsSolverRegistry.specs) {
        final eq = spec.create(inputs[spec.id]!);
        expect(eq.validate(), isTrue, reason: spec.id);
        final r = eq.solve();
        expect(r.hasError, isFalse, reason: spec.id);
        expect(eq.getSteps(), isNotEmpty, reason: spec.id);
      }
    });

    test('x^2 - 5x + 6 = 0 gives roots 2 and 3', () {
      final r = QuadraticsSolverRegistry.byId('g9-quadratic-formula')!
          .create('x^2 - 5x + 6 = 0')
          .solve();
      expect(r.answer, contains('2'));
      expect(r.answer, contains('3'));
    });

    test('sqrt(x + 5) = 3 gives x = 4', () {
      final r = QuadraticsSolverRegistry.byId('g9-radical-equations')!
          .create('sqrt(x + 5) = 3')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('4'));
    });

    test('arith a1=2 d=3 n=5 gives a(5)=14 S(5)=40', () {
      final r = QuadraticsSolverRegistry.byId('g10-sequences')!
          .create('arith a1 = 2, d = 3, n = 5')
          .solve();
      expect(r.answer, contains('14'));
      expect(r.answer, contains('40'));
    });

    test('garbage never throws, empty fails validation', () {
      for (final spec in QuadraticsSolverRegistry.specs) {
        final bad = spec.create('hello world');
        expect(() => bad.solve(), returnsNormally);
        expect(() => bad.getSteps(), returnsNormally);
        expect(spec.create('   ').validate(), isFalse);
      }
    });
  });

  group('Quadratics LaTeX coverage', () {
    List<String> texOf(BaseEquation eq) => [
          for (final s in eq.getSteps())
            if (s.latex != null) s.latex!,
          for (final s in eq.getSteps()) ...?s.subLatex,
        ];

    test('per-solver math steps carry real-value TeX; prose stays null', () {
      final v = VariationEquation('direct, x = 2, y = 10, x = 5').getSteps();
      expect(v, hasLength(3));
      expect(v[0].latex, 'y = kx');
      expect(v[1].latex, 'k = \\frac{y}{x} = 5');
      expect(v[1].subLatex, ['y = 25\\ \\text{when}\\ x = 5']);
      expect(v[2].latex, isNull); // 'Predict new values' guidance -> prose

      final a = SequenceEquation('arith a1 = 2, d = 3, n = 5').getSteps();
      expect(a, hasLength(3));
      expect(a[0].latex, 'a_{n} = a_{1} + (n - 1)d');
      expect(a[0].subLatex, ['S_{n} = \\frac{n}{2}(2a_{1} + (n - 1)d)']);
      expect(a[1].latex, 'a_{5} = 2 + (5 - 1)(3)');
      expect(a[2].latex, 'a_{5} = 14');
      expect(a[2].subLatex, ['S_{5} = 40']);

      final g = SequenceEquation('geom a1 = 3, r = 2, n = 4').getSteps();
      expect(g[0].latex, 'a_{n} = a_{1} r^{n-1}');
      expect(g[1].latex, 'a_{4} = 3 \\cdot 2^{3}');
      expect(g[2].latex, 'a_{4} = 24');
      expect(g[2].subLatex, ['S_{4} = 45']);

      final r1 = RadicalEquation('sqrt(x + 5) = 3').getSteps();
      expect(r1, hasLength(4));
      expect(r1[0].latex, 'x+5 \\ge 0 \\implies x \\ge -5');
      expect(r1[1].latex, '\\sqrt{x+5} = 3 - 0 = 3');
      expect(r1[2].latex, isNull); // 'Square both sides' rule -> prose
      expect(r1[3].latex, 'x = 4');

      final r2 = RadicalEquation('sqrt(x+5)=x').getSteps();
      expect(r2, hasLength(4));
      expect(r2[1].latex, '\\sqrt{x+5} = x');
      expect(r2[2].latex, 'x^{2} - x - 5 = 0');
      expect(r2[3].latex, startsWith('x = '));

      final q = QuadraticEquation('x^2 - 5x + 6 = 0').getSteps();
      expect(q, hasLength(4));
      expect(q[0].latex, 'a = 1,\\quad b = -5,\\quad c = 6');
      expect(q[1].latex, '\\Delta = b^{2} - 4ac = 1');
      expect(q[2].latex, 'x = \\frac{-b \\pm \\sqrt{\\Delta}}{2a}');
      expect(q[3].latex, 'x_{1} = 2,\\quad x_{2} = 3');

      final qn = QuadraticEquation('x^2 + 1 = 0').getSteps();
      expect(qn[3].latex, '\\Delta = -4 < 0 \\implies \\text{no real roots}');

      final p =
          PolyDivisionEquation('(x^3 + 2x^2 - 5x + 1)/(x - 1)').getSteps();
      expect(p, hasLength(4));
      expect(p[0].latex, isNull); // synthetic-division guidance -> prose
      expect(p[1].latex, isNull); // bring-down/multiply guidance -> prose
      expect(p[2].latex, 'x^{2} + 3x - 2');
      expect(p[2].subLatex, ['R = -1']);
      expect(p[3].latex, isNull); // remainder-theorem rule -> prose
    });

    test('every emitted line is non-empty ASCII; guard counts', () {
      final inputs = <BaseEquation>[
        VariationEquation('direct, x = 2, y = 10, x = 5'),
        VariationEquation('inverse, x = 2, y = 10, x = 5'),
        VariationEquation('joint x = 2, y = 3, z = 24'),
        SequenceEquation('arith a1 = 2, d = 3, n = 5'),
        SequenceEquation('geom a1 = 3, r = 2, n = 4'),
        RadicalEquation('sqrt(x + 5) = 3'),
        RadicalEquation('sqrt(x + 5) - 1 = 2'),
        RadicalEquation('sqrt(x+5)=x'),
        RadicalEquation('sqrt(x+6)=x'),
        QuadraticEquation('x^2 - 5x + 6 = 0'),
        QuadraticEquation('x^2 + 1 = 0'),
        QuadraticEquation('x^2 - 2x + 1 = 0'),
        PolyDivisionEquation('(x^3 + 2x^2 - 5x + 1)/(x - 1)'),
        PolyDivisionEquation('(x^2 - 1)/(x - 1)'),
      ];
      var checked = 0;
      for (final eq in inputs) {
        for (final t in texOf(eq)) {
          expect(t, isNotEmpty);
          expect(t.codeUnits.every((c) => c >= 0x20 && c <= 0x7e), isTrue,
              reason: 'non-ASCII TeX: $t');
          checked++;
        }
      }
      expect(checked, greaterThan(0));
    });

    testWidgets('all quadratics TeX parses; malformed TeX fires fallback',
        (tester) async {
      final inputs = <BaseEquation>[
        VariationEquation('direct, x = 2, y = 10, x = 5'),
        VariationEquation('inverse, x = 2, y = 10, x = 5'),
        VariationEquation('joint x = 2, y = 3, z = 24'),
        SequenceEquation('arith a1 = 2, d = 3, n = 5'),
        SequenceEquation('geom a1 = 3, r = 2, n = 4'),
        RadicalEquation('sqrt(x + 5) = 3'),
        RadicalEquation('sqrt(x + 5) - 1 = 2'),
        RadicalEquation('sqrt(x+5)=x'),
        RadicalEquation('sqrt(x+6)=x'),
        QuadraticEquation('x^2 - 5x + 6 = 0'),
        QuadraticEquation('x^2 + 1 = 0'),
        QuadraticEquation('x^2 - 2x + 1 = 0'),
        PolyDivisionEquation('(x^3 + 2x^2 - 5x + 1)/(x - 1)'),
        PolyDivisionEquation('(x^2 - 1)/(x - 1)'),
      ];
      var checked = 0;
      for (final eq in inputs) {
        for (final t in texOf(eq)) {
          expect(await _parses(tester, t), isTrue, reason: 'unparsed TeX: $t');
          checked++;
        }
      }
      expect(checked, greaterThan(0));
      // Guard: a deliberately-malformed string MUST fire the fallback.
      expect(await _parses(tester, '\\frac{1}{'), isFalse);
    });
  });
}
