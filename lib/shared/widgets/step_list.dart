// ─────────────────────────────────────────────────────────────
// STEP LIST — central LaTeX step renderer for solution walkthroughs.
//
// One shared widget renders a List<StepModel> as the step list
// inside SolutionStepsModal. Steps WITH latex render KaTeX math
// (SelectableMath, MathStyle.text, FittedBox-wrapped so long forms
// scale down instead of overflowing) with a plain-text fallback so
// malformed TeX can never crash the sheet: flutter_math_fork routes
// parse errors through Math's `onErrorFallback`, which renders the
// step's explanation instead of a red error box.
//
// Steps WITHOUT latex render title/explanation as plain Text —
// zero regression for G6 solvers that only fill those fields.
// subLatex (secondary line) and expandable details ("Show work")
// render when present, matching StepsDrawer's behavior.
//
// KaTeX subset constraints (simpleclub/flutter_math doc/unsupported.md):
// avoid gather, Vmatrix, \hspace*, \smash, \mathchoice, \pmb, \\[8pt];
// use ^{2}/\pi, never unicode ²/π.
//
// Styling via ThemeProvider only. Offline (pure-Dart solvers).
// ─────────────────────────────────────────────────────────────
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';

class StepList extends StatefulWidget {
  final List<StepModel> steps;

  const StepList({super.key, required this.steps});

  /// Plain-text copy of the walkthrough for clipboard affordances:
  /// latex steps copy stripped math (never raw TeX commands), plain
  /// steps copy their title + explanation.
  static String buildCopyText(List<StepModel> steps) {
    final buf = StringBuffer();
    for (final s in steps) {
      final line = s.latex != null && s.latex!.isNotEmpty
          ? stripLatex(s.latex!)
          : [
              if (s.title.isNotEmpty) s.title,
              if (s.explanation.isNotEmpty) s.explanation,
            ].join(' — ');
      if (line.isNotEmpty) buf.writeln(line);
    }
    return buf.toString();
  }

  /// Strips TeX commands from [s], leaving readable plain-text math.
  /// Ported from StepsDrawer's `_stripLatex` strip list.
  static String stripLatex(String s) {
    s = s.replaceAllMapped(
        RegExp(r'\\frac\{([^}]*)\}\{([^}]*)\}'), (m) => '${m[1]}/${m[2]}');
    s = s
        .replaceAll(r'\lvert ', '|')
        .replaceAll(r'\lvert', '|')
        .replaceAll(r'\rvert ', '|')
        .replaceAll(r'\rvert', '|')
        .replaceAll(r'\infty', '\u221e')
        .replaceAll(r'\cup', '\u222a')
        .replaceAll(r'\neq', '\u2260')
        .replaceAll(r'\geq', '\u2265')
        .replaceAll(r'\leq', '\u2264')
        .replaceAll(r'\emptyset', '\u2205')
        .replaceAll(r'\Downarrow', '')
        .replaceAll(r'\downarrow', '');
    s = s.replaceAllMapped(RegExp(r'\\text\{([^}]*)\}'), (m) => m[1] ?? '');
    s = s.replaceAll(RegExp(r'[\{\}]'), '');
    return s.trim();
  }

  @override
  State<StepList> createState() => _StepListState();
}

class _StepListState extends State<StepList> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < widget.steps.length; i++) ...[
          _StepRow(
            step: widget.steps[i],
            isExpanded: _expanded.contains(i),
            onToggle: () => setState(() {
              if (_expanded.contains(i)) {
                _expanded.remove(i);
              } else {
                _expanded.add(i);
              }
            }),
          ),
          if (i < widget.steps.length - 1) const SizedBox(height: 18),
        ],
      ],
    );
  }
}

/// One step: number badge (visual parity with the G6 shell badge),
/// primary math or plain title/explanation, then secondary lines.
class _StepRow extends StatelessWidget {
  final StepModel step;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _StepRow({
    required this.step,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final accent = theme.accentColor;
    final hasLatex = step.latex != null && step.latex!.isNotEmpty;
    final fallback = Text(
      step.explanation,
      style: TextStyle(
        fontSize: 13,
        height: 1.45,
        color: theme.textPrimary,
      ),
    );

    return Row(
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
              '${step.stepNumber}',
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
              if (step.title.isNotEmpty)
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
                  ),
                ),
              if (hasLatex) ...[
                if (step.title.isNotEmpty) const SizedBox(height: 6),
                _StepMath(
                  step.latex!,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textPrimary,
                    height: 1.5,
                  ),
                  fallback: fallback,
                ),
              ] else if (step.explanation.isNotEmpty) ...[
                if (step.title.isNotEmpty) const SizedBox(height: 4),
                Text(
                  step.explanation,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: theme.textSecondary,
                  ),
                ),
              ],
              if (step.subLatex != null && step.subLatex!.isNotEmpty)
                for (final line in step.subLatex!) ...[
                  const SizedBox(height: 8),
                  _StepMath(
                    line,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.textPrimary,
                      height: 1.5,
                    ),
                    fallback: Text(
                      StepList.stripLatex(line),
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: theme.textSecondary,
                      ),
                    ),
                  ),
                ],
              if (step.hint != null && step.hint!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    step.hint!,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textSecondary,
                      fontStyle: FontStyle.italic,
                      height: 1.3,
                    ),
                  ),
                ),
              if (step.details != null && step.details!.isNotEmpty)
                _StepDetails(
                  details: step.details!,
                  isExpanded: isExpanded,
                  onToggle: onToggle,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// KaTeX math wrapped in a FittedBox so long forms scale down instead
/// of overflowing. Malformed TeX never crashes: flutter_math_fork catches
/// parse errors and routes them through `onErrorFallback`, which renders
/// [fallback] (the plain-text step content) instead.
class _StepMath extends StatelessWidget {
  final String tex;
  final TextStyle style;
  final Widget fallback;

  const _StepMath(this.tex, {required this.style, required this.fallback});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: SelectableMath.tex(
        tex,
        mathStyle: MathStyle.text,
        textStyle: style,
        onErrorFallback: (_) => fallback,
      ),
    );
  }
}

/// Expandable "Show work" section for a step's arithmetic details
/// (parity with StepsDrawer's behavior).
class _StepDetails extends StatelessWidget {
  final List<String> details;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _StepDetails({
    required this.details,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final accent = theme.accentColor;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: isExpanded ? 'Hide work' : 'Show work',
            button: true,
            onTap: onToggle,
            excludeSemantics: true,
            child: GestureDetector(
              excludeFromSemantics: true,
              onTap: onToggle,
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more_rounded,
                      size: 16,
                      color: theme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isExpanded ? 'Hide work' : 'Show work',
                    style: TextStyle(
                      fontSize: 11,
                      color: accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var j = 0; j < details.length; j++) ...[
                            if (j > 0) const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\u2022',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: accent,
                                    height: 1.8,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _StepMath(
                                    details[j],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.textSecondary,
                                      height: 1.6,
                                    ),
                                    fallback: Text(
                                      StepList.stripLatex(details[j]),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: theme.textSecondary,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
