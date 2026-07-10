import 'dart:math';
import 'package:calculus_system/topics/midterm/theme/inequalities_theme/inequality_theme.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AnimatedInequalityCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color accentColor;
  final List<String> tags;

  const AnimatedInequalityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.accentColor,
    required this.tags,
  });

  @override
  State<AnimatedInequalityCard> createState() => _AnimatedInequalityCardState();
}

class _AnimatedInequalityCardState extends State<AnimatedInequalityCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;
  late AnimationController _orbitCtrl;

  static const Color _purple = Color(0xFF6C63FF);
  static const double _baseDesignWidth = 400.0;

  @override
  void initState() {
    super.initState();
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double effectiveWidth = constraints.hasInfiniteWidth
            ? _baseDesignWidth
            : constraints.maxWidth;
        final double s = (effectiveWidth / _baseDesignWidth).clamp(0.7, 1.2);

        return MouseRegion(
          onEnter: (_) => setState(() {
            _hovered = true;
            _orbitCtrl.repeat();
          }),
          onExit: (_) => setState(() {
            _hovered = false;
            _orbitCtrl.stop();
          }),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: () => context.go(widget.route),
            child: AnimatedScale(
              scale: _pressed ? 0.97 : 1.0,
              duration: const Duration(milliseconds: 110),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: InequalityTheme.card(context),
                  borderRadius: BorderRadius.circular(20 * s),
                  border: Border.all(
                    color: _hovered
                        ? widget.accentColor.withValues(alpha: 0.5)
                        : _purple.withValues(alpha: 0.3),
                    width: _hovered ? 2 * s : 1 * s,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _hovered
                          ? widget.accentColor.withValues(alpha: 0.25)
                          : _purple.withValues(alpha: 0.15),
                      blurRadius: _hovered ? 40 * s : 24 * s,
                      offset: Offset(0, 8 * s),
                      spreadRadius: _hovered ? 4 * s : 0,
                    ),
                    BoxShadow(
                      color: context.watch<ThemeProvider>().shadowColor,
                      blurRadius: 16 * s,
                      offset: Offset(0, 6 * s),
                      spreadRadius: -4 * s,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20 * s),
                  child: Padding(
                    padding: EdgeInsets.all(24 * s),
                    child: Row(
                      children: [
                        _IconOrbit(
                          icon: widget.icon,
                          accent: widget.accentColor,
                          hovered: _hovered,
                          controller: _orbitCtrl,
                          s: s,
                        ),
                        SizedBox(width: 18 * s),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 18 * s,
                                  fontWeight: FontWeight.w600,
                                  color: _hovered
                                      ? widget.accentColor
                                      : InequalityTheme.text(context),
                                  letterSpacing: -0.4 * s,
                                ),
                                child: Text(widget.title),
                              ),
                              SizedBox(height: 8 * s),
                              Wrap(
                                spacing: 6 * s,
                                runSpacing: 4 * s,
                                children: widget.tags
                                    .map((t) => _TagPill(
                                        label: t,
                                        color: widget.accentColor,
                                        s: s))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        _ArrowButton(
                            hovered: _hovered,
                            accent: widget.accentColor,
                            s: s),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IconOrbit extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final bool hovered;
  final AnimationController controller;
  final double s;

  static const Color _purple = Color(0xFF6C63FF);

  const _IconOrbit({
    required this.icon,
    required this.accent,
    required this.hovered,
    required this.controller,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64 * s,
      height: 64 * s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hovered)
            AnimatedBuilder(
              animation: controller,
              builder: (_, __) => CustomPaint(
                size: Size(64 * s, 64 * s),
                painter:
                    _OrbitPainter(progress: controller.value, color: accent),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 52 * s,
            height: 52 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: hovered
                    ? accent.withValues(alpha: 0.5)
                    : _purple.withValues(alpha: 0.3),
                width: 2 * s,
              ),
              gradient: RadialGradient(colors: [
                _purple.withValues(alpha: hovered ? 0.3 : 0.15),
                accent.withValues(alpha: hovered ? 0.1 : 0.05),
              ]),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: hovered ? 0.3 : 0.15),
                  blurRadius: hovered ? 20 * s : 12 * s,
                  offset: Offset(0, 4 * s),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: hovered ? 50 * s : 44 * s,
                  height: hovered ? 50 * s : 44 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent.withValues(alpha: hovered ? 0.4 : 0.2),
                      width: 2 * s,
                    ),
                  ),
                ),
                Icon(icon,
                    color: hovered ? const Color(0xFFF5EBF5) : accent,
                    size: 24 * s),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final bool hovered;
  final Color accent;
  final double s;

  static const Color _purple = Color(0xFF6C63FF);

  const _ArrowButton({
    required this.hovered,
    required this.accent,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: hovered
          ? Matrix4.translationValues(6.0 * s, 0.0, 0.0)
          : Matrix4.identity(),
      child: Container(
        width: 40 * s,
        height: 40 * s,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: hovered
                ? accent.withValues(alpha: 0.4)
                : _purple.withValues(alpha: 0.2),
            width: 1.5 * s,
          ),
          gradient: LinearGradient(colors: [
            _purple.withValues(alpha: hovered ? 0.2 : 0.05),
            accent.withValues(alpha: hovered ? 0.1 : 0.02),
          ]),
        ),
        child: Icon(
          Icons.arrow_forward_rounded,
          color:
              hovered ? const Color(0xFFF5EBF5) : accent.withValues(alpha: 0.7),
          size: 20 * s,
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  final Color color;
  final double s;

  const _TagPill({required this.label, required this.color, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 3 * s),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8 * s),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10 * s,
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _OrbitPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final angle = progress * 2 * pi;
    final dot = Offset(
        center.dx + radius * cos(angle), center.dy + radius * sin(angle));
    canvas.drawCircle(dot, 5, Paint()..color = color.withValues(alpha: 0.3));
    canvas.drawCircle(dot, 2.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter old) => progress != old.progress;
}
