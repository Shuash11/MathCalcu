import 'package:calculus_system/core/module_registry.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ParallelPerpendicularModuleCard extends StatefulWidget {
  final ModuleEntry module;

  const ParallelPerpendicularModuleCard({
    super.key,
    required this.module,
  });

  @override
  State<ParallelPerpendicularModuleCard> createState() =>
      _ParallelPerpendicularModuleCardState();
}

class _ParallelPerpendicularModuleCardState
    extends State<ParallelPerpendicularModuleCard> {
  bool _pressed = false;
  bool _hovered = false;

  static const Color _indigo = Color(0xFF4F46E5);
  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _sky = Color(0xFF7DD3FC);
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: theme.card,
                  borderRadius: BorderRadius.circular(20 * s),
                  border: Border.all(
                    color: _hovered
                        ? _cyan.withValues(alpha: 0.45)
                        : _indigo.withValues(alpha: 0.25),
                    width: _hovered ? 2 * s : 1 * s,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _hovered
                          ? _cyan.withValues(alpha: 0.2)
                          : _indigo.withValues(alpha: 0.1),
                      blurRadius: _hovered ? 36 * s : 22 * s,
                      offset: Offset(0, 8 * s),
                      spreadRadius: _hovered ? 2 : 0,
                    ),
                    BoxShadow(
                      color: theme.shadowColor,
                      blurRadius: 14 * s,
                      offset: Offset(0, 4 * s),
                      spreadRadius: -4 * s,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20 * s),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        top: _hovered ? -50 * s : -32 * s,
                        right: _hovered ? -40 * s : -20 * s,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _hovered ? 170 * s : 120 * s,
                          height: _hovered ? 170 * s : 120 * s,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _cyan.withValues(alpha: _hovered ? 0.14 : 0.07),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 450),
                        bottom: _hovered ? -36 * s : -20 * s,
                        left: _hovered ? -24 * s : -12 * s,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 320),
                          width: _hovered ? 150 * s : 100 * s,
                          height: _hovered ? 150 * s : 100 * s,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _indigo.withValues(alpha: _hovered ? 0.12 : 0.06),
                                Colors.transparent,
                              ],
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
                              duration: const Duration(milliseconds: 260),
                              width: _hovered ? 4 * s : 2 * s,
                              height: 80 * s,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3 * s),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    _indigo.withValues(alpha: 0.15),
                                    _cyan.withValues(alpha: 0.85),
                                    _sky.withValues(alpha: 0.95),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 18 * s),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: 60 * s,
                              height: 60 * s,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16 * s),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _indigo.withValues(alpha: 0.22),
                                    _cyan.withValues(alpha: 0.1),
                                  ],
                                ),
                                border: Border.all(
                                  color: _hovered
                                      ? _sky.withValues(alpha: 0.6)
                                      : _cyan.withValues(alpha: 0.3),
                                  width: _hovered ? 2 * s : 1.5 * s,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.align_vertical_center_rounded,
                                    color: _indigo.withValues(alpha: 0.35),
                                    size: 30 * s,
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    transform: _hovered
                                        ? (Matrix4.identity()
                                          ..scale(1.12)
                                          ..translate(0.0, -2.0 * s))
                                        : Matrix4.identity(),
                                    child: Icon(
                                      widget.module.icon,
                                      color: _hovered ? _sky : _cyan,
                                      size: 25 * s,
                                    ),
                                  ),
                                ],
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
                                      fontSize: 16 * s,
                                      fontWeight: FontWeight.w600,
                                      color: _hovered ? _sky : theme.textPrimary,
                                      letterSpacing: -0.4 * s,
                                      height: 1.2,
                                    ),
                                    child: Text(
                                      widget.module.label,
                                      softWrap: true,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: 4 * s),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      fontSize: 12 * s,
                                      color: _hovered
                                          ? _sky.withValues(alpha: 0.72)
                                          : theme.textSecondary,
                                      height: 1.3,
                                    ),
                                    child: Text(
                                      widget.module.subtitle,
                                      softWrap: true,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: 10 * s),
                                  Wrap(
                                    spacing: 6 * s,
                                    runSpacing: 6 * s,
                                    children: [
                                      _TagPill(
                                        label: 'Two Lines',
                                        color: _indigo,
                                        s: s,
                                      ),
                                      _TagPill(
                                        label: 'Slope Check',
                                        color: _cyan,
                                        s: s,
                                      ),
                                      _TagPill(
                                        label: 'Compare',
                                        color: _sky,
                                        s: s,
                                      ),
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
                                    ? (Matrix4.identity()..translate(6.0 * s, 0.0))
                                    : Matrix4.identity(),
                                child: Container(
                                  width: 40 * s,
                                  height: 40 * s,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        _indigo.withValues(alpha: 0.12),
                                        _cyan.withValues(alpha: 0.08),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: _hovered
                                          ? _sky.withValues(alpha: 0.55)
                                          : _cyan.withValues(alpha: 0.22),
                                      width: 1.5 * s,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: _hovered
                                        ? _sky
                                        : _cyan.withValues(alpha: 0.75),
                                    size: 20 * s,
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

class _TagPill extends StatelessWidget {
  final String label;
  final Color color;
  final double s;

  const _TagPill({
    required this.label,
    required this.color,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8 * s),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10 * s,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}