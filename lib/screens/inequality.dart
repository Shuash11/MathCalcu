import 'package:calculus_system/core/module_registry.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class InequalityModuleCard extends StatefulWidget {
  final ModuleEntry module;
  const InequalityModuleCard({super.key, required this.module});

  @override
  State<InequalityModuleCard> createState() => _InequalityModuleCardState();
}

class _InequalityModuleCardState extends State<InequalityModuleCard> {
  bool _pressed = false;
  bool _hovered = false;

  static const Color _purple = Color(0xFF6C63FF);
  static const Color _purpleLight = Color(0xFF9B8FFF);
  static const Color _teal = Color(0xFF2DD4BF);

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    // Responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;

    final iconSize = isSmall ? 48.0 : 60.0;
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: theme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hovered
                    ? _purple.withValues(alpha: 0.5)
                    : _purple.withValues(alpha: 0.22),
                width: _hovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _hovered
                      ? _purple.withValues(alpha: 0.25)
                      : _purple.withValues(alpha: 0.1),
                  blurRadius: _hovered ? 36 : 24,
                  offset: const Offset(0, 8),
                  spreadRadius: _hovered ? 2 : 0,
                ),
                BoxShadow(
                  color: _teal.withValues(alpha: _hovered ? 0.15 : 0.05),
                  blurRadius: _hovered ? 24 : 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Animated radial gradient background
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    top: _hovered ? -30 : 0,
                    left: _hovered ? -30 : 0,
                    right: _hovered ? -30 : 40,
                    bottom: _hovered ? -30 : 40,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.topLeft,
                          radius: 1.2,
                          colors: [
                            _purple.withValues(alpha: _hovered ? 0.15 : 0.04),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Icon container
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: iconSize,
                              height: iconSize,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _purple.withValues(
                                        alpha: _hovered ? 0.28 : 0.2),
                                    _teal.withValues(alpha: 0.12),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _hovered
                                      ? _purple.withValues(alpha: 0.5)
                                      : _purple.withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  transform: _hovered
                                      ? (Matrix4.identity()..scale(1.15))
                                      : Matrix4.identity(),
                                  child: Icon(
                                    widget.module.icon,
                                    color: _hovered ? _purpleLight : _purple,
                                    size: iconSize * 0.47,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: isSmall ? 12 : 18),
                            // Label + subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          widget.module.label,
                                          style: TextStyle(
                                            fontSize: titleSize,
                                            fontWeight: FontWeight.w600,
                                            color: theme.textPrimary,
                                            letterSpacing: -0.5,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      SizedBox(width: isSmall ? 6 : 8),
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: isSmall ? 6 : 8,
                                        height: isSmall ? 6 : 8,
                                        decoration: BoxDecoration(
                                          color: _hovered ? _teal : _purple,
                                          shape: BoxShape.circle,
                                          boxShadow: _hovered
                                              ? [
                                                  BoxShadow(
                                                    color: _teal.withValues(
                                                        alpha: 0.7),
                                                    blurRadius: 8,
                                                    spreadRadius: 2,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isSmall ? 4 : 6),
                                  Text(
                                    widget.module.subtitle,
                                    style: TextStyle(
                                      fontSize: subtitleSize,
                                      color: theme.textSecondary,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: isSmall ? 8 : 12),
                            // Animated arrow
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
                                      ? _purple.withValues(alpha: 0.15)
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _hovered
                                        ? _purple.withValues(alpha: 0.4)
                                        : _purple.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  color: _hovered
                                      ? _purpleLight
                                      : _purple.withValues(alpha: 0.7),
                                  size: isSmall ? 16 : 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmall ? 12 : 18),
                        // Type pills
                        Wrap(
                          spacing: isSmall ? 6 : 8,
                          runSpacing: isSmall ? 4 : 6,
                          children: [
                            _TypePill(
                                label: 'Strict',
                                color: _purple,
                                hovered: _hovered,
                                isSmall: isSmall),
                            _TypePill(
                                label: 'Absolute',
                                color: _purpleLight,
                                hovered: _hovered,
                                isSmall: isSmall),
                            _TypePill(
                                label: 'Rational',
                                color: _teal,
                                hovered: _hovered,
                                isSmall: isSmall),
                            _TypePill(
                                label: '+4 more',
                                color: _teal,
                                hovered: _hovered,
                                isSmall: isSmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Decorative corners
                  Positioned(
                    top: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _hovered ? 0.6 : 0.15,
                      child: Container(
                        width: _hovered ? 120 : 100,
                        height: _hovered ? 120 : 100,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topRight,
                            radius: 0.8,
                            colors: [
                              _purple.withValues(alpha: 0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _hovered ? 0.4 : 0.08,
                      child: Container(
                        width: _hovered ? 100 : 80,
                        height: _hovered ? 100 : 80,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.bottomLeft,
                            radius: 0.8,
                            colors: [
                              _teal.withValues(alpha: 0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
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
  }
}

class _TypePill extends StatelessWidget {
  final String label;
  final Color color;
  final bool hovered;
  final bool isSmall;

  const _TypePill({
    required this.label,
    required this.color,
    required this.hovered,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 8 : 10, vertical: isSmall ? 3 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: hovered ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: hovered ? 0.4 : 0.2),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isSmall ? 10 : 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
