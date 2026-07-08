import 'package:calculus_system/main.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App launches and shows the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: ThemeProvider(),
        child: const CalculusApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Should show the main app content (no activation gate)
    expect(find.text('Finals'), findsOneWidget);
  });
}