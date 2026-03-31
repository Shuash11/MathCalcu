import 'package:calculus_system/main.dart';

import 'package:flutter_test/flutter_test.dart';



void main() {
  testWidgets('App launches and shows category picker', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculusApp());
    await tester.pumpAndSettle();

    // The landing screen should show both category titles
    expect(find.text('Inequalities'), findsOneWidget);
    expect(find.text('Solvers'), findsOneWidget);
  });
}