// lib/modules/y-intercept/ui/parallel_perpendicular_screen.dart

import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/topics/calculus/midterm/graph/yintercept_graph/perpenparallel_graph.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/yintercept_solver/yi_solver.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/yintercept_solver/yi_steps.dart';
import 'package:calculus_system/shared/widgets/solution_step_card.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:calculus_system/shared/widgets/math_keyboard.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';

const _accent = FinalsTheme.primary;

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
    extends State<ParallelPerpendicularScreen> {
  final _line1Ctrl = TextEditingController();
  final _line2Ctrl = TextEditingController();
  final _line1Focus = FocusNode();
  final _line2Focus = FocusNode();
  TextEditingController? _activeController;
  final _hideKeyboardSignal = ValueNotifier<int>(0);
  final _resultNotifier = ValueNotifier<PPResult?>(null);
  final _errorNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _line1Focus.addListener(_onLine1FocusChange);
    _line2Focus.addListener(_onLine2FocusChange);
  }

  @override
  void dispose() {
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _line1Focus
      ..removeListener(_onLine1FocusChange)
      ..dispose();
    _line2Focus
      ..removeListener(_onLine2FocusChange)
      ..dispose();
    _resultNotifier.dispose();
    _errorNotifier.dispose();
    _hideKeyboardSignal.dispose();
    super.dispose();
  }

  void _onLine1FocusChange() {
    if (_line1Focus.hasFocus) {
      setState(() => _activeController = _line1Ctrl);
    }
  }

  void _onLine2FocusChange() {
    if (_line2Focus.hasFocus) {
      setState(() => _activeController = _line2Ctrl);
    }
  }

  void _compute() {
    _hideKeyboardSignal.value++;
    final l1 = _line1Ctrl.text.trim();
    final l2 = _line2Ctrl.text.trim();
    if (l1.isEmpty || l2.isEmpty) {
      _resultNotifier.value = null;
      _errorNotifier.value = null;
      return;
    }
    final result =
        ParallelPerpendicularSolver.tryParse(line1: l1, line2: l2);
    if (result == null) {
      _resultNotifier.value = null;
      _errorNotifier.value =
          'Could not parse one or both equations.\nTry: 2x + 3y = 6  or  2x + 3y + 4 = 0';
      return;
    }
    _errorNotifier.value = null;
    _resultNotifier.value = result;
  }

  void _showSteps(PPResult result) {
    showSolutionStepsModal(
      context: context,
      design: AppDesign.app,
      child: ParallelPerpendicularSteps(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emerald = const Color(0xFF334155);
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().surface,
      body: SafeArea(
        child: Column(
          children: [
            // -- Top bar ----------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.35),
                            width: 1.5),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: context.watch<ThemeProvider>().accentColor, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ResponsiveText(
                    'Parallel & Perpendicular',
                    style: TextStyle(fontSize: 13, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.8) : const Color(0xFF334155).withValues(alpha: 0.7), height: 1.3).copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: context.watch<ThemeProvider>().textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // -- Body -------------------------------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _HintBanner(),
                    const SizedBox(height: 14),
                    _EquationField(
                      controller: _line1Ctrl,
                      focusNode: _line1Focus,
                      label: 'LINE 1',
                      hint: 'e.g. 2x + 3y = 6',
                      accent: context.watch<ThemeProvider>().accentColor,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => _line2Focus.requestFocus(),
                    ),
                    const SizedBox(height: 10),
                    _EquationField(
                      controller: _line2Ctrl,
                      focusNode: _line2Focus,
                      label: 'LINE 2',
                      hint: 'e.g. 4x - 6y + 1 = 0',
                      accent: emerald,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () => _line2Focus.unfocus(),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: _compute,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Solve',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E), letterSpacing: 0.3),
                          ),
                        ),
                      ),
                    ),

                    // error message
                    ValueListenableBuilder<String?>(
                      valueListenable: _errorNotifier,
                      builder: (_, err, __) {
                        if (err == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(err,
                              style: TextStyle(
                                  color: Colors.redAccent.shade200,
                                  fontSize: 12)),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // results area
                    ValueListenableBuilder<PPResult?>(
                      valueListenable: _resultNotifier,
                      builder: (context, result, _) {
                        if (result == null) {
                          return const SizedBox.shrink();
                        }
                        return _ResultSection(
                          result: result,
                          accent: context.watch<ThemeProvider>().accentColor,
                          emerald: emerald,
                          onStepsTap: () => _showSteps(result),
                          onGraphTap: () => showGraphSheet(context, result),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    MathKeyboard(
                      controller: _activeController ?? _line1Ctrl,
                      accentColor: context.watch<ThemeProvider>().accentColor,
                      hideSignal: _hideKeyboardSignal,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// UI Components
// -------------------------------------------------------------

class _HintBanner extends StatelessWidget {
  const _HintBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.8), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: ResponsiveText(
              'Enter equations in any format (e.g., y = 2x + 1, 3x - 4y = 12, or 2x + y - 5 = 0).',
              style: TextStyle(fontSize: 13, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.8) : const Color(0xFF334155).withValues(alpha: 0.7), height: 1.3).copyWith(
                color: context.watch<ThemeProvider>().textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EquationField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final Color accent;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const _EquationField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.accent,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  State<_EquationField> createState() => _EquationFieldState();
}

class _EquationFieldState extends State<_EquationField> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(widget.label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.7) : const Color(0xFF334155).withValues(alpha: 0.5), letterSpacing: 1.2)
                .copyWith(color: widget.accent, fontSize: 10)),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.none,
          textInputAction: widget.textInputAction,
          onEditingComplete: widget.onEditingComplete,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155) : const Color(0xFF334155), fontFamily: 'monospace').copyWith(
            color: context.watch<ThemeProvider>().textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(fontSize: 13, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.8) : const Color(0xFF334155).withValues(alpha: 0.7), height: 1.3).copyWith(
              color: context.watch<ThemeProvider>().textSecondary.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: context.watch<ThemeProvider>().surface.withValues(alpha: 0.8),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.accent.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.accent.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultSection extends StatelessWidget {
  final PPResult result;
  final Color accent;
  final Color emerald;
  final VoidCallback onStepsTap;
  final VoidCallback onGraphTap;

  const _ResultSection({
    required this.result,
    required this.accent,
    required this.emerald,
    required this.onStepsTap,
    required this.onGraphTap,
  });

  Color _verdictColor(BuildContext context) {
    final accent = context.watch<ThemeProvider>().accentColor;
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

  @override
  Widget build(BuildContext context) {
    final color = _verdictColor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onGraphTap,
          child: _VerdictCard(result: result, accent: color),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _EquationResultCard(
                title: 'Line 1',
                equation: result.slopeIntercept1,
                meta: 'm = ${result.slope1?.toString() ?? 'undefined'}',
                accent: context.watch<ThemeProvider>().accentColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EquationResultCard(
                title: 'Line 2',
                equation: result.slopeIntercept2,
                meta: 'm = ${result.slope2?.toString() ?? 'undefined'}',
                accent: emerald,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onStepsTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_rounded, color: accent, size: 16),
                const SizedBox(width: 8),
                ResponsiveText(
                  'View Solution Steps',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.7) : const Color(0xFF334155).withValues(alpha: 0.5), letterSpacing: 1.2)
                      .copyWith(color: accent, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VerdictCard extends StatelessWidget {
  final PPResult result;
  final Color accent;
  const _VerdictCard({required this.result, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: accent.withValues(alpha: 0.28), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ResponsiveText(
                'VERDICT',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.7) : const Color(0xFF334155).withValues(alpha: 0.5), letterSpacing: 1.2)
                    .copyWith(color: accent, fontSize: 10),
              ),
              const Spacer(),
              Icon(Icons.show_chart_rounded, color: accent, size: 16),
              const SizedBox(width: 4),
              ResponsiveText(
                'Tap to graph',
                style: TextStyle(fontSize: 13, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.8) : const Color(0xFF334155).withValues(alpha: 0.7), height: 1.3).copyWith(
                    color: accent.withValues(alpha: 0.7), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ResponsiveText(
            '${result.verdictSymbol}  ${result.verdict}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155) : const Color(0xFF334155), fontFamily: 'monospace')
                .copyWith(color: accent, fontSize: 22),
          ),
        ],
      ),
    );
  }
}

class _EquationResultCard extends StatelessWidget {
  final String title;
  final String equation;
  final String meta;
  final Color accent;

  const _EquationResultCard({
    required this.title,
    required this.equation,
    required this.meta,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(title,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.7) : const Color(0xFF334155).withValues(alpha: 0.5), letterSpacing: 1.2)
                  .copyWith(color: accent)),
          const SizedBox(height: 6),
          SelectableText(
            equation,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155) : const Color(0xFF334155), fontFamily: 'monospace').copyWith(
                color: context.watch<ThemeProvider>().textPrimary, fontSize: 15),
          ),
          const SizedBox(height: 8),
          ResponsiveText(
            meta,
            style: TextStyle(fontSize: 13, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.8) : const Color(0xFF334155).withValues(alpha: 0.7), height: 1.3)
                .copyWith(color: context.watch<ThemeProvider>().textSecondary),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// STEPS WIDGET — MIGRATED TO SolutionStepCard
//
// Each PPSolverStep becomes a SolutionStepCard.
// Blocks (note/formula/substitution/working/result) are rendered
// inside the dark math-content card as a Column. The 'si' groupKey
// pair (Line 1 / Line 2 conversion) renders side-by-side.
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
        for (final row in rows) ...[
          row,
          if (row != rows.last) const SizedBox(height: 8),
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
    return SolutionStepCard(design: AppDesign.app,
      stepNumber: step.number,
      title: step.title,
      description: 'Step ${step.number}',
      mathContent: _StepBlocks(steps: [step]),
    );
  }

  // For side-by-side (groupKey:'si') we render two SolutionStepCards
  // in a Row sharing the same number/header row, but each card
  // displays its own blocks. Number circle is shown for both.
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

// A single step rendered as a numbered circle + title + math blocks.
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: FinalsTheme.primary,
            ),
            child: Center(
              child: ResponsiveText(
                stepNumber.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
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

// Renders a list of PPSolverStep's blocks inside the dark math card.
// Maps each PPBlockType to a styled row (formula/substitution/working
// use a tinted bordered box; result uses a highlighted centered block;
// note uses plain text).
class _StepBlocks extends StatelessWidget {
  final List<PPSolverStep> steps;
  const _StepBlocks({required this.steps});

  static const _borderColors = {
    PPBlockType.formula: _accent,
    PPBlockType.substitution: Color(0xFF64748B),
    PPBlockType.working: _accent,
    PPBlockType.result: _accent,
  };

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
          borderColor: _borderColors[block.type]!,
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
          _renderMath(latex, fallback),
        ],
      ),
    );
  }

  Widget _renderResult(BuildContext context, String? latex, String fallback) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _accent.withValues(alpha: 0.5), width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Center(child: _renderMath(latex, fallback, fontSize: 14)),
    );
  }

  Widget _renderMath(String? latex, String fallback, {double fontSize = 13}) {
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

    if (lines.length == 1) {
      return _mathLine(lines[0], fontSize);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: lines
          .map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: _mathLine(l, fontSize),
              ))
          .toList(),
    );
  }

  Widget _mathLine(String tex, double fontSize) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: RepaintBoundary(
        child: Math.tex(
          tex,
          textStyle: TextStyle(fontSize: fontSize, color: _accent),
          onErrorFallback: (err) => Text(
            tex,
            style: TextStyle(
              fontSize: fontSize,
              color: _accent,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}
