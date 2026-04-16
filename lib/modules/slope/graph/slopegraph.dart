import 'package:calculus_system/modules/slope/types/slope_solver.dart';
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// SlopeGraphScreen
//
// Pass either:
//   • result1 only  → single-line graph
//   • result1 + result2 + comparison → two-line graph with badge
// ═══════════════════════════════════════════════════════════════

class SlopeGraphScreen extends StatelessWidget {
  final SlopeSolverResult result1;
  final SlopeSolverResult? result2;
  final SlopeComparisonResult? comparison;

  const SlopeGraphScreen({
    super.key,
    required this.result1,
    this.result2,
    this.comparison,
  });

  // ── Relationship helpers ───────────────────────────────────

  /// True when the two lines lie exactly on top of each other.
  bool get _isCoincident {
    final r2 = result2;
    if (r2 == null) return false;

    // Both vertical on same x
    if (result1.isVertical && r2.isVertical) {
      return result1.x1 == r2.x1;
    }
    if (result1.isVertical || r2.isVertical) return false;

    // Same slope AND same y-intercept
    final slopeSame = (result1.slope - r2.slope).abs() < 0.0001;
    if (!slopeSame) return false;

    final b1 = result1.y1 - result1.slope * result1.x1;
    final b2 = r2.y1 - r2.slope * r2.x1;
    return (b1 - b2).abs() < 0.0001;
  }

  String get _relationshipLabel {
    if (result2 == null) return '';
    if (_isCoincident) return 'Coincident';
    return switch (comparison?.relationship ?? 'neither') {
      'parallel' => 'Parallel',
      'perpendicular' => 'Perpendicular',
      _ => 'Neither',
    };
  }

  Color get _relationshipColor {
    if (_isCoincident) return const Color(0xFFFFD700);
    return switch (comparison?.relationship ?? 'neither') {
      'parallel' => const Color(0xFF4ECDC4),
      'perpendicular' => const Color(0xFFFFB347),
      _ => const Color(0xFF95A3B3),
    };
  }

  IconData get _relationshipIcon {
    if (_isCoincident) return Icons.layers_rounded;
    return switch (comparison?.relationship ?? 'neither') {
      'parallel' => Icons.trending_up_rounded,
      'perpendicular' => Icons.add_rounded,
      _ => Icons.trending_flat_rounded,
    };
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final label = _relationshipLabel;
    final color = _relationshipColor;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text(
          'Slope Graph',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF12121A),
        iconTheme: const IconThemeData(color: Color(0xFFFF6B6B)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Relationship badge ───────────────────────────
          if (label.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: color.withValues(alpha: 0.35), width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(_relationshipIcon, color: color, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _badgeSubtitle,
                      style: TextStyle(
                        color: color.withValues(alpha: 0.65),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Legend ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                _LegendDot(
                    color: const Color(0xFFFF6B6B), label: result1.equation),
                if (result2 != null && !_isCoincident) ...[
                  const SizedBox(width: 16),
                  _LegendDot(
                      color: const Color(0xFF4ECDC4), label: result2!.equation),
                ],
                if (_isCoincident) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(lines overlap)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Graph ────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size =
                      Size(constraints.maxWidth, constraints.maxHeight);
                  return CustomPaint(
                    size: size,
                    painter: _SlopePainter(
                      result1: result1,
                      result2: result2,
                      isCoincident: _isCoincident,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _badgeSubtitle {
    if (_isCoincident) return '— same line, infinite intersections';
    return switch (comparison?.relationship ?? 'neither') {
      'parallel' => '— same slope, never intersect',
      'perpendicular' => '— slopes multiply to −1',
      _ => '— different slopes, not perpendicular',
    };
  }
}

// ─── Legend dot ───────────────────────────────────────────────

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
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Painter
// ═══════════════════════════════════════════════════════════════

class _SlopePainter extends CustomPainter {
  final SlopeSolverResult result1;
  final SlopeSolverResult? result2;
  final bool isCoincident;

  _SlopePainter({
    required this.result1,
    required this.result2,
    required this.isCoincident,
  });

  // ── Auto-scale: pick a scale so all 4 points are visible ──

  double _computeScale(Size size) {
    final pts = <double>[
      result1.x1.abs(),
      result1.y1.abs(),
      result1.x2.abs(),
      result1.y2.abs(),
      if (result2 != null) ...[
        result2!.x1.abs(),
        result2!.y1.abs(),
        result2!.x2.abs(),
        result2!.y2.abs(),
      ],
    ];
    final maxVal = pts.fold(1.0, (a, b) => b > a ? b : a);
    // Fit maxVal into ~40% of half-canvas with a floor of 20
    final scale = (size.width / 2 * 0.4) / maxVal;
    return scale.clamp(10.0, 40.0);
  }

  Offset _toCanvas(double x, double y, Size size, double scale) {
    return Offset(size.width / 2 + x * scale, size.height / 2 - y * scale);
  }

  String _fmt(double n) => n == n.truncateToDouble()
      ? n.toInt().toString()
      : n.toStringAsFixed(1).replaceAll(RegExp(r'\.?0+$'), '');

  // ── Draw extended line ─────────────────────────────────────

  void _drawExtendedLine(
    Canvas canvas,
    SlopeSolverResult r,
    Paint paint,
    Size size,
    double scale,
  ) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    if (r.isVertical) {
      final canvasX = cx + r.x1 * scale;
      canvas.drawLine(Offset(canvasX, 0), Offset(canvasX, size.height), paint);
      return;
    }

    final b = r.y1 - r.slope * r.x1;

    final leftX = (0 - cx) / scale;
    final leftY = r.slope * leftX + b;

    final rightX = (size.width - cx) / scale;
    final rightY = r.slope * rightX + b;

    canvas.drawLine(
      Offset(0, cy - leftY * scale),
      Offset(size.width, cy - rightY * scale),
      paint,
    );
  }

  // ── Draw equation label near line ─────────────────────────

  void _drawLineLabel(
    Canvas canvas,
    SlopeSolverResult r,
    Color color,
    Size size,
    double scale, {
    double verticalOffset = 0,
  }) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: r.equation,
        style: TextStyle(
          color: color.withValues(alpha: 0.9),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
        ),
      ),
    )..layout(maxWidth: size.width * 0.45);

    // Place label near the right edge of the canvas, offset slightly
    final labelX = size.width - textPainter.width - 8;
    double labelY;

    if (r.isVertical) {
      labelY = 10 + verticalOffset;
    } else {
      final rightX = (size.width - size.width / 2) / scale;
      final rightY = r.slope * rightX + (r.y1 - r.slope * r.x1);
      labelY = (size.height / 2 - rightY * scale) - 18 + verticalOffset;
    }

    labelY = labelY.clamp(4, size.height - 16);
    textPainter.paint(canvas, Offset(labelX, labelY));
  }

  // ── Grid ──────────────────────────────────────────────────

  void _drawGrid(Canvas canvas, Size size, double scale) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.5;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Grid lines every 1 unit
    final stepsX = (cx / scale).ceil();
    final stepsY = (cy / scale).ceil();

    for (int i = -stepsX; i <= stepsX; i++) {
      final x = cx + i * scale;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (int i = -stepsY; i <= stepsY; i++) {
      final y = cy + i * scale;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Axes
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), axisPaint);
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), axisPaint);

    // Tick labels
    final labelStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.35),
      fontSize: 9,
    );

    void drawTick(String text, Offset pos) {
      final tp = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(text: text, style: labelStyle),
      )..layout();
      tp.paint(canvas, pos);
    }

    // X-axis ticks (skip 0)
    for (int i = -stepsX; i <= stepsX; i++) {
      if (i == 0) continue;
      if (i % 2 != 0) continue; // every 2 units to avoid clutter
      final x = cx + i * scale;
      drawTick('$i', Offset(x - 4, cy + 3));
    }

    // Y-axis ticks (skip 0)
    for (int i = -stepsY; i <= stepsY; i++) {
      if (i == 0) continue;
      if (i % 2 != 0) continue;
      final y = cy - i * scale;
      drawTick('$i', Offset(cx + 3, y - 5));
    }

    // Origin label
    drawTick('0', Offset(cx + 3, cy + 3));
  }

  // ── Paint ─────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final scale = _computeScale(size);

    _drawGrid(canvas, size, scale);

    const color1 = Color(0xFFFF6B6B);
    const color2 = Color(0xFF4ECDC4);

    final line1Paint = Paint()
      ..color = color1
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // ── Draw line 1 ──────────────────────────────────────────
    _drawExtendedLine(canvas, result1, line1Paint, size, scale);

    // ── Draw line 2 (if present) ──────────────────────────────
    if (result2 != null) {
      final line2Paint = Paint()
        ..color = isCoincident
            ? color1.withValues(alpha: 0.45) // faded overlay for coincident
            : color2
        ..strokeWidth = isCoincident ? 4.5 : 2.5
        ..style = PaintingStyle.stroke;

      _drawExtendedLine(canvas, result2!, line2Paint, size, scale);
    }

    // ── Equation labels ───────────────────────────────────────
    _drawLineLabel(canvas, result1, color1, size, scale, verticalOffset: 0);
    if (result2 != null && !isCoincident) {
      _drawLineLabel(canvas, result2!, color2, size, scale, verticalOffset: 16);
    }

    // ── Points ────────────────────────────────────────────────
    _drawPoints(canvas, result1, color1, size, scale);
    if (result2 != null && !isCoincident) {
      _drawPoints(canvas, result2!, color2, size, scale);
    }

    // ── Coincident overlay text ────────────────────────────────
    if (isCoincident) {
      _drawCenteredBadge(canvas, size, '⟵ Lines are identical ⟶');
    }
  }

  void _drawPoints(
    Canvas canvas,
    SlopeSolverResult r,
    Color color,
    Size size,
    double scale,
  ) {
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final pts = [
      _toCanvas(r.x1, r.y1, size, scale),
      _toCanvas(r.x2, r.y2, size, scale),
    ];
    final labels = [
      '(${_fmt(r.x1)}, ${_fmt(r.y1)})',
      '(${_fmt(r.x2)}, ${_fmt(r.y2)})',
    ];

    final tp = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < pts.length; i++) {
      canvas.drawCircle(pts[i], 5, dotPaint);
      canvas.drawCircle(pts[i], 8, ringPaint);

      tp.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 10,
          shadows: const [Shadow(blurRadius: 3, color: Colors.black)],
        ),
      );
      tp.layout();

      // Nudge label so it doesn't overlap the dot
      double ox = 10, oy = -16;
      if (pts[i].dx > size.width * 0.75) ox = -tp.width - 6;
      if (pts[i].dy < 20) oy = 10;

      tp.paint(canvas, pts[i] + Offset(ox, oy));
    }
  }

  void _drawCenteredBadge(Canvas canvas, Size size, String text) {
    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFFFFD700),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    )..layout();

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height - 20),
        width: tp.width + 20,
        height: tp.height + 10,
      ),
      const Radius.circular(8),
    );

    canvas.drawRRect(
      bgRect,
      Paint()..color = const Color(0xFFFFD700).withValues(alpha: 0.12),
    );
    tp.paint(
      canvas,
      Offset(size.width / 2 - tp.width / 2, size.height - 20 - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _SlopePainter old) =>
      old.result1 != result1 || old.result2 != result2;
}
