import 'package:flutter/material.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import '../core/module_registry.dart';
import 'package:go_router/go_router.dart';

class SlopeModuleCard extends StatefulWidget {
  final ModuleEntry module;
  const SlopeModuleCard({required this.module, super.key});

  @override
  State<SlopeModuleCard> createState() => _SlopeModuleCardState();
}

class _SlopeModuleCardState extends State<SlopeModuleCard> {
  bool _pressed = false;
  bool _hovered = false;

  // Pink accent colors
  static const Color pinkAccent = Color(0xFFFF6B6B);
  static const Color deepPink = Color(0xFFFF4757);
  static const Color lightPink = Color(0xFFFFB8B8);

  @override
  Widget build(BuildContext context) {
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
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: context.watch<ThemeProvider>().card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hovered ? pinkAccent.withValues(alpha :0.4) : pinkAccent.withValues(alpha :0.18),
                width: _hovered ? 2 : 1,
              ),
              boxShadow: [
                // Enhanced shadow on hover
                BoxShadow(
                  color: _hovered ? pinkAccent.withValues(alpha :0.2) : pinkAccent.withValues(alpha :0.08),
                  blurRadius: _hovered ? 36 : 24,
                  offset: const Offset(0, 8),
                  spreadRadius: _hovered ? 2 : 0,
                ),
                // Inner depth shadow
                BoxShadow(
                  color: context.watch<ThemeProvider>().shadowColor,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Animated background circle (top right)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    top: _hovered ? -40 : -30,
                    right: _hovered ? -40 : -30,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _hovered ? 160 : 120,
                      height: _hovered ? 160 : 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: pinkAccent.withValues(alpha :_hovered ? 0.12 : 0.07),
                      ),
                    ),
                  ),

                  // Animated background circle (bottom left)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    bottom: _hovered ? -30 : -20,
                    left: _hovered ? -30 : -20,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _hovered ? 140 : 100,
                      height: _hovered ? 140 : 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: pinkAccent.withValues(alpha :_hovered ? 0.1 : 0.05),
                      ),
                    ),
                  ),

                  // Additional glow circle on hover
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    top: _hovered ? 30 : 50,
                    right: _hovered ? 80 : 60,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _hovered ? 0.5 : 0,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: deepPink.withValues(alpha :0.2),
                          boxShadow: [
                            BoxShadow(
                              color: pinkAccent.withValues(alpha :0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Rising slope indicator on hover
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    bottom: _hovered ? 20 : 10,
                    left: 20,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _hovered ? 0.6 : 0.2,
                      child: CustomPaint(
                        size: const Size(40, 30),
                        painter: _SlopeLinePainter(
                          color: lightPink.withValues(alpha :_hovered ? 0.8 : 0.4),
                          strokeWidth: _hovered ? 3 : 2,
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        // Icon container with hover effects
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                pinkAccent.withValues(alpha :_hovered ? 0.2 : 0.12),
                                pinkAccent.withValues(alpha :_hovered ? 0.1 : 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _hovered ? pinkAccent.withValues(alpha :0.5) : pinkAccent.withValues(alpha :0.25),
                              width: _hovered ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: pinkAccent.withValues(alpha :_hovered ? 0.3 : 0.15),
                                blurRadius: _hovered ? 16 : 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              transform: _hovered
                                  ? (Matrix4.identity()..scale(1.15)..rotateZ(-0.1))
                                  : Matrix4.identity(),
                              child: Icon(
                                widget.module.icon,
                                color: _hovered ? lightPink : pinkAccent,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),

                        // Text content with hover animations
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: _hovered ? lightPink : context.watch<ThemeProvider>().textPrimary,
                                  letterSpacing: -0.4,
                                ),
                                child: Text(widget.module.label),
                              ),
                              const SizedBox(height: 4),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _hovered 
                                      ? lightPink.withValues(alpha :0.7) 
                                      : context.watch<ThemeProvider>().textSecondary,
                                ),
                                child: Text(widget.module.subtitle),
                              ),
                            ],
                          ),
                        ),

                        // Animated arrow
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: _hovered
                              ? (Matrix4.identity()..translate(4.0, 0.0))
                              : Matrix4.identity(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _hovered ? pinkAccent.withValues(alpha :0.15) : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _hovered ? pinkAccent.withValues(alpha :0.4) : pinkAccent.withValues(alpha :0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: _hovered ? lightPink : pinkAccent.withValues(alpha :0.6),
                              size: 16,
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
}

// Custom painter for slope line decoration
class _SlopeLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _SlopeLinePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw rising line (positive slope)
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, 0),
      paint,
    );

    // Draw arrow at top
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width - 8, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 8)
      ..close();
    canvas.drawPath(path, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}