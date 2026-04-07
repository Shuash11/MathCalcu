import 'package:calculus_system/modules/two-point%20slope/Theme/two_point_slope_theme.dart';
import 'package:calculus_system/modules/two-point%20slope/controller/two_point_slope_controller.dart';
import 'package:calculus_system/modules/two-point%20slope/graph/two_point_slope_graph.dart';
import 'package:calculus_system/modules/two-point%20slope/solver/two_point_slope_steps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────
// TWO-POINT SLOPE SCREEN - COMPLETE & FIXED
// ─────────────────────────────────────────────────────────────

class TwoPointSlopeScreen extends StatefulWidget {
  const TwoPointSlopeScreen({super.key});

  @override
  State<TwoPointSlopeScreen> createState() => _TwoPointSlopeScreenState();
}

class _TwoPointSlopeScreenState extends State<TwoPointSlopeScreen>
    with SingleTickerProviderStateMixin {
  late final TwoPointSlopeController _controller;
  late final AnimationController _headerAnim;
  late final Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _controller = TwoPointSlopeController();
    _controller.addListener(() => setState(() {}));

    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _headerFade = CurvedAnimation(
      parent: _headerAnim,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _headerAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwoPointSlopeTheme.surface(context),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  _buildInputCard(),
                  const SizedBox(height: 20),
                  if (_controller.hasSolved) ...[
                    _buildResultCard(),
                    const SizedBox(height: 20),
                    TwoPointSlopeGraph(result: _controller.result!),
                    const SizedBox(height: 20),
                    TwoPointSlopeSteps(result: _controller.result!),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _headerFade,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: TwoPointSlopeTheme.cardBg(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: TwoPointSlopeTheme.border(0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: TwoPointSlopeTheme.textSecondary(context),
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: TwoPointSlopeTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'TWO-POINT SLOPE',
                          style: TwoPointSlopeTheme.labelStyle(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Slope Calculator',
                      style: TwoPointSlopeTheme.headingStyle(context),
                    ),
                  ],
                ),
              ),

              // Example button
              GestureDetector(
                onTap: () {
                  _controller.fillExample();
                  try {
                    HapticFeedback.lightImpact();
                  } catch (_) {}
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: TwoPointSlopeTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: TwoPointSlopeTheme.border(0.3),
                    ),
                  ),
                  child: const Text(
                    'Example',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: TwoPointSlopeTheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Input card ────────────────────────────────────────────
  Widget _buildInputCard() {
    return Container(
      decoration: TwoPointSlopeTheme.cardDecoration(context),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section label
            Text('ENTER COORDINATES',
                style: TwoPointSlopeTheme.labelStyle(context)),
            const SizedBox(height: 20),

            // Point 1
            const _PointLabel(
              label: 'Point 1',
              color: TwoPointSlopeTheme.stepBlue,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _CoordField(
                    controller: _controller.x1Controller,
                    label: 'x₁',
                    hint: '0',
                    validator: _controller.validateNumber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CoordField(
                    controller: _controller.y1Controller,
                    label: 'y₁',
                    hint: '0',
                    validator: _controller.validateNumber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Swap button between points
            Center(
              child: GestureDetector(
                onTap: () {
                  _controller.swapPoints();
                  try {
                    HapticFeedback.lightImpact();
                  } catch (_) {}
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: TwoPointSlopeTheme.surface(context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: TwoPointSlopeTheme.border(0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.swap_vert_rounded,
                    color: TwoPointSlopeTheme.textSecondary(context),
                    size: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Point 2
            const _PointLabel(
              label: 'Point 2',
              color: TwoPointSlopeTheme.stepGreen,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _CoordField(
                    controller: _controller.x2Controller,
                    label: 'x₂',
                    hint: '0',
                    validator: _controller.validateNumber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CoordField(
                    controller: _controller.y2Controller,
                    label: 'y₂',
                    hint: '0',
                    validator: _controller.validateNumber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // Reset
                if (_controller.hasSolved)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        _controller.reset();
                        try {
                          HapticFeedback.lightImpact();
                        } catch (_) {}
                      },
                      child: Container(
                        width: 48,
                        height: 52,
                        decoration: BoxDecoration(
                          color: TwoPointSlopeTheme.surface(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: TwoPointSlopeTheme.border(0.15),
                          ),
                        ),
                        child: Icon(
                          Icons.refresh_rounded,
                          color: TwoPointSlopeTheme.textSecondary(context),
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                // Solve button
                Expanded(
                  child: _SolveButton(
                    onTap: () {
                      _controller.solve();
                      try {
                        HapticFeedback.mediumImpact();
                      } catch (_) {}
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Result card ───────────────────────────────────────────
  Widget _buildResultCard() {
    final result = _controller.result!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      decoration: TwoPointSlopeTheme.cardDecoration(context, glowing: true),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RESULT', style: TwoPointSlopeTheme.labelStyle(context)),
          const SizedBox(height: 20),

          // Slope + type row
          Row(
            children: [
              Expanded(
                child: _ResultTile(
                  label: 'Slope (m)',
                  value: result.slopeDisplay,
                  color: TwoPointSlopeTheme.primary,
                  icon: Icons.show_chart_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultTile(
                  label: 'Type',
                  value: result.slopeType,
                  color: TwoPointSlopeTheme.stepPurple,
                  icon: Icons.info_outline_rounded,
                  smallText: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (!result.isVertical) ...[
            // Slope-intercept form
            _EquationTile(
              label: 'Slope-Intercept Form',
              tag: 'y = mx + b',
              equation: result.lineEquation,
              color: TwoPointSlopeTheme.primaryLight,
              tagColor: TwoPointSlopeTheme.primary,
            ),

            const SizedBox(height: 10),

            // Standard form
            _EquationTile(
              label: 'Standard Form',
              tag: 'Ax + By = C',
              equation: result.standardForm,
              color: TwoPointSlopeTheme.stepBlue,
              tagColor: TwoPointSlopeTheme.stepBlue,
            ),

            const SizedBox(height: 10),

            // General form
            _EquationTile(
              label: 'General Form',
              tag: 'Ax + By + C = 0',
              equation: result.generalForm,
              color: TwoPointSlopeTheme.stepGreen,
              tagColor: TwoPointSlopeTheme.stepGreen,
            ),
          ] else ...[
            // Vertical line special case
            _EquationTile(
              label: 'Line Equation',
              tag: 'Vertical',
              equation: result.lineEquation,
              color: TwoPointSlopeTheme.primaryLight,
              tagColor: TwoPointSlopeTheme.primary,
            ),
            const SizedBox(height: 10),
            _EquationTile(
              label: 'General Form',
              tag: 'Ax + By + C = 0',
              equation: result.generalForm,
              color: TwoPointSlopeTheme.stepGreen,
              tagColor: TwoPointSlopeTheme.stepGreen,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SUB-WIDGETS - ALL FIXED
// ─────────────────────────────────────────────────────────────

class _PointLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _PointLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      );
}

class _CoordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?) validator;

  const _CoordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: TextInputType.text,
      style: TextStyle(
        color: TwoPointSlopeTheme.textPrimary(context),
        fontSize: 16,
        fontFamily: 'monospace',
      ),
      decoration: TwoPointSlopeTheme.inputDecoration(context, label, hint),
    );
  }
}

class _SolveButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SolveButton({required this.onTap});

  @override
  State<_SolveButton> createState() => _SolveButtonState();
}

class _SolveButtonState extends State<_SolveButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  TwoPointSlopeTheme.primary,
                  TwoPointSlopeTheme.orange,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: TwoPointSlopeTheme.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calculate_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Solve',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _EquationTile extends StatelessWidget {
  final String label;
  final String tag;
  final String equation;
  final Color color;
  final Color tagColor;

  const _EquationTile({
    required this.label,
    required this.tag,
    required this.equation,
    required this.color,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: TwoPointSlopeTheme.textSecondary(context)
                      .withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 9,
                    fontFamily: 'monospace',
                    color: tagColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            equation,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool smallText;

  const _ResultTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.smallText = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color.withValues(alpha: 0.7)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: smallText ? 13 : 22,
                fontWeight: FontWeight.w700,
                color: color,
                height: 1.2,
              ),
            ),
          ],
        ),
      );
}
