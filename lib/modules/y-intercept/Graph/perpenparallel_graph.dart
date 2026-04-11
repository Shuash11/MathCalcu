// lib/modules/yintercept/screens/parallel_perpendicular_graph.dart
import 'package:calculus_system/modules/y-intercept/Theme/theme.dart';
import 'package:calculus_system/modules/y-intercept/solver/parallel_perpendicular.dart';

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// GRAPH SHEET
// Usage: call showGraphSheet(context, result) from anywhere.
// ─────────────────────────────────────────────────────────────

void showGraphSheet(BuildContext context, PPResult result) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _GraphSheet(result: result),
  );
}

class _GraphSheet extends StatelessWidget {
  final PPResult result;
  const _GraphSheet({required this.result});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF06B6D4);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.45,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: YITheme.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: accent.withValues(alpha: 0.28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Graph', style: YITheme.titleStyle(context)),
                          const SizedBox(height: 2),
                          Text(
                            '${result.verdictSymbol}  ${result.verdict}',
                            style: YITheme.subtitleStyle(context)
                                .copyWith(color: accent.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: accent),
                    ),
                  ],
                ),
              ),
              // legend
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _LegendDot(
                      color: const Color(0xFF06B6D4),
                      label: result.slopeIntercept1,
                    ),
                    const SizedBox(width: 16),
                    _LegendDot(
                      color: const Color(0xFF10B981),
                      label: result.slopeIntercept2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // canvas
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: YITheme.isLight(context)
                          ? const Color(0xFFF8FAFC)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accent.withValues(alpha: 0.2)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomPaint(
                        painter: PPLinePainter(result: result),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// LEGEND DOT
// ─────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: YITheme.subtitleStyle(context).copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// LINE PAINTER
// Draws both lines on a cartesian grid with full axis labels.
// ─────────────────────────────────────────────────────────────

class PPLinePainter extends CustomPainter {
  final PPResult result;

  const PPLinePainter({required this.result});

  static const double _range = 8.0;

  // Margin reserved for axis labels (left & bottom)
  static const double _marginLeft = 28.0;
  static const double _marginBottom = 22.0;
  static const double _marginRight = 16.0;
  static const double _marginTop = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Plot area dimensions
    final plotW = size.width - _marginLeft - _marginRight;
    final plotH = size.height - _marginTop - _marginBottom;

    // ── Coordinate converters (within plot area) ──────────────
    double toScreenX(double mathX) =>
        _marginLeft + (mathX + _range) / (2 * _range) * plotW;
    double toScreenY(double mathY) =>
        _marginTop + (1 - (mathY + _range) / (2 * _range)) * plotH;
    double fromScreenX(double px) =>
        (px - _marginLeft) / plotW * (2 * _range) - _range;

    // ── Grid lines ────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 0.5;

    for (double v = -_range; v <= _range; v++) {
      canvas.drawLine(
        Offset(toScreenX(v), _marginTop),
        Offset(toScreenX(v), _marginTop + plotH),
        gridPaint,
      );
      canvas.drawLine(
        Offset(_marginLeft, toScreenY(v)),
        Offset(_marginLeft + plotW, toScreenY(v)),
        gridPaint,
      );
    }

    // ── Axes ──────────────────────────────────────────────────
    final axisPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.55)
      ..strokeWidth = 1.2;

    // Y-axis
    canvas.drawLine(
      Offset(toScreenX(0), _marginTop),
      Offset(toScreenX(0), _marginTop + plotH),
      axisPaint,
    );
    // X-axis
    canvas.drawLine(
      Offset(_marginLeft, toScreenY(0)),
      Offset(_marginLeft + plotW, toScreenY(0)),
      axisPaint,
    );

    // ── Axis arrow heads ──────────────────────────────────────
    final arrowPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.55)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.fill;

    void drawArrow(Offset tip, Offset dir) {
      const sz = 5.0;
      final perp = Offset(-dir.dy, dir.dx);
      final path = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - dir.dx * sz + perp.dx * (sz / 2),
            tip.dy - dir.dy * sz + perp.dy * (sz / 2))
        ..lineTo(tip.dx - dir.dx * sz - perp.dx * (sz / 2),
            tip.dy - dir.dy * sz - perp.dy * (sz / 2))
        ..close();
      canvas.drawPath(path, arrowPaint);
    }

    // Up arrow on Y-axis
    drawArrow(Offset(toScreenX(0), _marginTop), const Offset(0, -1));
    // Right arrow on X-axis
    drawArrow(Offset(_marginLeft + plotW, toScreenY(0)), const Offset(1, 0));

    // ── Axis name labels  x, y ────────────────────────────────
    final axisNameStyle = TextStyle(
      color: Colors.grey.withValues(alpha: 0.75),
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    void drawText(String text, double sx, double sy, {TextAlign align = TextAlign.left}) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: axisNameStyle),
        textDirection: TextDirection.ltr,
        textAlign: align,
      )..layout();
      tp.paint(canvas, Offset(sx, sy));
    }

    // "x" to the right of the x-axis arrow
    drawText('x', _marginLeft + plotW + 4, toScreenY(0) - 7);
    // "y" above the y-axis arrow
    drawText('y', toScreenX(0) + 4, _marginTop - 14);

    // ── Tick labels ───────────────────────────────────────────
    final tickStyle = TextStyle(
      color: Colors.grey.withValues(alpha: 0.55),
      fontSize: 8.5,
    );

    void drawTick(String text, double sx, double sy) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: tickStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      // Centre horizontally / vertically
      tp.paint(canvas, Offset(sx - tp.width / 2, sy - tp.height / 2));
    }

    // Tick marks on x-axis (every 2 units)
    for (double v = -_range + 2; v <= _range - 2; v += 2) {
      if (v == 0) continue;
      // small tick line
      canvas.drawLine(
        Offset(toScreenX(v), toScreenY(0) - 3),
        Offset(toScreenX(v), toScreenY(0) + 3),
        Paint()..color = Colors.grey.withValues(alpha: 0.4)..strokeWidth = 0.8,
      );
      drawTick(v.toInt().toString(), toScreenX(v), toScreenY(0) + 9);
    }

    // Tick marks on y-axis (every 2 units)
    for (double v = -_range + 2; v <= _range - 2; v += 2) {
      if (v == 0) continue;
      canvas.drawLine(
        Offset(toScreenX(0) - 3, toScreenY(v)),
        Offset(toScreenX(0) + 3, toScreenY(v)),
        Paint()..color = Colors.grey.withValues(alpha: 0.4)..strokeWidth = 0.8,
      );
      drawTick(v.toInt().toString(), toScreenX(0) - 10, toScreenY(v));
    }

    // Origin label "0"
    drawTick('0', toScreenX(0) - 8, toScreenY(0) + 9);

    // ── Draw one line given Ax + By + C = 0 ──────────────────
    void drawLine(int A, int B, int C, Color color) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;

      if (B == 0) {
        if (A == 0) return;
        final x = -C / A;
        canvas.drawLine(
          Offset(toScreenX(x), _marginTop),
          Offset(toScreenX(x), _marginTop + plotH),
          paint,
        );
        return;
      }

      final xLeft = fromScreenX(_marginLeft);
      final xRight = fromScreenX(_marginLeft + plotW);
      final yLeft = (-A * xLeft - C) / B;
      final yRight = (-A * xRight - C) / B;

      canvas.drawLine(
        Offset(toScreenX(xLeft), toScreenY(yLeft)),
        Offset(toScreenX(xRight), toScreenY(yRight)),
        paint,
      );
    }

    drawLine(result.a1, result.b1, result.c1, const Color(0xFF06B6D4));
    drawLine(result.a2, result.b2, result.c2, const Color(0xFF10B981));

    // ── Equation labels at line endpoints ────────────────────
    void drawLineLabel(int A, int B, int C, String label, Color color) {
      if (B == 0) return; // skip vertical for now

      final xRight = fromScreenX(_marginLeft + plotW - 4);
      final yAtRight = (-A * xRight - C) / B;
      final sy = toScreenY(yAtRight);

      // Clamp inside plot area
      final clampedSY = sy.clamp(_marginTop + 4.0, _marginTop + plotH - 14.0);

      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            backgroundColor: Colors.black.withValues(alpha: 0.35),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(_marginLeft + plotW - tp.width - 6, clampedSY),
      );
    }

    drawLineLabel(result.a1, result.b1, result.c1, result.slopeIntercept1, const Color(0xFF06B6D4));
    drawLineLabel(result.a2, result.b2, result.c2, result.slopeIntercept2, const Color(0xFF10B981));

    // ── Intersection dot (perpendicular / neither) ────────────
    if (result.relationship == PPRelationship.perpendicular ||
        result.relationship == PPRelationship.neither) {
      final det = result.a1 * result.b2 - result.a2 * result.b1;
      if (det != 0) {
        final ix = (-result.c1 * result.b2 + result.c2 * result.b1) / det;
        final iy = (-result.a1 * (-result.c2) + result.a2 * (-result.c1)) / det;
        if (ix.abs() <= _range && iy.abs() <= _range) {
          canvas.drawCircle(
            Offset(toScreenX(ix), toScreenY(iy)),
            5,
            Paint()..color = Colors.white..style = PaintingStyle.fill,
          );
          canvas.drawCircle(
            Offset(toScreenX(ix), toScreenY(iy)),
            5,
            Paint()
              ..color = Colors.orange
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );

          // Coordinates label at intersection
          final coordLabel = '(${_fmt(ix)}, ${_fmt(iy)})';
          final ctp = TextPainter(
            text: TextSpan(
              text: coordLabel,
              style: TextStyle(
                color: Colors.orange.withValues(alpha: 0.9),
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          ctp.paint(canvas, Offset(toScreenX(ix) + 7, toScreenY(iy) - 10));
        }
      }
    }
  }

  /// Format a double for the intersection label: show as integer if whole.
  static String _fmt(double v) {
    final r = (v * 100).round() / 100;
    return r == r.truncateToDouble() ? r.toInt().toString() : r.toString();
  }

  @override
  bool shouldRepaint(PPLinePainter oldDelegate) =>
      oldDelegate.result.a1 != result.a1 ||
      oldDelegate.result.b1 != result.b1 ||
      oldDelegate.result.c1 != result.c1 ||
      oldDelegate.result.a2 != result.a2 ||
      oldDelegate.result.b2 != result.b2 ||
      oldDelegate.result.c2 != result.c2;
}