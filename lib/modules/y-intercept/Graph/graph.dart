// lib/modules/yintercept/graph/yintercept_graph.dart
import 'package:flutter/material.dart';

class YInterceptGraph extends StatelessWidget {
  final String mText;
  final String bText;

  const YInterceptGraph({
    super.key,
    this.mText = '',
    this.bText = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F17),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF059669).withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          size: const Size(double.infinity, 220),
          painter: YInterceptGraphPainter(
            mText: mText,
            bText: bText,
          ),
        ),
      ),
    );
  }
}

class YInterceptGraphPainter extends CustomPainter {
  final String mText;
  final String bText;

  YInterceptGraphPainter({
    required this.mText,
    required this.bText,
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
      ..color = const Color(0xFF10B981).withValues(alpha: 0.1)
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
      ..color = const Color(0xFF6EE7B7).withValues(alpha: 0.3)
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
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.4)
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final linePaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final p0 = toScreen(xMin, m * xMin + b);
    final p1 = toScreen(xMax, m * xMax + b);

    canvas.drawLine(p0, p1, glowPaint);
    canvas.drawLine(p0, p1, linePaint);

    // Draw y-intercept point (gold)
    final yIntPoint = toScreen(0, b);
    canvas.drawCircle(
      yIntPoint,
      8,
      Paint()..color = const Color(0xFFF59E0B),
    );
    canvas.drawCircle(
      yIntPoint,
      4,
      Paint()..color = Colors.white,
    );

    // Draw x-intercept point (emerald)
    if (m != 0) {
      final xIntPoint = toScreen(xIntercept, 0);
      canvas.drawCircle(
        xIntPoint,
        8,
        Paint()..color = const Color(0xFF10B981),
      );
      canvas.drawCircle(
        xIntPoint,
        4,
        Paint()..color = Colors.white,
      );

      // Label x-intercept
      final xLabel = TextPainter(
        text: TextSpan(
          text: '(${xIntercept.toStringAsFixed(1)}, 0)',
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF10B981),
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
        text: '(0, ${b.toStringAsFixed(1)})',
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFFF59E0B),
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    yLabel.paint(canvas, Offset(yIntPoint.dx + 10, yIntPoint.dy - 25));
  }

  void _drawEmptyState(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTWH(40, 40, size.width - 80, size.height - 80),
      paint,
    );

    final text = TextPainter(
      text: const TextSpan(
        text: 'Enter slope and y-intercept',
        style: TextStyle(
          fontSize: 12,
          color: Color(0x806EE7B7),
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
      oldDelegate.mText != mText || oldDelegate.bText != bText;
}