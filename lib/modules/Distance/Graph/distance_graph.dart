import 'dart:math';
import 'package:calculus_system/modules/Distance/Theme/distancetheme.dart';
import 'package:flutter/material.dart';

class DistanceGraphScreen extends StatelessWidget {
  final bool is2D;
  final double x1;
  final double? y1;
  final double x2;
  final double? y2;
  final double distance;
  final String distanceLabel;

  const DistanceGraphScreen({
    super.key,
    required this.is2D,
    required this.x1,
    this.y1,
    required this.x2,
    this.y2,
    required this.distance,
    required this.distanceLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DistanceTheme.surface(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: DistanceTheme.card(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DistanceTheme.accent15),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: DistanceTheme.text(context),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Graph Visualization',
                          style: DistanceTheme.headerTitle(context),
                        ),
                        Text(
                          is2D ? 'Coordinate Plane' : 'Number Line',
                          style: DistanceTheme.headerSubtitle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Graph
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: DistanceTheme.card(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: DistanceTheme.accent15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: is2D
                          ? FullScreenCoordinatePainter(
                              x1: x1,
                              y1: y1!,
                              x2: x2,
                              y2: y2!,
                              distance: distance,
                              distanceLabel: distanceLabel,
                              surfaceColor: DistanceTheme.surface(context),
                              textColor: DistanceTheme.text(context),
                            )
                          : FullScreenNumberLinePainter(
                              x1: x1,
                              x2: x2,
                              distance: distance,
                              distanceLabel: distanceLabel,
                              surfaceColor: DistanceTheme.surface(context),
                              textColor: DistanceTheme.text(context),
                            ),
                    ),
                  ),
                ),
              ),
            ),

            // Info panel
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DistanceTheme.card(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: DistanceTheme.accent15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                            context,
                            'Point A',
                            is2D ? '($x1, $y1)' : 'x = $x1',
                            DistanceTheme.accent),
                        Container(
                            width: 1,
                            height: 40,
                            color: DistanceTheme.accent.withValues(alpha: 0.2)),
                        _buildInfoItem(
                            context,
                            'Point B',
                            is2D ? '($x2, $y2)' : 'x = $x2',
                            DistanceTheme.text(context)),
                        Container(
                            width: 1,
                            height: 40,
                            color: DistanceTheme.accent.withValues(alpha: 0.2)),
                        _buildInfoItem(context, 'Distance',
                            'd = $distanceLabel', DistanceTheme.accent),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      BuildContext context, String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: DistanceTheme.text40(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class FullScreenCoordinatePainter extends CustomPainter {
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final double distance;
  final String distanceLabel;
  final Color surfaceColor;
  final Color textColor;

  FullScreenCoordinatePainter({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.distance,
    required this.distanceLabel,
    required this.surfaceColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 60.0;
    final graphWidth = size.width - (padding * 2);
    final graphHeight = size.height - (padding * 2);

    final allX = [x1, x2];
    final allY = [y1, y2];

    final xMargin = (allX.reduce(max) - allX.reduce(min)).abs() * 0.3 + 2;
    final yMargin = (allY.reduce(max) - allY.reduce(min)).abs() * 0.3 + 2;

    final minX = allX.reduce(min) - xMargin;
    final maxX = allX.reduce(max) + xMargin;
    final minY = allY.reduce(min) - yMargin;
    final maxY = allY.reduce(max) + yMargin;

    final xRange = maxX - minX;
    final yRange = maxY - minY;
    final scaleX = graphWidth / xRange;
    final scaleY = graphHeight / yRange;
    final scale = min(scaleX, scaleY);

    final offsetX = padding + (graphWidth - (xRange * scale)) / 2;
    final offsetY = padding + (graphHeight - (yRange * scale)) / 2;

    double tx(double x) => offsetX + (x - minX) * scale;
    double ty(double y) => size.height - (offsetY + (y - minY) * scale);

    // Grid
    final gridPaint = Paint()
      ..color = DistanceTheme.accent.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    for (double i = minX.floorToDouble(); i <= maxX.ceilToDouble(); i += 1) {
      final x = tx(i);
      canvas.drawLine(
          Offset(x, padding), Offset(x, size.height - padding), gridPaint);
    }
    for (double i = minY.floorToDouble(); i <= maxY.ceilToDouble(); i += 1) {
      final y = ty(i);
      canvas.drawLine(
          Offset(padding, y), Offset(size.width - padding, y), gridPaint);
    }

    // Axes
    final axisPaint = Paint()
      ..color = textColor.withValues(alpha: 0.3)
      ..strokeWidth = 2;

    final zeroY = ty(0);
    if (zeroY >= padding && zeroY <= size.height - padding) {
      canvas.drawLine(Offset(padding, zeroY),
          Offset(size.width - padding, zeroY), axisPaint);
    }

    final zeroX = tx(0);
    if (zeroX >= padding && zeroX <= size.width - padding) {
      canvas.drawLine(Offset(zeroX, padding),
          Offset(zeroX, size.height - padding), axisPaint);
    }

    // Points and line
    final pointA = Offset(tx(x1), ty(y1));
    final pointB = Offset(tx(x2), ty(y2));

    // Distance line with glow
    final glowPaint = Paint()
      ..color = DistanceTheme.accent.withValues(alpha: 0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(pointA, pointB, glowPaint);

    final linePaint = Paint()
      ..color = DistanceTheme.accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(pointA, pointB, linePaint);

    // Points
    _drawPoint(canvas, pointA, DistanceTheme.accent, 'A', '$x1, $y1');
    _drawPoint(canvas, pointB, textColor, 'B', '$x2, $y2');

    // Distance label
    final midX = (pointA.dx + pointB.dx) / 2;
    final midY = (pointA.dy + pointB.dy) / 2;

    final textSpan = TextSpan(
      text: 'd = $distanceLabel',
      style: TextStyle(
        color: surfaceColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(midX, midY - 25),
        width: textPainter.width + 20,
        height: textPainter.height + 12,
      ),
      const Radius.circular(6),
    );

    final bgP = Paint()..color = DistanceTheme.accent;
    canvas.drawRRect(bgRect, bgP);

    textPainter.paint(
      canvas,
      Offset(midX - textPainter.width / 2, midY - 25 - textPainter.height / 2),
    );
  }

  void _drawPoint(Canvas canvas, Offset position, Color color, String label,
      String coords) {
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 15, glowPaint);

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 8, pointPaint);

    final labelSpan = TextSpan(
      text: '$label ($coords)',
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
    final labelPainter = TextPainter(
      text: labelSpan,
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(canvas, Offset(position.dx + 15, position.dy - 25));
  }

  @override
  bool shouldRepaint(covariant FullScreenCoordinatePainter oldDelegate) => true;
}

class FullScreenNumberLinePainter extends CustomPainter {
  final double x1;
  final double x2;
  final double distance;
  final String distanceLabel;
  final Color surfaceColor;
  final Color textColor;

  FullScreenNumberLinePainter({
    required this.x1,
    required this.x2,
    required this.distance,
    required this.distanceLabel,
    required this.surfaceColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 80.0;
    final lineY = size.height / 2;
    const lineStart = padding;
    final lineEnd = size.width - padding;

    final minVal = min(x1, x2) - (distance * 0.5 + 2);
    final maxVal = max(x1, x2) + (distance * 0.5 + 2);
    final range = maxVal - minVal;
    final scale = (lineEnd - lineStart) / range;

    double tx(double x) => lineStart + (x - minVal) * scale;

    // Number line track
    final trackPaint = Paint()
      ..color = DistanceTheme.accent.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, lineY),
          width: size.width - padding * 2,
          height: 60,
        ),
        const Radius.circular(12),
      ),
      trackPaint,
    );

    // Main line
    final linePaint = Paint()
      ..color = textColor.withValues(alpha: 0.4)
      ..strokeWidth = 4;
    canvas.drawLine(
        Offset(lineStart, lineY), Offset(lineEnd, lineY), linePaint);

    // Ticks
    final tickPaint = Paint()
      ..color = textColor.withValues(alpha: 0.3)
      ..strokeWidth = 2;

    final step = _calculateStep(range);
    for (double i = minVal; i <= maxVal; i += step) {
      final x = tx(i);
      canvas.drawLine(Offset(x, lineY - 10), Offset(x, lineY + 10), tickPaint);
      _drawText(canvas, _formatNumber(i), x, lineY + 28,
          textColor.withValues(alpha: 0.6), 12);
    }

    // Points
    final p1 = tx(x1);
    final p2 = tx(x2);

    _drawPoint(
        canvas, p1, lineY, DistanceTheme.accent, 'x₁ = ${_formatNumber(x1)}');
    _drawPoint(canvas, p2, lineY, textColor, 'x₂ = ${_formatNumber(x2)}');

    // Bracket
    _drawBracket(canvas, p1, p2, lineY);
  }

  double _calculateStep(double range) {
    if (range <= 2) return 0.5;
    if (range <= 5) return 1;
    if (range <= 10) return 2;
    return (range / 6).ceilToDouble();
  }

  String _formatNumber(double n) {
    if (n == n.toInt()) return n.toInt().toString();
    return n.toStringAsFixed(1);
  }

  void _drawPoint(
      Canvas canvas, double x, double y, Color color, String label) {
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 14, glowPaint);

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 8, pointPaint);

    _drawText(canvas, label, x, y - 35, color, 13);
  }

  void _drawBracket(Canvas canvas, double p1, double p2, double y) {
    final left = min(p1, p2);
    final right = max(p1, p2);
    final bracketY = y + 50;

    final bracketPaint = Paint()
      ..color = DistanceTheme.accent
      ..strokeWidth = 3;

    canvas.drawLine(
        Offset(left, bracketY - 10), Offset(left, bracketY + 10), bracketPaint);
    canvas.drawLine(Offset(right, bracketY - 10), Offset(right, bracketY + 10),
        bracketPaint);
    canvas.drawLine(
        Offset(left, bracketY), Offset(right, bracketY), bracketPaint);

    // Arrow heads
    final arrowPaint = Paint()
      ..color = DistanceTheme.accent
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(left + 8, bracketY - 4)
      ..lineTo(left, bracketY)
      ..lineTo(left + 8, bracketY + 4);
    canvas.drawPath(path, arrowPaint);

    final path2 = Path()
      ..moveTo(right - 8, bracketY - 4)
      ..lineTo(right, bracketY)
      ..lineTo(right - 8, bracketY + 4);
    canvas.drawPath(path2, arrowPaint);

    _drawText(canvas, 'd = $distanceLabel', (left + right) / 2, bracketY + 20,
        DistanceTheme.accent, 13);
  }

  void _drawText(Canvas canvas, String text, double x, double y, Color color,
      double size) {
    final textSpan = TextSpan(
      text: text,
      style:
          TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w600),
    );
    final textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y));
  }

  @override
  bool shouldRepaint(covariant FullScreenNumberLinePainter oldDelegate) => true;
}
