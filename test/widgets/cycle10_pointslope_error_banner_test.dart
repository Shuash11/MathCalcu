import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/calculus/midterm/screens/pointslope_screen/pointslopescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget buildTestApp() {
  return ChangeNotifierProvider.value(
    value: ThemeProvider(),
    child: const MaterialApp(home: PointSlopeScreen()),
  );
}

void main() {
  Finder errorBanner(Finder child) => find.ancestor(
        of: child,
        matching: find.byWidgetPredicate(
          (w) => w is Padding && w.padding == const EdgeInsets.only(bottom: 8),
        ),
      );

  testWidgets('shows inline error banner when any field is empty',
      (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.enterText(find.byType(TextField).at(0), '2');
    await tester.enterText(find.byType(TextField).at(1), '1');
    await tester.tap(find.text('Solve'));
    await tester.pump();

    expect(find.text('Please fill in all three fields'), findsOneWidget);
    expect(errorBanner(find.text('Please fill in all three fields')),
        findsOneWidget);
  });

  testWidgets('shows inline error banner when input is invalid',
      (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.enterText(find.byType(TextField).at(0), '3/');
    await tester.enterText(find.byType(TextField).at(1), '1');
    await tester.enterText(find.byType(TextField).at(2), '2');
    await tester.tap(find.text('Solve'));
    await tester.pump();

    expect(
      find.text('Invalid input — use numbers or fractions like 3/4'),
      findsOneWidget,
    );
  });

  testWidgets('clears the error banner after a successful solve',
      (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Solve'));
    await tester.pump();
    expect(find.text('Please fill in all three fields'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), '2');
    await tester.enterText(find.byType(TextField).at(1), '1');
    await tester.enterText(find.byType(TextField).at(2), '3');
    await tester.tap(find.text('Solve'));
    await tester.pump();

    expect(find.text('Please fill in all three fields'), findsNothing);
    expect(
      find.text('Invalid input — use numbers or fractions like 3/4'),
      findsNothing,
    );
  });
}
