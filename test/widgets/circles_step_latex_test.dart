// Regression tests for the CIRCLES step surfaces: the center/radius solvers
// now emit a per-line LaTeX view (`stepsLatex`) alongside the pre-formatted
// `steps` string, and the two monospace step screens render that LaTeX through
// `SelectableMath.tex`.
//
// The parse assertions matter because `SelectableMath` is a StatelessWidget
// that builds its `onErrorFallback` on a parse error — a body that fails to
// parse still counts as a SelectableMath, so a widget-count assertion alone
// cannot catch a parse-failure regression. Every line is parsed with an
// explicit recording `onErrorFallback` (asserted NOT invoked), and the live
// widgets are checked via `SelectableMath.parseException`.
import 'package:calculus_system/topics/calculus/midterm/screens/circles_screen/center/step_section.dart';
import 'package:calculus_system/topics/calculus/midterm/screens/circles_screen/radius/radius_steps.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/circles_solver/center_solver.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/circles_solver/radius_solver.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
  await tester.pump();
}

/// Assert every [SelectableMath] currently in the tree parsed successfully.
/// Must be called before any re-pump.
void _expectAllRenderedMathParsed(WidgetTester tester) {
  final math = tester.widgetList<SelectableMath>(find.byType(SelectableMath));
  expect(math, isNotEmpty);
  for (final m in math) {
    expect(
      m.parseException,
      isNull,
      reason: 'a rendered SelectableMath failed to parse: ${m.parseException}',
    );
  }
}

/// Render [tex] with an explicit recording `onErrorFallback` and assert it was
/// NOT invoked, i.e. the TeX parses. Replaces the current widget tree.
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

List<String> _nonEmpty(List<String> lines) =>
    lines.where((l) => l.trim().isNotEmpty).toList();

Finder get _monospaceText => find.byWidgetPredicate(
      (w) => w is Text && w.style?.fontFamily == 'monospace',
    );

void main() {
  group('CenterResult stepsLatex (per-line TeX alongside steps)', () {
    test('steps string preserved; stepsLatex mirrors it line-for-line', () {
      final r = CenterSolver.computeExact(x1: '1', y1: '2', x2: '3', y2: '4')!;
      // The pre-formatted string (other consumers) is untouched.
      expect(r.steps, contains('Midpoint Formula: C(h, k)'));
      expect(r.steps.split('\n').length, r.stepsLatex.length);
      final lines = _nonEmpty(r.stepsLatex);
      expect(lines, isNotEmpty);
      expect(lines.first, contains('x_{1}'));
      // k = (2 + 4) / 2 = 3
      expect(lines.last, 'k = 3');
    });

    testWidgets('every non-empty line parses (recording fallback)',
        (tester) async {
      const cases = [
        ['1', '2', '3', '4'],
        ['0', '0', '5', '5'],
        ['1/2', '1', '3/2', '2'],
        ['-3', '4', '7', '-8'],
        ['0', '0', '1', '0'],
      ];
      for (final c in cases) {
        final r = CenterSolver.computeExact(
          x1: c[0],
          y1: c[1],
          x2: c[2],
          y2: c[3],
        )!;
        for (final line in _nonEmpty(r.stepsLatex)) {
          await _expectTexParses(tester, line);
        }
      }
    });
  });

  group('RadiusResult.stepsLatex (per-line TeX alongside steps)', () {
    test('steps string preserved; stepsLatex mirrors the work', () {
      final r = RadiusSolver.solve(x: 1, y: 2, h: 0, k: 0);
      expect(r.steps, isNotEmpty);
      expect(r.stepsLatex, isNotEmpty);
      expect(r.stepsLatex.first, contains('sqrt'));
      // 5 -> prime radicand -> exact radical + decimal approximation.
      expect(r.stepsLatex.last, contains('approx'));
    });

    testWidgets('every line parses across cases (recording fallback)',
        (tester) async {
      final cases = <RadiusResult>[
        RadiusSolver.solve(x: 3, y: 4, h: 0, k: 0), // perfect square -> 5
        RadiusSolver.solve(x: 1, y: 2, h: 0, k: 0), // prime radicand -> sqrt
        RadiusSolver.solve(x: 2, y: 4, h: 0, k: 0), // composite -> coeff sqrt
        RadiusSolver.solve(x: 5, y: -1, h: 2, k: 3), // negatives
        RadiusSolver.solveFromStrings(
          x: '1/2',
          y: '0',
          h: '0',
          k: '0',
        ), // fraction raw
      ];
      for (final r in cases) {
        expect(r.stepsLatex, isNotEmpty);
        for (final line in r.stepsLatex) {
          await _expectTexParses(tester, line);
        }
      }
    });
  });

  group('CenterStepsSection renders LaTeX (not monospace)', () {
    testWidgets('latex path yields parsing math widgets, no monospace Text',
        (tester) async {
      final r = CenterSolver.computeExact(x1: '1', y1: '2', x2: '3', y2: '4')!;
      await _pump(
        tester,
        CenterStepsSection(steps: r.steps, stepsLatex: r.stepsLatex),
      );

      expect(
        find.byType(SelectableMath),
        findsNWidgets(_nonEmpty(r.stepsLatex).length),
      );
      expect(_monospaceText, findsNothing);
      expect(tester.takeException(), isNull);
      _expectAllRenderedMathParsed(tester);
    });

    testWidgets('plain steps string path still renders monospace Text',
        (tester) async {
      await _pump(tester, const CenterStepsSection(steps: 'h = 1'));
      expect(find.byType(SelectableMath), findsNothing);
      expect(find.text('h = 1'), findsOneWidget);
      expect(_monospaceText, findsOneWidget);
    });
  });

  group('RadiusStepsCard renders LaTeX (not monospace)', () {
    testWidgets('latex path yields parsing math widgets, no monospace Text',
        (tester) async {
      final r = RadiusSolver.solve(x: 1, y: 2, h: 0, k: 0);
      await _pump(
        tester,
        RadiusStepsCard(steps: r.steps, stepsLatex: r.stepsLatex),
      );

      expect(find.byType(SelectableMath), findsNWidgets(r.stepsLatex.length));
      expect(_monospaceText, findsNothing);
      expect(tester.takeException(), isNull);
      _expectAllRenderedMathParsed(tester);
    });

    testWidgets('plain steps string path still renders monospace Text',
        (tester) async {
      await _pump(tester, const RadiusStepsCard(steps: 'r = 5'));
      expect(find.byType(SelectableMath), findsNothing);
      expect(find.text('r = 5'), findsOneWidget);
      expect(_monospaceText, findsOneWidget);
    });
  });
}
