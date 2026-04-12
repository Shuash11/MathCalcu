// lib/modules/y-intercept/ui/parallel_perpendicular_screen.dart

import 'dart:async';
import 'package:calculus_system/modules/y-intercept/Graph/perpenparallel_graph.dart';
import 'package:calculus_system/modules/y-intercept/Theme/theme.dart';
import 'package:calculus_system/modules/y-intercept/solver/parallel_perpendicular.dart';
import 'package:calculus_system/modules/y-intercept/ui/widgets/pp_stepblock_widget.dart';
import 'package:flutter/material.dart';

const _cyan = Color(0xFF06B6D4);

// ─────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────

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
  final _resultNotifier = ValueNotifier<PPResult?>(null);
  final _errorNotifier = ValueNotifier<String?>(null);
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _line1Ctrl.addListener(_onChanged);
    _line2Ctrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _line1Ctrl
      ..removeListener(_onChanged)
      ..dispose();
    _line2Ctrl
      ..removeListener(_onChanged)
      ..dispose();
    _resultNotifier.dispose();
    _errorNotifier.dispose();
    super.dispose();
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _compute);
  }

  void _compute() {
    final l1 = _line1Ctrl.text.trim();
    final l2 = _line2Ctrl.text.trim();
    if (l1.isEmpty || l2.isEmpty) {
      _resultNotifier.value = null;
      _errorNotifier.value = null;
      return;
    }
    final result = ParallelPerpendicularSolver.tryParse(line1: l1, line2: l2);
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SolutionStepsSheet(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emerald = YITheme.emerald(context);
    return Scaffold(
      backgroundColor: YITheme.surface(context),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────
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
                        color: _cyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _cyan.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: _cyan, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Parallel & Perpendicular',
                    style: YITheme.subtitleStyle(context).copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: YITheme.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HintBanner(),
                    const SizedBox(height: 14),
                    _EquationField(
                      controller: _line1Ctrl,
                      label: 'LINE 1',
                      hint: 'e.g. 2x + 3y = 6',
                      accent: _cyan,
                    ),
                    const SizedBox(height: 10),
                    _EquationField(
                      controller: _line2Ctrl,
                      label: 'LINE 2',
                      hint: 'e.g. 4x - 6y + 1 = 0',
                      accent: emerald,
                    ),
                    const SizedBox(height: 8),

                    // Error
                    ValueListenableBuilder<String?>(
                      valueListenable: _errorNotifier,
                      builder: (_, err, __) {
                        if (err == null) return const SizedBox.shrink();
                        return Container(
                          margin: const EdgeInsets.only(top: 4, bottom: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.redAccent.withValues(alpha: 0.3)),
                          ),
                          child: Text(err,
                              style: TextStyle(
                                  color: Colors.redAccent.shade200,
                                  fontSize: 12)),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Results
                    ValueListenableBuilder<PPResult?>(
                      valueListenable: _resultNotifier,
                      builder: (context, result, _) {
                        if (result == null) return const _EmptyState();
                        return _ResultSection(
                          result: result,
                          emerald: emerald,
                          onStepsTap: () => _showSteps(result),
                          onGraphTap: () => showGraphSheet(context, result),
                        );
                      },
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

// ─────────────────────────────────────────────────────────────
// Hint Banner
// ─────────────────────────────────────────────────────────────

class _HintBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _cyan.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cyan.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              color: _cyan.withValues(alpha: 0.7), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Accepts: Ax + By = C · Ax + By + C = 0 · y = mx + b\nTerms may appear in any order.',
              style: YITheme.subtitleStyle(context).copyWith(
                  fontSize: 12,
                  color: YITheme.textSecondary(context),
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Equation Field
// ─────────────────────────────────────────────────────────────

class _EquationField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Color accent;

  const _EquationField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
        color: YITheme.isLight(context)
            ? Colors.black.withValues(alpha: 0.02)
            : Colors.white.withValues(alpha: 0.03),
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(label,
                style: YITheme.inputLabelStyle(context)
                    .copyWith(color: accent, fontSize: 10, letterSpacing: 0.5)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: YITheme.inputTextStyle(context).copyWith(fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
                hintText: hint,
                hintStyle: YITheme.inputTextStyle(context).copyWith(
                    color:
                        YITheme.textSecondary(context).withValues(alpha: 0.4),
                    fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: _cyan.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cyan.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Icon(Icons.compare_arrows_rounded,
              color: _cyan.withValues(alpha: 0.3), size: 40),
          const SizedBox(height: 12),
          Text('Enter two equations above',
              style: YITheme.titleStyle(context).copyWith(
                  color: YITheme.textSecondary(context), fontSize: 14)),
          const SizedBox(height: 4),
          Text('Results will appear here automatically.',
              textAlign: TextAlign.center,
              style: YITheme.subtitleStyle(context).copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Result Section
// ─────────────────────────────────────────────────────────────

class _ResultSection extends StatelessWidget {
  final PPResult result;
  final Color emerald;
  final VoidCallback onStepsTap;
  final VoidCallback onGraphTap;

  const _ResultSection({
    required this.result,
    required this.emerald,
    required this.onStepsTap,
    required this.onGraphTap,
  });

  Color _verdictColor() {
    switch (result.relationship) {
      case PPRelationship.parallel:
        return _cyan;
      case PPRelationship.perpendicular:
        return const Color(0xFF8B5CF6);
      case PPRelationship.sameLine:
        return const Color(0xFFF59E0B);
      case PPRelationship.neither:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _verdictColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Verdict
        GestureDetector(
          onTap: onGraphTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Text(result.verdictSymbol,
                        style: TextStyle(fontSize: 22, color: color)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RESULT',
                          style: YITheme.inputLabelStyle(context).copyWith(
                              color: color.withValues(alpha: 0.7),
                              fontSize: 10,
                              letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(result.verdict,
                          style: YITheme.titleStyle(context).copyWith(
                              color: color,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Line cards side by side
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _LineCard(
                label: 'Line 1',
                equation: result.slopeIntercept1,
                slope: result.slope1?.toString() ?? 'undefined',
                accent: _cyan,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LineCard(
                label: 'Line 2',
                equation: result.slopeIntercept2,
                slope: result.slope2?.toString() ?? 'undefined',
                accent: emerald,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onStepsTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: _cyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _cyan.withValues(alpha: 0.28)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long_rounded,
                          color: _cyan, size: 15),
                      const SizedBox(width: 6),
                      Text('Solution Steps',
                          style: YITheme.inputLabelStyle(context)
                              .copyWith(color: _cyan, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: onGraphTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: emerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: emerald.withValues(alpha: 0.28)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.show_chart_rounded, color: emerald, size: 15),
                      const SizedBox(width: 6),
                      Text('Graph',
                          style: YITheme.inputLabelStyle(context)
                              .copyWith(color: emerald, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Line Card
// ─────────────────────────────────────────────────────────────

class _LineCard extends StatelessWidget {
  final String label;
  final String equation;
  final String slope;
  final Color accent;

  const _LineCard({
    required this.label,
    required this.equation,
    required this.slope,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: YITheme.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.3), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: accent.withValues(alpha: 0.12),
            child: Text(label,
                textAlign: TextAlign.center,
                style: YITheme.inputLabelStyle(context)
                    .copyWith(color: accent, fontSize: 11, letterSpacing: 0.5)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Text(equation,
                  style: YITheme.resultEquationStyle(context).copyWith(
                      color: YITheme.textPrimary(context), fontSize: 13)),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 12),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: accent.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(8),
              color: accent.withValues(alpha: 0.06),
            ),
            child: Text('m = $slope',
                textAlign: TextAlign.center,
                style: YITheme.resultEquationStyle(context).copyWith(
                    color: accent, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Solution Steps Bottom Sheet
// ─────────────────────────────────────────────────────────────

class _SolutionStepsSheet extends StatelessWidget {
  final PPResult result;
  const _SolutionStepsSheet({required this.result});

  @override
  Widget build(BuildContext context) {
    final emerald = YITheme.emerald(context);
    final steps = result.steps;

    // Group steps into display rows:
    // Steps that share the same groupKey are paired side-by-side.
    // Steps with no groupKey (or unique groupKey) render full-width.
    final rows = _groupSteps(steps, emerald);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: YITheme.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: _cyan.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _cyan.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Solution Steps',
                              style: YITheme.titleStyle(context)
                                  .copyWith(fontSize: 17)),
                          Text('Complete step-by-step working',
                              style: YITheme.subtitleStyle(context).copyWith(
                                  color: _cyan.withValues(alpha: 0.7),
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded,
                          color: _cyan, size: 20),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Subtract the ListView's left+right padding (16+16=32)
                    // so cards never exceed the visible area.
                    const hPad = 16.0;
                    final availableWidth = constraints.maxWidth - hPad * 2;
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(hPad, 4, hPad, 32),
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) =>
                          rows[i].build(context, availableWidth),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Pairs steps that share the same [groupKey] into [_SideBySideRow].
  /// All others become [_FullWidthRow].
  List<_StepRow> _groupSteps(List<PPSolverStep> steps, Color emerald) {
    final rows = <_StepRow>[];
    final Map<String, PPSolverStep> pending = {};

    for (final step in steps) {
      final key = step.groupKey;
      if (key == null) {
        rows.add(_FullWidthRow(step: step, accent: _cyan));
        continue;
      }
      if (pending.containsKey(key)) {
        final first = pending.remove(key)!;
        rows.add(_SideBySideRow(
          left: first,
          right: step,
          leftAccent: _cyan,
          rightAccent: emerald,
        ));
      } else {
        pending[key] = step;
      }
    }

    // Flush any unpaired steps as full-width
    for (final step in pending.values) {
      rows.add(_FullWidthRow(step: step, accent: _cyan));
    }

    return rows;
  }
}

// ─────────────────────────────────────────────────────────────
// Step Row abstractions
// ─────────────────────────────────────────────────────────────

abstract class _StepRow {
  Widget build(BuildContext context, double availableWidth);
}

/// Renders a single step at full width.
class _FullWidthRow extends _StepRow {
  final PPSolverStep step;
  final Color accent;
  _FullWidthRow({required this.step, required this.accent});

  @override
  Widget build(BuildContext context, double availableWidth) {
    return _StepCard(
      step: step,
      accent: accent,
      width: availableWidth,
    );
  }
}

/// Renders two steps side-by-side, each occupying exactly half the width.
class _SideBySideRow extends _StepRow {
  final PPSolverStep left;
  final PPSolverStep right;
  final Color leftAccent;
  final Color rightAccent;

  _SideBySideRow({
    required this.left,
    required this.right,
    required this.leftAccent,
    required this.rightAccent,
  });

  @override
  Widget build(BuildContext context, double availableWidth) {
    const gap = 10.0;
    final colWidth = (availableWidth - gap) / 2;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepCard(step: left, accent: leftAccent, width: colWidth),
        const SizedBox(width: gap),
        _StepCard(step: right, accent: rightAccent, width: colWidth),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step Card
// Uses an explicit [width] so LaTeX always has bounded constraints.
// ─────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final PPSolverStep step;
  final Color accent;

  /// Explicit width — must always be a finite value so LaTeX renders correctly.
  final double width;

  const _StepCard({
    required this.step,
    required this.accent,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: YITheme.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.22)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              color: accent.withValues(alpha: 0.08),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('${step.number}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(step.title,
                        style:
                            YITheme.titleStyle(context).copyWith(fontSize: 13)),
                  ),
                ],
              ),
            ),

            // Blocks — width is passed directly into PPStepBlockWidget so
            // LaTeX always has a finite bounded constraint. No IntrinsicWidth,
            // no ConstrainedBox, no SingleChildScrollView wrapping — these all
            // cause assertion failures and kill scrolling performance.
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: step.blocks.map((b) {
                  // innerWidth = card width minus the 12px padding on each side
                  final innerWidth = width - 24.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PPStepBlockWidget(block: b, width: innerWidth),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
