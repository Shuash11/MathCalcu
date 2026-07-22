import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/shared/widgets/graph_widget.dart';
import 'package:calculus_system/shared/widgets/math_keyboard.dart';
import 'package:calculus_system/shared/widgets/answer_card.dart';
import 'package:calculus_system/shared/widgets/full_screen_graph_screen.dart';
import 'package:calculus_system/topics/calculus/midterm/graph/inequalities_graph/inequality_graph.dart';

Widget buildTestApp(Widget child, {ThemeProvider? theme}) {
  return ChangeNotifierProvider.value(
    value: theme ?? ThemeProvider(),
    child: MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

Widget buildFullApp(Widget child, {ThemeProvider? theme}) {
  return ChangeNotifierProvider.value(
    value: theme ?? ThemeProvider(),
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('MathKeyboard toggle label', () {
    testWidgets('shows "Show math keyboard" when hidden',
        (WidgetTester tester) async {
      final ctrl = TextEditingController();
      await tester.pumpWidget(
        buildTestApp(
          MathKeyboard(
            controller: ctrl,
            accentColor: Colors.blue,
            hideSignal: ValueNotifier(0),
          ),
        ),
      );

      // Initially visible, tap to hide
      await tester.tap(find.text('Hide math keyboard'));
      await tester.pump();

      expect(find.text('Show math keyboard'), findsOneWidget);
      expect(find.text('Hide math keyboard'), findsNothing);
      ctrl.dispose();
    });

    testWidgets('shows "Hide math keyboard" when visible initially',
        (WidgetTester tester) async {
      final ctrl = TextEditingController();
      await tester.pumpWidget(
        buildTestApp(
          MathKeyboard(
            controller: ctrl,
            accentColor: Colors.blue,
            hideSignal: ValueNotifier(0),
          ),
        ),
      );

      expect(find.text('Hide math keyboard'), findsOneWidget);
      ctrl.dispose();
    });

    testWidgets('keyboard toggle has Semantics with button flag',
        (WidgetTester tester) async {
      final ctrl = TextEditingController();
      await tester.pumpWidget(
        buildTestApp(
          MathKeyboard(
            controller: ctrl,
            accentColor: Colors.blue,
            hideSignal: ValueNotifier(0),
          ),
        ),
      );

      // Find semantics for toggle
      final semantics = tester.getSemantics(find.text('Hide math keyboard'));
      expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);

      // Tap to hide
      await tester.tap(find.text('Hide math keyboard'));
      await tester.pump();

      final hiddenSemantics =
          tester.getSemantics(find.text('Show math keyboard'));
      expect(hiddenSemantics.hasFlag(SemanticsFlag.isButton), isTrue);
      ctrl.dispose();
    });

    testWidgets('backspace key has Semantics', (WidgetTester tester) async {
      final ctrl = TextEditingController();
      await tester.pumpWidget(
        buildTestApp(
          MathKeyboard(
            controller: ctrl,
            accentColor: Colors.blue,
            hideSignal: ValueNotifier(0),
          ),
        ),
      );

      // Backspace icon button
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);

      // Check semantics
      final semantics =
          tester.getSemantics(find.byIcon(Icons.backspace_outlined));
      expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
      ctrl.dispose();
    });
  });

  group('GraphWidget title', () {
    testWidgets('shows "Solution graph" label', (WidgetTester tester) async {
      const result = SolveResult(
        answer: 'x > 3',
        points: [3.0],
        intervalNotation: '(3, ∞)',
      );

      await tester.pumpWidget(
        buildTestApp(
          GraphWidget(
            result: result,
            accentColor: Colors.blue,
            graphBody: const SizedBox(),
          ),
        ),
      );

      expect(find.text('Solution graph'), findsOneWidget);
      expect(find.text('Graph'), findsNothing);
    });
  });

  group('AnswerCard rendering', () {
    testWidgets('renders answer text and steps hint',
        (WidgetTester tester) async {
      const result = SolveResult(
        answer: 'x > 3',
        points: [3.0],
        intervalNotation: '(3, ∞)',
      );

      await tester.pumpWidget(
        buildTestApp(
          AnswerCard(
            result: result,
            accentColor: Colors.blue,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Answer'), findsOneWidget);
      expect(find.text('Steps'), findsOneWidget);
      expect(find.text('x > 3'), findsOneWidget);
      expect(find.text('(3, ∞)'), findsOneWidget);
    });

    testWidgets('renders in dark theme without error',
        (WidgetTester tester) async {
      const result = SolveResult(
        answer: 'x ≤ 5',
        points: [5.0],
        intervalNotation: '(-∞, 5]',
      );

      final darkTheme = ThemeProvider()..toggleTheme();

      await tester.pumpWidget(
        buildTestApp(
          AnswerCard(
            result: result,
            accentColor: const Color(0xFFE9ECEF),
            onTap: () {},
          ),
          theme: darkTheme,
        ),
      );

      expect(find.text('Answer'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('FullScreenGraphScreen semantics', () {
    testWidgets('close/back button has button semantics',
        (WidgetTester tester) async {
      const result = SolveResult(
        answer: 'x > 3',
        points: [3.0],
        intervalNotation: '(3, ∞)',
      );

      await tester.pumpWidget(
        buildFullApp(
          FullScreenGraphScreen(
            title: 'Test Graph',
            graph: InequalityGraph(
              result: result,
              accentColor: Colors.blue,
            ),
            keyInfo: [
              FullScreenInfoItem(label: 'Interval', value: '(3, ∞)'),
            ],
          ),
        ),
      );

      // The back button should have semantics
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      final semantics =
          tester.getSemantics(find.byIcon(Icons.arrow_back_rounded));
      expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
    });
  });

  group('InequalityGraph renders key states', () {
    testWidgets('renders single-boundary open endpoint in light theme',
        (WidgetTester tester) async {
      const result = SolveResult(
        answer: 'x > 3',
        points: [3.0],
        intervalNotation: '(3, ∞)',
      );

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 300,
            height: 200,
            child: InequalityGraph(
              result: result,
              accentColor: const Color(0xFF334155),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders single-boundary closed endpoint',
        (WidgetTester tester) async {
      const result = SolveResult(
        answer: 'x ≤ 5',
        points: [5.0],
        intervalNotation: '(-∞, 5]',
      );

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 300,
            height: 200,
            child: InequalityGraph(
              result: result,
              accentColor: const Color(0xFF334155),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders two-boundary union', (WidgetTester tester) async {
      const result = SolveResult(
        answer: 'x < -2 or x > 2',
        points: [-2.0, 2.0],
        intervalNotation: '(-∞, -2) ∪ (2, ∞)',
      );

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 300,
            height: 200,
            child: InequalityGraph(
              result: result,
              accentColor: const Color(0xFF334155),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders "No solution" state', (WidgetTester tester) async {
      const result = SolveResult(
        answer: 'No solution',
        points: [],
        intervalNotation: '∅',
      );

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 300,
            height: 200,
            child: InequalityGraph(
              result: result,
              accentColor: const Color(0xFF334155),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders "All real numbers" state',
        (WidgetTester tester) async {
      const result = SolveResult(
        answer: 'All real numbers',
        points: [],
        intervalNotation: '(-∞, ∞)',
      );

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 300,
            height: 200,
            child: InequalityGraph(
              result: result,
              accentColor: const Color(0xFF334155),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in dark theme with light accent color',
        (WidgetTester tester) async {
      const result = SolveResult(
        answer: 'x > 3',
        points: [3.0],
        intervalNotation: '(3, ∞)',
      );

      final darkTheme = ThemeProvider()..toggleTheme();

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 300,
            height: 200,
            child: InequalityGraph(
              result: result,
              accentColor: const Color(0xFFE9ECEF), // dark mode accent
            ),
          ),
          theme: darkTheme,
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
