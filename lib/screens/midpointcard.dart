import 'package:calculus_system/core/module_registry.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MidpointModuleCard extends StatefulWidget {
  final ModuleEntry module;
  const MidpointModuleCard({super.key, required this.module});

  @override
  State<MidpointModuleCard> createState() => _MidpointModuleCardState();
}

class _MidpointModuleCardState extends State<MidpointModuleCard> {
  bool _pressed = false;
  bool _hovered = false;

  static const double _baseDesignWidth = 400.0;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    final Color accent =
        theme.isLight ? const Color(0xFF334155) : const Color(0xFFF8F9FA);
    final Color secondary =
        theme.isLight ? const Color(0xFF475569) : const Color(0xFFE9ECEF);
    final Color subtle =
        theme.isLight ? const Color(0xFF64748B) : const Color(0xFFDEE2E6);

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
                        ? accent.withValues(alpha: 0.4)
                        : accent.withValues(alpha: 0.15),
                    width: _hovered ? 2 * s : 1 * s,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(
                        alpha: _hovered ? 0.2 : 0.08,
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
                        top: -20 * s,
                        right: -20 * s,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 100 * s,
                          height: 100 * s,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.topRight,
                              radius: 0.8,
                              colors: [
                                accent.withValues(
                                  alpha: _hovered ? 0.15 : 0.08,
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
                          duration: const Duration(milliseconds: 300),
                          width: 110 * s,
                          height: 110 * s,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: secondary.withValues(
                              alpha: _hovered ? 0.12 : 0.05,
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
                              duration: const Duration(milliseconds: 200),
                              width: 60 * s,
                              height: 60 * s,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    accent.withValues(
                                      alpha: _hovered ? 0.2 : 0.15,
                                    ),
                                    accent.withValues(alpha: 0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16 * s),
                                border: Border.all(
                                  color: accent.withValues(
                                    alpha: _hovered ? 0.3 : 0.2,
                                  ),
                                  width: 1.5 * s,
                                ),
                              ),
                              child: Icon(
                                widget.module.icon,
                                color: secondary,
                                size: 28 * s,
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
                                      Flexible(
                                        child: Text(
                                          widget.module.label,
                                          style: TextStyle(
                                            fontSize: 18 * s,
                                            fontWeight: FontWeight.w800,
                                            color: theme.textPrimary,
                                            letterSpacing: -0.5 * s,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      SizedBox(width: 8 * s),
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: 7 * s,
                                        height: 7 * s,
                                        decoration: BoxDecoration(
                                          color: _hovered ? accent : subtle,
                                          shape: BoxShape.circle,
                                          boxShadow: _hovered
                                              ? [
                                                  BoxShadow(
                                                    color: accent.withValues(
                                                      alpha: 0.4,
                                                    ),
                                                    blurRadius: 6 * s,
                                                    spreadRadius: 1,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8 * s),
                                  Wrap(
                                    spacing: 6 * s,
                                    runSpacing: 6 * s,
                                    children: [
                                      _buildTag('Midpoint', accent, s),
                                      _buildTag('Endpoint', secondary, s),
                                    ],
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
                                  width: 36 * s,
                                  height: 36 * s,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _hovered
                                        ? accent.withValues(alpha: 0.1)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: accent.withValues(
                                        alpha: _hovered ? 0.25 : 0.15,
                                      ),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: secondary.withValues(
                                      alpha: _hovered ? 0.9 : 0.7,
                                    ),
                                    size: 18 * s,
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

  Widget _buildTag(String label, Color color, double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8 * s),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10 * s,
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}