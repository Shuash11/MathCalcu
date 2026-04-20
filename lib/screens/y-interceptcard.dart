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

  static const Color _forestGreen = Color(0xFF059669);
  static const Color _emerald = Color(0xFF10B981);
  static const Color _mint = Color(0xFF6EE7B7);
  static const Color _gold = Color(0xFFF59E0B);
  static const double _baseDesignWidth = 400.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
          onEnter: (_) {
            if (mounted) setState(() => _hovered = true);
          },
          onExit: (_) {
            if (mounted) setState(() => _hovered = false);
          },
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
                        ? _emerald.withValues(alpha: 0.5)
                        : _forestGreen.withValues(alpha: 0.25),
                    width: _hovered ? 2 * s : 1 * s,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _hovered
                          ? _emerald.withValues(alpha: 0.25)
                          : _forestGreen.withValues(alpha: 0.1),
                      blurRadius: _hovered ? 40 * s : 20 * s,
                      offset: Offset(0, 8 * s),
                      spreadRadius: _hovered ? 4 : 0,
                    ),
                    BoxShadow(
                      color: _gold.withValues(alpha: _hovered ? 0.1 : 0.05),
                      blurRadius: _hovered ? 30 * s : 20 * s,
                      offset: Offset(0, -4 * s),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20 * s),
                  child: SizedBox(
                    height: 140 * s,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          top: _hovered ? -40 * s : 0,
                          left: _hovered ? 0 : -40 * s,
                          right: _hovered ? -40 * s : 0,
                          bottom: _hovered ? 0 : -40 * s,
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
                          top: _hovered ? -20 * s : 20 * s,
                          right: _hovered ? -20 * s : 20 * s,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _hovered ? 150 * s : 100 * s,
                            height: _hovered ? 150 * s : 100 * s,
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
                          left: 20 * s,
                          top: 20 * s,
                          bottom: 20 * s,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _hovered ? 4 * s : 2 * s,
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
                              borderRadius: BorderRadius.circular(2 * s),
                              boxShadow: _hovered
                                  ? [
                                      BoxShadow(
                                        color: _emerald.withValues(alpha: 0.4),
                                        blurRadius: 8 * s,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(44 * s, 24 * s, 24 * s, 24 * s),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 60 * s,
                                height: 60 * s,
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
                                  borderRadius: BorderRadius.circular(16 * s),
                                  border: Border.all(
                                    color: _hovered
                                        ? _mint.withValues(alpha: 0.6)
                                        : _emerald.withValues(alpha: 0.3),
                                    width: _hovered ? 2.5 * s : 2 * s,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _emerald.withValues(
                                          alpha: _hovered ? 0.4 : 0.15),
                                      blurRadius: _hovered ? 20 * s : 12 * s,
                                      offset: Offset(0, 4 * s),
                                      spreadRadius: _hovered ? 2 : 0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    transform: _hovered
                                        ? (Matrix4.identity()
                                          ..scale(1.15 * s)
                                          ..translate(0.0, -3.0 * s))
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
                                              size: 32 * s,
                                            );
                                          },
                                        ),
                                        Icon(
                                          widget.module.icon,
                                          color: _hovered ? _mint : _emerald,
                                          size: 24 * s,
                                        ),
                                      ],
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
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      style: TextStyle(
                                        fontSize: 17 * s,
                                        fontWeight: FontWeight.w600,
                                        color: _hovered
                                            ? _mint
                                            : theme.textPrimary,
                                        letterSpacing: -0.5 * s,
                                        height: 1.2,
                                      ),
                                      child: Text(
                                        widget.module.label,
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                    SizedBox(height: 4 * s),
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      style: TextStyle(
                                        fontSize: 13 * s,
                                        color: _hovered
                                            ? _mint.withValues(alpha: 0.7)
                                            : theme.textSecondary,
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
                              SizedBox(width: 12 * s),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                transform: _hovered
                                    ? (Matrix4.identity()..translate(6.0 * s, 0.0))
                                    : Matrix4.identity(),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: 40 * s,
                                  height: 40 * s,
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
                                      width: _hovered ? 2 * s : 1.5 * s,
                                    ),
                                    boxShadow: _hovered
                                        ? [
                                            BoxShadow(
                                              color: _emerald.withValues(alpha: 0.3),
                                              blurRadius: 12 * s,
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
                                    size: 20 * s,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 20 * s,
                          left: 18 * s,
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: _hovered ? 12 * s : 8 * s,
                                height: _hovered ? 12 * s : 8 * s,
                                decoration: BoxDecoration(
                                  color: _gold,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _gold.withValues(
                                          alpha: _hovered ? 0.9 : 0.5),
                                      blurRadius: _hovered ? 20 * s : 10 * s,
                                      spreadRadius: _hovered ? 3 : 1,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: 4 * s,
                                    height: 4 * s,
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
                              width: _hovered ? 80 * s : 60 * s,
                              height: _hovered ? 80 * s : 60 * s,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment.topRight,
                                  radius: 0.8,
                                  colors: [
                                    _emerald.withValues(alpha: 1.0),
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
                              width: _hovered ? 60 * s : 40 * s,
                              height: _hovered ? 60 * s : 40 * s,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment.bottomLeft,
                                  radius: 0.8,
                                  colors: [
                                    _gold.withValues(alpha: 1.0),
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