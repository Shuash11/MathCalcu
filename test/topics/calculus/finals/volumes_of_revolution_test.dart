// Cycle 12 Item 5: Volumes of Revolution — solver engine tests
// (disk / washer / shell closed forms, clean errors on invalid
// input) plus a wiring test that the registry entry resolves to
// its thin solver screen (mirrors the cycle-11/12 wiring pattern).
import 'dart:math' as math;

import 'package:calculus_system/app_router.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/calculus/finals/finals_module_registry.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/volumes_of_revolution/volumes_of_revolution_equation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

VolumesOfRevolutionEquation eq(String input) =>
    VolumesOfRevolutionEquation(input);

void main() {
  group('VolumesOfRevolutionEquation — disk method', () {
    test('x^2 about x-axis from 0 to 1 → π/5 (V = π∫f² dx)', () {
      final r = eq('volume x^2 about x-axis from 0 to 1').solve();
      expect(r.hasError, isFalse);
      final volume = r.customData!.first['volume'] as double;
      // V = π ∫[0,1] f(x)² dx = π ∫[0,1] x⁴ dx = π/5.
      // (The audit's example value π/3 corresponds to π∫x² dx — the
      // disk method squares the radius function f, so π/5 is the
      // correct closed form for f(x) = x².)
      expect(volume, closeTo(math.pi / 5, 1e-6));
      expect(r.answer, contains('π/5'));
      expect(r.answer, contains('0.6283'));
    });

    test('sqrt(x) about x-axis from 0 to 1 → π/2', () {
      final r = eq('volume sqrt(x) about x-axis from 0 to 1').solve();
      expect(r.hasError, isFalse);
      final volume = r.customData!.first['volume'] as double;
      // V = π ∫[0,1] (√x)² dx = π ∫[0,1] x dx = π/2.
      expect(volume, closeTo(math.pi / 2, 1e-6));
    });

    test('accepts "the x-axis" and "x axis" spellings', () {
      final r1 = eq('volume x^2 about the x-axis from 0 to 1').solve();
      final r2 = eq('volume x^2 about x axis from 0 to 1').solve();
      expect(r1.hasError, isFalse);
      expect(r2.hasError, isFalse);
      expect(
        (r1.customData!.first['volume'] as double),
        closeTo(math.pi / 5, 1e-6),
      );
      expect(
        (r2.customData!.first['volume'] as double),
        closeTo(math.pi / 5, 1e-6),
      );
    });

    test('disk steps cover setup, substitution, evaluation, result', () {
      final e = eq('volume x^2 about x-axis from 0 to 1');
      final steps = e.getSteps();
      expect(steps.length, 4);
      expect(steps[0].title, 'Identify the method');
      expect(steps[0].explanation, contains('disk'));
      expect(steps[1].title, 'Substitute');
      expect(steps[1].explanation, contains('x^2'));
      expect(steps[2].title, 'Evaluate numerically (Simpson)');
      expect(steps[3].title, 'Final answer');
      expect(steps[3].explanation, contains('π'));
    });
  });

  group('VolumesOfRevolutionEquation — washer method', () {
    test('washer x x^2 about x-axis from 0 to 1 → 2π/15', () {
      final r = eq('volume washer x x^2 about x-axis from 0 to 1').solve();
      expect(r.hasError, isFalse);
      final volume = r.customData!.first['volume'] as double;
      // V = π ∫[0,1] (x² − x⁴) dx = π(1/3 − 1/5) = 2π/15.
      expect(volume, closeTo(2 * math.pi / 15, 1e-6));
      expect(r.answer, contains('2π/15'));
      expect(r.customData!.first['g'], 'x^2');
    });

    test('washer steps mention outer and inner radii', () {
      final steps =
          eq('volume washer x x^2 about x-axis from 0 to 1').getSteps();
      expect(steps.length, 4);
      expect(steps[0].explanation, contains('outer'));
      expect(steps[0].explanation, contains('inner'));
      expect(steps[1].explanation, contains('x^2'));
    });
  });

  group('VolumesOfRevolutionEquation — shell method', () {
    test('shell y about y-axis from 0 to 1 → 2π/3', () {
      final r = eq('volume shell y about y-axis from 0 to 1').solve();
      expect(r.hasError, isFalse);
      final volume = r.customData!.first['volume'] as double;
      // V = 2π ∫[0,1] y·y dy = 2π/3.
      expect(volume, closeTo(2 * math.pi / 3, 1e-6));
      expect(r.answer, contains('2π/3'));
      expect(r.answer, contains('2.0944'));
    });

    test('shell 2y about y-axis from 0 to 2 → 32π/3', () {
      final r = eq('volume shell 2y about y-axis from 0 to 2').solve();
      expect(r.hasError, isFalse);
      final volume = r.customData!.first['volume'] as double;
      // V = 2π ∫[0,2] 2y² dy = 2π·16/3 = 32π/3.
      expect(volume, closeTo(32 * math.pi / 3, 1e-6));
    });

    test('shell steps cover setup, substitution, evaluation, result', () {
      final steps = eq('volume shell y about y-axis from 0 to 1').getSteps();
      expect(steps.length, 4);
      expect(steps[0].explanation, contains('y-axis'));
      expect(steps[1].explanation, contains('2π'));
      expect(steps[2].explanation, contains('2π'));
      expect(steps[3].explanation, contains('π'));
    });
  });

  group('VolumesOfRevolutionEquation — clean errors', () {
    test('a ≥ b is rejected', () {
      final r = eq('volume x^2 about x-axis from 1 to 0').solve();
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('less than b'));
    });

    test('negative disk radius is rejected', () {
      final r = eq('volume -x^2 about x-axis from 0 to 1').solve();
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('radius cannot be negative'));
    });

    test('outer ≤ inner washer is rejected', () {
      final r = eq('volume washer x^2 x about x-axis from 0 to 1').solve();
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('outer radius'));
    });

    test('negative shell lower limit is rejected', () {
      final r = eq('volume shell y about y-axis from -1 to 1').solve();
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('non-negative'));
    });

    test('unparseable input returns the format guide', () {
      final r = eq('volume of a sphere radius 3').solve();
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('Formats:'));
    });

    test('empty input is rejected', () {
      final r = eq('').solve();
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('Enter a volume'));
    });
  });

  group('Volumes of Revolution — wiring', () {
    testWidgets('registry route renders its screen', (tester) async {
      final entry = FinalsModuleRegistry.modules
          .singleWhere((m) => m.label == 'Volumes of Revolution');
      expect(entry.route, '/topics/calculus/finals/volumes');

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: ThemeProvider(),
          child: MaterialApp.router(routerConfig: AppRouter.router),
        ),
      );
      AppRouter.router.go(entry.route);
      await tester.pumpAndSettle();
      expect(find.text('Volumes of Revolution'), findsWidgets);
      expect(find.text('Topic coming soon'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
