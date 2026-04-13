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

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    // Responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;

    final iconSize = isSmall ? 48.0 : 56.0;
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
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: theme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hovered
                    ? orange.withValues(alpha: 0.35)
                    : orange.withValues(alpha: 0.18),
                width: _hovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: orange.withValues(alpha: _hovered ? 0.15 : 0.08),
                  blurRadius: _hovered ? 32 : 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Decorative circles
                  Positioned(
                    top: -30,
                    right: -30,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _hovered ? 140 : 120,
                      height: _hovered ? 140 : 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: orange.withValues(alpha: _hovered ? 0.1 : 0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _hovered ? 120 : 100,
                      height: _hovered ? 120 : 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: orange.withValues(alpha: _hovered ? 0.08 : 0.05),
                      ),
                    ),
                  ),
                  // Content row
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
                                orange.withValues(
                                    alpha: _hovered ? 0.18 : 0.12),
                                orange.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: orange.withValues(
                                  alpha: _hovered ? 0.35 : 0.25),
                            ),
                          ),
                          child: Icon(
                            widget.module.icon,
                            color: orange,
                            size: iconSize * 0.46,
                          ),
                        ),
                        SizedBox(width: isSmall ? 12 : 18),
                        // Labels
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.module.label,
                                style: TextStyle(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              SizedBox(height: isSmall ? 2 : 4),
                              Text(
                                widget.module.subtitle,
                                style: TextStyle(
                                  fontSize: subtitleSize,
                                  color: theme.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
                                  ? orange.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              border: Border.all(
                                color: orange.withValues(
                                    alpha: _hovered ? 0.3 : 0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: _hovered
                                  ? orange
                                  : lightOrange.withValues(alpha: 0.8),
                              size: isSmall ? 16 : 16,
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
