// Cycle 12 Item 3 Slice 4c: wiring test — Differential Equations
// registry entry resolves to its separable solver screen (mirrors
// the cycle-11 wiring test pattern).
import 'package:calculus_system/app_router.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/calculus/finals/finals_module_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Differential Equations registry route renders its screen',
      (tester) async {
    final entry = FinalsModuleRegistry.modules
        .singleWhere((m) => m.label == 'Differential Equations');
    expect(entry.route, '/topics/calculus/finals/diffeq');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: ThemeProvider(),
        child: MaterialApp.router(routerConfig: AppRouter.router),
      ),
    );
    AppRouter.router.go(entry.route);
    await tester.pumpAndSettle();
    expect(find.text('Differential Equations'), findsWidgets);
    expect(find.text('Topic coming soon'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
