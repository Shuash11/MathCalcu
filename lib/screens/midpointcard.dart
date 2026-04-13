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

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    // Responsive breakpoints
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;

    // Responsive values
    final iconSize = isSmall ? 48.0 : 56.0;
    final titleSize = isSmall ? 16.0 : 20.0;

    final tagPadding = isSmall ? 6.0 : 8.0;
    final padding = isSmall ? 16.0 : 24.0;

    // Theme-aware colors
    final Color accent =
        theme.isLight ? const Color(0xFF334155) : const Color(0xFFF8F9FA);
    final Color secondary =
        theme.isLight ? const Color(0xFF475569) : const Color(0xFFE9ECEF);
    final Color subtle =
        theme.isLight ? const Color(0xFF64748B) : const Color(0xFFDEE2E6);

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
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: theme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hovered
                    ? accent.withValues(alpha: 0.25)
                    : accent.withValues(alpha: 0.12),
                width: _hovered ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: _hovered ? 0.12 : 0.06),
                  blurRadius: _hovered ? 28 : 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Decorative radial — top right
                  Positioned(
                    top: -20,
                    right: -20,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _hovered ? 100 : 80,
                      height: _hovered ? 100 : 80,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.topRight,
                          radius: 0.8,
                          colors: [
                            accent.withValues(alpha: _hovered ? 0.12 : 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Decorative circle — bottom left
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _hovered ? 110 : 90,
                      height: _hovered ? 110 : 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            secondary.withValues(alpha: _hovered ? 0.08 : 0.05),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon box
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accent.withValues(alpha: _hovered ? 0.2 : 0.15),
                                accent.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: accent.withValues(
                                  alpha: _hovered ? 0.3 : 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            widget.module.icon,
                            color: secondary,
                            size: iconSize * 0.46,
                          ),
                        ),
                        SizedBox(width: isSmall ? 12 : 18),
                        // Labels + tags
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
                                        fontWeight: FontWeight.w700,
                                        color: theme.textPrimary,
                                        letterSpacing: -0.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: isSmall ? 6 : 8),
                                  // Pulsing indicator
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: isSmall ? 6 : 7,
                                    height: isSmall ? 6 : 7,
                                    decoration: BoxDecoration(
                                      color: _hovered ? accent : subtle,
                                      shape: BoxShape.circle,
                                      boxShadow: _hovered
                                          ? [
                                              BoxShadow(
                                                color: accent.withValues(
                                                    alpha: 0.4),
                                                blurRadius: 6,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isSmall ? 6 : 8),
                              Wrap(
                                spacing: isSmall ? 4 : 6,
                                runSpacing: isSmall ? 4 : 6,
                                children: [
                                  _buildTag(
                                      'Midpoint', accent, tagPadding, isSmall),
                                  _buildTag('Endpoint', secondary, tagPadding,
                                      isSmall),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: isSmall ? 8 : 12),
                        // Arrow
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: _hovered
                              ? (Matrix4.identity()..translate(4.0, 0.0))
                              : Matrix4.identity(),
                          child: Container(
                            width: isSmall ? 32 : 36,
                            height: isSmall ? 32 : 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _hovered
                                  ? accent.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              border: Border.all(
                                color: accent.withValues(
                                    alpha: _hovered ? 0.25 : 0.15),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: secondary.withValues(
                                  alpha: _hovered ? 0.9 : 0.7),
                              size: isSmall ? 16 : 18,
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

  Widget _buildTag(String label, Color color, double padding, bool isSmall) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: padding, vertical: isSmall ? 2 : 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isSmall ? 9 : 10,
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
