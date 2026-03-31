import 'package:flutter/material.dart';

class SlopeGraphScreen extends StatelessWidget {
  final double x1, y1, x2, y2;
  final double? x3, y3, x4, y4;

  const SlopeGraphScreen({
    super.key,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    this.x3,
    this.y3,
    this.x4,
    this.y4,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Slope Graph"),
        backgroundColor: const Color(0xFF2A1010),
        iconTheme: const IconThemeData(color: Color(0xFFFF6B6B)),
      ),
      backgroundColor: const Color(0xFF0A0A0F),
      body: Center(
        child: CustomPaint(
          size: const Size(300, 300),
          painter: _SlopePainter(x1, y1, x2, y2, x3, y3, x4, y4),
        ),
      ),
    );
  }
}

class _SlopePainter extends CustomPainter {
  final double x1, y1, x2, y2;
  final double? x3, y3, x4, y4;

  _SlopePainter(this.x1, this.y1, this.x2, this.y2, this.x3, this.y3, this.x4, this.y4);

  // Convert Cartesian coords to canvas points (with padding & origin in middle)
  Offset _toCanvas(double x, double y, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // scale factor for plotting, adjust to zoom
    const scale = 20.0;

    return Offset(centerX + x * scale, centerY - y * scale);
  }

  String _formatNum(double num) {
    if (num % 1 == 0) {
      return num.toInt().toString();
    }
    return num.toStringAsFixed(1);
  }

  // Draw extended line across canvas using slope-intercept form
  void _drawExtendedLine(Canvas canvas, double x1, double y1, double x2, double y2, Paint paint, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    const scale = 20.0;

    // Calculate slope
    final dx = x2 - x1;
    final dy = y2 - y1;

    if (dx == 0) {
      // Vertical line
      final canvasX = centerX + x1 * scale;
      canvas.drawLine(Offset(canvasX, 0), Offset(canvasX, size.height), paint);
    } else {
      // Regular line: extend across canvas
      final slope = dy / dx;
      final b = y1 - (slope * x1);

      // Calculate points at canvas edges
      // Left edge (x = -canvas_width/2 / scale)
      const leftCanvasX = 0.0;
      final leftX = (leftCanvasX - centerX) / scale;
      final leftY = slope * leftX + b;
      final leftPoint = Offset(leftCanvasX, centerY - leftY * scale);

      // Right edge (x = canvas_width/2 / scale)
      final rightCanvasX = size.width;
      final rightX = (rightCanvasX - centerX) / scale;
      final rightY = slope * rightX + b;
      final rightPoint = Offset(rightCanvasX, centerY - rightY * scale);

      // Draw extended line
      canvas.drawLine(leftPoint, rightPoint, paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paintAxis = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    final paintPoint = Paint()
      ..color = const Color(0xFFFF6B6B)
      ..style = PaintingStyle.fill;

    final paintLine = Paint()
      ..color = const Color(0xFFFF6B6B)
      ..strokeWidth = 2.5;

    // Draw axes
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paintAxis,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paintAxis,
    );

    // Draw extended line 1 across entire canvas
    _drawExtendedLine(canvas, x1, y1, x2, y2, paintLine, size);

    // Draw points for line 1
    final p1 = _toCanvas(x1, y1, size);
    final p2 = _toCanvas(x2, y2, size);
    canvas.drawCircle(p1, 6, paintPoint);
    canvas.drawCircle(p2, 6, paintPoint);

    // Draw second line if provided
    if (x3 != null && y3 != null && x4 != null && y4 != null) {
      final paintLine2 = Paint()
        ..color = const Color(0xFF4ECDC4)
        ..strokeWidth = 2.5;

      // Draw extended line 2
      _drawExtendedLine(canvas, x3!, y3!, x4!, y4!, paintLine2, size);

      // Draw points for line 2
      final p3 = _toCanvas(x3!, y3!, size);
      final p4 = _toCanvas(x4!, y4!, size);
      canvas.drawCircle(p3, 6, paintLine2);
      canvas.drawCircle(p4, 6, paintLine2);

      // Draw labels for second line
      final textPainter = TextPainter(
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );

      void drawLabel(String label, Offset pos) {
        final span = TextSpan(
          text: label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        );
        textPainter.text = span;
        textPainter.layout();
        textPainter.paint(canvas, pos + const Offset(6, -18));
      }

      drawLabel("(${_formatNum(x3!)}, ${_formatNum(y3!)})", p3);
      drawLabel("(${_formatNum(x4!)}, ${_formatNum(y4!)})", p4);
    }

    // Draw labels for first line
    final textPainter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    void drawLabel(String label, Offset pos) {
      final span = TextSpan(
        text: label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      );
      textPainter.text = span;
      textPainter.layout();
      textPainter.paint(canvas, pos + const Offset(6, -18));
    }

    drawLabel("(${_formatNum(x1)}, ${_formatNum(y1)})", p1);
    drawLabel("(${_formatNum(x2)}, ${_formatNum(y2)})", p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}