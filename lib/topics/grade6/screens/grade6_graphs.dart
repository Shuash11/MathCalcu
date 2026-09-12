// ─────────────────────────────────────────────────────────────
// GRADE 6 GRAPHS — BaseGraph painters driven by solver customData.
//
// Each solver returns graph-ready data in SolveResult.customData:
//   G6-7 integers  → {a, result, min, max, jumps:[{from,to}]}
//   G6-4 ratio     → {bars:[{label,value}], ...}
//   G6-8 geometry  → {shape, dims:{...}}
//   G6-9 volume    → {solid, dims:[...], formula}
//   G6-10 pie      → {total, slices:[{label,value,percent,degrees}]}
//
// Offline CustomPainters. Colors come from the theme accent +
// text colors passed in — no hardcoded hex in this file.
// ─────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:calculus_system/core/base_graph.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:flutter/material.dart';

/// Reads customData[0] as a map, or returns an empty map.
Map<String, dynamic> _dataOf(SolveResult result) {
  final data = result.customData;
  if (data == null || data.isEmpty) return const {};
  final first = data.first;
  if (first is Map<String, dynamic>) return first;
  if (first is Map) return Map<String, dynamic>.from(first);
  return const {};
}

void _label(
  Canvas canvas,
  String text,
  Offset at, {
  required Color color,
  double size = 11,
  FontWeight weight = FontWeight.w600,
  TextAlign align = TextAlign.center,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: size, fontWeight: weight),
    ),
    textAlign: align,
    textDirection: TextDirection.ltr,
  )..layout();
  final offset = switch (align) {
    TextAlign.center => at - Offset(painter.width / 2, painter.height / 2),
    TextAlign.right => at - Offset(painter.width, painter.height / 2),
    _ => at - Offset(0, painter.height / 2),
  };
  painter.paint(canvas, offset);
}

// ── Number line (G6-7 integers) ─────────────────────────────────

class G6NumberLineGraph extends BaseGraph {
  final Color textPrimary;
  final Color textSecondary;

  const G6NumberLineGraph({
    super.key,
    required super.result,
    required super.accentColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NumberLinePainter(
        data: _dataOf(result),
        accent: accentColor,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
      ),
    );
  }
}

class _NumberLinePainter extends CustomPainter {
  final Map<String, dynamic> data;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;

  _NumberLinePainter({
    required this.data,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
  });

  double _num(Object? v, double fallback) {
    if (v is num) return v.toDouble();
    return fallback;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final a = _num(data['a'], 0);
    final answer = _num(data['result'], a);
    var min = _num(data['min'], math.min(a, answer) - 2);
    var max = _num(data['max'], math.max(a, answer) + 2);
    if ((max - min).abs() < 1e-9) {
      min -= 2;
      max += 2;
    }

    const pad = 28.0;
    final midY = size.height * 0.52;
    final axis = Paint()
      ..color = textSecondary.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(pad, midY), Offset(size.width - pad, midY), axis);

    // Arrowhead at the right end.
    final head = Paint()..color = textSecondary.withValues(alpha: 0.5);
    const headLen = 8.0;
    final right = Offset(size.width - pad, midY);
    canvas.drawPath(
      Path()
        ..moveTo(right.dx, midY)
        ..lineTo(right.dx - headLen, midY - 4)
        ..lineTo(right.dx - headLen, midY + 4)
        ..close(),
      head,
    );

    double xOf(double v) =>
        pad + (v - min) / (max - min) * (size.width - pad * 2);

    // Ticks for every integer in range (cap at ~21 ticks).
    final lo = min.ceil();
    final hi = max.floor();
    final span = hi - lo;
    final step = span > 20 ? ((span / 20).ceil()) : 1;
    for (var t = lo; t <= hi; t += step) {
      final x = xOf(t.toDouble());
      canvas.drawLine(
        Offset(x, midY - 5),
        Offset(x, midY + 5),
        Paint()
          ..color = textSecondary.withValues(alpha: 0.35)
          ..strokeWidth = 1.5,
      );
      _label(canvas, '$t', Offset(x, midY + 20), color: textSecondary, size: 10);
    }

    // Jump arrow from a to the answer, arcing above the axis.
    final fromX = xOf(a);
    final toX = xOf(answer);
    if ((toX - fromX).abs() > 2) {
      final jump = Paint()
        ..color = accent
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final lift = math.min(56.0, size.height * 0.28);
      canvas.drawPath(
        Path()
          ..moveTo(fromX, midY - 8)
          ..quadraticBezierTo(
            (fromX + toX) / 2,
            midY - 8 - lift,
            toX,
            midY - 8,
          ),
        jump,
      );
      // Arrowhead into the landing point.
      final dir = toX > fromX ? 1.0 : -1.0;
      canvas.drawPath(
        Path()
          ..moveTo(toX, midY - 8)
          ..lineTo(toX - dir * 8, midY - 14)
          ..lineTo(toX - dir * 8, midY - 2)
          ..close(),
        Paint()..color = accent,
      );
    }

    // Start marker (hollow) and answer marker (filled).
    canvas.drawCircle(
      Offset(fromX, midY),
      6,
      Paint()
        ..color = accent.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(fromX, midY),
      6,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(Offset(toX, midY), 7, Paint()..color = accent);
    _label(
      canvas,
      '${answer.round() == answer ? answer.toInt() : answer}',
      Offset(toX.clamp(pad, size.width - pad), midY - 34),
      color: textPrimary,
      size: 14,
      weight: FontWeight.w800,
    );
  }

  @override
  bool shouldRepaint(covariant _NumberLinePainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.accent != accent;
}

// ── Bar strips (G6-4 ratio) ─────────────────────────────────────

class G6RatioBarsGraph extends BaseGraph {
  final Color textPrimary;
  final Color textSecondary;

  const G6RatioBarsGraph({
    super.key,
    required super.result,
    required super.accentColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RatioBarsPainter(
        data: _dataOf(result),
        accent: accentColor,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
      ),
    );
  }
}

class _RatioBarsPainter extends CustomPainter {
  final Map<String, dynamic> data;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;

  _RatioBarsPainter({
    required this.data,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final raw = data['bars'];
    final bars = raw is List ? raw.take(4).toList() : const [];
    if (bars.isEmpty) {
      _label(
        canvas,
        'Solve to see the bar strips',
        Offset(size.width / 2, size.height / 2),
        color: textSecondary,
      );
      return;
    }
    double maxV = 1;
    for (final b in bars) {
      final v = b is Map && b['value'] is num
          ? (b['value'] as num).toDouble().abs()
          : 0.0;
      if (v > maxV) maxV = v;
    }
    const leftPad = 64.0;
    const rightPad = 56.0;
    final rowH = size.height / (bars.length + 0.6);
    for (var i = 0; i < bars.length; i++) {
      final b = bars[i] as Map;
      final label = '${b['label'] ?? ''}';
      final v = b['value'] is num ? (b['value'] as num).toDouble() : 0.0;
      final cy = rowH * (i + 0.8);
      final w = (v.abs() / maxV) * (size.width - leftPad - rightPad);
      _label(
        canvas,
        label,
        Offset(leftPad - 10, cy),
        color: textPrimary,
        align: TextAlign.right,
      );
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(leftPad, cy - 11, math.max(w, 4), 22),
        const Radius.circular(6),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = accent.withValues(alpha: 0.25 + 0.15 * (i % 3)),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      _label(
        canvas,
        v == v.roundToDouble() ? '${v.toInt()}' : '$v',
        Offset(leftPad + w + 8, cy),
        color: textSecondary,
        align: TextAlign.left,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RatioBarsPainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.accent != accent;
}

// ── Shape diagram (G6-8 geometry) ───────────────────────────────

class G6ShapeGraph extends BaseGraph {
  final Color textPrimary;
  final Color textSecondary;

  const G6ShapeGraph({
    super.key,
    required super.result,
    required super.accentColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShapePainter(
        data: _dataOf(result),
        accent: accentColor,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final Map<String, dynamic> data;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;

  _ShapePainter({
    required this.data,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
  });

  String _dim(Map dims, String key) {
    final v = dims[key];
    if (v is num) {
      return v == v.roundToDouble() ? '${v.toInt()}' : '$v';
    }
    return '';
  }

  @override
  void paint(Canvas canvas, Size size) {
    final shape = '${data['shape'] ?? ''}';
    final rawDims = data['dims'];
    final dims = rawDims is Map ? rawDims : const {};
    final cx = size.width / 2;
    final cy = size.height / 2 - 6;
    final outline = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = accent.withValues(alpha: 0.12);

    switch (shape) {
      case 'circle':
        const r = 62.0;
        canvas.drawCircle(Offset(cx, cy), r, fill);
        canvas.drawCircle(Offset(cx, cy), r, outline);
        canvas.drawLine(Offset(cx, cy), Offset(cx + r, cy), outline);
        _label(canvas, 'r = ${_dim(dims, 'r')}', Offset(cx + r / 2, cy - 14),
            color: textPrimary);
      case 'triangle':
        final path = Path()
          ..moveTo(cx, cy - 64)
          ..lineTo(cx + 72, cy + 52)
          ..lineTo(cx - 72, cy + 52)
          ..close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, outline);
        _label(canvas, 'b = ${_dim(dims, 'b')}', Offset(cx, cy + 68),
            color: textPrimary);
        _label(canvas, 'h = ${_dim(dims, 'h')}', Offset(cx + 84, cy + 6),
            color: textPrimary);
      case 'parallelogram':
        const skew = 28.0;
        final path = Path()
          ..moveTo(cx - 70 + skew, cy - 50)
          ..lineTo(cx + 70 + skew, cy - 50)
          ..lineTo(cx + 70 - skew, cy + 50)
          ..lineTo(cx - 70 - skew, cy + 50)
          ..close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, outline);
        _label(canvas, 'b = ${_dim(dims, 'b')}', Offset(cx, cy + 66),
            color: textPrimary);
      case 'trapezoid':
        final path = Path()
          ..moveTo(cx - 44, cy - 50)
          ..lineTo(cx + 44, cy - 50)
          ..lineTo(cx + 72, cy + 50)
          ..lineTo(cx - 72, cy + 50)
          ..close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, outline);
        _label(canvas, 'a = ${_dim(dims, 'a')}', Offset(cx, cy - 64),
            color: textPrimary);
        _label(canvas, 'b = ${_dim(dims, 'b')}', Offset(cx, cy + 66),
            color: textPrimary);
      case 'composite':
        final r1 = Rect.fromCenter(center: Offset(cx - 44, cy), width: 88, height: 96);
        final r2 = Rect.fromCenter(center: Offset(cx + 52, cy + 20), width: 64, height: 56);
        for (final r in [r1, r2]) {
          canvas.drawRect(r, fill);
          canvas.drawRect(r, outline);
        }
      default:
        // square / rectangle fallback.
        final w = shape == 'square' ? 110.0 : 150.0;
        final rect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: 100);
        canvas.drawRect(rect, fill);
        canvas.drawRect(rect, outline);
        final keys = dims.keys.map((e) => '$e').toList();
        _label(
          canvas,
          keys.isEmpty
              ? shape
              : keys.map((k) => '$k = ${_dim(dims, k)}').join('   '),
          Offset(cx, cy + 68),
          color: textPrimary,
        );
    }
    _label(canvas, shape.isEmpty ? 'shape' : shape, Offset(cx, size.height - 18),
        color: textSecondary, size: 10);
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.accent != accent;
}

// ── 3D wireframe (G6-9 volume) ──────────────────────────────────

class G6WireframeGraph extends BaseGraph {
  final Color textPrimary;
  final Color textSecondary;

  const G6WireframeGraph({
    super.key,
    required super.result,
    required super.accentColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WireframePainter(
        data: _dataOf(result),
        accent: accentColor,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
      ),
    );
  }
}

void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
  const dash = 6.0;
  const gap = 4.0;
  final total = (b - a).distance;
  var drawn = 0.0;
  while (drawn < total) {
    final t0 = drawn / total;
    final t1 = math.min((drawn + dash) / total, 1.0);
    canvas.drawLine(
      Offset.lerp(a, b, t0)!,
      Offset.lerp(a, b, t1)!,
      paint,
    );
    drawn += dash + gap;
  }
}

class _WireframePainter extends CustomPainter {
  final Map<String, dynamic> data;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;

  _WireframePainter({
    required this.data,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final solid = '${data['solid'] ?? 'prism'}';
    final cx = size.width / 2;
    final cy = size.height / 2 - 8;
    final edge = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round;
    final hidden = Paint()
      ..color = accent.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    if (solid == 'sphere') {
      canvas.drawCircle(Offset(cx, cy), 58, edge);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: 116, height: 40),
        hidden,
      );
    } else if (solid == 'cylinder') {
      const w = 110.0;
      const h = 110.0;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy - h / 2), width: w, height: 30),
        edge,
      );
      canvas.drawLine(Offset(cx - w / 2, cy - h / 2), Offset(cx - w / 2, cy + h / 2), edge);
      canvas.drawLine(Offset(cx + w / 2, cy - h / 2), Offset(cx + w / 2, cy + h / 2), edge);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy + h / 2), width: w, height: 30),
        edge,
      );
    } else if (solid == 'cone' || solid == 'pyramid') {
      final base = Rect.fromCenter(center: Offset(cx, cy + 52), width: 140, height: solid == 'cone' ? 30 : 26);
      if (solid == 'cone') {
        canvas.drawOval(base, edge);
      } else {
        canvas.drawRect(base, edge);
      }
      final apex = Offset(cx, cy - 66);
      canvas.drawLine(apex, Offset(base.left + 8, base.center.dy), edge);
      canvas.drawLine(apex, Offset(base.right - 8, base.center.dy), edge);
      _dashedLine(canvas, apex, Offset(base.center.dx, base.center.dy), hidden);
      canvas.drawCircle(apex, 3, Paint()..color = accent);
    } else {
      // Cube / rectangular prism: isometric box, dashed hidden edges.
      const w = 130.0;
      const h = 100.0;
      const dx = 34.0;
      const dy = -26.0;
      final front = Rect.fromCenter(center: Offset(cx - 10, cy + 6), width: w, height: h);
      final back = front.shift(const Offset(dx, dy));
      canvas.drawRect(back, edge);
      _dashedLine(canvas, back.topLeft, front.topLeft, hidden);
      _dashedLine(canvas, back.topRight, front.topRight, hidden);
      _dashedLine(canvas, back.bottomRight, front.bottomRight, hidden);
      canvas.drawRect(front, edge);
      _dashedLine(canvas, back.bottomLeft, front.bottomLeft, hidden);
    }

    final dims = data['dims'];
    final dimText = dims is List ? dims.map((d) => '$d').join(' × ') : '';
    _label(canvas, solid, Offset(cx, size.height - 34),
        color: textPrimary, size: 13, weight: FontWeight.w800);
    if (dimText.isNotEmpty) {
      _label(canvas, dimText, Offset(cx, size.height - 16),
          color: textSecondary, size: 11);
    }
  }

  @override
  bool shouldRepaint(covariant _WireframePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.accent != accent;
}

// ── Pie chart (G6-10 data) ──────────────────────────────────────

class G6PieGraph extends BaseGraph {
  final Color textPrimary;
  final Color textSecondary;

  const G6PieGraph({
    super.key,
    required super.result,
    required super.accentColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PiePainter(
        data: _dataOf(result),
        accent: accentColor,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  final Map<String, dynamic> data;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;

  _PiePainter({
    required this.data,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final raw = data['slices'];
    final slices = raw is List ? raw.toList() : const [];
    if (slices.isEmpty) {
      _label(
        canvas,
        'Solve to see the pie chart',
        Offset(size.width / 2, size.height / 2),
        color: textSecondary,
      );
      return;
    }
    // Cap at 6 slices; fold the rest into "Other".
    final shown = slices.take(6).toList();
    if (slices.length > 6) {
      double rest = 0;
      for (final s in slices.skip(6)) {
        final m = s is Map ? s : const {};
        final pct = m['percent'];
        if (pct is num) rest += pct.toDouble();
      }
      shown.add({'label': 'Other', 'percent': rest});
    }
    final base = HSLColor.fromColor(accent);
    final center = Offset(size.height / 2 + 12, size.height / 2);
    const radius = 78.0;
    var start = -math.pi / 2;
    for (var i = 0; i < shown.length; i++) {
      final s = shown[i] as Map;
      final pct = s['percent'] is num ? (s['percent'] as num).toDouble() : 0.0;
      final sweep = pct / 100 * math.pi * 2;
      final color = base
          .withHue((base.hue + i * (360 / shown.length)) % 360)
          .withLightness((0.55 + (i % 3) * 0.1).clamp(0.0, 0.9))
          .toColor();
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        Paint()..color = color,
      );
      start += sweep;
    }
    canvas.drawCircle(center, radius, Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);

    // Legend on the right.
    var ly = 34.0;
    for (var i = 0; i < shown.length; i++) {
      final s = shown[i] as Map;
      final pct = s['percent'] is num ? (s['percent'] as num).toDouble() : 0.0;
      final color = base
          .withHue((base.hue + i * (360 / shown.length)) % 360)
          .withLightness((0.55 + (i % 3) * 0.1).clamp(0.0, 0.9))
          .toColor();
      final dotX = size.height + 8;
      if (dotX + 150 > size.width) break;
      canvas.drawCircle(Offset(dotX, ly), 5, Paint()..color = color);
      _label(
        canvas,
        '${s['label'] ?? ''} ${pct.toStringAsFixed(pct == pct.roundToDouble() ? 0 : 1)}%',
        Offset(dotX + 12, ly),
        color: textPrimary,
        size: 11,
        align: TextAlign.left,
      );
      ly += 24;
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.accent != accent;
}
