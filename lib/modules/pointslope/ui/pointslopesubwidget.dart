import 'package:calculus_system/modules/pointslope/Theme/pointslopetheme.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// ── Card shell ────────────────────────────────
class PSCard extends StatelessWidget {
  final Widget child;
  const PSCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: PSTheme.cardGradient(context),
        borderRadius: BorderRadius.circular(PSTheme.radiusCard),
        border: Border.all(
            color: PSTheme.glowPurple(0.25).withValues(alpha: 0.15),
            width: 1.5),
        boxShadow: PSTheme.cardShadow(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PSTheme.radiusCard),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    PSTheme.glowPurple(0.12),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    PSTheme.glowMagenta(0.07),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
            const Positioned(
              top: 0,
              right: 0,
              child: Opacity(
                opacity: 0.15,
                child: CustomPaint(
                  size: Size(110, 110),
                  painter: DiagonalLinesPainter(PSTheme.electricPurple),
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.all(24), child: child),
          ],
        ),
      ),
    );
  }
}

/// ── Header ────────────────────────────────────
class PSHeader extends StatelessWidget {
  final Animation<double> pulseAnim;
  const PSHeader({super.key, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: PSTheme.iconBoxGradient,
            borderRadius: BorderRadius.circular(PSTheme.radiusIconBox),
            border: Border.all(color: PSTheme.glowPurple(0.4), width: 2),
            boxShadow: PSTheme.iconBoxShadow,
          ),
          child: const Center(
            child: Icon(
              Icons.show_chart_rounded,
              color: PSTheme.electricPurple,
              size: 26,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Point-Slope Form', style: PSTheme.titleStyle(context)),
                  const SizedBox(width: 10),
                  AnimatedBuilder(
                    animation: pulseAnim,
                    builder: (_, __) => Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: PSTheme.neonMagenta,
                        boxShadow: [
                          BoxShadow(
                            color: PSTheme.glowMagenta(pulseAnim.value),
                            blurRadius: pulseAnim.value * 14,
                            spreadRadius: pulseAnim.value * 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'Linear equation builder & visualiser',
                style: PSTheme.subtitleStyle(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ── Formula banner ────────────────────────────
class PSFormulaBanner extends StatelessWidget {
  const PSFormulaBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: PSTheme.glowViolet(0.12),
        borderRadius: BorderRadius.circular(PSTheme.radiusChip),
        border: Border.all(color: PSTheme.glowViolet(0.3)),
      ),
      child: Column(
        children: [
          Text('STANDARD FORM', style: PSTheme.monoCaptionStyle(context)),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: PSTheme.formulaStyle(context),
              children: [
                const TextSpan(text: 'y − '),
                TextSpan(text: 'y₁', style: PSTheme.highlightVarStyle),
                const TextSpan(text: ' = '),
                TextSpan(text: 'm', style: PSTheme.highlightVarStyle),
                const TextSpan(text: '(x − '),
                TextSpan(text: 'x₁', style: PSTheme.highlightVarStyle),
                const TextSpan(text: ')'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Inputs row ────────────────────────────────
class PSInputsRow extends StatelessWidget {
  final TextEditingController mCtrl, x1Ctrl, y1Ctrl;

  const PSInputsRow({
    super.key,
    required this.mCtrl,
    required this.x1Ctrl,
    required this.y1Ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PSInputField(
            label: 'SLOPE',
            variable: 'm',
            controller: mCtrl,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PSInputField(
            label: 'POINT',
            variable: 'x₁',
            controller: x1Ctrl,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PSInputField(
            label: 'POINT',
            variable: 'y₁',
            controller: y1Ctrl,
          ),
        ),
      ],
    );
  }
}

class PSInputField extends StatelessWidget {
  final String label, variable;
  final TextEditingController controller;

  const PSInputField({
    super.key,
    required this.label,
    required this.variable,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('$label  ', style: PSTheme.inputLabelStyle(context)),
            Text(variable, style: PSTheme.inputVarStyle),
          ],
        ),
        const SizedBox(height: 6),
        PSTextField(controller: controller),
      ],
    );
  }
}

/// ── Text Field ─────────────────
class PSTextField extends StatelessWidget {
  final TextEditingController controller;

  const PSTextField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PSTheme.isLight(context)
            ? Colors.black.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(PSTheme.radiusInput),
        border: Border.all(
          color: PSTheme.glowPurple(0.2).withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        // Show full keyboard for flexible input including slashes, spaces, etc.
        keyboardType: TextInputType.text,
        // Allow digits, spaces, slashes, dots, and minus signs
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d\s./-]')),
        ],
        style: PSTheme.inputTextStyle(context),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: InputBorder.none,
          hintText: '3/4 or 1.5',
          hintStyle: PSTheme.inputHintStyle(context),
        ),
      ),
    );
  }
}

/// ── Divider ───────────────────────────────────
class PSDivider extends StatelessWidget {
  const PSDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: const BoxDecoration(gradient: PSTheme.dividerGradient),
    );
  }
}

/// ── UPDATED: Result banner with General and Standard Form ─────────────────────────────
class PSResultBanner extends StatelessWidget {
  final String? pointSlopeEq;
  final String? generalFormEq;
  final String? standardFormEq;
  final bool tappable;

  const PSResultBanner({
    super.key,
    this.pointSlopeEq,
    this.generalFormEq,
    this.standardFormEq,
    this.tappable = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasResult = pointSlopeEq != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: BoxDecoration(
        gradient: PSTheme.resultBannerGradient(context, active: hasResult),
        borderRadius: BorderRadius.circular(PSTheme.radiusInner),
        border: Border.all(
          color: hasResult ? PSTheme.glowMagenta(0.5) : PSTheme.glowPurple(0.3),
          width: 1.5,
        ),
        boxShadow: hasResult ? PSTheme.resultActiveShadow : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasResult) ...[
            // Point-Slope Form (Input)
            Text('POINT-SLOPE FORM', style: PSTheme.monoCaptionStyle(context)),
            const SizedBox(height: 4),
            Text(
              pointSlopeEq!,
              style: PSTheme.resultEquationStyle(context).copyWith(
                color: PSTheme.electricPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // General Form (Answer 1)
            Text('GENERAL FORM', style: PSTheme.monoCaptionStyle(context)),
            const SizedBox(height: 4),
            Text(
              generalFormEq!,
              style: PSTheme.resultEquationStyle(context).copyWith(
                color: PSTheme.neonMagenta,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Standard Form (Answer 2)
            Text('STANDARD FORM', style: PSTheme.monoCaptionStyle(context)),
            const SizedBox(height: 4),
            Text(
              standardFormEq!,
              style: PSTheme.resultEquationStyle(context).copyWith(
                color: const Color(0xFF10B981), // Emerald green
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Text('Enter values above',
                style: PSTheme.placeholderStyle(context)),
          ],
          if (tappable) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  color: PSTheme.neonMagenta.withValues(alpha: 0.7),
                  size: 13,
                ),
                const SizedBox(width: 5),
                Text(
                  'Tap to see step-by-step solution',
                  style: TextStyle(
                    color: PSTheme.neonMagenta.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// ── Graph ─────────────────────────────────────
class PSGraph extends StatelessWidget {
  final String mText;
  final String xText;
  final String yText;

  const PSGraph({
    super.key,
    this.mText = '',
    this.xText = '',
    this.yText = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(PSTheme.radiusInner),
        border: Border.all(color: PSTheme.glowViolet(0.25)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PSTheme.radiusInner),
        child: CustomPaint(
          size: const Size(double.infinity, 200),
          painter: SimpleGraphPainter(
            mText: mText,
            xText: xText,
            yText: yText,
          ),
        ),
      ),
    );
  }
}

/// ── Simple Graph Painter ───────────────────────
class SimpleGraphPainter extends CustomPainter {
  final String mText;
  final String xText;
  final String yText;

  SimpleGraphPainter({
    required this.mText,
    required this.xText,
    required this.yText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final m = double.tryParse(mText);
    final x1 = double.tryParse(xText);
    final y1 = double.tryParse(yText);

    String formatCoordinate(double value) {
      if (value == value.roundToDouble()) {
        return value.toInt().toString();
      } else {
        return value.toStringAsFixed(1);
      }
    }

    if (m == null || x1 == null || y1 == null) {
      _drawEmptyState(canvas, size);
      return;
    }

    const padding = 36.0;
    final innerW = size.width - padding * 2;
    final innerH = size.height - padding * 2;

    final b = y1 - m * x1;

    const range = 8.0;
    final xMin = x1 - range;
    final xMax = x1 + range;
    final yMin = y1 - range;
    final yMax = y1 + range;

    Offset toScreen(double wx, double wy) {
      final sx = padding + ((wx - xMin) / (xMax - xMin)) * innerW;
      final sy = padding + (1 - (wy - yMin) / (yMax - yMin)) * innerH;
      return Offset(sx, sy);
    }

    final gridPaint = Paint()
      ..color = const Color(0x1AA855F7)
      ..strokeWidth = 0.5;

    for (int gx = xMin.ceil(); gx <= xMax.floor(); gx++) {
      final s = toScreen(gx.toDouble(), 0);
      canvas.drawLine(
        Offset(s.dx, padding),
        Offset(s.dx, size.height - padding),
        gridPaint,
      );
    }

    for (int gy = yMin.ceil(); gy <= yMax.floor(); gy++) {
      final s = toScreen(0, gy.toDouble());
      canvas.drawLine(
        Offset(padding, s.dy),
        Offset(size.width - padding, s.dy),
        gridPaint,
      );
    }

    final axisPaint = Paint()
      ..color = const Color(0x40C4B5FD)
      ..strokeWidth = 1;

    if (yMin <= 0 && yMax >= 0) {
      final s = toScreen(0, 0);
      canvas.drawLine(
        Offset(padding, s.dy),
        Offset(size.width - padding, s.dy),
        axisPaint,
      );
    }

    if (xMin <= 0 && xMax >= 0) {
      final s = toScreen(0, 0);
      canvas.drawLine(
        Offset(s.dx, padding),
        Offset(s.dx, size.height - padding),
        axisPaint,
      );
    }

    final glowPaint = Paint()
      ..color = const Color(0x99E879F9)
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final linePaint = Paint()
      ..color = const Color(0xFFE879F9)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final p0 = toScreen(xMin, m * xMin + b);
    final p1 = toScreen(xMax, m * xMax + b);

    canvas.drawLine(p0, p1, glowPaint);
    canvas.drawLine(p0, p1, linePaint);

    final rp = toScreen(x1, y1);
    canvas.drawCircle(rp, 6, Paint()..color = const Color(0xFFA855F7));

    final tp = TextPainter(
      text: TextSpan(
        text: '(${formatCoordinate(x1)}, ${formatCoordinate(y1)})',
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFFC4B5FD),
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(rp.dx + 8, rp.dy - 14));
  }

  void _drawEmptyState(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x30C4B5FD)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTWH(36, 36, size.width - 72, size.height - 72),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant SimpleGraphPainter oldDelegate) =>
      oldDelegate.mText != mText ||
      oldDelegate.xText != xText ||
      oldDelegate.yText != yText;
}

/// ── Badges ────────────────────────────────────
class PSBadges extends StatelessWidget {
  final String direction;
  final String angle;
  final String riseRun;

  const PSBadges({
    super.key,
    required this.direction,
    required this.angle,
    required this.riseRun,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        PSBadge(key_: 'Direction', value: direction),
        PSBadge(key_: 'Angle', value: angle),
        PSBadge(key_: 'Rise/Run', value: riseRun),
      ],
    );
  }
}

class PSBadge extends StatelessWidget {
  final String key_, value;

  const PSBadge({super.key, required this.key_, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      decoration: BoxDecoration(
        color: PSTheme.glowViolet(0.15),
        borderRadius: BorderRadius.circular(PSTheme.radiusBadge),
        border: Border.all(color: PSTheme.glowPurple(0.3)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: '$key_: ', style: PSTheme.badgeKeyStyle),
            TextSpan(text: value, style: PSTheme.badgeValueStyle(context)),
          ],
        ),
      ),
    );
  }
}

/// ── Decoration painter ───────────────────────
class DiagonalLinesPainter extends CustomPainter {
  final Color color;

  const DiagonalLinesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 1.5;

    for (int i = -2; i < 6; i++) {
      final sx = i * 20.0;
      canvas.drawLine(Offset(sx, 0), Offset(sx + 40, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
