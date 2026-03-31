// radical_parser.dart
//
// Responsibility: turn a raw user string into a RadicalPrep.
// Nothing in here knows how to solve anything.

import 'package:calculus_system/modules/inequalities/core/inequality_core_solver.dart';
import 'radical_models.dart';

class RadicalParser {
  // ── public entry ──────────────────────────────────────────────────────────

  /// Returns null if the input cannot be recognised as a radical inequality.
  static RadicalPrep? parse(String input) {
    final s = _normalise(input);
    final op = _extractOp(s);
    if (op == null) return null;

    final idx = _opIndex(s, op);
    if (idx == -1) return null;

    final left = s.substring(0, idx);
    final right = s.substring(idx + op.length);

    final leftInner = _radicalInner(left);
    final rightInner = _radicalInner(right);

    // At least one side must be a radical.
    if (leftInner == null && rightInner == null) return null;

    // Normalise: √ always on the left by flipping op when needed.
    final String inner;
    final String rhsExpr;
    final String effectiveOp;

    if (leftInner != null) {
      inner = leftInner;
      rhsExpr = right;
      effectiveOp = op;
    } else {
      inner = rightInner!;
      rhsExpr = left;
      effectiveOp = InequalityCoreSolver.flipOp(op);
    }

    // Parse radicand as linear: ia·x + ib.
    final innerParsed = InequalityCoreSolver.parseLinear(inner);
    if (innerParsed == null) return null;
    final ia = innerParsed['x']!;
    final ib = innerParsed['c']!;

    // ── Classify RHS ────────────────────────────────────────────────────────

    // 1. Plain constant.
    final constVal = double.tryParse(rhsExpr);
    if (constVal != null) {
      return RadicalPrep(
        original: input.trim(),
        inner: inner,
        ia: ia,
        ib: ib,
        op: effectiveOp,
        rhsType: RhsType.constant,
        k: constVal,
      );
    }

    // 2. Another radical: √(cx+d).
    final rhsInner2 = _radicalInner(rhsExpr);
    if (rhsInner2 != null) {
      final rp = InequalityCoreSolver.parseLinear(rhsInner2);
      if (rp != null) {
        return RadicalPrep(
          original: input.trim(),
          inner: inner,
          ia: ia,
          ib: ib,
          op: effectiveOp,
          rhsType: RhsType.radical,
          rhsExpr: rhsInner2,
          rc: rp['x']!,
          rd: rp['c']!,
        );
      }
    }

    // 3. Quadratic: qe·x²+rc·x+rd  — must check before linear so it isn't
    //    misclassified when the x² term is present.
    final quadParsed = _parseQuadratic(rhsExpr);
    if (quadParsed != null && quadParsed['a'] != 0) {
      return RadicalPrep(
        original: input.trim(),
        inner: inner,
        ia: ia,
        ib: ib,
        op: effectiveOp,
        rhsType: RhsType.quadratic,
        rhsExpr: rhsExpr,
        qe: quadParsed['a']!,
        rc: quadParsed['b']!,
        rd: quadParsed['c']!,
      );
    }

    // 4. Linear: rc·x + rd.
    final linearParsed = InequalityCoreSolver.parseLinear(rhsExpr);
    if (linearParsed != null) {
      return RadicalPrep(
        original: input.trim(),
        inner: inner,
        ia: ia,
        ib: ib,
        op: effectiveOp,
        rhsType: RhsType.linear,
        rhsExpr: rhsExpr,
        rc: linearParsed['x']!,
        rd: linearParsed['c']!,
      );
    }

    return null;
  }

  // ── normalisation ─────────────────────────────────────────────────────────

  static String _normalise(String input) => input
      .trim()
      .replaceAll('\u2212', '-')
      .replaceAll('\u2013', '-')
      .replaceAll('>=', '≥')
      .replaceAll('<=', '≤')
      .replaceAll('=>', '≥')
      .replaceAll('=<', '≤')
      .replaceAll('sqrt', '√')
      .replaceAll('x²', 'x^2')
      .replaceAll('²', '^2')
      .replaceAll(' ', '');

  // ── operator helpers ──────────────────────────────────────────────────────

  static String? _extractOp(String s) {
    if (s.contains('≥')) return '≥';
    if (s.contains('≤')) return '≤';
    if (s.contains('>')) return '>';
    if (s.contains('<')) return '<';
    return null;
  }

  /// Scan right-to-left for bare > / < to avoid matching inside expressions.
  static int _opIndex(String s, String op) {
    if (op == '>' || op == '<') {
      for (int i = s.length - 1; i >= 0; i--) {
        if (s[i] == op) {
          if (i + 1 < s.length && s[i + 1] == '=') continue;
          return i;
        }
      }
      return -1;
    }
    return s.indexOf(op);
  }

  // ── radical pattern ───────────────────────────────────────────────────────

  // Matches √expr or √(expr) and captures the inner expression.
  static final _radPat = RegExp(r'^√\(?([^)]*)\)?$');

  static String? _radicalInner(String s) => _radPat.firstMatch(s)?.group(1);

  // ── quadratic expression parser  ax² + bx + c ────────────────────────────

  static Map<String, double>? _parseQuadratic(String expr) {
    expr = expr.trim().replaceAll(' ', '');
    if (!expr.contains('x^2')) return null;

    double a = 0, b = 0, c = 0;
    final tokens = <String>[];
    String cur = '';
    int depth = 0;

    for (int i = 0; i < expr.length; i++) {
      final ch = expr[i];
      if (ch == '(') {
        depth++;
        cur += ch;
      } else if (ch == ')') {
        depth--;
        cur += ch;
      } else if ((ch == '+' || ch == '-') &&
          i > 0 &&
          depth == 0 &&
          cur.isNotEmpty) {
        tokens.add(cur);
        cur = ch;
      } else {
        cur += ch;
      }
    }
    if (cur.isNotEmpty) tokens.add(cur);

    for (final tok in tokens) {
      final t = tok.replaceAll('*', '');
      if (t.contains('x^2')) {
        a += _coef(t.substring(0, t.indexOf('x')));
      } else if (t.contains('x')) {
        b += _coef(t.substring(0, t.indexOf('x')));
      } else {
        c += double.tryParse(t.startsWith('+') ? t.substring(1) : t) ?? 0;
      }
    }
    return {'a': a, 'b': b, 'c': c};
  }

  static double _coef(String s) {
    s = s.trim();
    if (s.isEmpty || s == '+') return 1;
    if (s == '-') return -1;
    return double.tryParse(s) ?? 0;
  }
}
