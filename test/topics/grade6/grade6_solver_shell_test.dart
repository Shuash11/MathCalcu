import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/answer_card.dart';
import 'package:calculus_system/shared/widgets/step_list.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _StubEquation extends BaseEquation {
  _StubEquation(this._input, [this._steps = const []]);

  final String _input;
  final List<StepModel> _steps;

  @override
  String get rawInput => _input;

  @override
  bool validate() => true;

  @override
  SolveResult solve() => const SolveResult(answer: '42', points: [42]);

  @override
  List<StepModel> getSteps() => _steps;
}

Grade6SolverConfig _config({List<StepModel> steps = const []}) =>
    Grade6SolverConfig(
      title: 'Ratio & Proportion',
      subtitle: 'Simplify, missing term, sharing',
      hint: 'e.g. 12:18 or 3/4 = x/20',
      helper: 'Use : or / and x for unknown',
      depedCode: 'M6NS-Id-140',
      icon: Icons.balance_rounded,
      createEquation: (input) => _StubEquation(input, steps),
    );

Future<void> _pumpShell(
  WidgetTester tester, {
  double width = 800,
  bool isDark = false,
  List<StepModel> steps = const [],
}) async {
  final theme = ThemeProvider();
  if (isDark) {
    theme.toggleTheme();
  }
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: Size(width, 900)),
      child: ChangeNotifierProvider.value(
        value: theme,
        child: MaterialApp(
          home: Grade6SolverScreen(config: _config(steps: steps)),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Solves with the stub, scrolls the result section into view, then
/// opens the steps modal via the AnswerCard tap.
Future<void> _openStepsModal(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), '12:18');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  // The result section builds lazily below the fold — scroll it in.
  await tester.drag(find.byType(ListView), const Offset(0, -600));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(AnswerCard));
  await tester.pumpAndSettle();
}

void main() {
  group('Grade6SolverScreen responsive shell (F5 MED)', () {
    testWidgets('centers content with a 720 max-width cap', (tester) async {
      await _pumpShell(tester, width: 1280);

      expect(
        find.byWidgetPredicate(
          (w) => w is ConstrainedBox && w.constraints.maxWidth == 720,
        ),
        findsOneWidget,
      );
      expect(find.byType(LayoutBuilder), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reflows at 320px in light and dark themes', (tester) async {
      for (final isDark in [false, true]) {
        await _pumpShell(tester, width: 320, isDark: isDark);

        expect(find.text('Enter your problem'), findsOneWidget);
        expect(find.text('Solve'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('solves without overflow from phone to desktop',
        (tester) async {
      for (final width in [320.0, 768.0, 1280.0]) {
        await _pumpShell(tester, width: width);

        await tester.enterText(find.byType(TextField), '12:18');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        // The result section builds lazily below the fold — scroll it in.
        await tester.drag(find.byType(ListView), const Offset(0, -600));
        await tester.pumpAndSettle();

        expect(find.byType(AnswerCard), findsOneWidget);
        expect(find.text('42'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('StepList LaTeX step rendering (Cycle 13 Item 1)', () {
    // Math widgets inside the steps modal — the page has no
    // DraggableScrollableSheet, so this scope excludes the AnswerCard.
    final inModalMath = find.descendant(
      of: find.byType(DraggableScrollableSheet),
      matching: find.byType(SelectableMath),
    );

    testWidgets('(a) latex-filled steps render Math widgets in the modal',
        (tester) async {
      const steps = [
        StepModel(
          stepNumber: 1,
          title: 'Simplify the ratio',
          explanation: 'Divide both terms by their GCF.',
          latex: r'\frac{12}{18} = \frac{2}{3}',
        ),
        StepModel(
          stepNumber: 2,
          title: 'Check the answer',
          explanation: 'The simplified ratio is 2:3.',
          latex: r'2 \times 9 = 18',
        ),
      ];
      await _pumpShell(tester, steps: steps);
      await _openStepsModal(tester);

      expect(
        inModalMath,
        findsNWidgets(2), // 2 steps → 2 primary Math widgets (modal-scoped)
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        '(b) plain steps (no latex) render title/explanation '
        'unchanged — zero regression', (tester) async {
      const steps = [
        StepModel(
          stepNumber: 1,
          title: 'Plain step title',
          explanation: 'Plain step explanation line.',
        ),
      ];
      await _pumpShell(tester, steps: steps);
      await _openStepsModal(tester);

      expect(find.text('Plain step title'), findsOneWidget);
      expect(find.text('Plain step explanation line.'), findsOneWidget);
      expect(
        inModalMath,
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        '(c) malformed TeX never crashes — the explanation '
        'fallback renders', (tester) async {
      const steps = [
        StepModel(
          stepNumber: 1,
          title: 'Broken step',
          explanation: 'Malformed fallback line.',
          latex: r'\frac{', // unclosed group — ParseException in flutter_math
        ),
      ];
      await _pumpShell(tester, steps: steps);
      await _openStepsModal(tester);

      expect(find.text('Malformed fallback line.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('(d) subLatex and expandable details render when present',
        (tester) async {
      const steps = [
        StepModel(
          stepNumber: 1,
          title: 'With extras',
          explanation: 'Primary explanation.',
          latex: r'x + 5 = 7',
          subLatex: [r'x = 7 - 5'],
          details: [r'12 \div 3 = 4'],
        ),
      ];
      await _pumpShell(tester, steps: steps);
      await _openStepsModal(tester);

      // Primary latex + subLatex are visible; details are collapsed.
      expect(inModalMath, findsNWidgets(2));

      await tester.tap(find.text('Show work'));
      await tester.pumpAndSettle();

      // Details expanded: the arithmetic detail adds one more Math widget.
      expect(inModalMath, findsNWidgets(3));
      expect(find.text('Hide work'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('(e) light and dark themes render without exceptions',
        (tester) async {
      const steps = [
        StepModel(
          stepNumber: 1,
          title: 'Theme step',
          explanation: 'Theme explanation.',
          latex: r'\frac{3}{4}',
        ),
      ];
      for (final isDark in [false, true]) {
        await _pumpShell(tester, width: 320, isDark: isDark, steps: steps);
        await _openStepsModal(tester);

        expect(
          inModalMath,
          findsOneWidget,
        );
        expect(find.text('Theme step'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Navigator state survives pumpWidget — close the modal so the
        // next iteration opens a fresh one under the new theme.
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
      }
    });

    test('(f) copy-text strips TeX commands into plain-text math', () {
      final stripped = StepList.stripLatex(
        r'\frac{3}{4} \cup \emptyset \neq \geq \leq \infty \text{x = 2}',
      );
      expect(stripped, contains('3/4'));
      expect(stripped, contains('\u222a')); // \cup
      expect(stripped, contains('\u2205')); // \emptyset
      expect(stripped, contains('\u2260')); // \neq
      expect(stripped, contains('\u2265')); // \geq
      expect(stripped, contains('\u2264')); // \leq
      expect(stripped, contains('\u221e')); // \infty
      expect(stripped, contains('x = 2'));
      expect(stripped, isNot(contains('\\')));
      expect(stripped, isNot(contains('{')));

      final copy = StepList.buildCopyText(const [
        StepModel(
          stepNumber: 1,
          title: 'Copy step',
          explanation: 'Copy explanation.',
          latex: r'\frac{12}{18}',
        ),
        StepModel(
          stepNumber: 2,
          title: 'Plain copy step',
          explanation: 'Plain copy explanation.',
        ),
      ]);
      expect(copy, contains('12/18'));
      expect(copy, contains('Plain copy step — Plain copy explanation.'));
      expect(copy, isNot(contains(r'\frac')));
    });
  });
}
