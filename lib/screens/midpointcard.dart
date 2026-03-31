import 'package:calculus_system/core/module_registry.dart';
import 'package:flutter/material.dart';
import 'package:calculus_system/theme/theme_provider.dart';
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

  // Dynamic colors for light/dark mode compatibility
  Color get _iceWhite => context.watch<ThemeProvider>().isLight
      ? const Color(0xFF334155) // Slate 800 - Good contrast in light mode
      : const Color(0xFFF8F9FA); // Frost white - Good in dark mode

  Color get _silver => context.watch<ThemeProvider>().isLight
      ? const Color(0xFF475569)
      : const Color(0xFFE9ECEF);

  Color get _frost => context.watch<ThemeProvider>().isLight
      ? const Color(0xFF64748B)
      : const Color(0xFFDEE2E6);

  Color get _glow => context.watch<ThemeProvider>().isLight
      ? const Color(0xFF0F172A)
      : const Color(0xFFFFFFFF);

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
                    ? _iceWhite.withValues(alpha: 0.4)
                    : _iceWhite.withValues(alpha: 0.12),
                width: _hovered ? 1.5 : 1,
              ),
              boxShadow: [
                // Soft accent glow
                BoxShadow(
                  color: _hovered
                      ? _iceWhite.withValues(alpha: 0.15)
                      : _iceWhite.withValues(alpha: 0.05),
                  blurRadius: _hovered ? 32 : 20,
                  offset: const Offset(0, 8),
                  spreadRadius: _hovered ? 2 : 0,
                ),
                // Inner depth shadow
                BoxShadow(
                  color: theme.shadowColor,
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
                  // Animated gradient background
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
                            _iceWhite.withValues(alpha: _hovered ? 0.08 : 0.03),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        // Icon container with frosted glass effect
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _iceWhite.withValues(alpha: 0.15),
                                _iceWhite.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _hovered
                                  ? _iceWhite.withValues(alpha: 0.5)
                                  : _iceWhite.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _iceWhite.withValues(alpha: 0.1),
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
                                color: _hovered ? _glow : _silver,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),

                        // Text content
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.module.label,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          _hovered ? _glow : theme.textPrimary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Unique indicator dot
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _hovered ? _glow : _frost,
                                      shape: BoxShape.circle,
                                      boxShadow: _hovered
                                          ? [
                                              BoxShadow(
                                                color: _glow.withValues(
                                                    alpha: 0.6),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Mode Tags
                              Wrap(
                                spacing: 6,
                                children: [
                                  _buildTag('Midpoint', _iceWhite),
                                  _buildTag('Endpoint', _silver),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Animated arrow
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
                                  ? _iceWhite.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _hovered
                                    ? _iceWhite.withValues(alpha: 0.3)
                                    : _iceWhite.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: _hovered
                                  ? _glow
                                  : _silver.withValues(alpha: 0.7),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Decorative corner accent
                  Positioned(
                    top: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _hovered ? 0.6 : 0.2,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topRight,
                            radius: 0.8,
                            colors: [
                              _iceWhite,
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

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
