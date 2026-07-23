// lib/topics/calculus/midterm/screens/yintercept_screen/parallel_perpendicular_screen.dart

import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/topics/calculus/midterm/graph/yintercept_graph/perpenparallel_graph.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/yintercept_solver/yi_solver.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/yintercept_solver/yi_steps.dart';
import 'package:calculus_system/shared/widgets/solution_step_card.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:calculus_system/shared/widgets/accent_glow.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';

// -------------------------------------------------------------
// Screen
// -------------------------------------------------------------

class ParallelPerpendicularScreen extends StatefulWidget {
  const ParallelPerpendicularScreen({super.key});

  @override
  State<ParallelPerpendicularScreen> createState() =>
      _ParallelPerpendicularScreenState();
}

class _ParallelPerpendicularScreenState
    extends State<ParallelPerpendicularScreen>
    with SingleTickerProviderStateMixin {
  final _line1Ctrl = TextEditingController();
  final _line2Ctrl = TextEditingController();
  final _line1Focus = FocusNode();
  final _line2Focus = FocusNode();
  final _resultNotifier = ValueNotifier<PPResult?>(null);
  final _errorNotifier = ValueNotifier<String?>(null);
  bool _showGraph = false;
  bool _hasSolved = false;

  late final AnimationController _headerAnim;
  late final Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
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
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _line1Focus.dispose();
    _line2Focus.dispose();
    _resultNotifier.dispose();
    _errorNotifier.dispose();
    _headerAnim.dispose();
    super.dispose();
  }

  void _compute() {
    final l1 = _line1Ctrl.text.trim();
    final l2 = _line2Ctrl.text.trim();
    if (l1.isEmpty || l2.isEmpty) {
      _resultNotifier.value = null;
      _errorNotifier.value = null;
      setState(() => _hasSolved = false);
      return;
    }
    final result = ParallelPerpendicularSolver.tryParse(line1: l1, line2: l2);
    if (result == null) {
      _resultNotifier.value = null;
      _errorNotifier.value =
          'Could not parse one or both equations.\nTry: 2x + 3y = 6  or  2x + 3y + 4 = 0';
      setState(() => _hasSolved = false);
      return;
    }
    _errorNotifier.value = null;
    _resultNotifier.value = result;
    setState(() {
      _hasSolved = true;
      _showGraph = false;
    });
  }

  void _reset() {
    _line1Ctrl.clear();
    _line2Ctrl.clear();
    _resultNotifier.value = null;
    _errorNotifier.value = null;
    setState(() => _hasSolved = false);
  }

  void _showSteps(PPResult result) {
    showSolutionStepsModal(
      context: context,
      design: AppDesign.app,
      child: ParallelPerpendicularSteps(result: result),
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
              if (_hasSolved) ...[
                _buildResultCard(),
                const SizedBox(height: space4xl),
                if (_showGraph) ...[
                  _buildGraphWidget(),
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
                  color: context
                      .watch<ThemeProvider>()
                      .accentColor
                      .withValues(alpha: 0.2),
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
              color: context
                  .watch<ThemeProvider>()
                  .accentColor
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context
                    .watch<ThemeProvider>()
                    .accentColor
                    .withValues(alpha: 0.2),
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
                  'Parallel & Perpendicular',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: context.watch<ThemeProvider>().textPrimary,
                    letterSpacing: -1.0,
                    height: 1.1,
                  ),
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
      decoration: BoxDecoration(
        color: context.watch<ThemeProvider>().card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context
              .watch<ThemeProvider>()
              .accentColor
              .withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
                alpha: context.watch<ThemeProvider>().isLight ? 0.05 : 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          ResponsiveText(
            'ENTER EQUATIONS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context
                  .watch<ThemeProvider>()
                  .textSecondary
                  .withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),

          // Line 1
          _PointLabel(
            label: 'Line 1',
            color: context.watch<ThemeProvider>().accentColor,
          ),
          const SizedBox(height: 10),
          _CoordField(
            controller: _line1Ctrl,
            focusNode: _line1Focus,
            label: 'Equation',
            hint: 'e.g. 2x + 3y = 6',
            textInputAction: TextInputAction.next,
            onEditingComplete: () => _line2Focus.requestFocus(),
          ),

          const SizedBox(height: 16),

          // Swap button
          Center(
            child: GestureDetector(
              onTap: () {
                final temp = _line1Ctrl.text;
                _line1Ctrl.text = _line2Ctrl.text;
                _line2Ctrl.text = temp;
                _compute();
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.watch<ThemeProvider>().surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context
                        .watch<ThemeProvider>()
                        .accentColor
                        .withValues(alpha: 0.2),
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

          // Line 2
          _PointLabel(
            label: 'Line 2',
            color: context.watch<ThemeProvider>().accentColor,
          ),
          const SizedBox(height: 10),
          _CoordField(
            controller: _line2Ctrl,
            focusNode: _line2Focus,
            label: 'Equation',
            hint: 'e.g. 4x - 6y + 1 = 0',
            textInputAction: TextInputAction.done,
            onEditingComplete: () => _line2Focus.unfocus(),
          ),

          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              // Reset
              if (_hasSolved)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: _reset,
                    child: Container(
                      width: 48,
                      height: 52,
                      decoration: BoxDecoration(
                        color: context.watch<ThemeProvider>().surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: context
                              .watch<ThemeProvider>()
                              .accentColor
                              .withValues(alpha: 0.15),
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

              Expanded(
                child: _SolveButton(
                  onTap: _compute,
                  accent: context.watch<ThemeProvider>().accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -- Result card -------------------------------------------
  Widget _buildResultCard() {
    final result = _resultNotifier.value!;
    final accent = context.watch<ThemeProvider>().accentColor;

    Color verdictColor() {
      switch (result.relationship) {
        case PPRelationship.parallel:
          return accent;
        case PPRelationship.perpendicular:
          return accent;
        case PPRelationship.sameLine:
          return accent;
        case PPRelationship.neither:
          return const Color(0xFF64748B);
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: context.watch<ThemeProvider>().card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context
              .watch<ThemeProvider>()
              .accentColor
              .withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: context
                .watch<ThemeProvider>()
                .accentColor
                .withValues(alpha: 0.15),
            blurRadius: 32,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'RESULT',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context
                        .watch<ThemeProvider>()
                        .textSecondary
                        .withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _toggleGraph,
                child: _buildShowGraphChip(accent),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _showSteps(result),
                child: _buildShowStepsChip(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Verdict card
          _VerdictCard(
            result: result,
            accent: verdictColor(),
          ),

          const SizedBox(height: 16),

          // Slope comparison row
          Row(
            children: [
              Expanded(
                child: _ResultTile(
                  label: 'Slope 1',
                  value: result.slope1?.toDouble().toStringAsFixed(2) ??
                      'undefined',
                  color: context.watch<ThemeProvider>().accentColor,
                  icon: Icons.show_chart_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultTile(
                  label: 'Slope 2',
                  value: result.slope2?.toDouble().toStringAsFixed(2) ??
                      'undefined',
                  color: context.watch<ThemeProvider>().accentColor,
                  icon: Icons.show_chart_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Line 1 equations
          _EquationTile(
            label: 'Line 1 — Slope-Intercept',
            tag: 'y = mx + b',
            equation: result.slopeIntercept1,
            color: context.watch<ThemeProvider>().accentColor,
            tagColor: context.watch<ThemeProvider>().accentColor,
          ),

          const SizedBox(height: 10),

          _EquationTile(
            label: 'Line 1 — Standard Form',
            tag: 'Ax + By = C',
            equation: _toStandardForm(result.a1, result.b1, result.c1),
            color: context.watch<ThemeProvider>().accentColor,
            tagColor: context.watch<ThemeProvider>().accentColor,
          ),

          const SizedBox(height: 10),

          _EquationTile(
            label: 'Line 1 — General Form',
            tag: 'Ax + By + C = 0',
            equation: _toGeneralForm(result.a1, result.b1, result.c1),
            color: accent,
            tagColor: accent,
          ),

          const SizedBox(height: 16),

          // Line 2 equations
          _EquationTile(
            label: 'Line 2 — Slope-Intercept',
            tag: 'y = mx + b',
            equation: result.slopeIntercept2,
            color: context.watch<ThemeProvider>().accentColor,
            tagColor: context.watch<ThemeProvider>().accentColor,
          ),

          const SizedBox(height: 10),

          _EquationTile(
            label: 'Line 2 — Standard Form',
            tag: 'Ax + By = C',
            equation: _toStandardForm(result.a2, result.b2, result.c2),
            color: context.watch<ThemeProvider>().accentColor,
            tagColor: context.watch<ThemeProvider>().accentColor,
          ),

          const SizedBox(height: 10),

          _EquationTile(
            label: 'Line 2 — General Form',
            tag: 'Ax + By + C = 0',
            equation: _toGeneralForm(result.a2, result.b2, result.c2),
            color: accent,
            tagColor: accent,
          ),
        ],
      ),
    );
  }

  String _toStandardForm(int A, int B, int C) {
    return '${_formatTerm(A, 'x')} ${_formatTerm(B, 'y', true)} = ${-C}';
  }

  String _toGeneralForm(int A, int B, int C) {
    return '${_formatTerm(A, 'x')} ${_formatTerm(B, 'y')} ${_formatConstant(C)} = 0';
  }

  String _formatTerm(int coeff, String variable, [bool isStandard = false]) {
    if (coeff == 0) return '';
    final sign = coeff > 0 ? '+' : '-';
    final absCoeff = coeff.abs();
    final coeffStr = absCoeff == 1 ? '' : absCoeff.toString();
    return '$sign $coeffStr$variable';
  }

  String _formatConstant(int C) {
    if (C == 0) return '';
    final sign = C > 0 ? '+' : '-';
    return '$sign ${C.abs()}';
  }

  Widget _buildShowStepsChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.1),
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
              color: context.watch<ThemeProvider>().accentColor,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded,
              color: context.watch<ThemeProvider>().accentColor, size: 16),
        ],
      ),
    );
  }

  Widget _buildShowGraphChip(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _showGraph
            ? accent.withValues(alpha: 0.2)
            : accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.show_chart_rounded, color: accent, size: 14),
          const SizedBox(width: 4),
          ResponsiveText(
            _showGraph ? 'Hide graph' : 'Show graph',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphWidget() {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: context
                .watch<ThemeProvider>()
                .accentColor
                .withValues(alpha: 0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: PPLinePainter(
            result: _resultNotifier.value!,
            accentColor: context.watch<ThemeProvider>().accentColor,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// UI Components - Exact match with TwoPointSlopeScreen
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
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const _CoordField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.text,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      style: TextStyle(
        color: context.watch<ThemeProvider>().textPrimary,
        fontSize: 16,
        fontFamily: 'monospace',
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: context.watch<ThemeProvider>().textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: context
              .watch<ThemeProvider>()
              .textSecondary
              .withValues(alpha: 0.6),
          fontSize: 14,
        ),
        filled: true,
        fillColor: context.watch<ThemeProvider>().surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: context
                .watch<ThemeProvider>()
                .accentColor
                .withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: context
                .watch<ThemeProvider>()
                .accentColor
                .withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}

class _SolveButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color accent;
  const _SolveButton({required this.onTap, required this.accent});

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
              gradient: LinearGradient(
                colors: [
                  widget.accent,
                  widget.accent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [AccentGlow.halo(context)],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calculate_rounded,
                      color: FinalsTheme.onPrimaryFor(context), size: 18),
                  const SizedBox(width: 8),
                  ResponsiveText(
                    'Solve',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: FinalsTheme.onPrimaryFor(context),
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

class _VerdictCard extends StatelessWidget {
  final PPResult result;
  final Color accent;
  const _VerdictCard({required this.result, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.28), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ResponsiveText(
                'VERDICT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: accent,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Icon(Icons.show_chart_rounded, color: accent, size: 16),
              const SizedBox(width: 4),
              ResponsiveText(
                'Tap to graph',
                style: TextStyle(
                  color: accent.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ResponsiveText(
            '${result.verdictSymbol}  ${result.verdict}',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: accent,
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
                  color: context
                      .watch<ThemeProvider>()
                      .textSecondary
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

// -------------------------------------------------------------
// STEPS WIDGET — MIGRATED TO SolutionStepCard
// -------------------------------------------------------------

class ParallelPerpendicularSteps extends StatelessWidget {
  final PPResult result;

  const ParallelPerpendicularSteps({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final rows = _groupSteps(result.steps);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          rows[i],
          if (i != rows.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  List<Widget> _groupSteps(List<PPSolverStep> steps) {
    final rows = <Widget>[];
    final pending = <String, PPSolverStep>{};

    for (final step in steps) {
      final key = step.groupKey;
      if (key == null) {
        rows.add(_buildStepCard(step));
        continue;
      }
      if (pending.containsKey(key)) {
        final first = pending.remove(key)!;
        rows.add(_buildSideBySide(first, step));
      } else {
        pending[key] = step;
      }
    }

    for (final step in pending.values) {
      rows.add(_buildStepCard(step));
    }

    return rows;
  }

  Widget _buildStepCard(PPSolverStep step) {
    return SolutionStepCard(
      design: AppDesign.app,
      stepNumber: step.number,
      title: step.title,
      description: 'Step ${step.number}',
      mathContent: _StepBlocks(steps: [step]),
    );
  }

  Widget _buildSideBySide(PPSolverStep left, PPSolverStep right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MiniStepColumn(
                  stepNumber: left.number,
                  title: left.title,
                  steps: [left],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStepColumn(
                  stepNumber: right.number,
                  title: right.title,
                  steps: [right],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStepColumn extends StatelessWidget {
  final int stepNumber;
  final String title;
  final List<PPSolverStep> steps;

  const _MiniStepColumn({
    required this.stepNumber,
    required this.title,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.watch<ThemeProvider>().accentColor,
            ),
            child: Center(
              child: ResponsiveText(
                stepNumber.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: FinalsTheme.onPrimaryFor(context),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                title,
                style: FinalsTheme.titleStyle(context).copyWith(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: FinalsTheme.cardSecondary(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _StepBlocks(steps: steps),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepBlocks extends StatelessWidget {
  final List<PPSolverStep> steps;
  const _StepBlocks({required this.steps});

  static Map<PPBlockType, Color> _borderColors(BuildContext context) {
    final accent = context.watch<ThemeProvider>().accentColor;
    return {
      PPBlockType.formula: accent,
      PPBlockType.substitution: const Color(0xFF64748B),
      PPBlockType.working: accent,
      PPBlockType.result: accent,
    };
  }

  static const _labels = {
    PPBlockType.formula: 'Formula',
    PPBlockType.substitution: null,
    PPBlockType.working: 'Working',
    PPBlockType.result: null,
  };

  @override
  Widget build(BuildContext context) {
    final blocks = <Widget>[];
    for (final step in steps) {
      for (var i = 0; i < step.blocks.length; i++) {
        final block = step.blocks[i];
        blocks.add(_buildBlock(context, block));
        if (i != step.blocks.length - 1) {
          blocks.add(const SizedBox(height: 8));
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: blocks,
    );
  }

  Widget _buildBlock(BuildContext context, PPStepBlock block) {
    switch (block.type) {
      case PPBlockType.note:
        return _renderNote(context, block.content);
      case PPBlockType.formula:
      case PPBlockType.substitution:
      case PPBlockType.working:
        return _renderMathBlock(
          context,
          label: block.label ?? _labels[block.type],
          latex: block.latex,
          fallback: block.content,
          borderColor: _borderColors(context)[block.type]!,
        );
      case PPBlockType.result:
        return _renderResult(context, block.latex, block.content);
    }
  }

  Widget _renderNote(BuildContext context, String text) {
    final isDark = !context.watch<ThemeProvider>().isLight;
    final color = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : Colors.black.withValues(alpha: 0.55);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ResponsiveText(
        text,
        style: TextStyle(fontSize: 12, color: color, height: 1.4),
      ),
    );
  }

  Widget _renderMathBlock(
    BuildContext context, {
    required String? label,
    required String? latex,
    required String fallback,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: borderColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null && label.isNotEmpty) ...[
            ResponsiveText(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: borderColor.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 4),
          ],
          _renderMath(latex, fallback, accent: borderColor),
        ],
      ),
    );
  }

  Widget _renderResult(BuildContext context, String? latex, String fallback) {
    final accent = context.watch<ThemeProvider>().accentColor;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Center(
          child: _renderMath(latex, fallback, fontSize: 14, accent: accent)),
    );
  }

  Widget _renderMath(String? latex, String fallback,
      {double fontSize = 13, Color? accent}) {
    if (latex == null || latex.isEmpty) {
      return ResponsiveText(
        fallback,
        style: const TextStyle(fontSize: 13, height: 1.4),
      );
    }
    final lines = latex
        .replaceAll(r'\\[6pt]', r'\\')
        .replaceAll(r'\\[4pt]', r'\\')
        .replaceAll(r'\\[8pt]', r'\\')
        .split(RegExp(r'\\\\|\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final resolvedAccent = accent ?? Colors.black;
    if (lines.length == 1) {
      return _mathLine(lines[0], fontSize, accent: resolvedAccent);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: lines
          .map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: _mathLine(l, fontSize, accent: resolvedAccent),
              ))
          .toList(),
    );
  }

  Widget _mathLine(String tex, double fontSize, {required Color accent}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: RepaintBoundary(
        child: Math.tex(
          tex,
          textStyle: TextStyle(fontSize: fontSize, color: accent),
          onErrorFallback: (err) => Text(
            tex,
            style: TextStyle(
              fontSize: fontSize,
              color: accent,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}
