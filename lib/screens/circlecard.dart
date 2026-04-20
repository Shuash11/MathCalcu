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

class _CircleModuleCardState extends State<CircleModuleCard> {
  bool _pressed = false;
  bool _hovered = false;

  static const Color _indigo = Color(0xFF6366F1);
  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _teal = Color(0xFF14B8A6);
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
              scale: _pressed ? 0.97 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: theme.card,
                  borderRadius: BorderRadius.circular(20 * s),
                  border: Border.all(
                    color: _hovered
                        ? _indigo.withValues(alpha: 0.45)
                        : _indigo.withValues(alpha: 0.3),
                    width: _hovered ? 2 * s : 1 * s,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _indigo.withValues(alpha: _hovered ? 0.18 : 0.1),
                      blurRadius: _hovered ? 32 * s : 24 * s,
                      offset: Offset(0, 8 * s),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20 * s),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -20 * s,
                        right: -20 * s,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _hovered ? 120 * s : 100 * s,
                          height: _hovered ? 120 * s : 100 * s,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                _indigo.withValues(alpha: _hovered ? 0.12 : 0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -20 * s,
                        left: -20 * s,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _hovered ? 110 * s : 90 * s,
                          height: _hovered ? 110 * s : 90 * s,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _cyan.withValues(alpha: _hovered ? 0.1 : 0.06),
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
                              width: 56 * s,
                              height: 56 * s,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    _indigo.withValues(
                                        alpha: _hovered ? 0.2 : 0.15),
                                    _cyan.withValues(alpha: 0.05),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _indigo.withValues(
                                      alpha: _hovered ? 0.4 : 0.3),
                                  width: 1.5 * s,
                                ),
                              ),
                              child: Icon(
                                widget.module.icon,
                                color: _cyan,
                                size: 24 * s,
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
                                      fontWeight: FontWeight.w600,
                                      color: theme.textPrimary,
                                      letterSpacing: -0.5 * s,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  SizedBox(height: 4 * s),
                                  Text(
                                    widget.module.subtitle,
                                    style: TextStyle(
                                      fontSize: 13 * s,
                                      color: theme.textSecondary,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8 * s),
                                  Wrap(
                                    spacing: 6 * s,
                                    runSpacing: 6 * s,
                                    children: [
                                      _buildTypePill('Standard', _indigo, s),
                                      _buildTypePill(
                                          'General', _cyan, s),
                                      _buildTypePill(
                                          'Center', _teal, s),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12 * s),
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
                                        ? _indigo.withValues(alpha: 0.1)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: _indigo.withValues(
                                          alpha: _hovered ? 0.3 : 0.2),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color:
                                        _cyan.withValues(alpha: _hovered ? 0.9 : 0.7),
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

  Widget _buildTypePill(String label, Color color, double s) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 8 * s, vertical: 3 * s),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8 * s),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10 * s,
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}