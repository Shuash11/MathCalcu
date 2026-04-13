import 'package:calculus_system/core/module_registry.dart';
import 'package:flutter/material.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class TwoPointSlopeModuleCard extends StatefulWidget {
  final ModuleEntry module;
  const TwoPointSlopeModuleCard({super.key, required this.module});

  @override
  State<TwoPointSlopeModuleCard> createState() =>
      _TwoPointSlopeModuleCardState();
}

class _TwoPointSlopeModuleCardState extends State<TwoPointSlopeModuleCard> {
  bool _pressed = false;
  bool _hovered = false;

  static const Color _amber = Color(0xFFF59E0B);

  static const Color _softGold = Color(0xFFFCD34D);

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    // Responsive breakpoints
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;

    // Responsive sizing
    final iconSize = isSmall ? 48.0 : 56.0;
    final titleSize = isSmall ? 16.0 : 20.0;
    final subtitleSize = isSmall ? 12.0 : 13.0;
    final padding = isSmall ? 16.0 : 24.0;

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
              color: theme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hovered
                    ? _amber.withValues(alpha: 0.4)
                    : _amber.withValues(alpha: 0.18),
                width: _hovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _hovered
                      ? _amber.withValues(alpha: 0.2)
                      : _amber.withValues(alpha: 0.08),
                  blurRadius: _hovered ? 36 : 24,
                  offset: const Offset(0, 8),
                  spreadRadius: _hovered ? 2 : 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              // REMOVED: Fixed height SizedBox - now uses intrinsic height
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background blobs
                  Positioned(
                    top: -30,
                    right: -30,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _hovered ? 160 : 120,
                      height: _hovered ? 160 : 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _amber.withValues(alpha: _hovered ? 0.12 : 0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _hovered ? 140 : 100,
                      height: _hovered ? 140 : 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _amber.withValues(alpha: _hovered ? 0.10 : 0.05),
                      ),
                    ),
                  ),
                  // Optional: Hide decorative line on very small screens to save space
                  if (!isSmall)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _hovered ? 0.6 : 0.2,
                        child: CustomPaint(
                          size: const Size(48, 30),
                          painter: _TwoPointPainter(
                            color: _softGold.withValues(
                                alpha: _hovered ? 0.8 : 0.4),
                            strokeWidth: _hovered ? 3 : 2,
                          ),
                        ),
                      ),
                    ),
                  // Main content
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _amber.withValues(alpha: _hovered ? 0.2 : 0.12),
                                _amber.withValues(alpha: _hovered ? 0.1 : 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _hovered
                                  ? _amber.withValues(alpha: 0.5)
                                  : _amber.withValues(alpha: 0.25),
                              width: _hovered ? 2 : 1,
                            ),
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
                                color: _hovered ? _softGold : _amber,
                                size: iconSize * 0.46,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isSmall ? 12 : 18),
                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title with overflow protection
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _hovered ? _softGold : theme.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                                child: Text(
                                  widget.module.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: isSmall ? 2 : 4),
                              // Subtitle with overflow protection
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: subtitleSize,
                                  color: _hovered
                                      ? _softGold.withValues(alpha: 0.7)
                                      : theme.textSecondary,
                                ),
                                child: Text(
                                  widget.module.subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: isSmall ? 8 : 10),
                              // Formula chip - responsive text
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: EdgeInsets.symmetric(
                                    horizontal: isSmall ? 8 : 10,
                                    vertical: isSmall ? 3 : 4),
                                decoration: BoxDecoration(
                                  color: _amber.withValues(
                                      alpha: _hovered ? 0.15 : 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _amber.withValues(
                                        alpha: _hovered ? 0.4 : 0.2),
                                  ),
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: isSmall ? 10 : 12,
                                      color: _hovered ? _softGold : _amber,
                                    ),
                                    children: [
                                      const TextSpan(text: 'm = '),
                                      TextSpan(
                                        text: '(y₂−y₁)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: isSmall ? 10 : 12,
                                        ),
                                      ),
                                      const TextSpan(text: ' / '),
                                      TextSpan(
                                        text: '(x₂−x₁)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: isSmall ? 10 : 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: isSmall ? 8 : 12),
                        // Arrow
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: _hovered
                              ? (Matrix4.identity()..translate(4.0, 0.0))
                              : Matrix4.identity(),
                          child: Container(
                            width: isSmall ? 32 : 36,
                            height: isSmall ? 32 : 36,
                            decoration: BoxDecoration(
                              color: _hovered
                                  ? _amber.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _hovered
                                    ? _amber.withValues(alpha: 0.4)
                                    : _amber.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: _hovered
                                  ? _softGold
                                  : _amber.withValues(alpha: 0.6),
                              size: isSmall ? 16 : 16,
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

class _TwoPointPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _TwoPointPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), linePaint);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(0, size.height), strokeWidth + 1, dotPaint);
    canvas.drawCircle(Offset(size.width, 0), strokeWidth + 1, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
