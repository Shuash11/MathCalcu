// lib/modules/yintercept/screens/parallel_perpendicular_screen.dart
import 'dart:async';
import 'package:calculus_system/modules/y-intercept/Graph/perpenparallel_graph.dart';
import 'package:calculus_system/modules/y-intercept/Theme/theme.dart';
import 'package:calculus_system/modules/y-intercept/solver/parallel_perpendicular.dart';
import 'package:calculus_system/modules/y-intercept/ui/widgets/pp_stepblock_widget.dart';


import 'package:flutter/material.dart';

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
    _debounce = Timer(const Duration(milliseconds: 350), _compute);
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
          'Could not parse one or both equations. Try: 2x + 3y = 6  or  2x + 3y + 4 = 0';
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
    const cyan = Color(0xFF06B6D4);

    return Scaffold(
      backgroundColor: YITheme.surface(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              // ── Header ────────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: cyan.withValues(alpha: 0.35), width: 1.5),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: cyan, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Parallel and Perpendicular',
                      style: YITheme.subtitleStyle(context).copyWith(
                          fontSize: 16,
                          color: YITheme.textPrimary(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── Input card ────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: YITheme.cardGradient(context),
                  borderRadius: BorderRadius.circular(YITheme.radiusCard),
                  border: Border.all(
                      color: cyan.withValues(alpha: 0.24), width: 1.5),
                  boxShadow: YITheme.cardShadow(context),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // icon + title row
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(colors: [
                                cyan.withValues(alpha: 0.22),
                                emerald.withValues(alpha: 0.14),
                              ]),
                              border: Border.all(
                                  color: cyan.withValues(alpha: 0.35)),
                            ),
                            child: const Icon(
                                Icons.compare_arrows_rounded, color: cyan),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Line Relationship Solver',
                                    style: YITheme.titleStyle(context)),
                                const SizedBox(height: 4),
                                Text(
                                  'Enter two linear equations in any form or order.',
                                  style: YITheme.subtitleStyle(context)
                                      .copyWith(
                                          color: cyan.withValues(alpha: 0.7)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // hint banner
                      const _HintBanner(accent: cyan),
                      const SizedBox(height: 20),

                      // inputs
                      _EquationField(
                        controller: _line1Ctrl,
                        label: 'LINE 1',
                        hint: '2x + 3y = 6  or  3y - 2x + 1 = 0',
                        accent: cyan,
                      ),
                      const SizedBox(height: 14),
                      _EquationField(
                        controller: _line2Ctrl,
                        label: 'LINE 2',
                        hint: '4x - 6y + 1 = 0  or  -x + 2y = 5',
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

                      _divider(cyan),
                      const SizedBox(height: 18),

                      // results area
                      ValueListenableBuilder<PPResult?>(
                        valueListenable: _resultNotifier,
                        builder: (context, result, _) {
                          if (result == null) {
                            return const _EmptyState(accent: cyan);
                          }
                          return _ResultSection(
                            result: result,
                            accent: cyan,
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
      ),
    );
  }

  Widget _divider(Color accent) => Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.transparent,
            accent.withValues(alpha: 0.35),
            Colors.transparent,
          ]),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// Result section
// ─────────────────────────────────────────────────────────────

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onGraphTap,
          child: _VerdictCard(result: result, accent: accent),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _EquationResultCard(
                title: 'Line 1',
                equation: result.slopeIntercept1,
                meta: 'm = ${result.slope1?.toString() ?? 'undefined'}',
                accent: accent,
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
        const SizedBox(height: 14),

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

// ─────────────────────────────────────────────────────────────
// Solution Steps Bottom Sheet
// ─────────────────────────────────────────────────────────────

class _SolutionStepsSheet extends StatelessWidget {
  final PPResult result;
  const _SolutionStepsSheet({required this.result});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF06B6D4);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: YITheme.surface(context),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: accent.withValues(alpha: 0.28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Solution Steps',
                              style: YITheme.titleStyle(context)),
                          const SizedBox(height: 2),
                          Text(
                            'Complete step-by-step working',
                            style: YITheme.subtitleStyle(context).copyWith(
                                color: accent.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: accent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  itemCount: result.steps.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) =>
                      _ClassroomStepCard(step: result.steps[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Classroom Step Card
// ─────────────────────────────────────────────────────────────

class _ClassroomStepCard extends StatelessWidget {
  final PPSolverStep step;
  const _ClassroomStepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF06B6D4);

    return Container(
      decoration: BoxDecoration(
        color: YITheme.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // step header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                  bottom:
                      BorderSide(color: accent.withValues(alpha: 0.2))),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${step.number}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    step.title,
                    style:
                        YITheme.titleStyle(context).copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // step blocks — rendered via PPStepBlockWidget (LaTeX-aware)
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: step.blocks
                  .map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: PPStepBlockWidget(block: b),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Small reusable widgets
// ─────────────────────────────────────────────────────────────

class _HintBanner extends StatelessWidget {
  final Color accent;
  const _HintBanner({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accepted formats',
            style: YITheme.inputLabelStyle(context)
                .copyWith(color: accent, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text(
            'Ax + By = C  ·  Ax + By + C = 0  ·  y = mx + b\nTerms may appear in any order.',
            style: YITheme.resultEquationStyle(context)
                .copyWith(color: YITheme.textPrimary(context), fontSize: 13),
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
            style:
                YITheme.inputLabelStyle(context).copyWith(color: accent)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: YITheme.isLight(context)
                ? Colors.black.withValues(alpha: 0.03)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(YITheme.radiusInput),
            border: Border.all(color: accent.withValues(alpha: 0.24)),
          ),
          child: TextField(
            controller: controller,
            style: YITheme.inputTextStyle(context),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 13),
              hintText: hint,
              hintStyle: YITheme.inputTextStyle(context).copyWith(
                  color: YITheme.textSecondary(context)
                      .withValues(alpha: 0.45)),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Text(
        'Enter two line equations above to compare their slopes.',
        textAlign: TextAlign.center,
        style: YITheme.subtitleStyle(context)
            .copyWith(color: YITheme.textSecondary(context)),
      ),
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