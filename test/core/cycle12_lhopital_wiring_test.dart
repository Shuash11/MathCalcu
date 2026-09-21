// Cycle 12 Item 1: wiring test — L'Hopital's Rule picker entry resolves
// to its 5th-method screen (mirrors the cycle-11 wiring test pattern).
import 'package:calculus_system/app_router.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets("L'Hopital's Rule route renders its screen", (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: ThemeProvider(),
        child: MaterialApp.router(routerConfig: AppRouter.router),
      ),
    );
    AppRouter.router.go('/topics/calculus/finals/limits/lhopital');
    await tester.pumpAndSettle();
    expect(find.text("L'Hopital's Rule"), findsWidgets);
    expect(find.text('Topic coming soon'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets("Evaluating Limits picker shows the 5th L'Hopital entry",
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: ThemeProvider(),
        child: MaterialApp.router(routerConfig: AppRouter.router),
      ),
    );
    AppRouter.router.go('/topics/calculus/finals/limits');
    await tester.pumpAndSettle();

    final entryCard = find.text("By L'Hopital's Rule");
    await tester.scrollUntilVisible(entryCard, 200,
        scrollable: find.byType(Scrollable).first);
    expect(entryCard, findsOneWidget);

    await tester.tap(entryCard);
    await tester.pumpAndSettle();
    expect(find.text('Topic coming soon'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
