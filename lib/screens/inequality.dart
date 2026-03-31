import 'package:calculus_system/core/module_registry.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/theme_provider.dart';

// ═════════════════════════════════════════════════════════════
// JOASHUA — INEQUALITY MODULE CARD
// ─────────────────────────────────────────────────────────────
// Custom card for the Inequalities module on CategoryPickerScreen.
// Blends InequalityTheme (purple) + SolverTheme (teal) accents.
// Hover/press animation matches MidpointModuleCard style.
// ═════════════════════════════════════════════════════════════

class InequalityModuleCard extends StatefulWidget {
  final ModuleEntry module;
  const InequalityModuleCard({super.key, required this.module});

  @override
  State<InequalityModuleCard> createState() => _InequalityModuleCardState();
}

class _InequalityModuleCardState extends State<InequalityModuleCard> {
  bool _pressed = false;
  bool _hovered = false;

  // ── InequalityTheme ───────────────────────────────────────
  static const Color _purple = Color(0xFF6C63FF);
  static const Color _purpleLight = Color(0xFF9B8FFF);

  // ── SolverTheme ───────────────────────────────────────────
  static const Color _teal = Color(0xFF2DD4BF);

  @override
  Widget build(BuildContext context) {
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
              color: context.watch<ThemeProvider>().card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hovered
                    ? _purple.withValues(alpha: 0.5)
                    : _purple.withValues(alpha: 0.22),
                width: _hovered ? 1.5 : 1,
              ),
              boxShadow: [
                // Purple glow
                BoxShadow(
                  color: _hovered
                      ? _purple.withValues(alpha: 0.2)
                      : _purple.withValues(alpha: 0.08),
                  blurRadius: _hovered ? 36 : 24,
                  offset: const Offset(0, 8),
                  spreadRadius: _hovered ? 2 : 0,
                ),
                // Teal glow
                BoxShadow(
                  color: _hovered
                      ? _teal.withValues(alpha: 0.12)
                      : _teal.withValues(alpha: 0.05),
                  blurRadius: _hovered ? 24 : 16,
                  offset: const Offset(0, 4),
                  spreadRadius: _hovered ? 1 : 0,
                ),
                // Inner depth
                BoxShadow(
                  color: context.watch<ThemeProvider>().shadowColor,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // ── Animated radial gradient background ───
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    top: _hovered ? -20 : 0,
                    left: _hovered ? -20 : 0,
                    right: _hovered ? -20 : 40,
                    bottom: _hovered ? -20 : 40,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.topLeft,
                          radius: 1.2,
                          colors: [
                            _purple.withValues(alpha: _hovered ? 0.1 : 0.04),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Content ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // ── Icon container ────────────
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _purple.withValues(alpha: 0.2),
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
                                boxShadow: [
                                  BoxShadow(
                                    color: _purple.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  transform: _hovered
                                      ? (Matrix4.identity()..scale(1.1))
                                      : Matrix4.identity(),
                                  child: Icon(
                                    widget.module.icon,
                                    color: _hovered ? _purpleLight : _purple,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),

                            // ── Label + subtitle ──────────
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          widget.module.label,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: context
                                                .watch<ThemeProvider>()
                                                .textPrimary,
                                            letterSpacing: -0.5,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Indicator dot
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: 6,
                                        height: 6,
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
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.module.subtitle,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context
                                          .watch<ThemeProvider>()
                                          .textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── Animated arrow ────────────
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              transform: _hovered
                                  ? (Matrix4.identity()..translate(4.0, 0.0))
                                  : Matrix4.identity(),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _hovered
                                      ? _purple.withValues(alpha: 0.12)
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
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ── Type pills ────────────────────
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _TypePill(
                              label: 'Strict',
                              color: _purple,
                              hovered: _hovered,
                            ),
                            _TypePill(
                              label: 'Absolute',
                              color: _purpleLight,
                              hovered: _hovered,
                            ),
                            _TypePill(
                              label: 'Rational',
                              color: _teal,
                              hovered: _hovered,
                            ),
                            _TypePill(
                              label: '+4 more',
                              color: _teal,
                              hovered: _hovered,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Decorative corner accent ───────────────
                  Positioned(
                    top: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _hovered ? 0.6 : 0.15,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topRight,
                            radius: 0.8,
                            colors: [
                              _purple.withValues(alpha: 0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Teal corner accent (bottom left) ───────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _hovered ? 0.4 : 0.08,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.bottomLeft,
                            radius: 0.8,
                            colors: [
                              _teal.withValues(alpha: 0.4),
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

// ── Type pill badge ───────────────────────────────────────────
class _TypePill extends StatelessWidget {
  final String label;
  final Color color;
  final bool hovered;

  const _TypePill({
    required this.label,
    required this.color,
    required this.hovered,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: hovered ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: hovered ? 0.35 : 0.2),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
