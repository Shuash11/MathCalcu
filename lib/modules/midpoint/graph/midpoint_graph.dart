import 'dart:math';
import 'package:calculus_system/modules/midpoint/Theme/midpointtheme.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: MidpointTheme.surface(context),
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
                        color: MidpointTheme.card(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: MidpointTheme.accent15(context)),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: MidpointTheme.text(context),
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
                          style: MidpointTheme.headerTitle(context),
                        ),
                        Text(
                          'Classroom Concept Visualization',
                          style: MidpointTheme.headerSubtitle(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Graph Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: MidpointTheme.card(context),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: MidpointTheme.accent15(context), width: 1.5),
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
                            return CustomPaint(
                              size: Size.infinite,
                              painter: MidpointPainter(
                                x1: widget.x1,
                                y1: widget.y1,
                                x2: widget.x2,
                                y2: widget.y2,
                                mx: widget.mx,
                                my: widget.my,
                                progress: _progress.value,
                                isDark: isDark,
                                accentColor: MidpointTheme.accent(context),
                                textColor: MidpointTheme.text(context),
                              ),
                            );
                          },
                        ),
                        
                        // Theme Indicator (Subtle)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: MidpointTheme.accent(context).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                  size: 12,
                                  color: MidpointTheme.accent(context),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isDark ? 'Dark Mode' : 'Light Mode',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: MidpointTheme.accent(context),
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

            // Footer / Info Card
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: MidpointTheme.cardDecoration(context).copyWith(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPointInfo(context, widget.labelA, widget.x1, widget.y1, MidpointTheme.accent(context)),
                    Container(width: 1, height: 40, color: MidpointTheme.accent15(context)),
                    _buildPointInfo(context, widget.labelM, widget.mx, widget.my, MidpointTheme.accent(context), isMidpoint: true),
                    Container(width: 1, height: 40, color: MidpointTheme.accent15(context)),
                    _buildPointInfo(context, widget.labelB, widget.x2, widget.y2, MidpointTheme.text(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointInfo(BuildContext context, String label, double x, double y, Color color, {bool isMidpoint = false}) {
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

class MidpointPainter extends CustomPainter {
  final double x1, y1, x2, y2, mx, my;
  final double progress;
  final bool isDark;
  final Color accentColor;
  final Color textColor;

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
      _drawContent(canvas, toCanvas);
    }
  }

  String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  void _drawGrid(Canvas canvas, Size size, Offset origin, double scale) {
    final majorGridPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFD1D5DB).withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
      
    final minorGridPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFE5E7EB).withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    // Determine grid spacing
    double spacing = 1.0;
    if (scale < 10) spacing = 10.0;
    if (scale < 2) spacing = 50.0;

    // Draw vertical lines
    for (double x = (origin.dx % (spacing * scale)) - (spacing * scale); x < size.width; x += spacing * scale) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), majorGridPaint);
      
      // Minor lines (classroom feel)
      for (int i = 1; i < 5; i++) {
        double mx = x + (i * (spacing * scale) / 5);
        canvas.drawLine(Offset(mx, 0), Offset(mx, size.height), minorGridPaint);
      }
    }

    // Draw horizontal lines
    for (double y = (origin.dy % (spacing * scale)) - (spacing * scale); y < size.height; y += spacing * scale) {
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
      canvas.drawLine(Offset(origin.dx, 0), Offset(origin.dx, size.height), axisPaint);
    }
    
    // X Axis
    if (origin.dy >= 0 && origin.dy <= size.height) {
      canvas.drawLine(Offset(0, origin.dy), Offset(size.width, origin.dy), axisPaint);
    }
  }

  void _drawContent(Canvas canvas, Offset Function(double, double) toCanvas) {
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
    _drawPoint(canvas, p1, accentColor, "A", progress, label: "(${_fmt(x1)}, ${_fmt(y1)})");
    _drawPoint(canvas, p2, textColor.withValues(alpha: 0.7), "B", progress, label: "(${_fmt(x2)}, ${_fmt(y2)})");
    
    // Midpoint with special styling
    if (progress > 0.5) {
      final mProgress = (progress - 0.5) * 2;
      _drawMidpoint(canvas, pm, accentColor, mProgress, label: "(${_fmt(mx)}, ${_fmt(my)})");
    }
  }

  void _drawProjections(Canvas canvas, Offset p, Offset px, Offset py, double progress) {
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
      final subEnd = Offset.lerp(start, end, (currentDistance + dashWidth) / distance)!;
      canvas.drawLine(subStart, subEnd, paint);
      currentDistance += dashWidth + dashSpace;
    }
  }

  void _drawPoint(Canvas canvas, Offset pos, Color color, String name, double p, {String? label}) {
    final paint = Paint()
      ..color = color.withValues(alpha: p)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(pos, 6 * p, paint);
    
    // Halo
    canvas.drawCircle(pos, 12 * p, Paint()..color = color.withValues(alpha: 0.1 * p));

    if (p > 0.8) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: "$name $label",
          style: TextStyle(
            color: color.withValues(alpha: p),
            fontWeight: FontWeight.bold,
            fontSize: 11 * p,
            backgroundColor: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.5),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      
      // Determine label position based on quadrant to avoid overlap
      Offset offset = const Offset(10, -20);
      textPainter.paint(canvas, pos + offset);
    }
  }

  void _drawMidpoint(Canvas canvas, Offset pos, Color color, double p, {String? label}) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    // Outer Ring
    canvas.drawCircle(pos, 10 * p, Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
      
    // Inner center
    canvas.drawCircle(pos, 5 * p, paint);
    
    // "M" Label + Coordinates
    if (p > 0.8) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: "M $label",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13 * p,
            backgroundColor: isDark ? Colors.black.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.7),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      
      textPainter.paint(canvas, pos + const Offset(14, -28));
    }
  }

  @override
  bool shouldRepaint(covariant MidpointPainter oldDelegate) => 
    oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}
