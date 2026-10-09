// SHS wave 3 tests (Cycle 8 P1-2): all 10 registry specs resolve and
// solve their hint example; garbage never throws.
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/topics/shs/solvers/shs_solver_registry.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Render [tex] with a recording `onErrorFallback`; assert it was NOT invoked,
/// i.e. the TeX parsed (Phase-B technique for the LaTeX waves).
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
  group('ShsSolverRegistry wiring', () {
    test('10 specs, unique ids, byId round-trip', () {
      expect(ShsSolverRegistry.specs, hasLength(10));
      final ids = ShsSolverRegistry.specs.map((s) => s.id).toList();
      expect(ids.toSet(), hasLength(10));
      for (final s in ShsSolverRegistry.specs) {
        expect(ShsSolverRegistry.byId(s.id), isNotNull);
      }
      expect(ShsSolverRegistry.byId('nope'), isNull);
    });

    test('each spec creates a working equation', () {
      const inputs = {
        'g9-trig-ratios': 'sin 30',
        'g11-logarithms': '2^x = 32',
        'g11-interest': 'P = 10000, r = 5%, t = 2, compound',
        'g11-inverse-functions': 'f(x) = 2x + 3',
        'g11-rational-inequality': '(x - 1)/(x + 2) > 0',
        'g11-trig-equations': 'sin x = 1/2',
        'g11-trig-identities': 'prove: sin^2 + cos^2 = 1',
        'g12-definite-integral': 'def a = 0, b = 2, f = x^2',
        'g12-optimization': 'max xy, x + y = 20',
        'college-lhopital': 'lim x->0 sin(x)/x',
      };
      for (final spec in ShsSolverRegistry.specs) {
        final eq = spec.create(inputs[spec.id]!);
        expect(eq.validate(), isTrue, reason: spec.id);
        final r = eq.solve();
        expect(r.hasError, isFalse, reason: spec.id);
        expect(eq.getSteps(), isNotEmpty, reason: spec.id);
      }
    });

    test('sin x = 1/2 solves on [0, 2pi)', () {
      final r = ShsSolverRegistry.byId('g11-trig-equations')!
          .create('sin x = 1/2')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.points, isNotEmpty);
    });

    test('lhopital lim x->0 sin(x)/x = 1', () {
      final r = ShsSolverRegistry.byId('college-lhopital')!
          .create('lim x->0 sin(x)/x')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('1'));
    });

    test('garbage never throws, empty fails validation', () {
      for (final spec in ShsSolverRegistry.specs) {
        final bad = spec.create('hello world');
        expect(() => bad.solve(), returnsNormally);
        expect(() => bad.getSteps(), returnsNormally);
        expect(spec.create('   ').validate(), isFalse);
      }
    });
  });

  group('SHS registry LaTeX coverage', () {
    const inputs = {
      'g9-trig-ratios': 'sin 30',
      'g11-logarithms': '2^x = 32',
      'g11-interest': 'P = 10000, r = 5%, t = 2, compound',
      'g11-inverse-functions': 'f(x) = 2x + 3',
      'g11-rational-inequality': '(x - 1)/(x + 2) > 0',
      'g11-trig-equations': 'sin x = 1/2',
      'g11-trig-identities': 'prove: sin^2 + cos^2 = 1',
      'g12-definite-integral': 'def a = 0, b = 2, f = x^2',
      'g12-optimization': 'max xy, x + y = 20',
      'college-lhopital': 'lim x->0 sin(x)/x',
    };

    test('every solver emits LaTeX steps; all ASCII', () {
      var withTex = 0;
      var checked = 0;
      for (final spec in ShsSolverRegistry.specs) {
        final steps = spec.create(inputs[spec.id]!).getSteps();
        final texes = <String>[
          for (final s in steps)
            for (final t in <String?>[s.latex, ...?s.subLatex])
              if (t != null) t
        ];
        expect(texes, isNotEmpty, reason: spec.id);
        withTex++;
        for (final t in texes) {
          expect(t.codeUnits.every((c) => c >= 0x20 && c <= 0x7e), isTrue,
              reason: '${spec.id}: $t');
          checked++;
        }
      }
      expect(withTex, ShsSolverRegistry.specs.length);
      expect(checked, greaterThan(0));
    });

    testWidgets('all SHS hint-example TeX parses (recording fallback)',
        (tester) async {
      final cases = <BaseEquation>[
        for (final spec in ShsSolverRegistry.specs)
          spec.create(inputs[spec.id]!),
      ];
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
