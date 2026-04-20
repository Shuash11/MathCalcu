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
                        ? _amber.withValues(alpha: 0.6)
                        : _amber.withValues(alpha: 0.25),
                    width: _hovered ? 2 * s : 1 * s,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _amber.withValues(
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
                            color: _amber.withValues(
                              alpha: _hovered ? 0.25 : 0.12,
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
                            color: _amber.withValues(
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
                            duration: const Duration(milliseconds: 300),
                            opacity: _hovered ? 0.6 : 0.2,
                            child: CustomPaint(
                              size: Size(48 * s, 30 * s),
                              painter: _TwoPointPainter(
                                color: _softGold.withValues(
                                  alpha: _hovered ? 0.8 : 0.4,
                                ),
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
                                    _amber.withValues(
                                      alpha: _hovered ? 0.2 : 0.12,
                                    ),
                                    _amber.withValues(
                                      alpha: _hovered ? 0.1 : 0.05,
                                    ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16 * s),
                                border: Border.all(
                                  color: _amber.withValues(
                                    alpha: _hovered ? 0.5 : 0.35,
                                  ),
                                  width: _hovered ? 2 : 1.5,
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
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      fontSize: 18 * s,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4 * s,
                                      color: _hovered
                                          ? _softGold
                                          : theme.textPrimary,
                                    ),
                                    child: Text(
                                      widget.module.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: 6 * s),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      fontSize: 13 * s,
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
                                  SizedBox(height: 10 * s),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10 * s,
                                      vertical: 4 * s,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _amber.withValues(
                alpha: _hovered ? 0.15 : 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(8 * s),
                                      border: Border.all(
                                        color: _amber.withValues(
                                          alpha: _hovered ? 0.4 : 0.2,
                                        ),
                                      ),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12 * s,
                                          color: _hovered ? _softGold : _amber,
                                        ),
                                        children: [
                                          const TextSpan(text: 'm = '),
                                          TextSpan(
                                            text: '(y₂−y₁)',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12 * s,
                                            ),
                                          ),
                                          const TextSpan(text: ' / '),
                                          TextSpan(
                                            text: '(x₂−x₁)',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12 * s,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
                                    color: _hovered
                                        ? _amber.withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _amber.withValues(
                                        alpha: _hovered ? 0.5 : 0.25,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16 * s,
                                    color: _hovered
                                        ? _softGold
                                        : _amber.withValues(alpha: 0.6),
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