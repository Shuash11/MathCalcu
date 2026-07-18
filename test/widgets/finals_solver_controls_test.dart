import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/calculus/finals/widgets/finals_solver_controls.dart';

Widget buildTestApp(Widget child, {ThemeProvider? theme}) {
  return ChangeNotifierProvider.value(
    value: theme ?? ThemeProvider(),
    child: MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('FinalsSolverButton', () {
    testWidgets('renders "Solver" text and icon when not loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          FinalsSolverButton(onPressed: () {}),
        ),
      );

      expect(find.text('Solver'), findsOneWidget);
      expect(find.byIcon(Icons.calculate_rounded), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          FinalsSolverButton(onPressed: () {}, isLoading: true),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Solver'), findsNothing);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestApp(
          FinalsSolverButton(onPressed: () => tapped = true),
        ),
      );

      await tester.tap(find.byType(FinalsSolverButton));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onPressed when isLoading is true',
        (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestApp(
          FinalsSolverButton(onPressed: () => tapped = true, isLoading: true),
        ),
      );

      await tester.tap(find.byType(FinalsSolverButton));
      expect(tapped, isFalse);
    });
  });

  group('FinalsVariableChip', () {
    testWidgets('renders the variable letter', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          FinalsVariableChip(variable: 'x', onTap: () {}),
        ),
      );

      expect(find.text('x'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestApp(
          FinalsVariableChip(variable: 't', onTap: () => tapped = true),
        ),
      );

      await tester.tap(find.byType(FinalsVariableChip));
      expect(tapped, isTrue);
    });

    testWidgets('renders different variable letters', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          FinalsVariableChip(variable: 'θ', onTap: () {}),
        ),
      );

      expect(find.text('θ'), findsOneWidget);
    });
  });
}
