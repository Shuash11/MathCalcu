import 'package:calculus_system/core/module_registry.dart';
import 'package:flutter/material.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class PointSlopeModuleCard extends StatefulWidget {
  final ModuleEntry module;
  const PointSlopeModuleCard({super.key, required this.module});

  @override
  State<PointSlopeModuleCard> createState() => _PointSlopeModuleCardState();
}

class _PointSlopeModuleCardState extends State<PointSlopeModuleCard> {
  bool _pressed = false;
  bool _hovered = false;

  static const Color _deepViolet = Color(0xFF7C3AED);
  static const Color _electricPurple = Color(0xFFA855F7);
  static const Color _softLavender = Color(0xFFC4B5FD);
  static const Color _neonMagenta = Color(0xFFE879F9);
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
                        ? _electricPurple.withValues(alpha: 0.6)
                        : _deepViolet.withValues(alpha: 0.3),
                    width: _hovered ? 2 * s : 1.5 * s,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _hovered
                          ? _electricPurple.withValues(alpha: 0.25)
                          : _deepViolet.withValues(alpha: 0.15),
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
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        top: _hovered ? -30 * s : 0,
                        left: _hovered ? -30 * s : 0,
                        right: _hovered ? -30 * s : 0,
                        bottom: _hovered ? -30 * s : 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.topRight,
                              radius: 1.0,
                              colors: [
                                _electricPurple.withValues(
                                  alpha: _hovered ? 0.15 : 0.08,
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        bottom: _hovered ? -20 * s : 0,
                        left: _hovered ? -20 * s : 0,
                        right: _hovered ? -20 * s : 0,
                        top: _hovered ? -20 * s : 40 * s,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.bottomLeft,
                              radius: 0.8,
                              colors: [
                                _neonMagenta.withValues(
                                  alpha: _hovered ? 0.1 : 0.05,
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20 * s),
                        child: Row(
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
                                    _deepViolet.withValues(alpha: 0.3),
                                    _electricPurple.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16 * s),
                                border: Border.all(
                                  color: _hovered
                                      ? _electricPurple.withValues(alpha: 0.6)
                                      : _deepViolet.withValues(alpha: 0.4),
                                  width: 2 * s,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _electricPurple.withValues(
                                      alpha: _hovered ? 0.3 : 0.15,
                                    ),
                                    blurRadius: 16 * s,
                                    offset: Offset(0, 4 * s),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  transform: _hovered
                                      ? (Matrix4.identity()
                                        ..scale(1.15)
                                        ..rotateZ(0.1))
                                      : Matrix4.identity(),
                                  child: Icon(
                                    widget.module.icon,
                                    color: _hovered
                                        ? _softLavender
                                        : _electricPurple,
                                    size: 28 * s,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 18 * s),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        widget.module.label,
                                        style: TextStyle(
                                          color: _hovered
                                              ? _softLavender
                                              : theme.textPrimary,
                                          letterSpacing: -0.5 * s,
                                          fontSize: 18 * s,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(width: 10 * s),
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 1500),
                                        width: 8 * s,
                                        height: 8 * s,
                                        decoration: BoxDecoration(
                                          gradient: RadialGradient(
                                            colors: [
                                              _neonMagenta,
                                              _neonMagenta.withValues(alpha: 0.3),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: _neonMagenta.withValues(
                                                alpha: _hovered ? 0.8 : 0.4,
                                              ),
                                              blurRadius: _hovered ? 12 * s : 6 * s,
                                              spreadRadius: _hovered ? 2 : 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6 * s),
                                  Text(
                                    widget.module.subtitle,
                                    style: TextStyle(
                                      fontSize: 13 * s,
                                      color: theme.textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (s > 0.85)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                transform: _hovered
                                    ? (Matrix4.identity()..translate(6.0 * s, 0.0))
                                    : Matrix4.identity(),
                                child: Container(
                                  width: 40 * s,
                                  height: 40 * s,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        _electricPurple.withValues(
                                          alpha: _hovered ? 0.2 : 0.05,
                                        ),
                                        Colors.transparent,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _hovered
                                          ? _electricPurple.withValues(alpha: 0.5)
                                          : _deepViolet.withValues(alpha: 0.2),
                                      width: 1.5 * s,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: _hovered
                                        ? _softLavender
                                        : _electricPurple.withValues(alpha: 0.7),
                                    size: 20 * s,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _hovered ? 0.4 : 0.15,
                          child: CustomPaint(
                            size: Size(100 * s, 100 * s),
                            painter: _LinePatternPainter(_electricPurple),
                          ),
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

class _LinePatternPainter extends CustomPainter {
  final Color color;

  const _LinePatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 1.5;

    for (int i = -2; i < 6; i++) {
      final startX = i * 20.0;
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + 40, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}