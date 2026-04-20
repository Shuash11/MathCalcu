import 'package:calculus_system/core/module_registry.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DistanceModuleCard extends StatefulWidget {
  final ModuleEntry module;
  const DistanceModuleCard({required this.module, super.key});

  @override
  State<DistanceModuleCard> createState() => _DistanceModuleCardState();
}

class _DistanceModuleCardState extends State<DistanceModuleCard> {
  bool _pressed = false;
  bool _hovered = false;

  static const Color orange = Color(0xFFFF6B35);
  static const Color lightOrange = Color(0xFFFFB4A2);
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
                        ? orange.withValues(alpha: 0.6)
                        : orange.withValues(alpha: 0.25),
                    width: _hovered ? 2 * s : 1 * s,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: orange.withValues(
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
                                orange.withValues(
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
                            color: orange.withValues(
                              alpha: _hovered ? 0.15 : 0.08,
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
                                    orange.withValues(
                                      alpha: _hovered ? 0.2 : 0.12,
                                    ),
                                    orange.withValues(
                                      alpha: _hovered ? 0.1 : 0.05,
                                    ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16 * s),
                                border: Border.all(
                                  color: orange.withValues(
                                    alpha: _hovered ? 0.5 : 0.35,
                                  ),
                                  width: _hovered ? 2 : 1.5,
                                ),
                              ),
                              child: Icon(
                                widget.module.icon,
                                color: orange,
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
                                          ? orange
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
                                          ? orange.withValues(alpha: 0.7)
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
                                        ? orange.withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: orange.withValues(
                                        alpha: _hovered ? 0.5 : 0.25,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16 * s,
                                    color: _hovered
                                        ? orange
                                        : lightOrange.withValues(alpha: 0.8),
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