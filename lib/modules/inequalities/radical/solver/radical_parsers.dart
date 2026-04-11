// radical_parser.dart
//
// Responsibility: structural recognition only.
// Normalizes radical to left side, extracts coefficients, tracks flip state.

import 'package:calculus_system/modules/inequalities/core/inequality_core_solver.dart';
import 'radical_models.dart';

class RadicalParser {
  static RadicalPrep? parse(String input) {
    final s = _normalize(input);
    final op = _extractOp(s);
    if (op == null) return null;

    final idx = _opIndexBalanced(s, op);
    if (idx == -1) return null;

    final left = s.substring(0, idx).trim();
    final right = s.substring(idx + op.length).trim();

    // Both sides must be non-empty
    if (left.isEmpty || right.isEmpty) return null;

    final leftRad = _extractRadical(left);
    final rightRad = _extractRadical(right);

    if (leftRad == null && rightRad == null) return null;

    final String radInner;
    final String rhsExpr;
    final String effectiveOp;
    final bool wasFlipped;

    if (leftRad != null) {
      radInner = leftRad;
      rhsExpr = right;
      effectiveOp = op;
      wasFlipped = false;
    } else {
      radInner = rightRad!;
      rhsExpr = left;
      effectiveOp = InequalityCoreSolver.flipOp(op);
      wasFlipped = true;
    }

    final innerParsed = InequalityCoreSolver.parseLinear(radInner);
    if (innerParsed == null) return null;
    final ia = innerParsed['x']!;
    final ib = innerParsed['c']!;

    return _classifyRHS(
      original: input.trim(),
      inner: radInner,
      ia: ia,
      ib: ib,
      op: effectiveOp,
      wasFlipped: wasFlipped,
      rhsExpr: rhsExpr,
    );
  }

  static String _normalize(String s) => s
      .trim()
      .replaceAll(RegExp(r'[\u2212\u2013\u2014\u2010\u2011]'), '-')
      .replaceAll('>=', '≥')
      .replaceAll('<=', '≤')
      .replaceAll('=>', '≥')
      .replaceAll('=<', '≤')
      .replaceAll(RegExp(r'sqrt', caseSensitive: false), '√')
      .replaceAll('x²', 'x^2')
      .replaceAll('²', '^2')
      .replaceAll(RegExp(r'\s+'), '');

  static String? _extractOp(String s) {
    if (s.contains('≥')) return '≥';
    if (s.contains('≤')) return '≤';
    if (s.contains('>')) return '>';
    if (s.contains('<')) return '<';
    return null;
  }

  static int _opIndexBalanced(String s, String op) {
    int depth = 0;
    for (int i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '(') {
        depth++;
      } else if (c == ')') {
        depth--;
        if (depth < 0) return -1;
      } else if (depth == 0) {
        if ((op == '>' || op == '<') && c == op) {
          if (i + 1 >= s.length || s[i + 1] != '=') return i;
        } else if (s.substring(i).startsWith(op)) {
          return i;
        }
      }
    }
    return -1;
  }

  static String? _extractRadical(String s) {
    if (!s.startsWith('√')) return null;

    final rest = s.substring(1);
    if (rest.isEmpty) return null;

    if (rest.startsWith('(')) {
      int depth = 1;
      int i = 1;
      for (; i < rest.length && depth > 0; i++) {
        if (rest[i] == '(') {
          depth++;
          // ignore: curly_braces_in_flow_control_structures
        } else if (rest[i] == ')') depth--;
      }
      if (depth != 0) return null;
      if (i != rest.length) return null;
      return rest.substring(1, i - 1);
    }

    // Simple form - must not contain operators
    if (rest.contains(RegExp(r'[+\-<>≥≤]'))) return null;
    return rest;
  }

  static RadicalPrep? _classifyRHS({
    required String original,
    required String inner,
    required double ia,
    required double ib,
    required String op,
    required bool wasFlipped,
    required String rhsExpr,
  }) {
    // 1. Constant
    final constVal = double.tryParse(rhsExpr);
    if (constVal != null) {
      return RadicalPrep(
        original: original,
        inner: inner,
        ia: ia,
        ib: ib,
        op: op,
        rhsType: RhsType.constant,
        k: constVal,
        wasFlipped: wasFlipped,
      );
    }

    // 2. Radical
    final rhsRad = _extractRadical(rhsExpr);
    if (rhsRad != null) {
      final p = InequalityCoreSolver.parseLinear(rhsRad);
      if (p == null) return null;
      return RadicalPrep(
        original: original,
        inner: inner,
        ia: ia,
        ib: ib,
        op: op,
        rhsType: RhsType.radical,
        rhsExpr: rhsRad,
        rc: p['x']!,
        rd: p['c']!,
        wasFlipped: wasFlipped,
      );
    }

    // 3. Quadratic
    final quad = _parseQuadratic(rhsExpr);
    if (quad != null && quad['a'] != 0) {
      return RadicalPrep(
        original: original,
        inner: inner,
        ia: ia,
        ib: ib,
        op: op,
        rhsType: RhsType.quadratic,
        rhsExpr: rhsExpr,
        qe: quad['a']!,
        rc: quad['b']!,
        rd: quad['c']!,
        wasFlipped: wasFlipped,
      );
    }

    // 4. Linear
    final lin = InequalityCoreSolver.parseLinear(rhsExpr);
    if (lin != null) {
      return RadicalPrep(
        original: original,
        inner: inner,
        ia: ia,
        ib: ib,
        op: op,
        rhsType: RhsType.linear,
        rhsExpr: rhsExpr,
        rc: lin['x']!,
        rd: lin['c']!,
        wasFlipped: wasFlipped,
      );
    }

    return null;
  }

  static Map<String, double>? _parseQuadratic(String expr) {
    if (!expr.contains(RegExp(r'x\^2|x²'))) return null;

    String s = expr.replaceAll('x²', 'x^2');
    double a = 0, b = 0, c = 0;

    if (s.startsWith('-')) s = '0$s';

    final tokens = <String>[];
    var cur = '';
    var depth = 0;

    for (int i = 0; i < s.length; i++) {
      final ch = s[i];
      if (ch == '(') {
        depth++;
        cur += ch;
      } else if (ch == ')') {
        depth--;
        cur += ch;
      } else if ((ch == '+' || ch == '-') && i > 0 && depth == 0) {
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
        final pre = t.substring(0, t.indexOf('x^2')).trim();
        a += _coef(pre);
      } else if (t.contains('x')) {
        final pre = t.substring(0, t.indexOf('x')).trim();
        b += _coef(pre);
      } else {
        c += double.tryParse(tok) ?? 0;
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
