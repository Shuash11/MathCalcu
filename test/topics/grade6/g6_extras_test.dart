// G6 extras tests (Cycle 8 P2-1): GCF/LCM + Rate reachable via the
// backend registry (barrel already exports both engines).
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_extras_registry.dart';
import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Render [tex] with an explicit recording `onErrorFallback` and assert it was
/// NOT invoked, i.e. the TeX parses (Phase B technique for the LaTeX waves).
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
  group('G6ExtrasRegistry wiring', () {
    test('2 specs, byId round-trip', () {
      expect(G6ExtrasRegistry.specs, hasLength(2));
      expect(G6ExtrasRegistry.byId('g6-gcf-lcm'), isNotNull);
      expect(G6ExtrasRegistry.byId('g6-rate'), isNotNull);
      expect(G6ExtrasRegistry.byId('nope'), isNull);
    });

    test('GCF(12, 18) = 6 via registry', () {
      final eq = G6ExtrasRegistry.byId('g6-gcf-lcm')!.create('GCF(12, 18)');
      expect(eq, isA<G6GcfLcmEquation>());
      expect(eq.validate(), isTrue);
      expect(eq.solve().answer, contains('6'));
      expect(eq.getSteps(), hasLength(4));
    });

    test('LCM(4, 6) = 12 via registry', () {
      final r = G6ExtrasRegistry.byId('g6-gcf-lcm')!.create('lcm 4 6').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('12'));
    });

    test('R=? D=120 T=2 gives 60 via registry', () {
      final eq = G6ExtrasRegistry.byId('g6-rate')!.create('R=? D=120 T=2');
      expect(eq, isA<G6RateEquation>());
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('60'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('best-buy compare picks cheaper offer', () {
      final r = G6ExtrasRegistry.byId('g6-rate')!
          .create('compare 500g 120 vs 1kg 220')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('cheaper'));
    });

    test('meter reading bills use x rate', () {
      final r = G6ExtrasRegistry.byId('g6-rate')!
          .create('prev=1250 pres=1380 rate=12')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('130'));
    });

    test('garbage never throws', () {
      for (final spec in G6ExtrasRegistry.specs) {
        final bad = spec.create('hello world');
        expect(() => bad.solve(), returnsNormally);
        expect(() => bad.getSteps(), returnsNormally);
        expect(spec.create('   ').validate(), isFalse);
      }
    });
  });

  group('G6 extras LaTeX emission (Batch 2)', () {
    test('registry gcf/lcm + rate solvers emit non-null ASCII TeX', () {
      final gcf = G6ExtrasRegistry.byId('g6-gcf-lcm')!
          .create('GCF(12, 18)')
          .getSteps();
      expect(gcf, hasLength(4));
      for (final s in gcf) {
        expect(s.latex, isNotNull, reason: s.title);
      }
      final rate = G6ExtrasRegistry.byId('g6-rate')!
          .create('R=? D=120 T=2')
          .getSteps();
      expect(rate, hasLength(3));
      for (final s in rate) {
        expect(s.latex, isNotNull, reason: s.title);
        expect(s.latex!.codeUnits.every((c) => c >= 0x20 && c <= 0x7e), isTrue,
            reason: s.latex!);
      }
    });

    testWidgets('extras registry TeX parses (recording fallback)',
        (tester) async {
      final cases = <BaseEquation>[
        G6ExtrasRegistry.byId('g6-gcf-lcm')!.create('GCF(12, 18)'),
        G6ExtrasRegistry.byId('g6-gcf-lcm')!.create('lcm 4 6'),
        G6ExtrasRegistry.byId('g6-rate')!.create('R=? D=120 T=2'),
        G6ExtrasRegistry.byId('g6-rate')!.create('compare 500g 120 vs 1kg 220'),
        G6ExtrasRegistry.byId('g6-rate')!.create('prev=1250 pres=1380 rate=12'),
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
