import 'package:calculus_system/shared/widgets/full_screen_graph_screen.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/two_point_slope_solver/two_point_slope_solver.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';

// -------------------------------------------------------------
// GRAPH WIDGET
// Renders the coordinate plane and the line using fl_chart.
// Add fl_chart to pubspec.yaml:
//   fl_chart: ^0.68.0
// -------------------------------------------------------------

String _fmt(double v) {
  if (v == v.truncateToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(1);
}

class TwoPointSlopeGraph extends StatelessWidget {
  final TwoPointSlopeResult result;

  const TwoPointSlopeGraph({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullScreen(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 20,
                  decoration: BoxDecoration(
                    color: context.watch<ThemeProvider>().accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text('GRAPH',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context
                            .watch<ThemeProvider>()
                            .textSecondary
                            .withValues(alpha: 0.7),
                        letterSpacing: 0.5)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.lineEquation,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context
                          .watch<ThemeProvider>()
                          .accentColor
                          .withValues(alpha: 0.8),
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                // Legend
                _LegendDot(
                    color: context.watch<ThemeProvider>().accentColor,
                    label: 'Line'),
                const SizedBox(width: 12),
                _LegendDot(
                  color: context.watch<ThemeProvider>().accentColor,
                  label: 'P1 (${_fmt(result.x1)}, ${_fmt(result.y1)})',
                ),
                const SizedBox(width: 12),
                _LegendDot(
                  color: context.watch<ThemeProvider>().accentColor,
                  label: 'P2 (${_fmt(result.x2)}, ${_fmt(result.y2)})',
                ),
              ],
            ),
          ),

          // Chart card
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: context.watch<ThemeProvider>().card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context
                    .watch<ThemeProvider>()
                    .accentColor
                    .withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: context
                      .watch<ThemeProvider>()
                      .accentColor
                      .withValues(alpha: 0.15),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
            child: result.isVertical
                ? _VerticalLineGraph(result: result)
                : _LineGraph(result: result),
          ),
        ],
      ),
    );
  }

  void _openFullScreen(BuildContext context) {
    final accent = context.watch<ThemeProvider>().accentColor;
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FullScreenGraphScreen(
          title: 'Two-Point Slope',
          accentColor: accent,
          graph: Container(
            color: context.watch<ThemeProvider>().surface,
            child: result.isVertical
                ? _VerticalLineGraph(result: result)
                : _LineGraph(result: result),
          ),
          formula: result.lineEquation,
          keyInfo: [
            FullScreenInfoItem(
              label: 'P1',
              value: '(${_fmt(result.x1)}, ${_fmt(result.y1)})',
              color: accent,
            ),
            FullScreenInfoItem(
              label: 'P2',
              value: '(${_fmt(result.x2)}, ${_fmt(result.y2)})',
              color: context.watch<ThemeProvider>().accentColor,
            ),
            if (!result.isVertical)
              FullScreenInfoItem(
                label: 'Slope',
                value: result.slope != null ? _fmt(result.slope!) : 'N/A',
                color: accent,
              ),
            if (!result.isVertical && result.yIntercept != null)
              FullScreenInfoItem(
                label: 'Y-Intercept',
                value: _fmt(result.yIntercept!),
                color: accent,
              ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// Normal line graph (slope defined)
// -------------------------------------------------------------

class _LineGraph extends StatelessWidget {
  final TwoPointSlopeResult result;
  const _LineGraph({required this.result});

  @override
  Widget build(BuildContext context) {
    final m = result.slope!;
    final b = result.yIntercept!;

    // Determine axis bounds from the two points + padding
    final allX = [result.x1, result.x2];
    final allY = [result.y1, result.y2];

    final xMin = allX.reduce((a, b) => a < b ? a : b) - 4;
    final xMax = allX.reduce((a, b) => a > b ? a : b) + 4;
    final yMin = allY.reduce((a, b) => a < b ? a : b) - 4;
    final yMax = allY.reduce((a, b) => a > b ? a : b) + 4;

    // Build line points
    final lineSpots = <FlSpot>[
      FlSpot(xMin, m * xMin + b),
      FlSpot(xMax, m * xMax + b),
    ];

    // The two input points
    final point1 = FlSpot(result.x1, result.y1);
    final point2 = FlSpot(result.x2, result.y2);

    // Capture colors before callbacks (avoid calling context.watch outside widget tree)
    final bgColor = context.watch<ThemeProvider>().surface;
    final stepBlue = context.watch<ThemeProvider>().accentColor;
    final stepGreen = context.watch<ThemeProvider>().accentColor;

    return LineChart(
      LineChartData(
        backgroundColor: Colors.transparent,

        // Grid
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: Color(0xFF1A1A2E),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (_) => const FlLine(
            color: Color(0xFF1A1A2E),
            strokeWidth: 1,
          ),
        ),

        // Borders (axes)
        borderData: FlBorderData(show: false),

        // Axis titles
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: Text('Y',
                style: TextStyle(
                    color: context.watch<ThemeProvider>().textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            axisNameSize: 22,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (v, _) => _AxisLabel(v.toString()),
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: Text('X',
                style: TextStyle(
                    color: context.watch<ThemeProvider>().textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            axisNameSize: 22,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) => _AxisLabel(v.toString()),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        // Axis bounds
        minX: xMin,
        maxX: xMax,
        minY: yMin,
        maxY: yMax,
        // Clip to prevent overflow
        clipData: const FlClipData.all(),

        lineBarsData: [
          // -- The line -----------------------------------
          LineChartBarData(
            spots: lineSpots,
            isCurved: false,
            color: stepBlue,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: stepBlue.withValues(alpha: 0.06),
            ),
          ),

          // -- Point 1 ------------------------------------
          LineChartBarData(
            spots: [point1],
            isCurved: false,
            color: Colors.transparent,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 6,
                color: stepBlue,
                strokeWidth: 2,
                strokeColor: bgColor,
              ),
            ),
          ),

          // -- Point 2 ------------------------------------
          LineChartBarData(
            spots: [point2],
            isCurved: false,
            color: Colors.transparent,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 6,
                color: stepGreen,
                strokeWidth: 2,
                strokeColor: bgColor,
              ),
            ),
          ),
        ],

        // Tooltip
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) {
              return LineTooltipItem(
                '(${_fmt(s.x)}, ${_fmt(s.y)})',
                TextStyle(
                  color: context.watch<ThemeProvider>().textPrimary,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// Vertical line fallback (slope undefined)
// -------------------------------------------------------------

class _VerticalLineGraph extends StatelessWidget {
  final TwoPointSlopeResult result;
  const _VerticalLineGraph({required this.result});

  @override
  Widget build(BuildContext context) {
    final x = result.x1;
    final yMin = result.y1 < result.y2 ? result.y1 - 4 : result.y2 - 4;
    final yMax = result.y1 > result.y2 ? result.y1 + 4 : result.y2 + 4;

    // Capture colors before callbacks (avoid calling context.watch outside widget tree)
    final bgColor = context.watch<ThemeProvider>().surface;
    final stepBlue = context.watch<ThemeProvider>().accentColor;
    final stepGreen = context.watch<ThemeProvider>().accentColor;

    return LineChart(
      LineChartData(
        backgroundColor: Colors.transparent,
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xFF1A1A2E), strokeWidth: 1),
          getDrawingVerticalLine: (_) =>
              const FlLine(color: Color(0xFF1A1A2E), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: Text('Y',
                style: TextStyle(
                    color: context.watch<ThemeProvider>().textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            axisNameSize: 20,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (v, _) => _AxisLabel(v.toString()),
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: Text('X',
                style: TextStyle(
                    color: context.watch<ThemeProvider>().textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            axisNameSize: 20,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) => _AxisLabel(v.toString()),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        minX: x - 5,
        maxX: x + 5,
        minY: yMin,
        maxY: yMax,
        clipData: const FlClipData.all(),
        lineBarsData: [
          // Vertical line drawn as two points
          LineChartBarData(
            spots: [FlSpot(x, yMin), FlSpot(x, yMax)],
            isCurved: false,
            color: stepBlue,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: [FlSpot(result.x1, result.y1)],
            color: Colors.transparent,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 6,
                color: stepBlue,
                strokeWidth: 2,
                strokeColor: bgColor,
              ),
            ),
          ),
          LineChartBarData(
            spots: [FlSpot(result.x2, result.y2)],
            color: Colors.transparent,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 6,
                color: stepGreen,
                strokeWidth: 2,
                strokeColor: bgColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// Helpers
// -------------------------------------------------------------

class _AxisLabel extends StatelessWidget {
  final String text;
  const _AxisLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final v = double.tryParse(text);
    final label = v != null ? _fmt(v) : text;
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        color: context.watch<ThemeProvider>().textSecondary,
        fontFamily: 'monospace',
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: context.watch<ThemeProvider>().textSecondary,
            ),
          ),
        ],
      );
}
