import 'dart:math';
import 'package:flutter/material.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'finding _radius_card.dart';
import 'finding_center_card.dart';
import 'finding_center_radius_card.dart';

class CircleCardPickerScreen extends StatelessWidget {
  const CircleCardPickerScreen({super.key});

  static const Color _indigo = Color(0xFF6366F1);
  static const Color _cyan = Color(0xFF06B6D4);

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
            child: _AmbientOrb(color: _cyan.withValues(alpha: 0.12), size: 260),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child:
                _AmbientOrb(color: _indigo.withValues(alpha: 0.10), size: 200),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [_buildTopBar(context, theme)]),
                    const SizedBox(height: 16),
                    const _PickerHeader(),
                    const SizedBox(height: 20),
                    _divider(),
                    const SizedBox(height: 20),

                    // ── Cards wired in from their own files ──
                    const FindingCenterCard(),

                    const SizedBox(height: 12),
                    const FindingRadiusCard(),
                    const SizedBox(height: 12),
                    const FindingCenterRadiusCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ThemeProvider theme) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _indigo.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: _indigo.withValues(alpha: 0.35), width: 1.5),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: _indigo, size: 18),
      ),
    );
  }

  Widget _divider() => Container(
        height: 1,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.transparent,
            Color(0x4D6366F1),
            Color(0x3306B6D4),
            Colors.transparent,
          ]),
        ),
      );
}

// ── Header ────────────────────────────────────────────────────────────────────

class _PickerHeader extends StatelessWidget {
  const _PickerHeader();

  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _indigo = Color(0xFF6366F1);
  static const Color _teal = Color(0xFF14B8A6);

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Row(
      children: [
        _OrbitBadge(),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Circle Solvers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _cyan.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _cyan.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(_indigo),
              const SizedBox(width: 4),
              _dot(_cyan),
              const SizedBox(width: 4),
              _dot(_teal),
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
          Positioned.fill(
            child: SizedBox(
              width: 52,
              height: 52,
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => CustomPaint(
                  painter: _OrbitRingPainter(progress: _ctrl.value),
                ),
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.4),
                  width: 1.5),
              gradient: RadialGradient(colors: [
                const Color(0xFF6366F1).withValues(alpha: 0.25),
                const Color(0xFF06B6D4).withValues(alpha: 0.08),
              ]),
            ),
            child: const Icon(Icons.trip_origin_rounded,
                color: Color(0xFF06B6D4), size: 18),
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
        ..color = const Color(0xFF06B6D4).withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final angle = progress * 2 * pi;
    final dot = Offset(
        center.dx + radius * cos(angle), center.dy + radius * sin(angle));
    canvas.drawCircle(dot, 5,
        Paint()..color = const Color(0xFF06B6D4).withValues(alpha: 0.3));
    canvas.drawCircle(dot, 2.5, Paint()..color = const Color(0xFF06B6D4));
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
