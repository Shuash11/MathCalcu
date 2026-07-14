import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:calculus_system/topics/calculus/midterm/theme/pointslope_theme/pointslopetheme.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// ── Card shell ────────────────────────────────
class PSCard extends StatelessWidget {
  final Widget child;
  final double s;

  const PSCard({super.key, required this.child, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: PSTheme.cardGradient(context),
        borderRadius: BorderRadius.circular(PSTheme.radiusCard * s),
        border: Border.all(
            color: PSTheme.glowPurple(0.25).withValues(alpha: 0.15),
            width: 1.5 * s),
        boxShadow: PSTheme.cardShadow(context, s),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PSTheme.radiusCard * s),
        child: Stack(
          children: [
            Positioned(
              top: -60 * s,
              right: -60 * s,
              child: Container(
                width: 260 * s,
                height: 260 * s,
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
              bottom: -40 * s,
              left: -40 * s,
              child: Container(
                width: 200 * s,
                height: 200 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    PSTheme.glowMagenta(0.07),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Opacity(
                opacity: 0.15,
                child: CustomPaint(
                  size: Size(110 * s, 110 * s),
                  painter: const DiagonalLinesPainter(PSTheme.electricPurple),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(24 * s), child: child),
          ],
        ),
      ),
    );
  }
}

/// ── Header ────────────────────────────────────
class PSHeader extends StatelessWidget {
  final Animation<double> pulseAnim;
  final double s;

  const PSHeader({super.key, required this.pulseAnim, required this.s});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52 * s,
          height: 52 * s,
          decoration: BoxDecoration(
            gradient: PSTheme.iconBoxGradient,
            borderRadius: BorderRadius.circular(PSTheme.radiusIconBox * s),
            border: Border.all(color: PSTheme.glowPurple(0.4), width: 2 * s),
            boxShadow: PSTheme.iconBoxShadow(s),
          ),
          child: Center(
            child: Icon(
              Icons.show_chart_rounded,
              color: PSTheme.electricPurple,
              size: 26 * s,
            ),
          ),
        ),
        SizedBox(width: 14 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ResponsiveText('Equation of a line',
                      style: PSTheme.titleStyle(context, s)),
                  SizedBox(width: 10 * s),
                  AnimatedBuilder(
                    animation: pulseAnim,
                    builder: (_, __) => Container(
                      width: 8 * s,
                      height: 8 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: PSTheme.neonMagenta,
                        boxShadow: [
                          BoxShadow(
                            color: PSTheme.glowMagenta(pulseAnim.value),
                            blurRadius: pulseAnim.value * 14 * s,
                            spreadRadius: pulseAnim.value * 2 * s,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3 * s),
              ResponsiveText(
                'Linear equation builder & visualiser',
                style: PSTheme.subtitleStyle(context, s),
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
          ResponsiveText('Point Slope Form', style: PSTheme.monoCaptionStyle(context)),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: PSTheme.formulaStyle(context),
              children: [
                const TextSpan(text: 'y − '),
                TextSpan(text: 'y₁', style: PSTheme.highlightVarStyle()),
                const TextSpan(text: ' = '),
                TextSpan(text: 'm', style: PSTheme.highlightVarStyle()),
                const TextSpan(text: '(x − '),
                TextSpan(text: 'x₁', style: PSTheme.highlightVarStyle()),
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
  final FocusNode mFocus, x1Focus, y1Focus;
  final double s;

  const PSInputsRow({
    super.key,
    required this.mCtrl,
    required this.x1Ctrl,
    required this.y1Ctrl,
    required this.mFocus,
    required this.x1Focus,
    required this.y1Focus,
    required this.s,
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
            focusNode: mFocus,
            s: s,
            textInputAction: TextInputAction.next,
            onEditingComplete: () => x1Focus.requestFocus(),
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: PSInputField(
            label: 'POINT',
            variable: 'x₁',
            controller: x1Ctrl,
            focusNode: x1Focus,
            s: s,
            textInputAction: TextInputAction.next,
            onEditingComplete: () => y1Focus.requestFocus(),
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: PSInputField(
            label: 'POINT',
            variable: 'y₁',
            controller: y1Ctrl,
            focusNode: y1Focus,
            s: s,
            textInputAction: TextInputAction.done,
            onEditingComplete: () => y1Focus.unfocus(),
          ),
        ),
      ],
    );
  }
}

class PSInputField extends StatelessWidget {
  final String label, variable;
  final TextEditingController controller;
  final FocusNode focusNode;
  final double s;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const PSInputField({
    super.key,
    required this.label,
    required this.variable,
    required this.controller,
    required this.focusNode,
    required this.s,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('$label  ', style: PSTheme.inputLabelStyle(context, s)),
            Text(variable, style: PSTheme.inputVarStyle(s)),
          ],
        ),
        SizedBox(height: 6 * s),
        PSTextField(
          controller: controller,
          focusNode: focusNode,
          s: s,
          textInputAction: textInputAction,
          onEditingComplete: onEditingComplete,
        ),
      ],
    );
  }
}

/// ── Text Field ─────────────────
class PSTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final double s;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const PSTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.s,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PSTheme.isLight(context)
            ? Colors.black.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(PSTheme.radiusInput * s),
        border: Border.all(
          color: PSTheme.glowPurple(0.2).withValues(alpha: 0.15),
          width: 1.5 * s,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.text,
        textInputAction: textInputAction,
        onEditingComplete: onEditingComplete,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d\s./-]')),
        ],
        style: PSTheme.inputTextStyle(context, s),
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14 * s, vertical: 10 * s),
          border: InputBorder.none,
          hintText: '3/4 or 1.5',
          hintStyle: PSTheme.inputHintStyle(context, s),
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
  final double s;

  const PSResultBanner({
    super.key,
    this.pointSlopeEq,
    this.generalFormEq,
    this.standardFormEq,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final hasResult = pointSlopeEq != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20 * s, 18 * s, 20 * s, 14 * s),
      decoration: BoxDecoration(
        gradient: PSTheme.resultBannerGradient(context, active: hasResult),
        borderRadius: BorderRadius.circular(PSTheme.radiusInner * s),
        border: Border.all(
          color: hasResult ? PSTheme.glowMagenta(0.5) : PSTheme.glowPurple(0.3),
          width: 1.5 * s,
        ),
        boxShadow: hasResult ? PSTheme.resultActiveShadow(s) : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasResult) ...[
            Text('POINT-SLOPE FORM', style: PSTheme.monoCaptionStyle(context)),
            SizedBox(height: 4 * s),
            Text(
              pointSlopeEq!,
              style: PSTheme.resultEquationStyle(context, s).copyWith(
                color: PSTheme.electricPurple,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12 * s),
            const Divider(),
            SizedBox(height: 12 * s),
            Text('GENERAL FORM', style: PSTheme.monoCaptionStyle(context)),
            SizedBox(height: 4 * s),
            Text(
              generalFormEq!,
              style: PSTheme.resultEquationStyle(context, s).copyWith(
                color: PSTheme.neonMagenta,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12 * s),
            const Divider(),
            SizedBox(height: 12 * s),
            Text('STANDARD FORM', style: PSTheme.monoCaptionStyle(context)),
            SizedBox(height: 4 * s),
            Text(
              standardFormEq!,
              style: PSTheme.resultEquationStyle(context, s).copyWith(
                color: const Color(0xFF10B981),
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            const SizedBox.shrink(),
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
  final double s;

  const PSGraph({
    super.key,
    this.mText = '',
    this.xText = '',
    this.yText = '',
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200 * s,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(PSTheme.radiusInner * s),
        border: Border.all(color: PSTheme.glowViolet(0.25)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PSTheme.radiusInner * s),
        child: CustomPaint(
          size: Size(double.infinity, 200 * s),
          painter: SimpleGraphPainter(
            mText: mText,
            xText: xText,
            yText: yText,
            s: s,
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
  final double s;

  SimpleGraphPainter({
    required this.mText,
    required this.xText,
    required this.yText,
    required this.s,
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

    final padding = 36.0 * s;
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
      ..strokeWidth = 0.5 * s;

    for (int gx = xMin.ceil(); gx <= xMax.floor(); gx++) {
      final sg = toScreen(gx.toDouble(), 0);
      canvas.drawLine(
        Offset(sg.dx, padding),
        Offset(sg.dx, size.height - padding),
        gridPaint,
      );
    }

    for (int gy = yMin.ceil(); gy <= yMax.floor(); gy++) {
      final sg = toScreen(0, gy.toDouble());
      canvas.drawLine(
        Offset(padding, sg.dy),
        Offset(size.width - padding, sg.dy),
        gridPaint,
      );
    }

    final axisPaint = Paint()
      ..color = const Color(0x40C4B5FD)
      ..strokeWidth = 1 * s;

    if (yMin <= 0 && yMax >= 0) {
      final sg = toScreen(0, 0);
      canvas.drawLine(
        Offset(padding, sg.dy),
        Offset(size.width - padding, sg.dy),
        axisPaint,
      );
    }

    if (xMin <= 0 && xMax >= 0) {
      final sg = toScreen(0, 0);
      canvas.drawLine(
        Offset(sg.dx, padding),
        Offset(sg.dx, size.height - padding),
        axisPaint,
      );
    }

    final glowPaint = Paint()
      ..color = const Color(0x99E879F9)
      ..strokeWidth = 4 * s
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * s);

    final linePaint = Paint()
      ..color = const Color(0xFFE879F9)
      ..strokeWidth = 1.8 * s
      ..strokeCap = StrokeCap.round;

    final p0 = toScreen(xMin, m * xMin + b);
    final p1 = toScreen(xMax, m * xMax + b);

    canvas.drawLine(p0, p1, glowPaint);
    canvas.drawLine(p0, p1, linePaint);

    final rp = toScreen(x1, y1);
    canvas.drawCircle(rp, 6 * s, Paint()..color = const Color(0xFFA855F7));

    final tp = TextPainter(
      text: TextSpan(
        text: '(${formatCoordinate(x1)}, ${formatCoordinate(y1)})',
        style: TextStyle(
          fontSize: 10 * s,
          color: const Color(0xFFC4B5FD),
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(rp.dx + 8 * s, rp.dy - 14 * s));
  }

  void _drawEmptyState(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x30C4B5FD)
      ..strokeWidth = 1 * s
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTWH(36 * s, 36 * s, size.width - 72 * s, size.height - 72 * s),
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
  final double s;

  const PSBadges({
    super.key,
    required this.direction,
    required this.angle,
    required this.riseRun,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8 * s,
      runSpacing: 8 * s,
      children: [
        PSBadge(key_: 'Direction', value: direction, s: s),
        PSBadge(key_: 'Angle', value: angle, s: s),
        PSBadge(key_: 'Rise/Run', value: riseRun, s: s),
      ],
    );
  }
}

class PSBadge extends StatelessWidget {
  final String key_, value;
  final double s;

  const PSBadge({super.key, required this.key_, required this.value, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5 * s, horizontal: 12 * s),
      decoration: BoxDecoration(
        color: PSTheme.glowViolet(0.15),
        borderRadius: BorderRadius.circular(PSTheme.radiusBadge * s),
        border: Border.all(color: PSTheme.glowPurple(0.3)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: '$key_: ', style: PSTheme.badgeKeyStyle(s)),
            TextSpan(text: value, style: PSTheme.badgeValueStyle(context, s)),
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
      ..strokeWidth = 1.5 * (size.width / 110);

    for (int i = -2; i < 6; i++) {
      final sx = i * 20.0 * (size.width / 110);
      canvas.drawLine(Offset(sx, 0), Offset(sx + 40 * (size.width / 110), size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
