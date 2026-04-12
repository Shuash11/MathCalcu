// lib/modules/y-intercept/ui/widgets/pp_stepblock_widget.dart

import 'package:calculus_system/modules/y-intercept/solver/parallel_perpendicular.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:calculus_system/modules/y-intercept/Theme/theme.dart';

const _cyan  = Color(0xFF06B6D4);
const _amber = Color(0xFFF59E0B);
const _slate = Color(0xFF64748B);

// PPStepBlockWidget renders a single block inside a step card.
//
// [width] — the exact pixel width the block should occupy.
// Always pass this from _StepCard so LaTeX has a finite bounded constraint.
// Never rely on IntrinsicWidth or ConstrainedBox inside a scroll view.

class PPStepBlockWidget extends StatelessWidget {
  final PPStepBlock block;

  /// Explicit finite width for the block. Required for correct LaTeX layout.
  final double? width;

  const PPStepBlockWidget({
    super.key,
    required this.block,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = !YITheme.isLight(context);

    switch (block.type) {
      case PPBlockType.note:
        return _NoteBlock(text: block.content, isDark: isDark, width: width);

      case PPBlockType.formula:
        return _MathBlock(
          label: block.label ?? 'Formula',
          latex: block.latex,
          fallback: block.content,
          borderColor: _cyan,
          isDark: isDark,
          width: width,
        );

      case PPBlockType.substitution:
        return _MathBlock(
          label: block.label,
          latex: block.latex,
          fallback: block.content,
          borderColor: _slate,
          isDark: isDark,
          width: width,
        );

      case PPBlockType.working:
        return _MathBlock(
          label: block.label ?? 'Working',
          latex: block.latex,
          fallback: block.content,
          borderColor: _amber,
          isDark: isDark,
          width: width,
        );

      case PPBlockType.result:
        return _ResultBlock(
          latex: block.latex,
          fallback: block.content,
          isDark: isDark,
          width: width,
        );
    }
  }
}

// ─── Note block ───────────────────────────────────────────────

class _NoteBlock extends StatelessWidget {
  final String text;
  final bool isDark;
  final double? width;
  const _NoteBlock({required this.text, required this.isDark, this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.55),
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─── Generic math block ───────────────────────────────────────

class _MathBlock extends StatelessWidget {
  final String? label;
  final String? latex;
  final String fallback;
  final Color borderColor;
  final bool isDark;
  final double? width;

  const _MathBlock({
    this.label,
    this.latex,
    required this.fallback,
    required this.borderColor,
    required this.isDark,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      // ClipRRect ensures nothing bleeds outside the rounded border
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: borderColor.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor.withValues(alpha: 0.3), width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: borderColor.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 6),
          ],
          _renderMath(latex, fallback, isDark),
        ],
      ),
    );
  }
}

// ─── Result block ─────────────────────────────────────────────

class _ResultBlock extends StatelessWidget {
  final String? latex;
  final String fallback;
  final bool isDark;
  final double? width;

  const _ResultBlock({
    this.latex,
    required this.fallback,
    required this.isDark,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      // ClipRRect ensures nothing bleeds outside the rounded border
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: _cyan.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _cyan.withValues(alpha: 0.5), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: _renderMath(latex, fallback, isDark, fontSize: 15),
      ),
    );
  }
}

// ─── Core renderer ────────────────────────────────────────────

Widget _renderMath(
  String? latex,
  String fallback,
  bool isDark, {
  double fontSize = 13.5,
}) {
  final textColor = isDark
      ? Colors.white.withValues(alpha: 0.88)
      : Colors.black.withValues(alpha: 0.82);

  if (latex == null || latex.isEmpty) {
    return _plainLines(fallback, textColor, fontSize);
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
    return _mathLine(lines[0], textColor, fontSize);
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: lines
        .map((l) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _mathLine(l, textColor, fontSize),
            ))
        .toList(),
  );
}

Widget _mathLine(String tex, Color color, double fontSize) {
  // SingleChildScrollView (horizontal) prevents the LaTeX widget from
  // overflowing the card bounds on narrow screens (e.g. side-by-side cards).
  // RepaintBoundary isolates flutter_math_fork's internal MouseRegion widgets
  // from the parent scroll view, preventing mouse_tracker assertion errors
  // that fire on every scroll frame when math is inside a ListView.
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: const BouncingScrollPhysics(),
    child: RepaintBoundary(
      child: Math.tex(
        tex,
        textStyle: TextStyle(fontSize: fontSize, color: color),
        onErrorFallback: (err) => Text(
          tex,
          style: TextStyle(
              fontSize: fontSize, color: color, fontFamily: 'monospace'),
        ),
      ),
    ),
  );
}

Widget _plainLines(String text, Color color, double fontSize) {
  final lines = text.split('\n').where((l) => l.isNotEmpty).toList();
  if (lines.length == 1) {
    return Text(text,
        style: TextStyle(fontSize: fontSize, color: color, height: 1.4));
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: lines
        .map((l) => Text(l,
            style: TextStyle(fontSize: fontSize, color: color, height: 1.4)))
        .toList(),
  );
}