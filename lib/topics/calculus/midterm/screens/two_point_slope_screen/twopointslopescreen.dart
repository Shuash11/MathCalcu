import 'two_point_slope_controller.dart';
import 'package:calculus_system/topics/calculus/midterm/graph/two_point_slope_graph/two_point_slope_graph.dart';
import 'two_point_slope_steps.dart';
import 'package:calculus_system/shared/widgets/accent_glow.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';

// -------------------------------------------------------------
// TWO-POINT SLOPE SCREEN - COMPLETE & FIXED
// -------------------------------------------------------------

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
  final _x1Focus = FocusNode();
  final _y1Focus = FocusNode();
  final _x2Focus = FocusNode();
  final _y2Focus = FocusNode();
  bool _showGraph = false;

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
    _x1Focus.dispose();
    _y1Focus.dispose();
    _x2Focus.dispose();
    _y2Focus.dispose();
    super.dispose();
  }

  void _showStepsModal() {
    showSolutionStepsModal(
      context: context,
      title: 'Solution Steps',
      design: AppDesign.app,
      child: TwoPointSlopeSteps(result: _controller.result!),
    );
  }
  void _toggleGraph() => setState(() => _showGraph = !_showGraph);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const space5xl = 28.0;
    const space4xl = 24.0;
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            screenWidth < 360 ? 14 : 20,
            28,
            screenWidth < 360 ? 14 : 20,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              const SizedBox(height: space5xl),
              _buildInputCard(),
              const SizedBox(height: 20),
              if (_controller.hasSolved) ...[
                _buildResultCard(),
                const SizedBox(height: space4xl),
                if (_showGraph) ...[
                  TwoPointSlopeGraph(result: _controller.result!),
                  const SizedBox(height: space4xl),
                ],
              ],
              ],
            ),
          ),
        ),
    );
  }

  // -- App bar -----------------------------------------------
  Widget _buildAppBar() {
    return FadeTransition(
      opacity: _headerFade,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.watch<ThemeProvider>().card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.2),
                ),
                boxShadow: AccentGlow.stack(context),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: context.watch<ThemeProvider>().textSecondary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.2),
              ),
              boxShadow: AccentGlow.stack(context),
            ),
            child: Icon(
              Icons.show_chart_rounded,
              color: context.watch<ThemeProvider>().accentColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  'Two-Point Slope',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: context.watch<ThemeProvider>().textPrimary, letterSpacing: -1.0, height: 1.1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -- Input card --------------------------------------------
  Widget _buildInputCard() {
    return Container(
      decoration: BoxDecoration(color: context.watch<ThemeProvider>().card, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF334155).withValues(alpha: 0.15), width: 1), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: context.watch<ThemeProvider>().isLight ? 0.05 : 0.3), blurRadius: 16, offset: const Offset(0, 4))]),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section label
            ResponsiveText('ENTER COORDINATES',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().textSecondary.withValues(alpha: 0.7), letterSpacing: 0.5)),
            const SizedBox(height: 20),

            // Point 1
            const _PointLabel(
              label: 'Point 1',
              color: const Color(0xFF334155),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _CoordField(
                    controller: _controller.x1Controller,
                    focusNode: _x1Focus,
                    label: 'x1',
                    hint: '0',
                    validator: _controller.validateNumber,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => _y1Focus.requestFocus(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CoordField(
                    controller: _controller.y1Controller,
                    focusNode: _y1Focus,
                    label: 'y1',
                    hint: '0',
                    validator: _controller.validateNumber,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => _x2Focus.requestFocus(),
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
                    color: context.watch<ThemeProvider>().surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF334155).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.swap_vert_rounded,
                    color: context.watch<ThemeProvider>().textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Point 2
            const _PointLabel(
              label: 'Point 2',
              color: const Color(0xFF34D399),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _CoordField(
                    controller: _controller.x2Controller,
                    focusNode: _x2Focus,
                    label: 'x2',
                    hint: '0',
                    validator: _controller.validateNumber,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => _y2Focus.requestFocus(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CoordField(
                    controller: _controller.y2Controller,
                    focusNode: _y2Focus,
                    label: 'y2',
                    hint: '0',
                    validator: _controller.validateNumber,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () => _y2Focus.unfocus(),
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
                          color: context.watch<ThemeProvider>().surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF334155).withValues(alpha: 0.15),
                          ),
                        ),
                        child: Icon(
                          Icons.refresh_rounded,
                          color: context.watch<ThemeProvider>().textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                // Solve button
                Expanded(
                  child:                   _SolveButton(
                    onTap: () {
                      setState(() {
                        _showGraph = false;
                      });
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

  // -- Result card -------------------------------------------
  Widget _buildResultCard() {
    final result = _controller.result!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(color: context.watch<ThemeProvider>().card, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF334155).withValues(alpha: 0.35), width: 1.5), boxShadow: [BoxShadow(color: const Color(0xFF334155).withValues(alpha: 0.15), blurRadius: 32, offset: const Offset(0, 8), spreadRadius: 2)]),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('RESULT',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().textSecondary.withValues(alpha: 0.7), letterSpacing: 0.5)),
              ),
              GestureDetector(
                onTap: _toggleGraph,
                child: _buildShowGraphChip(),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _showStepsModal,
                child: _buildShowStepsChip(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Slope + type row
          Row(
            children: [
              Expanded(
                child: _ResultTile(
                  label: 'Slope (m)',
                  value: result.slopeDisplay,
                  color: const Color(0xFF334155),
                  icon: Icons.show_chart_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultTile(
                  label: 'Type',
                  value: result.slopeType,
                  color: const Color(0xFFA78BFA),
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
              color: const Color(0xFF334155),
              tagColor: const Color(0xFF334155),
            ),

            const SizedBox(height: 10),

            // Standard form
            _EquationTile(
              label: 'Standard Form',
              tag: 'Ax + By = C',
              equation: result.standardForm,
              color: const Color(0xFF334155),
              tagColor: const Color(0xFF334155),
            ),

            const SizedBox(height: 10),

            // General form
            _EquationTile(
              label: 'General Form',
              tag: 'Ax + By + C = 0',
              equation: result.generalForm,
              color: const Color(0xFF34D399),
              tagColor: const Color(0xFF34D399),
            ),
          ] else ...[
            // Vertical line special case
            _EquationTile(
              label: 'Line Equation',
              tag: 'Vertical',
              equation: result.lineEquation,
              color: const Color(0xFF334155),
              tagColor: const Color(0xFF334155),
            ),
            const SizedBox(height: 10),
            _EquationTile(
              label: 'General Form',
              tag: 'Ax + By + C = 0',
              equation: result.generalForm,
              color: const Color(0xFF34D399),
              tagColor: const Color(0xFF34D399),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShowStepsChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF334155).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ResponsiveText(
            'Show steps',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF334155), size: 16),
        ],
      ),
    );
  }

  Widget _buildShowGraphChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _showGraph
            ? const Color(0xFF34D399).withValues(alpha: 0.2)
            : const Color(0xFF34D399).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.show_chart_rounded,
              color: const Color(0xFF34D399), size: 14),
          const SizedBox(width: 4),
          ResponsiveText(
            _showGraph ? 'Hide graph' : 'Show graph',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF34D399),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// SUB-WIDGETS - ALL FIXED
// -------------------------------------------------------------

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
          ResponsiveText(
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
  final FocusNode focusNode;
  final String label;
  final String hint;
  final String? Function(String?) validator;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const _CoordField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.validator,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      keyboardType: TextInputType.text,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      style: TextStyle(
        color: context.watch<ThemeProvider>().textPrimary,
        fontSize: 16,
        fontFamily: 'monospace',
      ),
      decoration: InputDecoration(labelText: label, hintText: hint, labelStyle: TextStyle(color: context.watch<ThemeProvider>().textSecondary, fontSize: 13, fontWeight: FontWeight.w500), hintStyle: TextStyle(color: context.watch<ThemeProvider>().textSecondary.withValues(alpha: 0.6), fontSize: 14), filled: true, fillColor: context.watch<ThemeProvider>().surface, contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: const Color(0xFF334155).withValues(alpha: 0.15))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: const Color(0xFF334155).withValues(alpha: 0.5), width: 1.5)), errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.redAccent)), focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5))),
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
                  const Color(0xFF334155),
                  const Color(0xFF334155),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF334155).withValues(alpha: 0.35),
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
                      ResponsiveText(
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
              ResponsiveText(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: context.watch<ThemeProvider>().textSecondary
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
          ResponsiveText(
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
                ResponsiveText(
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
            ResponsiveText(
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
