import 'dart:math';
import 'package:calculus_system/shared/widgets/full_screen_graph_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';

class MidpointGraphScreen extends StatefulWidget {
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final double mx;
  final double my;
  final String labelA;
  final String labelB;
  final String labelM;

  const MidpointGraphScreen({
    super.key,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.mx,
    required this.my,
    this.labelA = 'A',
    this.labelB = 'B',
    this.labelM = 'M',
  });

  @override
  State<MidpointGraphScreen> createState() => _MidpointGraphScreenState();
}

class _MidpointGraphScreenState extends State<MidpointGraphScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFullScreen() {
    final accent = context.watch<ThemeProvider>().accentColor;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenGraphScreen(
          title: 'Midpoint Graph',
          formula: 'M = ((x1+x2)/2, (y1+y2)/2)',
          keyInfo: [
            FullScreenInfoItem(
              label: widget.labelA,
              value: '(${_fmt(widget.x1)}, ${_fmt(widget.y1)})',
              color: accent,
            ),
            FullScreenInfoItem(
              label: widget.labelM,
              value: '(${_fmt(widget.mx)}, ${_fmt(widget.my)})',
              color: accent,
            ),
            FullScreenInfoItem(
              label: widget.labelB,
              value: '(${_fmt(widget.x2)}, ${_fmt(widget.y2)})',
              color: context.watch<ThemeProvider>().textPrimary,
            ),
          ],
          accentColor: accent,
          graph: MidpointGraph(
            x1: widget.x1,
            y1: widget.y1,
            x2: widget.x2,
            y2: widget.y2,
            mx: widget.mx,
            my: widget.my,
            progress: _progress.value,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tp = context.watch<ThemeProvider>();
    final accent = tp.accentColor;

    return Scaffold(
      backgroundColor: tp.surface,
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
                        color: tp.card,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: accent.withValues(alpha: 0.15)),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: tp.textPrimary,
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
                          'Midpoint Graph',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: tp.textPrimary,
                              letterSpacing: -0.5),
                        ),
                        Text(
                          'Classroom Concept Visualization',
                          style: TextStyle(
                              fontSize: 12,
                              color: accent.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Graph Area (tappable to open full screen)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: _openFullScreen,
                  child: Container(
                    decoration: BoxDecoration(
                      color: tp.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: accent.withValues(alpha: 0.15), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          // The Painter
                          AnimatedBuilder(
                            animation: _progress,
                            builder: (context, child) {
                              return MidpointGraph(
                                x1: widget.x1,
                                y1: widget.y1,
                                x2: widget.x2,
                                y2: widget.y2,
                                mx: widget.mx,
                                my: widget.my,
                                progress: _progress.value,
                              );
                            },
                          ),

                          // Theme Indicator (Subtle)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isDark
                                        ? Icons.dark_mode_rounded
                                        : Icons.light_mode_rounded,
                                    size: 12,
                                    color: accent,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isDark ? 'Dark Mode' : 'Light Mode',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: accent,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Footer / Info Card
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                        color: tp.card,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: accent.withValues(alpha: 0.1)))
                    .copyWith(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPointInfo(
                        context, widget.labelA, widget.x1, widget.y1, accent),
                    Container(
                        width: 1,
                        height: 40,
                        color: accent.withValues(alpha: 0.15)),
                    _buildPointInfo(
                        context, widget.labelM, widget.mx, widget.my, accent,
                        isMidpoint: true),
                    Container(
                        width: 1,
                        height: 40,
                        color: accent.withValues(alpha: 0.15)),
                    _buildPointInfo(context, widget.labelB, widget.x2,
                        widget.y2, tp.textPrimary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointInfo(
      BuildContext context, String label, double x, double y, Color color,
      {bool isMidpoint = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color.withValues(alpha: 0.6),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '(${_fmt(x)}, ${_fmt(y)})',
          style: TextStyle(
            fontSize: 15,
            fontWeight: isMidpoint ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

/// Reusable midpoint graph widget for both inline and full-screen views.
class MidpointGraph extends StatelessWidget {
  final double x1, y1, x2, y2, mx, my;
  final double progress;

  const MidpointGraph({
    super.key,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.mx,
    required this.my,
    this.progress = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = context.watch<ThemeProvider>().accentColor;

    return CustomPaint(
      size: Size.infinite,
      painter: MidpointPainter(
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
        mx: mx,
        my: my,
        progress: progress,
        isDark: isDark,
        accentColor: accent,
        textColor: context.watch<ThemeProvider>().textPrimary,
      ),
    );
  }
}

class MidpointPainter extends CustomPainter {
  final double x1, y1, x2, y2, mx, my;
  final double progress;
  final bool isDark;
  final Color accentColor;
  final Color textColor;

  /// Scale factor derived from canvas size for responsive rendering.
  late final double _scaleFactor;

  /// Bounding boxes of placed labels for overlap detection.
  late final List<Rect> _labelBounds;

  MidpointPainter({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.mx,
    required this.my,
    required this.progress,
    required this.isDark,
    required this.accentColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Responsive scale factor: reference size ~350px, clamped 0.5–2.0
    final minDim = size.width < size.height ? size.width : size.height;
    _scaleFactor = (minDim / 350.0).clamp(0.5, 2.0);
    _labelBounds = [];

    final center = Offset(size.width / 2, size.height / 2);

    // Bounds calculation for focus
    final allX = [x1, x2, mx, 0.0];
    final allY = [y1, y2, my, 0.0];
    final minX = allX.reduce(min);
    final maxX = allX.reduce(max);
    final minY = allY.reduce(min);
    final maxY = allY.reduce(max);

    final rangeX = (maxX - minX).abs().clamp(4.0, 100.0) + 4;
    final rangeY = (maxY - minY).abs().clamp(4.0, 100.0) + 4;

    final scale = min(size.width / rangeX, size.height / rangeY);

    // Origin in canvas space
    final origin = Offset(
      center.dx - ((maxX + minX) / 2) * scale,
      center.dy + ((maxY + minY) / 2) * scale,
    );

    Offset toCanvas(double x, double y) {
      return Offset(origin.dx + x * scale, origin.dy - y * scale);
    }

    _drawGrid(canvas, size, origin, scale);
    _drawAxes(canvas, size, origin);

    if (progress > 0.1) {
      _drawContent(canvas, toCanvas, size);
    }
  }

  String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  void _drawGrid(Canvas canvas, Size size, Offset origin, double scale) {
    final majorGridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.05)
          : const Color(0xFFD1D5DB).withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    final minorGridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.02)
          : const Color(0xFFE5E7EB).withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    // Determine grid spacing
    double spacing = 1.0;
    if (scale < 10) spacing = 10.0;
    if (scale < 2) spacing = 50.0;

    // Draw vertical lines
    for (double x = (origin.dx % (spacing * scale)) - (spacing * scale);
        x < size.width;
        x += spacing * scale) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), majorGridPaint);

      // Minor lines (classroom feel)
      for (int i = 1; i < 5; i++) {
        double mx = x + (i * (spacing * scale) / 5);
        canvas.drawLine(Offset(mx, 0), Offset(mx, size.height), minorGridPaint);
      }
    }

    // Draw horizontal lines
    for (double y = (origin.dy % (spacing * scale)) - (spacing * scale);
        y < size.height;
        y += spacing * scale) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), majorGridPaint);

      // Minor lines
      for (int i = 1; i < 5; i++) {
        double my = y + (i * (spacing * scale) / 5);
        canvas.drawLine(Offset(0, my), Offset(size.width, my), minorGridPaint);
      }
    }
  }

  void _drawAxes(Canvas canvas, Size size, Offset origin) {
    final axisPaint = Paint()
      ..color = textColor.withValues(alpha: 0.2)
      ..strokeWidth = 2.0;

    // Y Axis
    if (origin.dx >= 0 && origin.dx <= size.width) {
      canvas.drawLine(
          Offset(origin.dx, 0), Offset(origin.dx, size.height), axisPaint);
    }

    // X Axis
    if (origin.dy >= 0 && origin.dy <= size.height) {
      canvas.drawLine(
          Offset(0, origin.dy), Offset(size.width, origin.dy), axisPaint);
    }
  }

  void _drawContent(
      Canvas canvas, Offset Function(double, double) toCanvas, Size size) {
    final p1 = toCanvas(x1, y1);
    final p2 = toCanvas(x2, y2);
    final pm = toCanvas(mx, my);

    final linePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.3 * progress)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Draw segment AB
    canvas.drawLine(p1, p2, linePaint);

    // Axis projections (dashed lines) - Classroom vibe
    _drawProjections(canvas, p1, toCanvas(x1, 0), toCanvas(0, y1), progress);
    _drawProjections(canvas, p2, toCanvas(x2, 0), toCanvas(0, y2), progress);

    // Points
    _drawPoint(canvas, p1, accentColor, "A", progress, size,
        label: "(${_fmt(x1)}, ${_fmt(y1)})");
    _drawPoint(
        canvas, p2, textColor.withValues(alpha: 0.7), "B", progress, size,
        label: "(${_fmt(x2)}, ${_fmt(y2)})");

    // Midpoint with special styling
    if (progress > 0.5) {
      final mProgress = (progress - 0.5) * 2;
      _drawMidpoint(canvas, pm, accentColor, mProgress, size,
          label: "(${_fmt(mx)}, ${_fmt(my)})");
    }
  }

  void _drawProjections(
      Canvas canvas, Offset p, Offset px, Offset py, double progress) {
    final paint = Paint()
      ..color = textColor.withValues(alpha: 0.1 * progress)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    _drawDashedLine(canvas, p, px, paint);
    _drawDashedLine(canvas, p, py, paint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double distance = (end - start).distance;
    double currentDistance = 0;

    while (currentDistance < distance) {
      final subStart = Offset.lerp(start, end, currentDistance / distance)!;
      final subEnd =
          Offset.lerp(start, end, (currentDistance + dashWidth) / distance)!;
      canvas.drawLine(subStart, subEnd, paint);
      currentDistance += dashWidth + dashSpace;
    }
  }

  void _drawPoint(Canvas canvas, Offset pos, Color color, String name, double p,
      Size canvasSize,
      {String? label}) {
    final paint = Paint()
      ..color = color.withValues(alpha: p)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(pos, 6 * p, paint);

    // Halo
    canvas.drawCircle(
        pos, 12 * p, Paint()..color = color.withValues(alpha: 0.1 * p));

    if (p > 0.8) {
      final fontSize = 11.0 * _scaleFactor * p;
      final textPainter = TextPainter(
        text: TextSpan(
          text: "$name $label",
          style: TextStyle(
            color: color.withValues(alpha: p),
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            backgroundColor: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.5),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Determine best label position, avoiding overlap
      final offset = _findNonOverlappingOffset(pos, textPainter, canvasSize);
      textPainter.paint(canvas, pos + offset);
    }
  }

  void _drawMidpoint(
      Canvas canvas, Offset pos, Color color, double p, Size canvasSize,
      {String? label}) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Outer Ring
    canvas.drawCircle(
        pos,
        10 * p,
        Paint()
          ..color = color.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Inner center
    canvas.drawCircle(pos, 5 * p, paint);

    // "M" Label + Coordinates
    if (p > 0.8) {
      final fontSize = 13.0 * _scaleFactor * p;
      final textPainter = TextPainter(
        text: TextSpan(
          text: "M $label",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            backgroundColor: isDark
                ? Colors.black.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.7),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Determine best label position, avoiding overlap
      final offset = _findNonOverlappingOffset(pos, textPainter, canvasSize);
      textPainter.paint(canvas, pos + offset);
    }
  }

  /// Finds an offset for a label that doesn't overlap previously placed labels.
  /// Tries preferred position first, then rotates through alternatives.
  Offset _findNonOverlappingOffset(
      Offset anchor, TextPainter tp, Size canvasSize) {
    final labelWidth = tp.width;
    final labelHeight = tp.height;
    final margin = 8.0 * _scaleFactor;

    // Candidate offsets relative to anchor point (tried in order)
    final candidates = [
      Offset(margin, -labelHeight - margin), // top-right
      Offset(-labelWidth - margin, -labelHeight - margin), // top-left
      Offset(margin, margin), // bottom-right
      Offset(-labelWidth - margin, margin), // bottom-left
      Offset(margin, 0), // right
      Offset(-labelWidth - margin, 0), // left
      Offset(0, -labelHeight - margin), // top-center
      Offset(0, margin), // bottom-center
    ];

    for (final offset in candidates) {
      final candidateRect = Rect.fromLTWH(
        anchor.dx + offset.dx,
        anchor.dy + offset.dy,
        labelWidth,
        labelHeight,
      );

      // Check canvas bounds
      if (candidateRect.left < 0 ||
          candidateRect.top < 0 ||
          candidateRect.right > canvasSize.width ||
          candidateRect.bottom > canvasSize.height) {
        continue;
      }

      // Check overlap with existing labels
      bool overlaps = false;
      for (final existing in _labelBounds) {
        if (candidateRect.overlaps(existing)) {
          overlaps = true;
          break;
        }
      }

      if (!overlaps) {
        _labelBounds.add(candidateRect);
        return offset;
      }
    }

    // Fallback: use preferred offset even if overlapping
    final fallback = Offset(margin, -labelHeight - margin);
    _labelBounds.add(Rect.fromLTWH(
      anchor.dx + fallback.dx,
      anchor.dy + fallback.dy,
      labelWidth,
      labelHeight,
    ));
    return fallback;
  }

  @override
  bool shouldRepaint(covariant MidpointPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}
