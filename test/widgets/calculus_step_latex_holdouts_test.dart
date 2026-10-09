// Holdout-conversion regression tests for the midterm calculus steps.
//
// The identify-points / point-slope / identify-endpoints step bodies were
// plain monospace Text; they now render through each screen's LaTeX path
// (SelectableMath.tex). No other test renders these step widgets directly,
// so this file pumps them and asserts (a) the converted bodies produce math
// widgets and (b) the former monospace Text is gone.
import 'package:calculus_system/theme/theme_provider.dart';
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
    });
  });
}
