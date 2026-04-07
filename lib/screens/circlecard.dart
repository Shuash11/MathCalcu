import 'dart:math';
import 'package:calculus_system/core/module_registry.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CircleModuleCard extends StatefulWidget {
  final ModuleEntry module;
  const CircleModuleCard({super.key, required this.module});

  @override
  State<CircleModuleCard> createState() => _CircleModuleCardState();
}

class _CircleModuleCardState extends State<CircleModuleCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  bool _hovered = false;
  late AnimationController _orbitController;

  // Indigo + cyan theme
  static const Color _indigo = Color(0xFF6366F1);
  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _teal = Color(0xFF14B8A6);
  static const Color _softIndigo = Color(0xFFA5B4FC);

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    // Don't start animation automatically - wait for hover
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (!_orbitController.isAnimating) {
      _orbitController.repeat();
    }
  }

  void _stopAnimation() {
    if (_orbitController.isAnimating) {
      _orbitController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovered = true;
          _startAnimation();
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
          _stopAnimation();
        });
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          context.push(widget.module.route);
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: context.watch<ThemeProvider>().card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hovered
                    ? _cyan.withValues(alpha: 0.5)
                    : _indigo.withValues(alpha: 0.3),
                width: _hovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _hovered
                      ? _cyan.withValues(alpha: 0.25)
                      : _indigo.withValues(alpha: 0.15),
                  blurRadius: _hovered ? 40 : 24,
                  offset: const Offset(0, 8),
                  spreadRadius: _hovered ? 4 : 0,
                ),
                BoxShadow(
                  color: context.watch<ThemeProvider>().shadowColor,
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Animated orbits - only when hovered
                  if (_hovered)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _orbitController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _OrbitPainter(
                              progress: _orbitController.value,
                              color1: _indigo,
                              color2: _cyan,
                              color3: _teal,
                              hovered: _hovered,
                            ),
                          );
                        },
                      ),
                    ),

                  // Static decoration when not hovered
                  if (!_hovered)
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _indigo.withValues(alpha: 0.08),
                        ),
                      ),
                    ),

                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    top: _hovered ? -30 : 0,
                    right: _hovered ? -30 : 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _hovered ? 150 : 100,
                      height: _hovered ? 150 : 100,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            _cyan.withValues(alpha: _hovered ? 0.2 : 0.1),
                            Colors.transparent,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                _indigo.withValues(
                                    alpha: _hovered ? 0.3 : 0.15),
                                _cyan.withValues(alpha: _hovered ? 0.1 : 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: _hovered
                                  ? _cyan.withValues(alpha: 0.5)
                                  : _indigo.withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _cyan.withValues(
                                    alpha: _hovered ? 0.3 : 0.15),
                                blurRadius: _hovered ? 20 : 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              transform: _hovered
                                  ? (Matrix4.identity()..scale(1.1))
                                  : Matrix4.identity(),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: _hovered ? 50 : 44,
                                    height: _hovered ? 50 : 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _cyan.withValues(
                                            alpha: _hovered ? 0.4 : 0.2),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    widget.module.icon,
                                    color: _hovered ? _softIndigo : _cyan,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.module.label,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: _hovered
                                            ? _softIndigo
                                            : context
                                                .watch<ThemeProvider>()
                                                .textPrimary,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _cyan.withValues(
                                          alpha: _hovered ? 0.2 : 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _cyan.withValues(
                                            alpha: _hovered ? 0.5 : 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildDot(_indigo, 0),
                                        const SizedBox(width: 3),
                                        _buildDot(_cyan, 1),
                                        const SizedBox(width: 3),
                                        _buildDot(_teal, 2),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _hovered
                                      ? _softIndigo.withValues(alpha: 0.7)
                                      : context
                                          .watch<ThemeProvider>()
                                          .textSecondary,
                                  height: 1.3,
                                ),
                                child: Text(widget.module.subtitle),
                              ),
                              const SizedBox(height: 8),
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: _hovered ? 1 : 0.7,
                                child: Wrap(
                                  spacing: 6,
                                  children: [
                                    _buildTypePill('Standard', _indigo),
                                    _buildTypePill('General', _cyan),
                                    _buildTypePill('Center', _teal),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: _hovered
                              ? (Matrix4.identity()..translate(6.0, 0.0))
                              : Matrix4.identity(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _indigo.withValues(
                                      alpha: _hovered ? 0.2 : 0.05),
                                  _cyan.withValues(
                                      alpha: _hovered ? 0.1 : 0.02),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _hovered
                                    ? _cyan.withValues(alpha: 0.4)
                                    : _indigo.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: _hovered
                                  ? _softIndigo
                                  : _cyan.withValues(alpha: 0.7),
                              size: 20,
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
  }

  Widget _buildDot(Color color, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: _hovered
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildTypePill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final double progress;
  final Color color1;
  final Color color2;
  final Color color3;
  final bool hovered;

  _OrbitPainter({
    required this.progress,
    required this.color1,
    required this.color2,
    required this.color3,
    required this.hovered,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.8, size.height * 0.5);
    final radius = hovered ? 50.0 : 35.0;

    final pathPaint = Paint()
      ..color = color2.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, pathPaint);

    final angles = [0.0, 2.094, 4.189];
    final colors = [color1, color2, color3];

    for (int i = 0; i < 3; i++) {
      final angle = angles[i] + (progress * 2 * pi);
      final double x = center.dx + radius * cos(angle);
      final double y = center.dy + radius * sin(angle);

      final glowPaint = Paint()
        ..color = colors[i].withValues(alpha: hovered ? 0.4 : 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), hovered ? 8 : 5, glowPaint);

      final dotPaint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), hovered ? 4 : 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return progress != oldDelegate.progress || hovered != oldDelegate.hovered;
  }
}
