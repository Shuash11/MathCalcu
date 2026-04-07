import 'dart:math';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FindingRadiusCard extends StatefulWidget {
  const FindingRadiusCard({super.key});

  @override
  State<FindingRadiusCard> createState() => _FindingRadiusCardState();
}

class _FindingRadiusCardState extends State<FindingRadiusCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;
  late AnimationController _orbitCtrl;

  static const Color _indigo = Color(0xFF6366F1);
  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _teal = Color(0xFF14B8A6);
  static const Color _softIndigo = Color(0xFFA5B4FC);
  static const Color _accent = _cyan;

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
        onTap: () => context.push('/circle/finding-radius'),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 110),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: context.watch<ThemeProvider>().card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hovered
                    ? _accent.withValues(alpha: 0.5)
                    : _indigo.withValues(alpha: 0.3),
                width: _hovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _hovered
                      ? _accent.withValues(alpha: 0.25)
                      : _indigo.withValues(alpha: 0.15),
                  blurRadius: _hovered ? 40 : 24,
                  offset: const Offset(0, 8),
                  spreadRadius: _hovered ? 4 : 0,
                ),
                BoxShadow(
                  color: context.watch<ThemeProvider>().shadowColor,
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    _IconOrbit(
                      icon: Icons.radio_button_unchecked_rounded,
                      accent: _accent,
                      hovered: _hovered,
                      controller: _orbitCtrl,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: _hovered
                                        ? _softIndigo
                                        : context
                                            .watch<ThemeProvider>()
                                            .textPrimary,
                                    letterSpacing: -0.4,
                                  ),
                                  child: const Text('Finding the Radius'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _StatusDotsPill(hovered: _hovered),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Wrap(
                            spacing: 6,
                            children: [
                              _TagPill(label: 'Standard', color: _indigo),
                              _TagPill(label: 'Geometry', color: _cyan),
                              _TagPill(label: 'Circle', color: _teal),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _ArrowButton(hovered: _hovered, accent: _accent),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared widgets local to this card ────────────────────────────────────────

class _IconOrbit extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final bool hovered;
  final AnimationController controller;

  static const Color _indigo = Color(0xFF6366F1);
  static const Color _softIndigo = Color(0xFFA5B4FC);

  const _IconOrbit({
    required this.icon,
    required this.accent,
    required this.hovered,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hovered)
            Positioned.fill(
              child: SizedBox(
                width: 64,
                height: 64,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) => CustomPaint(
                    painter: _OrbitPainter(progress: controller.value, color: accent),
                  ),
                ),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: hovered
                    ? accent.withValues(alpha: 0.5)
                    : _indigo.withValues(alpha: 0.3),
                width: 2,
              ),
              gradient: RadialGradient(colors: [
                _indigo.withValues(alpha: hovered ? 0.3 : 0.15),
                accent.withValues(alpha: hovered ? 0.1 : 0.05),
              ]),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: hovered ? 0.3 : 0.15),
                  blurRadius: hovered ? 20 : 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: hovered ? 50 : 44,
                  height: hovered ? 50 : 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent.withValues(alpha: hovered ? 0.4 : 0.2),
                      width: 2,
                    ),
                  ),
                ),
                Icon(icon, color: hovered ? _softIndigo : accent, size: 24),
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

  static const Color _indigo = Color(0xFF6366F1);
  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _softIndigo = Color(0xFFA5B4FC);

  const _ArrowButton({required this.hovered, required this.accent});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: hovered
          ? (Matrix4.identity()..translate(6.0, 0.0))
          : Matrix4.identity(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: hovered
                ? accent.withValues(alpha: 0.4)
                : _indigo.withValues(alpha: 0.2),
            width: 1.5,
          ),
          gradient: LinearGradient(colors: [
            _indigo.withValues(alpha: hovered ? 0.2 : 0.05),
            accent.withValues(alpha: hovered ? 0.1 : 0.02),
          ]),
        ),
        child: Icon(
          Icons.arrow_forward_rounded,
          color: hovered ? _softIndigo : _cyan.withValues(alpha: 0.7),
          size: 20,
        ),
      ),
    );
  }
}

class _StatusDotsPill extends StatelessWidget {
  final bool hovered;

  static const Color _indigo = Color(0xFF6366F1);
  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _teal = Color(0xFF14B8A6);

  const _StatusDotsPill({required this.hovered});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _cyan.withValues(alpha: hovered ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cyan.withValues(alpha: hovered ? 0.5 : 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dot(_indigo),
          const SizedBox(width: 3),
          _dot(_cyan),
          const SizedBox(width: 3),
          _dot(_teal),
        ],
      ),
    );
  }

  Widget _dot(Color color) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: hovered
              ? [
                  BoxShadow(
                      color: color.withValues(alpha: 0.6),
                      blurRadius: 4,
                      spreadRadius: 1)
                ]
              : null,
        ),
      );
}

class _TagPill extends StatelessWidget {
  final String label;
  final Color color;

  const _TagPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
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
