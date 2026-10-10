// Algebra wave tests (Cycle 8 P1-2): every registry spec resolves,
// validates its hint example, solves without throwing, and emits steps.
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/topics/algebra/solvers/algebra_solver_registry.dart';
import 'package:calculus_system/topics/algebra/solvers/factoring_equation.dart';
import 'package:calculus_system/topics/algebra/solvers/linear_equation.dart';
import 'package:calculus_system/topics/algebra/solvers/rational_equation.dart';
import 'package:calculus_system/topics/algebra/solvers/system_2x2_equation.dart';
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

/// Evaluate a factored answer like '-(x+3)(x-3)' or '-2(x+2)(x-2)' at [x].
double _evalFactored(String s, double x) {
  final idx = s.indexOf('(');
  final leadStr = s.substring(0, idx);
  final lead = leadStr == '-'
      ? -1.0
      : (leadStr.isEmpty ? 1.0 : double.parse(leadStr));
  var prod = lead;
  for (final m in RegExp(r'\(([^)]*)\)').allMatches(s)) {
    prod *= _evalLinear(m.group(1)!, x);
  }
  return prod;
}

/// Evaluate a linear factor body like 'x+3' or '2x-3' at [x].
double _evalLinear(String s, double x) {
  s = s.replaceAll(' ', '');
  var coef = 0.0, k = 0.0;
  for (final m in RegExp(r'([+-]?)(\d*)(x?)').allMatches(s)) {
    if (m.group(2)!.isEmpty && m.group(3)!.isEmpty) continue;
    final sign = m.group(1) == '-' ? -1.0 : 1.0;
    final dg = m.group(2)!;
    if (m.group(3) == 'x') {
      coef += sign * (dg.isEmpty ? 1 : double.parse(dg));
    } else {
      k += sign * double.parse(dg);
    }
  }
  return coef * x + k;
}

/// Evaluate the input polynomial 'ax^2+bx+c' (with signed terms) at [x].
double _evalPoly(String input, double x) {
  final e = input
      .replaceAll('×', '*')
      .replaceAll('−', '-')
      .replaceAll(' ', '')
      .replaceAll('X', 'x')
      .replaceAll('*', '');
  double a = 0, b = 0, c = 0;
  final s = e.startsWith('-') ? e : '+$e';
  for (final m in RegExp(r'[+-][^+-]+').allMatches(s)) {
    final t = m.group(0)!;
    final sign = t.startsWith('-') ? -1.0 : 1.0;
    final body = t.substring(1);
    if (body.contains('x^2')) {
      final co = body.replaceAll('x^2', '');
      a += sign * (co.isEmpty ? 1 : double.parse(co));
    } else if (body.contains('x')) {
      final co = body.replaceAll('x', '');
      b += sign * (co.isEmpty ? 1 : double.parse(co));
    } else {
      c += sign * double.parse(body);
    }
  }
  return a * x * x + b * x + c;
}

void main() {
  group('AlgebraSolverRegistry wiring', () {
    test('4 specs, unique ids, byId round-trip', () {
      expect(AlgebraSolverRegistry.specs, hasLength(4));
      final ids = AlgebraSolverRegistry.specs.map((s) => s.id).toList();
      expect(ids.toSet(), hasLength(4));
      for (final s in AlgebraSolverRegistry.specs) {
        expect(AlgebraSolverRegistry.byId(s.id), isNotNull);
      }
      expect(AlgebraSolverRegistry.byId('nope'), isNull);
    });

    test('each spec creates a working equation', () {
      const inputs = {
        'g7-linear-equations': '2x - 5 = 9',
        'g8-factoring': 'x^2 + 5x + 6',
        'g8-rational-equations': '1/x + 1/2 = 3/4',
        'g8-systems': 'x + y = 5, x - y = 1',
      };
      for (final spec in AlgebraSolverRegistry.specs) {
        final eq = spec.create(inputs[spec.id]!);
        expect(eq.validate(), isTrue, reason: spec.id);
        final r = eq.solve();
        expect(r.hasError, isFalse, reason: spec.id);
        expect(eq.getSteps(), isNotEmpty, reason: spec.id);
      }
    });

    test('2x - 5 = 9 gives x = 7', () {
      final eq = AlgebraSolverRegistry.byId('g7-linear-equations')!
          .create('2x - 5 = 9');
      expect(eq.solve().answer, contains('7'));
    });

    test('x^2 + 5x + 6 factors to (x+2)(x+3)', () {
      final r = AlgebraSolverRegistry.byId('g8-factoring')!
          .create('x^2 + 5x + 6')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('(x+2)(x+3)'));
    });

    test('system x+y=5, x-y=1 gives (3, 2)', () {
      final r = AlgebraSolverRegistry.byId('g8-systems')!
          .create('x + y = 5, x - y = 1')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('3'));
      expect(r.answer, contains('2'));
    });

    test('1/x + 1/2 = 3/4 gives x = 4 (fractional RHS)', () {
      final r = AlgebraSolverRegistry.byId('g8-rational-equations')!
          .create('1/x + 1/2 = 3/4')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('4'));
    });

    test('garbage never throws, empty fails validation', () {
      for (final spec in AlgebraSolverRegistry.specs) {
        final bad = spec.create('hello world');
        expect(() => bad.solve(), returnsNormally);
        expect(() => bad.getSteps(), returnsNormally);
        expect(spec.create('   ').validate(), isFalse);
      }
    });
  });

  group('Factoring sign fix (BUG B: dropped leading minus / negative GCF)', () {
    // Locks down BUG B: with a reduced leading coefficient a<0 the solver
    // dropped the leading minus (the DOTS branch emitted (x+p)(x-p) regardless
    // of sign) and mis-divided the negative GCF, so '-x^2 + 9' came out as
    // (x+3)(x-3) (which expands to x^2-9) and '-2x^2 + 8' errored out as
    // "Not factorable over integers" instead of giving -2(x+2)(x-2).
    test('-x^2 + 9 factors to -(x+3)(x-3)', () {
      final r = FactoringEquation('-x^2 + 9').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, '-(x+3)(x-3)');
    });

    test('9 - x^2 factors to -(x+3)(x-3)', () {
      final r = FactoringEquation('9 - x^2').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, '-(x+3)(x-3)');
    });

    test('-2x^2 + 8 factors to -2(x+2)(x-2)', () {
      final r = FactoringEquation('-2x^2 + 8').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, '-2(x+2)(x-2)');
    });

    test('expansion guard: answer re-evaluates to the input polynomial', () {
      // Numeric guard independent of the exact string form.
      const cases = <String, String>{
        '-x^2 + 9': '-(x+3)(x-3)',
        '9 - x^2': '-(x+3)(x-3)',
        '-2x^2 + 8': '-2(x+2)(x-2)',
        'x^2 - 9': '(x+3)(x-3)',
        '2x^2 - 8': '2(x+2)(x-2)',
        'x^2 + 5x + 6': '(x+2)(x+3)',
      };
      for (final e in cases.entries) {
        final r = FactoringEquation(e.key).solve();
        expect(r.hasError, isFalse, reason: e.key);
        expect(r.answer, e.value, reason: e.key);
        for (final x in <double>[-2.0, 0.0, 1.5, 3.0]) {
          expect(
            _evalFactored(r.answer, x),
            closeTo(_evalPoly(e.key, x), 1e-9),
            reason: '${e.key} @ x=$x (answer ${r.answer})',
          );
        }
      }
    });

    test('regressions: monic, positive-GCF, trinomial and a GCF case', () {
      expect(FactoringEquation('x^2 - 9').solve().answer, '(x+3)(x-3)');
      expect(FactoringEquation('2x^2 - 8').solve().answer, '2(x+2)(x-2)');
      expect(FactoringEquation('x^2 + 5x + 6').solve().answer, '(x+2)(x+3)');
      final gcf = FactoringEquation('2x^2 + 4x').solve();
      expect(gcf.hasError, isFalse);
      expect(gcf.answer, startsWith('2('));
    });

    testWidgets('step-3 factor TeX equals the answer; parses; ASCII', (
      tester,
    ) async {
      for (final input in <String>[
        '-x^2 + 9',
        '9 - x^2',
        '-2x^2 + 8',
        '2x^2 - 8',
        'x^2 + 5x + 6',
      ]) {
        final r = FactoringEquation(input).solve();
        final steps = FactoringEquation(input).getSteps();
        expect(steps[2].latex, r.answer, reason: input);
        final tex = steps[2].latex!;
        expect(
          tex.codeUnits.every((c) => c >= 0x20 && c <= 0x7e),
          isTrue,
          reason: 'non-ASCII TeX: $tex',
        );
        expect(await _parses(tester, tex), isTrue, reason: input);
      }
    });
  });

  group('Algebra LaTeX coverage', () {
    List<String> texOf(BaseEquation eq) => [
      for (final s in eq.getSteps())
        if (s.latex != null) s.latex!,
      for (final s in eq.getSteps()) ...?s.subLatex,
    ];

    test('per-solver math steps carry real-value TeX; prose stays null', () {
      final lin = LinearOneVarEquation('2x - 5 = 9').getSteps();
      expect(lin, hasLength(4));
      expect(lin[0].latex, isNull); // move-terms guidance -> prose
      expect(lin[1].latex, '2x = 14');
      expect(lin[2].latex, 'x = \\frac{14}{2} = 7');
      expect(lin[3].latex, isNull); // 'Check' guidance -> prose

      final fac = FactoringEquation('x^2 + 5x + 6').getSteps();
      expect(fac, hasLength(4));
      expect(fac[0].latex, isNull); // GCF guidance -> prose
      expect(fac[1].latex, isNull); // 'find two numbers' guidance -> prose
      expect(fac[2].latex, '(x+2)(x+3)');
      expect(fac[3].latex, isNull); // FOIL check guidance -> prose

      final dot = FactoringEquation('x^2 - 9').getSteps();
      expect(dot[1].title, 'Difference of squares');
      expect(dot[1].latex, 'a^{2} - b^{2} = (a + b)(a - b)');
      expect(dot[2].latex, '(x+3)(x-3)');

      final rat = RationalEquation('1/x + 1/2 = 3/4').getSteps();
      expect(rat, hasLength(4));
      expect(rat[0].latex, 'x \\neq 0');
      expect(rat[1].latex, isNull); // 'clear denominators' description -> prose
      expect(rat[2].latex, 'x = 4');
      expect(rat[3].latex, isNull); // extraneous-check guidance -> prose

      final sys = System2x2Equation('x + y = 5, x - y = 1').getSteps();
      expect(sys, hasLength(4));
      expect(sys[0].latex, '\\begin{pmatrix} 1 & 1 \\\\ 1 & -1 \\end{pmatrix}');
      expect(sys[0].subLatex, ['\\begin{pmatrix} 5 \\\\ 1 \\end{pmatrix}']);
      expect(sys[1].latex, isNull); // 'eliminate' guidance -> prose
      expect(sys[2].latex, '(x, y) = (3, 2)');
      expect(sys[3].latex, isNull); // 'check by substitution' guidance -> prose
    });

    test('every emitted line is non-empty ASCII; guard counts', () {
      final inputs = <BaseEquation>[
        LinearOneVarEquation('2x - 5 = 9'),
        LinearOneVarEquation('3(x+2) = 15'),
        FactoringEquation('x^2 + 5x + 6'),
        FactoringEquation('x^2 - 9'),
        FactoringEquation('2x^2 - 8'),
        RationalEquation('1/x + 1/2 = 3/4'),
        RationalEquation('2/(x-1) = 4'),
        RationalEquation('3/(x+1) = 6/(x+2)'),
        System2x2Equation('x + y = 5, x - y = 1'),
        System2x2Equation('2x + 3y = 12, x - y = 1'),
      ];
      var checked = 0;
      for (final eq in inputs) {
        for (final t in texOf(eq)) {
          expect(t, isNotEmpty);
          expect(
            t.codeUnits.every((c) => c >= 0x20 && c <= 0x7e),
            isTrue,
            reason: 'non-ASCII TeX: $t',
          );
          checked++;
        }
      }
      expect(checked, greaterThan(0));
    });

    testWidgets('all algebra TeX parses; malformed TeX fires fallback', (
      tester,
    ) async {
      final inputs = <BaseEquation>[
        LinearOneVarEquation('2x - 5 = 9'),
        LinearOneVarEquation('3(x+2) = 15'),
        FactoringEquation('x^2 + 5x + 6'),
        FactoringEquation('x^2 - 9'),
        FactoringEquation('2x^2 - 8'),
        RationalEquation('1/x + 1/2 = 3/4'),
        RationalEquation('2/(x-1) = 4'),
        RationalEquation('3/(x+1) = 6/(x+2)'),
        System2x2Equation('x + y = 5, x - y = 1'),
        System2x2Equation('2x + 3y = 12, x - y = 1'),
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
