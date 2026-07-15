import 'dart:math';
import 'package:calculus_system/shared/widgets/full_screen_graph_screen.dart';
import 'package:calculus_system/topics/calculus/midterm/theme/distance_theme/distancetheme.dart';
import 'package:flutter/material.dart';

class DistanceGraph extends StatelessWidget {
  final bool is2D;
  final double x1;
  final double? y1;
  final double x2;
  final double? y2;
  final double distance;
  final String distanceLabel;

  const DistanceGraph({
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
    return CustomPaint(
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
    );
  }
}

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

  String get _formula =>
      is2D ? 'd = √((x₂−x₁)² + (y₂−y₁)²)' : 'd = |x₂ − x₁|';

  List<FullScreenInfoItem> get _keyInfo => [
        FullScreenInfoItem(
          label: 'Point A',
          value: is2D ? '($x1, $y1)' : 'x = $x1',
          color: DistanceTheme.accentDefault,
        ),
        FullScreenInfoItem(
          label: 'Point B',
          value: is2D ? '($x2, $y2)' : 'x = $x2',
        ),
        FullScreenInfoItem(
          label: 'Distance',
          value: 'd = $distanceLabel',
          color: DistanceTheme.accentDefault,
        ),
      ];

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenGraphScreen(
          title: 'Distance Graph',
          formula: _formula,
          keyInfo: _keyInfo,
          accentColor: DistanceTheme.accentDefault,
          graph: DistanceGraph(
            is2D: is2D,
            x1: x1,
            y1: y1,
            x2: x2,
            y2: y2,
            distance: distance,
            distanceLabel: distanceLabel,
          ),
        ),
      ),
    );
  }

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
                        border: Border.all(color: DistanceTheme.accent15Static),
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

            // Graph (tap to expand)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => _openFullScreen(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: DistanceTheme.card(context),
                      borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: DistanceTheme.accent15Static),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: DistanceGraph(
                        is2D: is2D,
                        x1: x1,
                        y1: y1,
                        x2: x2,
                        y2: y2,
                        distance: distance,
                        distanceLabel: distanceLabel,
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
                        border: Border.all(color: DistanceTheme.accent15Static),
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
                            DistanceTheme.accentDefault),
                        Container(
                            width: 1,
                            height: 40,
                            color: DistanceTheme.accentDefault.withValues(alpha: 0.2)),
                        _buildInfoItem(
                            context,
                            'Point B',
                            is2D ? '($x2, $y2)' : 'x = $x2',
                            DistanceTheme.text(context)),
                        Container(
                            width: 1,
                            height: 40,
                            color: DistanceTheme.accentDefault.withValues(alpha: 0.2)),
                        _buildInfoItem(context, 'Distance',
                            'd = $distanceLabel', DistanceTheme.accentDefault),
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
    final scaleFactor = min(size.width, size.height) / 400;
    final padding = 60.0 * scaleFactor;
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

    final gridPaint = Paint()
      ..color = DistanceTheme.accentDefault.withValues(alpha: 0.08)
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

    final pointA = Offset(tx(x1), ty(y1));
    final pointB = Offset(tx(x2), ty(y2));

    final glowPaint = Paint()
      ..color = DistanceTheme.accentDefault.withValues(alpha: 0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(pointA, pointB, glowPaint);

    final linePaint = Paint()
      ..color = DistanceTheme.accentDefault
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(pointA, pointB, linePaint);

    final pointRadius = 8.0 * scaleFactor;
    final glowRadius = 15.0 * scaleFactor;
    final fontSize = (12.0 * scaleFactor).clamp(8.0, 16.0);
    final labelOffsetX = 15.0 * scaleFactor;
    final labelOffsetY = 25.0 * scaleFactor;

    final posA = _calculateLabelPosition(
      canvas, size, pointA, pointB, padding, glowRadius,
      labelOffsetX, labelOffsetY, fontSize, 'A', '$x1, $y1', DistanceTheme.accentDefault,
    );
    final posB = _calculateLabelPosition(
      canvas, size, pointB, pointA, padding, glowRadius,
      labelOffsetX, labelOffsetY, fontSize, 'B', '$x2, $y2', textColor,
    );

    _drawPoint(canvas, pointA, DistanceTheme.accentDefault, 'A', '$x1, $y1',
        pointRadius, glowRadius, posA);
    _drawPoint(canvas, pointB, textColor, 'B', '$x2, $y2',
        pointRadius, glowRadius, posB);

    final midX = (pointA.dx + pointB.dx) / 2;
    final midY = (pointA.dy + pointB.dy) / 2;

    final distFontSize = (14.0 * scaleFactor).clamp(9.0, 18.0);
    final distTextSpan = TextSpan(
      text: 'd = $distanceLabel',
      style: TextStyle(
        color: surfaceColor,
        fontSize: distFontSize,
        fontWeight: FontWeight.bold,
      ),
    );
    final distTextPainter = TextPainter(
      text: distTextSpan,
      textDirection: TextDirection.ltr,
    );
    distTextPainter.layout();

    var distLabelY = midY - 25 * scaleFactor;
    final distLabelRect = Rect.fromCenter(
      center: Offset(midX, distLabelY),
      width: distTextPainter.width + 20,
      height: distTextPainter.height + 12,
    );

    final aLabelRect = Rect.fromCenter(
      center: posA,
      width: 120 * scaleFactor,
      height: 30 * scaleFactor,
    );
    final bLabelRect = Rect.fromCenter(
      center: posB,
      width: 120 * scaleFactor,
      height: 30 * scaleFactor,
    );

    if (distLabelRect.overlaps(aLabelRect) || distLabelRect.overlaps(bLabelRect)) {
      distLabelY = midY + 30 * scaleFactor;
    }

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(midX, distLabelY),
        width: distTextPainter.width + 20,
        height: distTextPainter.height + 12,
      ),
      Radius.circular(6 * scaleFactor),
    );

    final bgP = Paint()..color = DistanceTheme.accentDefault;
    canvas.drawRRect(bgRect, bgP);

    distTextPainter.paint(
      canvas,
      Offset(midX - distTextPainter.width / 2, distLabelY - distTextPainter.height / 2),
    );
  }

  Offset _calculateLabelPosition(
    Canvas canvas,
    Size size,
    Offset point,
    Offset otherPoint,
    double padding,
    double glowRadius,
    double labelOffsetX,
    double labelOffsetY,
    double fontSize,
    String label,
    String coords,
    Color color,
  ) {
    final labelSpan = TextSpan(
      text: '$label ($coords)',
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      ),
    );
    final labelPainter = TextPainter(
      text: labelSpan,
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();

    final labelWidth = labelPainter.width;
    final labelHeight = labelPainter.height;

    final positions = <Offset>[];

    positions.add(Offset(point.dx + labelOffsetX, point.dy - labelOffsetY));
    positions.add(Offset(point.dx - labelOffsetX - labelWidth, point.dy - labelOffsetY));
    positions.add(Offset(point.dx + labelOffsetX, point.dy + labelOffsetY));
    positions.add(Offset(point.dx - labelOffsetX - labelWidth, point.dy + labelOffsetY));

    final otherLabelRect = Rect.fromCenter(
      center: otherPoint,
      width: 120,
      height: 30,
    );

    for (final pos in positions) {
      final testRect = Rect.fromLTWH(pos.dx, pos.dy, labelWidth, labelHeight);
      if (!testRect.overlaps(otherLabelRect) &&
          pos.dx >= padding &&
          pos.dx + labelWidth <= size.width - padding &&
          pos.dy >= padding &&
          pos.dy + labelHeight <= size.height - padding) {
        return Offset(pos.dx + labelWidth / 2, pos.dy + labelHeight / 2);
      }
    }

    return Offset(point.dx + labelOffsetX, point.dy - labelOffsetY);
  }

  void _drawPoint(Canvas canvas, Offset position, Color color, String label,
      String coords, double pointRadius, double glowRadius, Offset labelCenter) {
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, glowRadius, glowPaint);

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, pointRadius, pointPaint);

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
    labelPainter.paint(
      canvas,
      Offset(labelCenter.dx - labelPainter.width / 2, labelCenter.dy - labelPainter.height / 2),
    );
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
    final scaleFactor = min(size.width, size.height) / 400;
    final padding = (80.0 * scaleFactor).clamp(40.0, 120.0);
    final lineY = size.height / 2;
    final lineStart = padding;
    final lineEnd = size.width - padding;

    final minVal = min(x1, x2) - (distance * 0.5 + 2);
    final maxVal = max(x1, x2) + (distance * 0.5 + 2);
    final range = maxVal - minVal;
    final scale = (lineEnd - lineStart) / range;

    double tx(double x) => lineStart + (x - minVal) * scale;

    final trackHeight = (60.0 * scaleFactor).clamp(30.0, 80.0);

    // Number line track
    final trackPaint = Paint()
      ..color = DistanceTheme.accentDefault.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, lineY),
          width: size.width - padding * 2,
          height: trackHeight,
        ),
        Radius.circular(12 * scaleFactor),
      ),
      trackPaint,
    );

    // Main line
    final linePaint = Paint()
      ..color = textColor.withValues(alpha: 0.4)
      ..strokeWidth = (4 * scaleFactor).clamp(2.0, 6.0);
    canvas.drawLine(
        Offset(lineStart, lineY), Offset(lineEnd, lineY), linePaint);

    // Ticks
    final tickPaint = Paint()
      ..color = textColor.withValues(alpha: 0.3)
      ..strokeWidth = (2 * scaleFactor).clamp(1.0, 3.0);

    final tickFontSize = (12.0 * scaleFactor).clamp(8.0, 16.0);
    final tickHeight = (10.0 * scaleFactor).clamp(5.0, 15.0);
    final tickLabelOffset = (28.0 * scaleFactor).clamp(16.0, 40.0);

    final step = _calculateStep(range, lineEnd - lineStart, tickFontSize);
    final tickFormat = _chooseTickFormat(step);
    for (double i = minVal; i <= maxVal; i += step) {
      final x = tx(i);
      canvas.drawLine(
          Offset(x, lineY - tickHeight), Offset(x, lineY + tickHeight), tickPaint);
      _drawText(canvas, _formatNumber(i, tickFormat), x, lineY + tickLabelOffset,
          textColor.withValues(alpha: 0.6), tickFontSize);
    }

    // Points
    final p1 = tx(x1);
    final p2 = tx(x2);

    final pointRadius = (8.0 * scaleFactor).clamp(5.0, 12.0);
    final glowRadius = (14.0 * scaleFactor).clamp(8.0, 20.0);
    final pointFontSize = (13.0 * scaleFactor).clamp(9.0, 18.0);
    final pointLabelOffset = (35.0 * scaleFactor).clamp(22.0, 50.0);

    _drawPoint(canvas, p1, lineY, DistanceTheme.accentDefault,
        'x₁ = ${_formatNumber(x1, tickFormat)}',
        pointRadius, glowRadius, pointLabelOffset, pointFontSize);
    _drawPoint(canvas, p2, lineY, textColor,
        'x₂ = ${_formatNumber(x2, tickFormat)}',
        pointRadius, glowRadius, pointLabelOffset, pointFontSize);

    // Bracket
    _drawBracket(canvas, p1, p2, lineY, scaleFactor, tickFormat);
  }

  double _calculateStep(double range, double availableWidth, double fontSize) {
    // Estimate the pixel width of a tick label to find the max ticks we can fit
    final avgCharWidth = fontSize * 0.6;
    final minPixelSpacing = avgCharWidth * 3.5;

    if (range <= 0) return 1;

    double tryStep(double step) {
      if (step <= 0) return 1;
      final numTicks = range / step;
      final pixelPerTick = availableWidth / numTicks;
      return pixelPerTick;
    }

    final candidates = [0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0];
    for (final step in candidates) {
      if (tryStep(step) >= minPixelSpacing) return step;
    }

    final autoStep = (range * minPixelSpacing / availableWidth);
    final magnitude = pow(10, (log(autoStep) / ln10).floor());
    return (autoStep / magnitude).ceilToDouble() * magnitude;
  }

  String _chooseTickFormat(double step) {
    if (step < 1) return 'oneDecimal';
    return 'integer';
  }

  String _formatNumber(double n, String format) {
    if (format == 'oneDecimal') {
      final rounded = (n * 10).roundToDouble() / 10;
      if (rounded == rounded.toInt()) return rounded.toInt().toString();
      return rounded.toStringAsFixed(1);
    }
    final rounded = n.roundToDouble();
    return rounded.toInt().toString();
  }

  void _drawPoint(Canvas canvas, double x, double y, Color color, String label,
      double pointRadius, double glowRadius, double labelOffset, double fontSize) {
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), glowRadius, glowPaint);

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), pointRadius, pointPaint);

    _drawText(canvas, label, x, y - labelOffset, color, fontSize);
  }

  void _drawBracket(Canvas canvas, double p1, double p2, double y,
      double scaleFactor, String tickFormat) {
    final left = min(p1, p2);
    final right = max(p1, p2);
    final bracketY = y + 50 * scaleFactor;

    final bracketPaint = Paint()
      ..color = DistanceTheme.accentDefault
      ..strokeWidth = (3 * scaleFactor).clamp(2.0, 5.0);

    final armLength = (10.0 * scaleFactor).clamp(6.0, 16.0);
    canvas.drawLine(
        Offset(left, bracketY - armLength), Offset(left, bracketY + armLength), bracketPaint);
    canvas.drawLine(Offset(right, bracketY - armLength), Offset(right, bracketY + armLength),
        bracketPaint);
    canvas.drawLine(
        Offset(left, bracketY), Offset(right, bracketY), bracketPaint);

    // Arrow heads
    final arrowPaint = Paint()
      ..color = DistanceTheme.accentDefault
      ..style = PaintingStyle.fill;

    final arrowSize = (8.0 * scaleFactor).clamp(4.0, 12.0);
    final path = Path()
      ..moveTo(left + arrowSize, bracketY - 4 * scaleFactor)
      ..lineTo(left, bracketY)
      ..lineTo(left + arrowSize, bracketY + 4 * scaleFactor);
    canvas.drawPath(path, arrowPaint);

    final path2 = Path()
      ..moveTo(right - arrowSize, bracketY - 4 * scaleFactor)
      ..lineTo(right, bracketY)
      ..lineTo(right - arrowSize, bracketY + 4 * scaleFactor);
    canvas.drawPath(path2, arrowPaint);

    final bracketFontSize = (13.0 * scaleFactor).clamp(9.0, 18.0);
    final bracketLabelOffset = (20.0 * scaleFactor).clamp(12.0, 30.0);
    _drawText(canvas, 'd = $distanceLabel', (left + right) / 2,
        bracketY + bracketLabelOffset, DistanceTheme.accentDefault, bracketFontSize);
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
