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

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return MouseRegion(
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
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: theme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hovered
                    ? _electricPurple.withValues(alpha: 0.5)
                    : _deepViolet.withValues(alpha: 0.3),
                width: _hovered ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _hovered
                      ? _electricPurple.withValues(alpha: 0.25)
                      : _deepViolet.withValues(alpha: 0.15),
                  blurRadius: _hovered ? 40 : 24,
                  offset: const Offset(0, 8),
                  spreadRadius: _hovered ? 4 : 0,
                ),
                BoxShadow(
                  color: theme.shadowColor,
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox( // Bounded constraints
                height: 120,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      top: _hovered ? -30 : 0,
                      left: _hovered ? -30 : 0,
                      right: _hovered ? -30 : 0,
                      bottom: _hovered ? -30 : 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topRight,
                            radius: 1.0,
                            colors: [
                              _electricPurple.withValues(
                                  alpha: _hovered ? 0.15 : 0.08),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      bottom: _hovered ? -20 : 0,
                      left: _hovered ? -20 : 0,
                      right: _hovered ? -20 : 0,
                      top: _hovered ? -20 : 40,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.bottomLeft,
                            radius: 0.8,
                            colors: [
                              _neonMagenta.withValues(
                                  alpha: _hovered ? 0.1 : 0.05),
                              Colors.transparent,
                            ],
                          ),
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
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _deepViolet.withValues(alpha: 0.3),
                                  _electricPurple.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _hovered
                                    ? _electricPurple.withValues(alpha: 0.6)
                                    : _deepViolet.withValues(alpha: 0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _electricPurple.withValues(
                                      alpha: _hovered ? 0.3 : 0.15),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
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
                                  color:
                                      _hovered ? _softLavender : _electricPurple,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
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
                                        letterSpacing: -0.5,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 1500),
                                      width: 8,
                                      height: 8,
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
                                                alpha: _hovered ? 0.8 : 0.4),
                                            blurRadius: _hovered ? 12 : 6,
                                            spreadRadius: _hovered ? 2 : 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.module.subtitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.textSecondary,
                                    height: 1.3,
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
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _electricPurple.withValues(
                                        alpha: _hovered ? 0.2 : 0.05),
                                    Colors.transparent,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _hovered
                                      ? _electricPurple.withValues(alpha: 0.5)
                                      : _deepViolet.withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: _hovered
                                    ? _softLavender
                                    : _electricPurple.withValues(alpha: 0.7),
                                size: 20,
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
                          size: const Size(100, 100),
                          painter: const _LinePatternPainter(_electricPurple),
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