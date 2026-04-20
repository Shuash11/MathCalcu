import 'package:calculus_system/core/module_registry.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SlopeModuleCard extends StatefulWidget {
  final ModuleEntry module;
  const SlopeModuleCard({required this.module, super.key});

  @override
  State<SlopeModuleCard> createState() => _SlopeModuleCardState();
}

class _SlopeModuleCardState extends State<SlopeModuleCard> {
  bool _pressed = false;
  bool _hovered = false;

  static const Color pinkAccent = Color(0xFFFF6B6B);
  static const Color lightPink = Color(0xFFFFB8B8);
  static const double _baseDesignWidth = 400.0;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double effectiveWidth = constraints.hasInfiniteWidth
            ? _baseDesignWidth
            : constraints.maxWidth;
        final double s = (effectiveWidth / _baseDesignWidth).clamp(0.7, 1.2);

        Widget content = MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) {
              setState(() => _pressed = false);
              context.push(widget.module.route);
            },
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedScale(
              scale: _pressed ? 0.96 : 1,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: theme.card,
                  borderRadius: BorderRadius.circular(22 * s),
                  border: Border.all(
                    color: _hovered
                        ? pinkAccent.withValues(alpha: 0.6)
                        : pinkAccent.withValues(alpha: 0.25),
                    width: _hovered ? 2 * s : 1 * s,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: pinkAccent.withValues(
                        alpha: _hovered ? 0.3 : 0.1,
                      ),
                      blurRadius: _hovered ? 28 * s : 16 * s,
                      offset: Offset(0, 8 * s),
                    ),
                    BoxShadow(
                      color: theme.shadowColor,
                      blurRadius: 12 * s,
                      offset: Offset(0, 4 * s),
                      spreadRadius: -4 * s,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22 * s),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: -30 * s,
                        right: -30 * s,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 120 * s,
                          height: 120 * s,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                pinkAccent.withValues(
                                  alpha: _hovered ? 0.25 : 0.12,
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -20 * s,
                        left: -20 * s,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 100 * s,
                          height: 100 * s,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pinkAccent.withValues(
                              alpha: _hovered ? 0.15 : 0.08,
                            ),
                          ),
                        ),
                      ),
                      if (s > 0.85)
                        Positioned(
                          bottom: 20 * s,
                          left: 20 * s,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _hovered ? 0.4 : 0.2,
                            child: CustomPaint(
                              size: Size(40 * s, 30 * s),
                              painter: _SlopeLinePainter(
                                color: _hovered ? pinkAccent : lightPink,
                                strokeWidth: _hovered ? 3 * s : 2 * s,
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.all(20 * s),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 60 * s,
                              height: 60 * s,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    pinkAccent.withValues(
                                      alpha: _hovered ? 0.2 : 0.12,
                                    ),
                                    pinkAccent.withValues(
                                      alpha: _hovered ? 0.1 : 0.05,
                                    ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16 * s),
                                border: Border.all(
                                  color: pinkAccent.withValues(
                                    alpha: _hovered ? 0.5 : 0.35,
                                  ),
                                  width: _hovered ? 2 : 1.5,
                                ),
                              ),
                              child: Icon(
                                widget.module.icon,
                                color: _hovered
                                    ? pinkAccent
                                    : pinkAccent.withValues(alpha: 0.9),
                                size: 28 * s,
                              ),
                            ),
                            SizedBox(width: 18 * s),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.module.label,
                                    style: TextStyle(
                                      fontSize: 18 * s,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4 * s,
                                      color: _hovered
                                          ? pinkAccent
                                          : theme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6 * s),
                                  Text(
                                    widget.module.subtitle,
                                    style: TextStyle(
                                      fontSize: 13 * s,
                                      color: _hovered
                                          ? pinkAccent.withValues(alpha: 0.7)
                                          : theme.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (s > 0.85)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                transform: _hovered
                                    ? (Matrix4.identity()..translate(4.0 * s, 0.0))
                                    : Matrix4.identity(),
                                child: Container(
                                  width: 34 * s,
                                  height: 34 * s,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _hovered
                                        ? pinkAccent.withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: pinkAccent.withValues(
                                        alpha: _hovered ? 0.5 : 0.25,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16 * s,
                                    color: _hovered
                                        ? pinkAccent
                                        : pinkAccent.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        if (constraints.hasInfiniteWidth) {
          return SizedBox(width: effectiveWidth, child: content);
        }
        return content;
      },
    );
  }
}

class _SlopeLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _SlopeLinePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);

    final path = Path()
      ..moveTo(size.width - 8, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 8)
      ..close();
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}