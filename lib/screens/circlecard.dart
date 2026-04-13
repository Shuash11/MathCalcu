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
    final pillPadding = isSmall ? 6.0 : 8.0;

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
                    ? _indigo.withValues(alpha: 0.45)
                    : _indigo.withValues(alpha: 0.3),
                width: _hovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _indigo.withValues(alpha: _hovered ? 0.18 : 0.1),
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
                    top: -20,
                    right: -20,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _hovered ? 120 : 100,
                      height: _hovered ? 120 : 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _indigo.withValues(alpha: _hovered ? 0.12 : 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _hovered ? 110 : 90,
                      height: _hovered ? 110 : 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _cyan.withValues(alpha: _hovered ? 0.1 : 0.06),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon box — circle shape
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: iconSize,
                          height: iconSize,
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
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            widget.module.icon,
                            color: _cyan,
                            size: iconSize * 0.43,
                          ),
                        ),
                        SizedBox(width: isSmall ? 12 : 18),
                        // Labels + pills
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
                                  letterSpacing: -0.5,
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
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: isSmall ? 6 : 8),
                              Wrap(
                                spacing: isSmall ? 4 : 6,
                                runSpacing: isSmall ? 4 : 6,
                                children: [
                                  _buildTypePill('Standard', _indigo,
                                      pillPadding, isSmall),
                                  _buildTypePill(
                                      'General', _cyan, pillPadding, isSmall),
                                  _buildTypePill(
                                      'Center', _teal, pillPadding, isSmall),
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

  Widget _buildTypePill(
      String label, Color color, double padding, bool isSmall) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: padding, vertical: isSmall ? 2 : 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isSmall ? 9 : 10,
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
