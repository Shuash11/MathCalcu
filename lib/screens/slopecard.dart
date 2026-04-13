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
                    ? pinkAccent.withValues(alpha: 0.35)
                    : pinkAccent.withValues(alpha: 0.18),
                width: _hovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: pinkAccent.withValues(alpha: _hovered ? 0.15 : 0.08),
                  blurRadius: _hovered ? 32 : 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              // REMOVED: Fixed height - now uses intrinsic height
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Decorative circle — top right
                  Positioned(
                    top: -30,
                    right: -30,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _hovered ? 140 : 120,
                      height: _hovered ? 140 : 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: pinkAccent.withValues(alpha: _hovered ? 0.1 : 0.07),
                      ),
                    ),
                  ),
                  // Decorative circle — bottom left
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _hovered ? 120 : 100,
                      height: _hovered ? 120 : 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: pinkAccent.withValues(alpha: _hovered ? 0.08 : 0.05),
                      ),
                    ),
                  ),
                  // Slope line decoration — bottom left (hidden on small screens)
                  if (!isSmall)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _hovered ? 0.4 : 0.2,
                        child: CustomPaint(
                          size: const Size(40, 30),
                          painter: _SlopeLinePainter(
                            color: _hovered ? pinkAccent : lightPink,
                            strokeWidth: _hovered ? 3 : 2,
                          ),
                        ),
                      ),
                    ),
                  // Content
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon box with hover animation
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                pinkAccent.withValues(alpha: _hovered ? 0.18 : 0.12),
                                pinkAccent.withValues(alpha: _hovered ? 0.08 : 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: pinkAccent.withValues(alpha: _hovered ? 0.4 : 0.25),
                            ),
                          ),
                          child: Icon(
                            widget.module.icon,
                            color: _hovered ? pinkAccent : pinkAccent.withValues(alpha: 0.9),
                            size: iconSize * 0.46,
                          ),
                        ),
                        SizedBox(width: isSmall ? 12 : 18),
                        // Labels with overflow protection
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.module.label,
                                style: TextStyle(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: isSmall ? 2 : 4),
                              Text(
                                widget.module.subtitle,
                                style: TextStyle(
                                  fontSize: subtitleSize,
                                  color: theme.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: isSmall ? 8 : 12),
                        // Arrow with hover animation
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: _hovered 
                              ? (Matrix4.identity()..translate(4.0, 0.0))
                              : Matrix4.identity(),
                          child: Container(
                            width: isSmall ? 32 : 36,
                            height: isSmall ? 32 : 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _hovered ? pinkAccent.withValues(alpha: 0.12) : Colors.transparent,
                              border: Border.all(
                                color: pinkAccent.withValues(alpha: _hovered ? 0.35 : 0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: _hovered ? pinkAccent : pinkAccent.withValues(alpha: 0.6),
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