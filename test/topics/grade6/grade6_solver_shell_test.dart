import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/answer_card.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _StubEquation extends BaseEquation {
  _StubEquation(this._input);

  final String _input;

  @override
  String get rawInput => _input;

  @override
  bool validate() => true;

  @override
  SolveResult solve() => const SolveResult(answer: '42', points: [42]);

  @override
  List<StepModel> getSteps() => const [];
}

Grade6SolverConfig _config() => Grade6SolverConfig(
      title: 'Ratio & Proportion',
      subtitle: 'Simplify, missing term, sharing',
      hint: 'e.g. 12:18 or 3/4 = x/20',
      helper: 'Use : or / and x for unknown',
      depedCode: 'M6NS-Id-140',
      icon: Icons.balance_rounded,
      createEquation: (input) => _StubEquation(input),
    );

Future<void> _pumpShell(
  WidgetTester tester, {
  double width = 800,
  bool isDark = false,
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
          home: Grade6SolverScreen(config: _config()),
        ),
      ),
    ),
  );
  await tester.pump();
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
}
