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
                        color: _cyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _cyan.withValues(alpha: 0.35),
                            width: 1.5),
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
                    const _HintBanner(),
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
                          return const _EmptyState(accent: _cyan);
                        }
                        return _ResultSection(
                          result: result,
                          accent: _cyan,
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
// UI Components
// ─────────────────────────────────────────────────────────────

class _HintBanner extends StatelessWidget {
  const _HintBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cyan.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cyan.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: _cyan.withValues(alpha: 0.8), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Enter equations in any format (e.g., y = 2x + 1, 3x - 4y = 12, or 2x + y - 5 = 0).',
              style: YITheme.subtitleStyle(context).copyWith(
                color: YITheme.textSecondary(context),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: YITheme.inputLabelStyle(context)
                .copyWith(color: accent, fontSize: 10)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: YITheme.resultEquationStyle(context).copyWith(
            color: YITheme.textPrimary(context),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: YITheme.subtitleStyle(context).copyWith(
              color: YITheme.textSecondary(context).withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: YITheme.surface(context).withValues(alpha: 0.8),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accent.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accent.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Color accent;
  const _EmptyState({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Icon(Icons.compare_arrows_rounded,
              color: accent.withValues(alpha: 0.3), size: 40),
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
                accent: _cyan,
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
                Text(
                  'View Solution Steps',
                  style: YITheme.inputLabelStyle(context)
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
              Text(
                'VERDICT',
                style: YITheme.inputLabelStyle(context)
                    .copyWith(color: accent, fontSize: 10),
              ),
              const Spacer(),
              Icon(Icons.show_chart_rounded, color: accent, size: 16),
              const SizedBox(width: 4),
              Text(
                'Tap to graph',
                style: YITheme.subtitleStyle(context).copyWith(
                    color: accent.withValues(alpha: 0.7), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${result.verdictSymbol}  ${result.verdict}',
            style: YITheme.resultEquationStyle(context)
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
          Text(title,
              style: YITheme.inputLabelStyle(context)
                  .copyWith(color: accent)),
          const SizedBox(height: 6),
          SelectableText(
            equation,
            style: YITheme.resultEquationStyle(context).copyWith(
                color: YITheme.textPrimary(context), fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            meta,
            style: YITheme.subtitleStyle(context)
                .copyWith(color: YITheme.textSecondary(context)),
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
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: _cyan.withValues(alpha: 0.28)),
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
// THE MISSING STEP CARD WIDGET
// This wraps your PPStepBlockWidget to create the actual cards
// ─────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final PPSolverStep step;
  final Color accent;
  final double width;

  const _StepCard({
    required this.step,
    required this.accent,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    // Subtract padding so the inner math blocks don't overflow horizontally
    final innerWidth = width - 24; 

    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: YITheme.surface(context).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Step ${step.number}',
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  step.title,
                  style: TextStyle(
                    color: YITheme.textPrimary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Step Blocks (mapped to your PPStepBlockWidget)
          ...step.blocks.map((block) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PPStepBlockWidget(
                  block: block,
                  width: innerWidth, 
                ),
              )),
        ],
      ),
    );
  }
}