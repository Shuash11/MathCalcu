// Cycle 1 Phase 3 (P3-1): StepList semantic structure assertions and
// text-scale-2.0 overflow hardening for the shared StepList and the
// five fixed finals screens.
//
// Structural checks assert the walkthrough exposes a real screen-reader
// list: the container announces 'Solution steps' with
// SemanticsRole.list, each step row is a SemanticsRole.listItem
// anchored by its title/explanation (value "Step N"), and the 'Show
// work'/'Hide work' toggle inside a step keeps its button semantics.
//
// Overflow checks pump StepList (representative content, both themes)
// and the five finals screens the way step_list_and_finals_test.dart
// does, each under a MediaQuery textScaleFactor 2.0 override, and rely
// on flutter_test failing the test on any RenderFlex overflow exception
// (takeException is also asserted null after each pump sequence).
import 'dart:ui' show SemanticsRole;

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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Pumps [child] inside the standard test harness with an optional
/// text-scale override. MaterialApp supplies Directionality (StepList
/// has none of its own); Scaffold supplies the Material ancestor the
/// solver screens' TextFields require.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool isDark = false,
  double textScaleFactor = 1.0,
}) async {
  final theme = ThemeProvider();
  if (isDark) theme.toggleTheme();

  tester.view.physicalSize = const Size(390, 2000);
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: theme,
      child: MaterialApp(
        // The text-scale override wraps the app so every Text inside
        // (StepList rows and the finals screens) lays out at 2.0.
        builder: (context, widget) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScaleFactor),
          ),
          child: widget ?? const SizedBox.shrink(),
        ),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pump();
}

/// Representative step content: a latex step with subLatex, details and
/// hint plus a plain-text step — exercises every _StepRow branch.
const List<StepModel> _kRepresentativeSteps = [
  StepModel(
    stepNumber: 1,
    title: 'Simplify the ratio',
    explanation: 'Divide both terms by their GCF.',
    latex: r'\frac{12}{18} = \frac{2}{3}',
    subLatex: [r'12 \div 6 = 2'],
    details: [r'18 \div 6 = 3'],
    hint: 'Factor first, then cancel.',
  ),
  StepModel(
    stepNumber: 2,
    title: 'Check the answer',
    explanation: 'The simplified ratio is 2:3.',
  ),
];

void main() {
  group('StepList semantic structure', () {
    testWidgets('exposes list role, header label and listItem roles',
        (tester) async {
      final handle = tester.ensureSemantics();

      await _pump(
        tester,
        const SingleChildScrollView(
          child: StepList(steps: _kRepresentativeSteps),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // The list container announces itself as 'Solution steps'.
      expect(find.bySemanticsLabel('Solution steps'), findsOneWidget);

      // Each step row is a listItem node with the step content as its
      // reading-order anchor and the step number as its value.
      final listItemNodes = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((s) => s.properties.role == SemanticsRole.listItem)
          .toList();
      expect(listItemNodes, hasLength(2));
      expect(
        listItemNodes
            .map((s) => s.properties.label)
            .where((l) => l != null && l.contains('Simplify the ratio')),
        isNotEmpty,
      );
      expect(
        listItemNodes.map((s) => s.properties.value),
        everyElement(contains('Step ')),
      );

      // The step toggle inside the list keeps its button semantics.
      final toggle = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((s) =>
              s.properties.button == true &&
              (s.properties.label == 'Show work'))
          .toList();
      expect(toggle, hasLength(1));

      handle.dispose();
    });

    testWidgets('listItem parent nodes carry the list role', (tester) async {
      // The framework's debug role check requires every listItem's
      // parent semantics node to have role list — pump through the real
      // widget so the assertion in SemanticsNode._addToUpdate fires.
      final handle = tester.ensureSemantics();

      await _pump(
        tester,
        const SingleChildScrollView(
          child: StepList(steps: _kRepresentativeSteps),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
      expect(
        semantics.where((s) => s.properties.role == SemanticsRole.list),
        isNotEmpty,
      );
      expect(tester.takeException(), isNull);

      handle.dispose();
    });
  });

  group('StepList text scale 2.0', () {
    testWidgets('builds with zero overflow exceptions in both themes',
        (tester) async {
      for (final isDark in [false, true]) {
        await _pump(
          tester,
          const SingleChildScrollView(
            child: StepList(steps: _kRepresentativeSteps),
          ),
          isDark: isDark,
          textScaleFactor: 2.0,
        );
        // Settle animated (rotation/size) content before asserting.
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Show work'), findsOneWidget);
        // flutter_test fails the test on any RenderFlex overflow; the
        // takeException assertion also guards non-flex layout errors.
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('expanded details build with zero overflows at 2.0',
        (tester) async {
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
        textScaleFactor: 2.0,
      );
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Show work'));
      await tester.pumpAndSettle();
      expect(find.text('Hide work'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Finals screens text scale 2.0', () {
    testWidgets('derivatives screen builds with zero overflows at 2.0',
        (tester) async {
      await _pump(
        tester,
        const MaterialApp(home: DerivativeScreen()),
        textScaleFactor: 2.0,
      );
      expect(tester.takeException(), isNull);

      await tester.enterText(find.byType(TextField), 'x^2 + 3*x');
      // _solve shows the answer card after its 400ms UI-feel delay.
      await tester.tap(find.text('Solver'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      expect(find.text('Derivative Result'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('evaluating limits picker builds with zero overflows at 2.0',
        (tester) async {
      await _pump(
        tester,
        const MaterialApp(home: EvaluatingLimitsPicker()),
        textScaleFactor: 2.0,
      );
      // Staggered card fade-ins: 100ms offsets over 600ms controllers.
      await tester.pump(const Duration(milliseconds: 1100));

      expect(find.text('Back to Finals'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('limits infinity screen builds with zero overflows at 2.0',
        (tester) async {
      await _pump(
        tester,
        const MaterialApp(home: LimitsInfinityScreen()),
        textScaleFactor: 2.0,
      );
      expect(tester.takeException(), isNull);

      await tester.enterText(find.byType(TextField).first, '1/x');
      await tester.enterText(find.byType(TextField).last, '0');
      // _solve shows the answer card after its 400ms UI-feel delay.
      await tester.tap(find.text('Solver'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      expect(find.text('Limit Result'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('slope solver screen builds with zero overflows at 2.0',
        (tester) async {
      await _pump(
        tester,
        const MaterialApp(home: SlopeSolverScreen()),
        textScaleFactor: 2.0,
      );
      expect(tester.takeException(), isNull);

      // Defaults y = x^3 - 2x + 1 at x = 2 solve instantly (no delay).
      await tester.tap(find.text('Solver'));
      await tester.pumpAndSettle();

      expect(find.text('Slope (m)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('slope steps screen builds with zero overflows at 2.0',
        (tester) async {
      final result = SlopeSolver.solve(
        'y = x^3 - 2x + 1',
        pointValues: PointValues.parse('x=2'),
      );
      final solution = SolutionBuilder.build(result);

      await _pump(
        tester,
        MaterialApp(home: StepsScreen(solution: solution)),
        textScaleFactor: 2.0,
      );
      // Settle the sliver list layout before asserting.
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.bySemanticsLabel('Back to slope solution'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
