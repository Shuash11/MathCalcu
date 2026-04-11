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

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

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
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: theme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hovered
                    ? _cyan.withValues(alpha: 0.45)
                    : _indigo.withValues(alpha: 0.25),
                width: _hovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _hovered
                      ? _cyan.withValues(alpha: 0.2)
                      : _indigo.withValues(alpha: 0.1),
                  blurRadius: _hovered ? 36 : 22,
                  offset: const Offset(0, 8),
                  spreadRadius: _hovered ? 2 : 0,
                ),
                BoxShadow(
                  color: theme.shadowColor,
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    top: _hovered ? -50 : -32,
                    right: _hovered ? -40 : -20,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _hovered ? 170 : 120,
                      height: _hovered ? 170 : 120,
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
                    bottom: _hovered ? -36 : -20,
                    left: _hovered ? -24 : -12,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      width: _hovered ? 150 : 100,
                      height: _hovered ? 150 : 100,
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
                  Positioned(
                    left: 20,
                    top: 20,
                    bottom: 20,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      width: _hovered ? 4 : 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
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
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(42, 24, 24, 24),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
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
                              width: _hovered ? 2 : 1.5,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.align_vertical_center_rounded,
                                color: _indigo.withValues(alpha: 0.35),
                                size: 30,
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                transform: _hovered
                                    ? (Matrix4.identity()
                                      ..scale(1.12)
                                      ..translate(0.0, -2.0))
                                    : Matrix4.identity(),
                                child: Icon(
                                  widget.module.icon,
                                  color: _hovered ? _sky : _cyan,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: _hovered ? _sky : theme.textPrimary,
                                  letterSpacing: -0.4,
                                  height: 1.2,
                                ),
                                child: Text(
                                  widget.module.label,
                                  softWrap: true,
                                ),
                              ),
                              const SizedBox(height: 4),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _hovered
                                      ? _sky.withValues(alpha: 0.72)
                                      : theme.textSecondary,
                                  height: 1.3,
                                ),
                                child: Text(
                                  widget.module.subtitle,
                                  softWrap: true,
                                ),
                              ),
                              const SizedBox(height: 10),
                            const Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: const [
                                  _TagPill(label: 'Two Lines', color: _indigo),
                                  _TagPill(label: 'Slope Check', color: _cyan),
                                  _TagPill(label: 'Compare', color: _sky),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: _hovered
                              ? (Matrix4.identity()..translate(6.0, 0.0))
                              : Matrix4.identity(),
                          child: Container(
                            width: 40,
                            height: 40,
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
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: _hovered
                                  ? _sky
                                  : _cyan.withValues(alpha: 0.75),
                              size: 20,
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

class _TagPill extends StatelessWidget {
  final String label;
  final Color color;

  const _TagPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
