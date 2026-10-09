// Holdout-conversion regression tests for the midterm calculus steps.
//
// The identify-points / point-slope / identify-endpoints step bodies were
// plain monospace Text; they now render through each screen's LaTeX path
// (SelectableMath.tex). No other test renders these step widgets directly,
// so this file pumps them and asserts (a) the converted bodies produce math
// widgets, (b) the former monospace Text is gone, and (c) the emitted TeX
// actually PARSES.
//
// (c) matters because SelectableMath is a StatelessWidget whose build returns
// the `onErrorFallback` widget on a parse error, so a body that fails to parse
// still counts as a SelectableMath: the count/gone assertions alone cannot
// catch a parse-failure regression. The parse assertions below drive an
// explicit `onErrorFallback` that records invocation (asserting it was NOT
// invoked) and, for the live widgets, check `SelectableMath.parseException`.
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/derivatives_solver/expr_to_latex.dart';
import 'package:calculus_system/topics/calculus/midterm/screens/midpoint_screen/midpointsteps.dart';
import 'package:calculus_system/topics/calculus/midterm/screens/pointslope_screen/pointslopesteps.dart';
import 'package:calculus_system/topics/calculus/midterm/screens/slope_screen/slope_steps.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/midpoint_solver/midpointsolver.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/slope_solver/slope_solver.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: ThemeProvider(),
      child: MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );
  await tester.pump();
}

/// Assert every [SelectableMath] currently in the tree parsed successfully.
/// A parse failure is only visible via `parseException` (the widget then
/// builds its fallback), so this is the direct guard against a body that
/// silently fails to parse. Must be called before any re-pump.
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

/// Render [tex] with an explicit `onErrorFallback` and assert it was NOT
/// invoked, i.e. the TeX parses. Replaces the current widget tree.
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
  group('SlopeSteps identify-points body renders LaTeX', () {
    testWidgets('A/B points are math widgets, not monospace Text',
        (tester) async {
      await _pump(
        tester,
        SlopeSteps(
          result: SlopeSolverResult(
            x1: 1,
            y1: 2,
            x2: 3,
            y2: 4,
            slope: 1,
            deltaY: 2,
            deltaX: 2,
            isVertical: false,
            isHorizontal: false,
            equation: 'y = x + 1',
            slopeDisplay: '1',
          ),
        ),
      );

      // Step 1 now contributes two SelectableMath widgets (was a single
      // monospace Text): steps 2 + 3(×2) + 4 + 5 + step1(×2) = 7.
      expect(find.byType(SelectableMath), findsNWidgets(7));
      // The former plain-text body is gone.
      expect(find.text('A = (1, 2)\nB = (3, 4)'), findsNothing);
      expect(tester.takeException(), isNull);
      // Every rendered body must actually parse (not fall back).
      _expectAllRenderedMathParsed(tester);

      // The step-1 point lines, rendered directly through a recording
      // onErrorFallback, must parse.
      await _expectTexParses(tester, r'A = (x_1,\;y_1) = (1,\;2)');
      await _expectTexParses(tester, r'B = (x_2,\;y_2) = (3,\;4)');
    });
  });

  group('PointSlopeSteps identify-values body renders LaTeX', () {
    testWidgets('point and slope are math widgets, not monospace Text',
        (tester) async {
      await _pump(
        tester,
        const PointSlopeSteps(
          m: '2',
          x1: '1',
          y1: '3',
          b: '-1',
          generalForm: r'2x - y - 1 = 0',
          standardForm: r'2x - y = 1',
        ),
      );

      // Step 1 adds two SelectableMath widgets (was a monospace Text):
      // steps 1(×2) + 2 + 3 + 4(×2) + 5 + 6 + 7 = 9.
      expect(find.byType(SelectableMath), findsNWidgets(9));
      // The former plain-text body is gone.
      expect(find.text('Point:  (1, 3)\nSlope:  m = 2'), findsNothing);
      expect(tester.takeException(), isNull);
      _expectAllRenderedMathParsed(tester);

      // The step-1 point/slope lines must parse.
      await _expectTexParses(
          tester, r'\text{Point: } (x_1,\;y_1) = (1,\;3)');
      await _expectTexParses(tester, r'm = 2');
    });
  });

  group('MidpointSteps identify-endpoints body renders LaTeX', () {
    testWidgets('point bodies are math widgets, not monospace Text',
        (tester) async {
      await _pump(
        tester,
        const MidpointSteps(
          mode: StepMode.midpoint,
          rawAX: '1',
          rawAY: '2',
          rawBX: '3',
          rawBY: '4',
          resX: Fraction(numerator: 2, denominator: 1, isWhole: true),
          resY: Fraction(numerator: 3, denominator: 1, isWhole: true),
        ),
      );

      // Step 1 uses the latex path (1 SelectableMath) instead of the old
      // monospace Text fallback: steps 1 + 2 + 3(×2) + 4(×2) + 5 = 7.
      expect(find.byType(SelectableMath), findsNWidgets(7));
      // The former plain-text body is gone.
      expect(find.textContaining('(x1, y1)'), findsNothing);
      expect(tester.takeException(), isNull);
      _expectAllRenderedMathParsed(tester);

      // The step-1 \begin{aligned} block must parse (a broken `\\` or an
      // unterminated environment still renders as a SelectableMath and would
      // otherwise slip past the count assertion).
      await _expectTexParses(
        tester,
        r'\begin{aligned}'
        r'A &= (1,\;2) \to (x_1,\;y_1) \\'
        r'B &= (3,\;4) \to (x_2,\;y_2)'
        r'\end{aligned}',
      );
    });
  });

  group('exprToLatex function/radical transforms parse (Phase B2)', () {
    testWidgets('ln/sqrt/sin and the app hint input emit parseable TeX',
        (tester) async {
      const exprs = [
        'ln(x)',
        'sqrt(x)',
        'sin(x)',
        'x^2 + 3x + ln(x)', // the derivatives screen's own hint example
        'cos(x)',
        'tan(x)',
        'exp(x)',
        'sqrt(x + 1)',
        'sqrt(x) + sin(x)',
      ];
      for (final expr in exprs) {
        await _expectTexParses(tester, exprToLatex(expr));
      }
    });
  });
}
