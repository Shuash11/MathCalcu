// lib/modules/yintercept/graph/yintercept_graph.dart
import 'package:flutter/material.dart';

String _fmt(double v) {
  if (v == v.truncateToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(1);
}

class YInterceptGraph extends StatelessWidget {
  final String mText;
  final String bText;
  final double? height;
  final Color accentColor;
  final Color backgroundColor;

  const YInterceptGraph({
    super.key,
    this.mText = '',
    this.bText = '',
    this.height,
    this.accentColor = const Color(0xFF334155),
    this.backgroundColor = const Color(0xFFF4F4F1),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return CustomPaint(
              size: Size(
                constraints.maxWidth,
                height ?? constraints.maxHeight,
              ),
              painter: YInterceptGraphPainter(
                mText: mText,
                bText: bText,
                accentColor: accentColor,
                backgroundColor: backgroundColor,
              ),
            );
          },
        ),
      ),
    );
  }
}

class YInterceptGraphPainter extends CustomPainter {
  final String mText;
  final String bText;
  final Color accentColor;
  final Color backgroundColor;

  YInterceptGraphPainter({
    required this.mText,
    required this.bText,
    required this.accentColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final m = double.tryParse(mText);
    final b = double.tryParse(bText);

    if (m == null || b == null) {
      _drawEmptyState(canvas, size);
      return;
    }

    const padding = 40.0;
    final innerW = size.width - padding * 2;
    final innerH = size.height - padding * 2;

    // Calculate view bounds
    final yIntercept = b;
    final xIntercept = -b / m;

    // Center the view on the intercepts
    final centerX = xIntercept;
    final centerY = yIntercept;
    const range = 10.0;

    final xMin = centerX - range;
    final xMax = centerX + range;
    final yMin = centerY - range;
    final yMax = centerY + range;

    Offset toScreen(double wx, double wy) {
      final sx = padding + ((wx - xMin) / (xMax - xMin)) * innerW;
      final sy = padding + (1 - (wy - yMin) / (yMax - yMin)) * innerH;
      return Offset(sx, sy);
    }

    // Draw grid
    final gridPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    for (int gx = xMin.ceil(); gx <= xMax.floor(); gx++) {
      final s = toScreen(gx.toDouble(), 0);
      canvas.drawLine(
        Offset(s.dx, padding),
        Offset(s.dx, size.height - padding),
        gridPaint,
      );
    }

    for (int gy = yMin.ceil(); gy <= yMax.floor(); gy++) {
      final s = toScreen(0, gy.toDouble());
      canvas.drawLine(
        Offset(padding, s.dy),
        Offset(size.width - padding, s.dy),
        gridPaint,
      );
    }

    // Draw axes
    final axisPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.5;

    if (yMin <= 0 && yMax >= 0) {
      final s = toScreen(0, 0);
      canvas.drawLine(
        Offset(padding, s.dy),
        Offset(size.width - padding, s.dy),
        axisPaint,
      );
    }

    if (xMin <= 0 && xMax >= 0) {
      final s = toScreen(0, 0);
      canvas.drawLine(
        Offset(s.dx, padding),
        Offset(s.dx, size.height - padding),
        axisPaint,
      );
    }

    // Draw line with glow
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.4)
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final linePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final p0 = toScreen(xMin, m * xMin + b);
    final p1 = toScreen(xMax, m * xMax + b);

    canvas.drawLine(p0, p1, glowPaint);
    canvas.drawLine(p0, p1, linePaint);

    // Draw y-intercept point
    final yIntPoint = toScreen(0, b);
    canvas.drawCircle(
      yIntPoint,
      8,
      Paint()..color = accentColor,
    );
    canvas.drawCircle(
      yIntPoint,
      4,
      Paint()..color = Colors.white,
    );

    // Draw x-intercept point
    if (m != 0) {
      final xIntPoint = toScreen(xIntercept, 0);
      canvas.drawCircle(
        xIntPoint,
        8,
        Paint()..color = accentColor,
      );
      canvas.drawCircle(
        xIntPoint,
        4,
        Paint()..color = Colors.white,
      );

      // Label x-intercept
      final xLabel = TextPainter(
        text: TextSpan(
          text: '(${_fmt(xIntercept)}, 0)',
          style: TextStyle(
            fontSize: 10,
            color: accentColor,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      xLabel.paint(canvas, Offset(xIntPoint.dx + 10, xIntPoint.dy - 20));
    }

    // Label y-intercept
    final yLabel = TextPainter(
      text: TextSpan(
        text: '(0, ${_fmt(b)})',
        style: TextStyle(
          fontSize: 10,
          color: accentColor,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    yLabel.paint(canvas, Offset(yIntPoint.dx + 10, yIntPoint.dy - 25));
  }

  void _drawEmptyState(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor.withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTWH(40, 40, size.width - 80, size.height - 80),
      paint,
    );

    final text = TextPainter(
      text: TextSpan(
        text: 'Enter slope and y-intercept',
        style: TextStyle(
          fontSize: 12,
          color: accentColor.withValues(alpha: 0.5),
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    text.paint(
      canvas,
      Offset((size.width - text.width) / 2, (size.height - text.height) / 2),
    );
  }

  @override
  bool shouldRepaint(covariant YInterceptGraphPainter oldDelegate) =>
      oldDelegate.mText != mText ||
      oldDelegate.bText != bText ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.backgroundColor != backgroundColor;
}
