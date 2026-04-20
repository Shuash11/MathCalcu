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
                        ? _purple.withValues(alpha: 0.5)
                        : _purple.withValues(alpha: 0.22),
                    width: _hovered ? 2 * s : 1 * s,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _hovered
                          ? _purple.withValues(alpha: 0.25)
                          : _purple.withValues(alpha: 0.1),
                      blurRadius: _hovered ? 36 * s : 24 * s,
                      offset: Offset(0, 8 * s),
                      spreadRadius: _hovered ? 2 : 0,
                    ),
                    BoxShadow(
                      color: _teal.withValues(alpha: _hovered ? 0.15 : 0.05),
                      blurRadius: _hovered ? 24 * s : 16 * s,
                      offset: Offset(0, 4 * s),
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
                        curve: Curves.easeOut,
                        top: _hovered ? -30 * s : 0,
                        left: _hovered ? -30 * s : 0,
                        right: _hovered ? -30 * s : 40 * s,
                        bottom: _hovered ? -30 * s : 40 * s,
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
                      Padding(
                        padding: EdgeInsets.all(20 * s),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
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
                                        _purple.withValues(
                                            alpha: _hovered ? 0.28 : 0.2),
                                        _teal.withValues(alpha: 0.12),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16 * s),
                                    border: Border.all(
                                      color: _hovered
                                          ? _purple.withValues(alpha: 0.5)
                                          : _purple.withValues(alpha: 0.2),
                                      width: 1.5 * s,
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
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
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
                                          ),
                                          SizedBox(width: 8 * s),
                                          AnimatedContainer(
                                            duration:
                                                const Duration(milliseconds: 200),
                                            width: 8 * s,
                                            height: 8 * s,
                                            decoration: BoxDecoration(
                                              color: _hovered ? _teal : _purple,
                                              shape: BoxShape.circle,
                                              boxShadow: _hovered
                                                  ? [
                                                      BoxShadow(
                                                        color: _teal.withValues(
                                                            alpha: 0.7),
                                                        blurRadius: 8 * s,
                                                        spreadRadius: 2,
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6 * s),
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
                                        size: 18 * s,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 18 * s),
                            Wrap(
                              spacing: 8 * s,
                              runSpacing: 6 * s,
                              children: [
                                _TypePill(
                                    label: 'Strict',
                                    color: _purple,
                                    hovered: _hovered,
                                    s: s),
                                _TypePill(
                                    label: 'Absolute',
                                    color: _purpleLight,
                                    hovered: _hovered,
                                    s: s),
                                _TypePill(
                                    label: 'Rational',
                                    color: _teal,
                                    hovered: _hovered,
                                    s: s),
                                _TypePill(
                                    label: '+4 more',
                                    color: _teal,
                                    hovered: _hovered,
                                    s: s),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _hovered ? 0.6 : 0.15,
                          child: Container(
                            width: _hovered ? 120 * s : 100 * s,
                            height: _hovered ? 120 * s : 100 * s,
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
                            width: _hovered ? 100 * s : 80 * s,
                            height: _hovered ? 100 * s : 80 * s,
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

        if (constraints.hasInfiniteWidth) {
          return SizedBox(width: effectiveWidth, child: content);
        }
        return content;
      },
    );
  }
}

class _TypePill extends StatelessWidget {
  final String label;
  final Color color;
  final bool hovered;
  final double s;

  const _TypePill({
    required this.label,
    required this.color,
    required this.hovered,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
          horizontal: 10 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: color.withValues(alpha: hovered ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8 * s),
        border: Border.all(
          color: color.withValues(alpha: hovered ? 0.4 : 0.2),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11 * s,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}