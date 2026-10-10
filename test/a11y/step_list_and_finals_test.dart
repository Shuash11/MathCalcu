// Cycle 1 Phase 2 (P1-2): labeled tap targets on the finals screens
// and the shared StepList "Show work" toggle.
//
// Every tappable widget on these surfaces carries a Semantics label
// (or IconButton tooltip), so screen readers announce the control
// instead of reading an unnamed "button". Pumps the shared StepList
// and the five fixed finals screens the way their existing tests do,
// and asserts the Flutter labeledTapTargetGuideline in light and dark.
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/step_list.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/calculus/finals/screens/derivatives_screen/derivatives_screen.dart';
import 'package:calculus_system/topics/calculus/finals/screens/evaluating_limits_screen/evaluating_limits_picker.dart';
import 'package:calculus_system/topics/calculus/finals/screens/limits_infinity_screen/limits_infinity_screen.dart';
import 'package:calculus_system/topics/calculus/finals/screens/slope_using_derivatives_screen/slope_solver_screen.dart';
import 'package:calculus_system/topics/calculus/finals/screens/slope_using_derivatives_screen/steps_screen.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/slope_using_derivatives_solver/point_values.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/slope_using_derivatives_solver/slope_using_derivatives_solver.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/slope_using_derivatives_solver/steps.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool isDark = false,
}) async {
  final theme = ThemeProvider();
  if (isDark) theme.toggleTheme();

  tester.view.physicalSize = const Size(390, 2000);
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpWidget(
    // MaterialApp supplies Directionality (StepList has none of its own);
    // Scaffold supplies the Material ancestor the solver screens'
    // TextFields require. Nested Scaffolds on screens that build their
    // own are harmless in tests.
    ChangeNotifierProvider.value(
      value: theme,
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
  await tester.pump();
}

void main() {
  group('StepList "Show work" toggle', () {
    testWidgets('meets labeledTapTargetGuideline in both themes', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      for (final isDark in [false, true]) {
        await _pump(
          tester,
          const SingleChildScrollView(
            child: StepList(
              steps: [
                StepModel(
                  stepNumber: 1,
                  title: 'Simplify the ratio',
                  explanation: 'Divide both terms by their GCF.',
                  latex: r'\frac{12}{18} = \frac{2}{3}',
                  subLatex: [r'12 \div 6 = 2'],
                  details: [r'18 \div 6 = 3'],
                ),
                StepModel(
                  stepNumber: 2,
                  title: 'Check the answer',
                  explanation: 'The simplified ratio is 2:3.',
                ),
              ],
            ),
          ),
          isDark: isDark,
        );
        await tester.pump(const Duration(milliseconds: 300));

        // The toggle announces itself as Show work / Hide work.
        expect(find.text('Show work'), findsOneWidget);
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      }

      handle.dispose();
    });

    testWidgets('toggle flips its label when expanded', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const SingleChildScrollView(
          child: StepList(
            steps: [
              StepModel(
                stepNumber: 1,
                title: 'With details',
                explanation: 'Primary explanation.',
                details: [r'12 \div 3 = 4'],
              ),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Show work'));
      await tester.pumpAndSettle();
      expect(find.text('Hide work'), findsOneWidget);

      handle.dispose();
    });
  });

  group('Finals screens labeled tap targets', () {
    testWidgets(
      'derivatives screen meets labeledTapTargetGuideline in both themes',
      (tester) async {
        final handle = tester.ensureSemantics();

        for (final isDark in [false, true]) {
          await _pump(
            tester,
            const MaterialApp(home: DerivativeScreen()),
            isDark: isDark,
          );
          // _solve shows the answer card after its 400ms UI-feel delay.
          await tester.enterText(find.byType(TextField), 'x^2 + 3*x');
          await tester.tap(find.text('Solver'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          await tester.pump();

          expect(find.text('Derivative Result'), findsOneWidget);
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        }

        handle.dispose();
      },
    );

    testWidgets('evaluating limits picker meets labeledTapTargetGuideline '
        'in both themes', (tester) async {
      final handle = tester.ensureSemantics();

      for (final isDark in [false, true]) {
        await _pump(
          tester,
          const MaterialApp(home: EvaluatingLimitsPicker()),
          isDark: isDark,
        );
        // Staggered card fade-ins: 100ms offsets over 600ms controllers.
        await tester.pump(const Duration(milliseconds: 1100));
        // Advance the 600ms fade controllers to completion so the picker
        // cards render and their semantics subtrees exist for this check.
        await tester.pumpAndSettle();

        expect(find.text('Back to Finals'), findsOneWidget);
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      }

      handle.dispose();
    });

    testWidgets('limits infinity screen meets labeledTapTargetGuideline '
        'in both themes', (tester) async {
      final handle = tester.ensureSemantics();

      for (final isDark in [false, true]) {
        await _pump(
          tester,
          const MaterialApp(home: LimitsInfinityScreen()),
          isDark: isDark,
        );
        // _solve shows the answer card after its 400ms UI-feel delay.
        await tester.enterText(find.byType(TextField).first, '1/x');
        await tester.enterText(find.byType(TextField).last, '0');
        await tester.tap(find.text('Solver'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();

        expect(find.text('Limit Result'), findsOneWidget);
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      }

      handle.dispose();
    });

    testWidgets(
      'slope solver screen meets labeledTapTargetGuideline in both themes',
      (tester) async {
        final handle = tester.ensureSemantics();

        for (final isDark in [false, true]) {
          await _pump(
            tester,
            const MaterialApp(home: SlopeSolverScreen()),
            isDark: isDark,
          );
          // Defaults y = x^3 - 2x + 1 at x = 2 solve instantly (no delay).
          await tester.tap(find.text('Solver'));
          await tester.pumpAndSettle();

          expect(find.text('Slope (m)'), findsOneWidget);
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        }

        handle.dispose();
      },
    );

    testWidgets(
      'slope steps screen meets labeledTapTargetGuideline in both themes',
      (tester) async {
        final handle = tester.ensureSemantics();

        final result = SlopeSolver.solve(
          'y = x^3 - 2x + 1',
          pointValues: PointValues.parse('x=2'),
        );
        final solution = SolutionBuilder.build(result);

        for (final isDark in [false, true]) {
          await _pump(
            tester,
            MaterialApp(home: StepsScreen(solution: solution)),
            isDark: isDark,
          );

          expect(find.text('Back to slope solution'), findsNothing);
          expect(
            find.bySemanticsLabel('Back to slope solution'),
            findsOneWidget,
          );
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        }

        handle.dispose();
      },
    );
  });

  group('Converted step bodies render math widgets', () {
    testWidgets(
      'derivatives step bodies render Math widgets in the steps modal',
      (tester) async {
        await _pump(tester, const MaterialApp(home: DerivativeScreen()));

        await tester.enterText(find.byType(TextField), 'x^2 + 3*x');
        // _solve shows the answer card after its 400ms UI-feel delay.
        await tester.tap(find.text('Solver'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();

        // Open the steps modal, then assert each step expression is rendered
        // through the LaTeX path (a Math widget) instead of a plain Text.
        await tester.tap(find.text('Show Steps'));
        await tester.pumpAndSettle();

        final modalMath = find.descendant(
          of: find.byType(DraggableScrollableSheet),
          matching: find.byType(Math),
        );
        expect(modalMath, findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
