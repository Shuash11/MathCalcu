// ─────────────────────────────────────────────────────────────
// GRADE 6 SOLVER SCREEN — generic Phase-1 UI shell (Task 5).
//
// One config per G6 topic drives: MathInputField (exact hintText
// from the plan + helper + inline error), AnswerCard, steps via
// SolutionStepsModal, and the matching graph painter from
// grade6_graphs.dart. Thin per-topic screens only supply a
// Grade6SolverConfig — no duplicated layout code.
//
// Styling via ThemeProvider only. Offline (pure-Dart solvers).
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/answer_card.dart';
import 'package:calculus_system/shared/widgets/empty_state.dart';
import 'package:calculus_system/shared/widgets/graph_widget.dart';
import 'package:calculus_system/shared/widgets/math_input_field.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_graphs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Which graph the topic wires. `none` shows no graph section.
enum Grade6GraphKind { none, numberLine, ratioBars, shape, wireframe, pie }

/// Per-topic configuration. Thin screens construct one of these.
class Grade6SolverConfig {
  final String title;
  final String subtitle;
  final String hint;
  final String helper;
  final String depedCode;
  final IconData icon;
  final Grade6GraphKind graphKind;

  /// Builds the solver for a raw input line.
  final BaseEquation Function(String input) createEquation;

  /// Optional shortcut chips that insert a prefix (e.g. shape names).
  final List<String> chips;

  const Grade6SolverConfig({
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.helper,
    required this.depedCode,
    required this.icon,
    required this.createEquation,
    this.graphKind = Grade6GraphKind.none,
    this.chips = const [],
  });
}

class Grade6SolverScreen extends StatefulWidget {
  final Grade6SolverConfig config;

  const Grade6SolverScreen({super.key, required this.config});

  @override
  State<Grade6SolverScreen> createState() => _Grade6SolverScreenState();
}

class _Grade6SolverScreenState extends State<Grade6SolverScreen> {
  final _ctrl = TextEditingController();
  SolveResult? _result;
  List<StepModel> _steps = const [];
  bool _solved = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _solve() {
    final input = _ctrl.text;
    if (input.trim().isEmpty) {
      setState(() {
        _result = SolveResult.error(
          'Enter a value to solve — ${widget.config.hint}',
        );
        _steps = const [];
        _solved = true;
      });
      return;
    }
    final equation = widget.config.createEquation(input);
    final result = equation.solve();
    setState(() {
      _result = result;
      _steps = result.hasError ? const [] : equation.getSteps();
      _solved = true;
    });
  }

  void _showSteps() {
    if (_result == null || _result!.hasError || _steps.isEmpty) return;
    showSolutionStepsModal(
      context: context,
      title: '${widget.config.title} — Steps',
      design: AppDesign.app,
      child: _Grade6StepsList(steps: _steps),
    );
  }

  Widget _graphFor(SolveResult result, ThemeProvider theme) {
    final accent = theme.accentColor;
    final textPrimary = theme.textPrimary;
    final textSecondary = theme.textSecondary;
    final Widget body = switch (widget.config.graphKind) {
      Grade6GraphKind.numberLine => G6NumberLineGraph(
          result: result,
          accentColor: accent,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
      Grade6GraphKind.ratioBars => G6RatioBarsGraph(
          result: result,
          accentColor: accent,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
      Grade6GraphKind.shape => G6ShapeGraph(
          result: result,
          accentColor: accent,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
      Grade6GraphKind.wireframe => G6WireframeGraph(
          result: result,
          accentColor: accent,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
      Grade6GraphKind.pie => G6PieGraph(
          result: result,
          accentColor: accent,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
      Grade6GraphKind.none => const SizedBox.shrink(),
    };
    return GraphWidget(result: result, accentColor: accent, graphBody: body);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final accent = theme.accentColor;
    final result = _result;
    final hasError = result != null && result.hasError;

    return Scaffold(
      backgroundColor: theme.surface,
      // F5 MED shared responsive shell: LayoutBuilder breakpoints +
      // centered max-width cap. All thin inheriting screens (~20)
      // reflow at 320px and stop stretching on tablet/desktop.
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final double horizontal;
            if (maxWidth >= 900) {
              horizontal = 32;
            } else if (maxWidth >= 600) {
              horizontal = 24;
            } else {
              horizontal = 16;
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 40),
                  children: [
                    _Header(config: widget.config),
                    const SizedBox(height: 28),
                    Text(
                      'Enter your problem',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    MathInputField(
                      controller: _ctrl,
                      accentColor: accent,
                      hint: widget.config.hint,
                      helperText: widget.config.helper,
                      errorText: hasError ? result.errorMessage : null,
                      onSolve: _solve,
                      onChanged: (_) {
                        if (_solved && hasError) {
                          setState(() {
                            _result = null;
                            _solved = false;
                          });
                        }
                      },
                    ),
                    if (widget.config.chips.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final chip in widget.config.chips)
                            ActionChip(
                              label: Text(
                                chip.trim(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: accent,
                                ),
                              ),
                              backgroundColor: accent.withValues(alpha: 0.08),
                              side: BorderSide(
                                color: accent.withValues(alpha: 0.3),
                              ),
                              onPressed: () {
                                _ctrl.text = chip;
                                _ctrl.selection = TextSelection.collapsed(
                                  offset: _ctrl.text.length,
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _solve,
                        icon: const Icon(Icons.calculate_rounded, size: 18),
                        label: const ResponsiveText(
                          'Solve',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: theme.surface,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_solved && result != null) ...[
                      if (hasError)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded,
                                  color: accent, size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ResponsiveText(
                                  result.errorMessage ?? 'Unknown error',
                                  style: TextStyle(
                                    color: theme.textPrimary,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        if (widget.config.graphKind != Grade6GraphKind.none)
                          _graphFor(result, theme)
                        else
                          const NoGraphPlaceholder(
                            reason:
                                'Numeric answer only — no diagram needed for this input.',
                          ),
                        const SizedBox(height: 16),
                        AnswerCard(
                          result: result,
                          accentColor: accent,
                          onTap: _showSteps,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Grade6SolverConfig config;

  const _Header({required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final accent = theme.accentColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: theme.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.textSecondary.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 14,
                  color: theme.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accent.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(config.icon, color: accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveText(
                    config.title,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: theme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  ResponsiveText(
                    config.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accent.withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            config.depedCode,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accent,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// Steps list rendered inside the SolutionStepsModal bottom sheet.
/// G6 solvers fill title/explanation (not latex), so StepsDrawer
/// would render blank — this view reads title + explanation.
class _Grade6StepsList extends StatelessWidget {
  final List<StepModel> steps;

  const _Grade6StepsList({required this.steps});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final accent = theme.accentColor;
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${steps[i].stepNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (steps[i].title.isNotEmpty)
                      Text(
                        steps[i].title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                        ),
                      ),
                    if (steps[i].explanation.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        steps[i].explanation,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (i < steps.length - 1) const SizedBox(height: 18),
        ],
      ],
    );
  }
}
