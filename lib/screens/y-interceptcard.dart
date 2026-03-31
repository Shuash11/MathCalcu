import 'package:calculus_system/core/module_registry.dart';
import 'package:flutter/material.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class YInterceptModuleCard extends StatefulWidget {
  final ModuleEntry module;
  const YInterceptModuleCard({super.key, required this.module});

  @override
  State<YInterceptModuleCard> createState() => _YInterceptModuleCardState();
}

class _YInterceptModuleCardState extends State<YInterceptModuleCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  bool _hovered = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Emerald green + gold accent
  static const Color _forestGreen = Color(0xFF059669);
  static const Color _emerald = Color(0xFF10B981);
  static const Color _mint = Color(0xFF6EE7B7);
  static const Color _gold = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: context.watch<ThemeProvider>().card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hovered
                    ? _emerald.withValues(alpha: 0.5)
                    : _forestGreen.withValues(alpha: 0.25),
                width: _hovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _hovered
                      ? _emerald.withValues(alpha: 0.25)
                      : _forestGreen.withValues(alpha: 0.1),
                  blurRadius: _hovered ? 40 : 20,
                  offset: const Offset(0, 8),
                  spreadRadius: _hovered ? 4 : 0,
                ),
                BoxShadow(
                  color: _gold.withValues(alpha: _hovered ? 0.1 : 0.05),
                  blurRadius: _hovered ? 30 : 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    top: _hovered ? -40 : 0,
                    left: _hovered ? 0 : -40,
                    right: _hovered ? -40 : 0,
                    bottom: _hovered ? 0 : -40,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _emerald.withValues(alpha: _hovered ? 0.15 : 0.05),
                            Colors.transparent,
                            _gold.withValues(alpha: _hovered ? 0.1 : 0.03),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    top: _hovered ? -20 : 20,
                    right: _hovered ? -20 : 20,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _hovered ? 150 : 100,
                      height: _hovered ? 150 : 100,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            _emerald.withValues(alpha: _hovered ? 0.2 : 0.08),
                            Colors.transparent,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 20,
                    bottom: 20,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _hovered ? 4 : 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _mint.withValues(alpha: 0.1),
                            _emerald.withValues(alpha: _hovered ? 0.8 : 0.4),
                            _gold.withValues(alpha: _hovered ? 1.0 : 0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: _hovered
                            ? [
                                BoxShadow(
                                  color: _emerald.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(44, 24, 24, 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Changed to center for multi-line
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.8,
                              colors: [
                                _emerald.withValues(
                                    alpha: _hovered ? 0.3 : 0.15),
                                _forestGreen.withValues(
                                    alpha: _hovered ? 0.2 : 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _hovered
                                  ? _mint.withValues(alpha: 0.6)
                                  : _emerald.withValues(alpha: 0.3),
                              width: _hovered ? 2.5 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _emerald.withValues(
                                    alpha: _hovered ? 0.4 : 0.15),
                                blurRadius: _hovered ? 20 : 12,
                                offset: const Offset(0, 4),
                                spreadRadius: _hovered ? 2 : 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              transform: _hovered
                                  ? (Matrix4.identity()
                                    ..scale(1.15)
                                    ..translate(0.0, -3.0))
                                  : Matrix4.identity(),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Icon(
                                        Icons.vertical_align_center_rounded,
                                        color: _forestGreen.withValues(
                                            alpha: _hovered ? 0.2 : 0.3),
                                        size: 32,
                                      );
                                    },
                                  ),
                                  Icon(
                                    widget.module.icon,
                                    color: _hovered ? _mint : _emerald,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),

                        // Text content - AUTO WRAP TO NEXT LINE
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize:
                                MainAxisSize.min, // Allow column to shrink-wrap
                            children: [
                              // Title - wraps to next line if too long
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: _hovered
                                      ? _mint
                                      : context
                                          .watch<ThemeProvider>()
                                          .textPrimary,
                                  letterSpacing: -0.5,
                                  height:
                                      1.2, // Tighter line height for multi-line
                                ),
                                child: Text(
                                  widget.module.label,
                                  softWrap: true, // Allow wrapping
                                  overflow: TextOverflow.visible, // Don't clip
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Subtitle - wraps naturally
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _hovered
                                      ? _mint.withValues(alpha: 0.7)
                                      : context
                                          .watch<ThemeProvider>()
                                          .textSecondary,
                                  height: 1.3,
                                ),
                                child: Text(
                                  widget.module.subtitle,
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12), // Gap before arrow

                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: _hovered
                              ? (Matrix4.identity()..translate(6.0, 0.0))
                              : Matrix4.identity(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _emerald.withValues(
                                      alpha: _hovered ? 0.25 : 0.05),
                                  _gold.withValues(
                                      alpha: _hovered ? 0.15 : 0.02),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _hovered
                                    ? _mint.withValues(alpha: 0.5)
                                    : _emerald.withValues(alpha: 0.2),
                                width: _hovered ? 2 : 1.5,
                              ),
                              boxShadow: _hovered
                                  ? [
                                      BoxShadow(
                                        color: _emerald.withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: _hovered
                                  ? _mint
                                  : _emerald.withValues(alpha: 0.7),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 18,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _hovered ? 12 : 8,
                          height: _hovered ? 12 : 8,
                          decoration: BoxDecoration(
                            color: _gold,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _gold.withValues(
                                    alpha: _hovered ? 0.9 : 0.5),
                                blurRadius: _hovered ? 20 : 10,
                                spreadRadius: _hovered ? 3 : 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _hovered ? 0.6 : 0.2,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: _hovered ? 80 : 60,
                        height: _hovered ? 80 : 60,
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topRight,
                            radius: 0.8,
                            colors: [
                              _emerald,
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
                      duration: const Duration(milliseconds: 300),
                      opacity: _hovered ? 0.4 : 0.1,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: _hovered ? 60 : 40,
                        height: _hovered ? 60 : 40,
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.bottomLeft,
                            radius: 0.8,
                            colors: [
                              _gold,
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
