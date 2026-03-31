import 'dart:math';
import 'package:flutter/material.dart';

import 'absolute_card.dart';
import 'continued_card.dart';
import 'non_strict_card.dart';
import 'quadratic_card.dart';
import 'rational_card.dart';
import 'simple_card.dart';
import 'strict_card.dart';
import 'radical_card.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';

class InequalityCardPickerScreen extends StatelessWidget {
  const InequalityCardPickerScreen({super.key});

  static const Color _purple = Color(0xFF6C63FF);
  static const Color _teal = Color(0xFF2DD4BF);

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: theme.surface,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: _AmbientOrb(color: _teal.withValues(alpha: 0.12), size: 260),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child:
                _AmbientOrb(color: _purple.withValues(alpha: 0.10), size: 200),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/'),
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 16,
                            color: theme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _PickerHeader(),
                    const SizedBox(height: 20),
                    _divider(),
                    const SizedBox(height: 20),

                    // ── Cards wired in from their own files ──
                    const SimpleCard(),
                    const SizedBox(height: 12),
                    const StrictCard(),
                    const SizedBox(height: 12),
                    const NonStrictCard(),
                    const SizedBox(height: 12),
                    const AbsoluteCard(),
                    const SizedBox(height: 12),
                    const ContinuedCard(),
                    const SizedBox(height: 12),
                    const RationalCard(),
                    const SizedBox(height: 12),
                    const QuadraticCard(),
                    const SizedBox(height: 12),
                    const RadicalCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 1,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.transparent,
            Color(0x4D6C63FF),
            Color(0x332DD4BF),
            Colors.transparent,
          ]),
        ),
      );
}

// ── Header ────────────────────────────────────────────────────────────────────

class _PickerHeader extends StatelessWidget {
  const _PickerHeader();

  static const Color _teal = Color(0xFF2DD4BF);
  static const Color _purple = Color(0xFF6C63FF);
  static const Color _softPurple = Color(0xFF9B8FFF);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _OrbitBadge(),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inequality Solvers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.watch<ThemeProvider>().textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Select a module to explore',
              style: TextStyle(
                  fontSize: 12, color: _softPurple.withValues(alpha: 0.55)),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _purple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _purple.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(_purple),
              const SizedBox(width: 4),
              _dot(_teal),
              const SizedBox(width: 4),
              _dot(const Color(0xFF14B8A6)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dot(Color c) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: c.withValues(alpha: 0.6), blurRadius: 4, spreadRadius: 1)
          ],
        ),
      );
}

// ── Orbit Badge ───────────────────────────────────────────────────────────────

class _OrbitBadge extends StatefulWidget {
  @override
  State<_OrbitBadge> createState() => _OrbitBadgeState();
}

class _OrbitBadgeState extends State<_OrbitBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => CustomPaint(
              size: const Size(52, 52),
              painter: _OrbitRingPainter(progress: _ctrl.value),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                  width: 1.5),
              gradient: RadialGradient(colors: [
                const Color(0xFF6C63FF).withValues(alpha: 0.25),
                const Color(0xFF2DD4BF).withValues(alpha: 0.08),
              ]),
            ),
            child: const Icon(Icons.code_rounded,
                color: Color(0xFFF5EBF5), size: 18),
          ),
        ],
      ),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  final double progress;

  const _OrbitRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF6C63FF).withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final angle = progress * 2 * pi;
    final dot = Offset(
        center.dx + radius * cos(angle), center.dy + radius * sin(angle));
    canvas.drawCircle(dot, 5,
        Paint()..color = const Color(0xFF2DD4BF).withValues(alpha: 0.3));
    canvas.drawCircle(dot, 2.5, Paint()..color = const Color(0xFF2DD4BF));
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter old) =>
      progress != old.progress;
}

// ── Ambient Orb ───────────────────────────────────────────────────────────────

class _AmbientOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _AmbientOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
