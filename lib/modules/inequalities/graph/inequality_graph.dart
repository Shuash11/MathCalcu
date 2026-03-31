import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme_provider.dart';
import '../../../core/base_graph.dart';
import '../../../core/solve_result.dart';

class InequalityGraph extends BaseGraph {
  const InequalityGraph({
    super.key,
    required super.result,
    required super.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return CustomPaint(
      painter: _NumberLinePainter(
        result: result,
        accentColor: accentColor,
        backgroundColor: theme.surface,
      ),
    );
  }
}

class _NumberLinePainter extends CustomPainter {
  final SolveResult result;
  final Color accentColor;
  final Color backgroundColor;

  _NumberLinePainter(
      {required this.result,
      required this.accentColor,
      required this.backgroundColor});

  static const double gap = 40.0;
  static const int ticks = 5;
  static const double lineY = 110.0;
  static const double marginL = 48.0;
  static const double marginR = 48.0;

  void _drawArrow(Canvas canvas, Offset tip, bool pointRight, Paint paint) {
    final dir = pointRight ? 1.0 : -1.0;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - dir * 12, tip.dy - 6)
      ..lineTo(tip.dx - dir * 12, tip.dy + 6)
      ..close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  void _drawLabel(Canvas canvas, String text, double x, double y, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    const cy = lineY;
    final answer = result.answer;
    final interval = result.intervalNotation ?? '';

    double viewCenter = 0;
    if (result.points.isNotEmpty) {
      viewCenter =
          result.points.fold(0.0, (a, b) => a + b) / result.points.length;
      viewCenter = viewCenter.roundToDouble();
    }

    final linePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.25)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final shadePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final arrowPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final boundaryPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final boundaryFillPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final tickPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    final dimLabelColor = accentColor.withValues(alpha: 0.35);

    const lineLeft = marginL;
    final lineRight = size.width - marginR;

    canvas.drawLine(
        const Offset(lineLeft, cy), Offset(lineRight, cy), linePaint);
    _drawArrow(canvas, Offset(lineRight + 4, cy), true,
        arrowPaint..color = accentColor.withValues(alpha: 0.3));
    _drawArrow(canvas, const Offset(lineLeft - 4, cy), false,
        arrowPaint..color = accentColor.withValues(alpha: 0.3));

    // Collect boundary x-positions so we can skip overlapping tick labels
    final boundaryXs =
        result.points.map((p) => cx + p * gap - viewCenter * gap).toList();

    for (int i = -ticks; i <= ticks; i++) {
      final val = viewCenter + i;
      final xPos = cx + val * gap - viewCenter * gap;

      if (xPos < marginL + 8 || xPos > lineRight - 8) continue;

      canvas.drawLine(
        Offset(xPos, cy - 7),
        Offset(xPos, cy + 7),
        tickPaint,
      );

      // Skip tick label if a boundary label is too close (within 18 px)
      final tooClose = boundaryXs.any((bx) => (bx - xPos).abs() < 18);
      if (tooClose) continue;

      final isPoint = result.points.any((p) => (p - val).abs() < 0.01);
      _drawLabel(
        canvas,
        _fmtInt(val),
        xPos,
        cy + 12,
        isPoint ? accentColor : dimLabelColor,
      );
    }

    // ── Special cases ─────────────────────────────────────
    if (answer == 'No solution' || interval == '∅') {
      _drawLabel(canvas, 'No solution', cx, cy - 30, accentColor);
      return;
    }

    if (answer == 'All real numbers' ||
        interval == '(-∞, ∞)' ||
        interval == '(-∞, +∞)') {
      canvas.drawRect(
        Rect.fromLTRB(lineLeft, cy - 8, lineRight, cy + 8),
        shadePaint,
      );
      _drawArrow(canvas, Offset(lineRight + 4, cy), true,
          arrowPaint..color = accentColor);
      _drawArrow(canvas, const Offset(lineLeft - 4, cy), false,
          arrowPaint..color = accentColor);
      _drawLabel(canvas, 'All real numbers', cx, cy - 30, accentColor);
      return;
    }

    // ── Single boundary ───────────────────────────────────
    if (result.points.length == 1) {
      final boundary = result.points[0];
      final bx = cx + boundary * gap - viewCenter * gap;
      final goRight = interval.contains(', ∞)') || interval.contains(', +∞)');
      final isOpen = interval.startsWith('(') || interval.endsWith(')');

      if (goRight) {
        canvas.drawRect(
            Rect.fromLTRB(bx, cy - 8, lineRight, cy + 8), shadePaint);
        _drawArrow(canvas, Offset(lineRight + 4, cy), true,
            arrowPaint..color = accentColor);
        _drawLabel(canvas, '+∞', lineRight - 8, cy - 26, accentColor);
      } else {
        canvas.drawRect(
            Rect.fromLTRB(lineLeft, cy - 8, bx, cy + 8), shadePaint);
        _drawArrow(canvas, const Offset(lineLeft - 4, cy), false,
            arrowPaint..color = accentColor);
        _drawLabel(canvas, '-∞', lineLeft + 8, cy - 26, accentColor);
      }

      // Boundary label above the line
      _drawLabel(canvas, _fmtVal(boundary), bx, cy - 26, accentColor);

      _drawBoundaryCircle(
          canvas, bx, cy, isOpen, boundaryPaint, boundaryFillPaint);
    }

    // ── Two boundaries ────────────────────────────────────
    else if (result.points.length == 2) {
      final lo = result.points[0] < result.points[1]
          ? result.points[0]
          : result.points[1];
      final hi = result.points[0] < result.points[1]
          ? result.points[1]
          : result.points[0];
      final lx = cx + lo * gap - viewCenter * gap;
      final hx = cx + hi * gap - viewCenter * gap;

      final isUnion = interval.contains('∪');

      if (isUnion) {
        canvas.drawRect(
            Rect.fromLTRB(lineLeft, cy - 8, lx, cy + 8), shadePaint);
        canvas.drawRect(
            Rect.fromLTRB(hx, cy - 8, lineRight, cy + 8), shadePaint);
        _drawArrow(canvas, Offset(lineRight + 4, cy), true,
            arrowPaint..color = accentColor);
        _drawArrow(canvas, const Offset(lineLeft - 4, cy), false,
            arrowPaint..color = accentColor);
        _drawLabel(canvas, '+∞', lineRight - 8, cy - 26, accentColor);
        _drawLabel(canvas, '-∞', lineLeft + 8, cy - 26, accentColor);
      } else {
        canvas.drawRect(Rect.fromLTRB(lx, cy - 8, hx, cy + 8), shadePaint);
      }

      // Boundary labels — draw above the line, separated from tick labels
      _drawLabel(canvas, _fmtVal(lo), lx, cy - 26, accentColor);
      _drawLabel(canvas, _fmtVal(hi), hx, cy - 26, accentColor);

      // ── Bracket detection (fixed) ────────────────────────
      // For union:  (-∞, lo) ∪ (hi, +∞)
      //   lo bracket is the char just before the lo value  → after '('
      //   hi bracket is the char just before ', +∞'        → before ')'
      // For bounded: [lo, hi]  or  (lo, hi)  etc.
      bool loOpen, hiOpen;

      if (isUnion) {
        // Split on ∪ and read each part independently
        final parts = interval.split('∪');
        final leftPart = parts[0].trim(); // e.g. "(-∞, -1)"
        final rightPart = parts[1].trim(); // e.g. "(-1, +∞)"
        loOpen = leftPart.endsWith(')'); // closing bracket of left part
        hiOpen = rightPart.startsWith('('); // opening bracket of right part
      } else {
        loOpen = interval.startsWith('(');
        hiOpen = interval.endsWith(')');
      }

      if (isUnion) {
        _drawBoundaryCircle(
            canvas, lx, cy, loOpen, boundaryPaint, boundaryFillPaint);
        _drawBoundaryCircle(
            canvas, hx, cy, hiOpen, boundaryPaint, boundaryFillPaint);
      } else {
        _drawBoundaryCircle(
            canvas, lx, cy, loOpen, boundaryPaint, boundaryFillPaint);
        _drawBoundaryCircle(
            canvas, hx, cy, hiOpen, boundaryPaint, boundaryFillPaint);
      }
    }

    // ── Interval label at top ─────────────────────────────
    final tp = TextPainter(
      text: TextSpan(
        text: interval,
        style: TextStyle(
          color: accentColor.withValues(alpha: 0.9),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, 12));
  }

  void _drawBoundaryCircle(
    Canvas canvas,
    double bx,
    double cy,
    bool open,
    Paint strokePaint,
    Paint fillPaint,
  ) {
    if (open) {
      canvas.drawCircle(Offset(bx, cy), 7, strokePaint);
      canvas.drawCircle(
        Offset(bx, cy),
        5,
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill,
      );
    } else {
      canvas.drawCircle(Offset(bx, cy), 7, fillPaint);
    }
  }

  String _fmtVal(double n) {
    if (n == n.roundToDouble()) return n.toInt().toString();
    for (int d = 2; d <= 20; d++) {
      final num = (n * d).round();
      if ((num / d - n).abs() < 1e-9) {
        int g = _gcd(num.abs(), d);
        return '${num ~/ g}/${d ~/ g}';
      }
    }
    return n.toStringAsFixed(2);
  }

  String _fmtInt(double n) {
    if (n == n.roundToDouble()) return n.toInt().toString();
    return n.toStringAsFixed(1);
  }

  int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  @override
  bool shouldRepaint(covariant _NumberLinePainter old) =>
      old.result != result ||
      old.accentColor != accentColor ||
      old.backgroundColor != backgroundColor;
}
