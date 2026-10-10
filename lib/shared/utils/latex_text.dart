// ─────────────────────────────────────────────────────────────
// LATEX TEXT — single source of truth for turning step LaTeX into
// readable plain text.
//
// Both step surfaces (StepList, StepsDrawer) render math through a
// LaTeX renderer and need the SAME plain-text transforms for their
// clipboard affordances and for the readable fallback shown when
// TeX is malformed. This file holds those transforms exactly once;
// StepList.stripLatex / StepList.buildCopyText are kept as public
// entry points that delegate here, so no caller or test changes.
// ─────────────────────────────────────────────────────────────
import 'package:calculus_system/core/step_model.dart';

/// Strips TeX commands from [s], leaving readable plain-text math.
/// (Ported, byte-for-byte, from the strip list StepsDrawer's private
/// `_stripLatex` and StepList.stripLatex used to each carry.)
String stripLatex(String s) {
  s = s.replaceAllMapped(
    RegExp(r'\\frac\{([^}]*)\}\{([^}]*)\}'),
    (m) => '${m[1]}/${m[2]}',
  );
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

/// Plain-text copy of the walkthrough for clipboard affordances:
/// latex steps copy stripped math (never raw TeX commands), plain
/// steps copy their title + explanation.
String buildCopyText(List<StepModel> steps) {
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
