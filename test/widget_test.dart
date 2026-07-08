import 'package:calculus_system/main.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App launches and shows activation screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: ThemeProvider(),
        child: const CalculusApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Should show the activation lock screen since not activated
    expect(find.text('Activation Required'), findsOneWidget);
    expect(find.text('Activate'), findsWidgets);
  });
}