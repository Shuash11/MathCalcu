import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/calculus/midterm/graph/two_point_slope_graph/two_point_slope_graph.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/two_point_slope_solver/two_point_slope_solver.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

Widget _buildApp(TwoPointSlopeResult result) {
  return ChangeNotifierProvider.value(
    value: ThemeProvider(),
    child: MaterialApp(
      home: Scaffold(body: TwoPointSlopeGraph(result: result)),
    ),
  );
}

void main() {
  // Smoke test: safety net for future fl_chart upgrades. Pumps the widget with
  // representative inputs and asserts it builds (no exception) with the fl_chart
  // LineChart present.
  testWidgets('TwoPointSlopeGraph builds a LineChart for a sloped line',
      (tester) async {
    final result = TwoPointSlopeSolver.solve(x1: 1, y1: 1, x2: 3, y2: 5);

    await tester.pumpWidget(_buildApp(result));

    expect(tester.takeException(), isNull);
    expect(find.byType(LineChart), findsOneWidget);
    expect(find.text('GRAPH'), findsOneWidget);
  });

  testWidgets('TwoPointSlopeGraph builds a LineChart for a vertical line',
      (tester) async {
    final result = TwoPointSlopeSolver.solve(x1: 2, y1: 1, x2: 2, y2: 4);
    expect(result.isVertical, isTrue);

    await tester.pumpWidget(_buildApp(result));

    expect(tester.takeException(), isNull);
    expect(find.byType(LineChart), findsOneWidget);
  });
}
