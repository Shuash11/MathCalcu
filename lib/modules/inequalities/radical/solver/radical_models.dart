// radical_models.dart
//
// Shared data models used across all radical_*.dart files.
// Import only this file — never import sibling internals directly.

import 'dart:math' as math;

// ── RHS type classification ───────────────────────────────────────────────────

enum RhsType { constant, radical, linear, quadratic }

// ── Parsed problem representation ────────────────────────────────────────────

/// Holds every piece of information extracted by the parser so the
/// form-solvers never need to touch raw strings again.
class RadicalPrep {
  /// Original user-input string (untouched, for display).
  final String original;

  /// Inner radicand expression string, e.g. "2x+3".
  final String inner;

  /// Radicand coefficients: radicand = ia·x + ib.
  final double ia, ib;

  /// Effective operator after normalising √ to the left side.
  final String op;

  final RhsType rhsType;

  /// Raw RHS expression string (non-constant forms, used in step display).
  final String? rhsExpr;

  /// Constant RHS value (Form A/B only).
  final double? k;

  /// Linear / radical / quadratic RHS coefficients:
  ///   linear    → rc·x + rd
  ///   radical   → √(rc·x + rd)
  ///   quadratic → qe·x² + rc·x + rd
  final double? rc, rd, qe;

  const RadicalPrep({
    required this.original,
    required this.inner,
    required this.ia,
    required this.ib,
    required this.op,
    required this.rhsType,
    this.rhsExpr,
    this.k,
    this.rc,
    this.rd,
    this.qe,
  });
}

// ── Analytic interval model ───────────────────────────────────────────────────
//
// Represents one of six canonical interval shapes produced by the analytic
// quadratic solver. The numeric solver uses RadicalSpan instead.

enum IvKind { allReals, point, bounded, unbounded, halfLeft, halfRight }

class Iv {
  final IvKind kind;
  final double? lo, hi;
  final bool clo, chi; // closed-left / closed-right

  const Iv({
    required this.kind,
    this.lo,
    this.hi,
    this.clo = false,
    this.chi = false,
  });

  // ── factories ──────────────────────────────────────────────────────────────

  factory Iv.allReals() => const Iv(kind: IvKind.allReals);

  factory Iv.point(double x) =>
      Iv(kind: IvKind.point, lo: x, hi: x, clo: true, chi: true);

  factory Iv.bounded(double l, double h, bool closed) =>
      Iv(kind: IvKind.bounded, lo: l, hi: h, clo: closed, chi: closed);

  /// Represents (-∞, lo] ∪ [hi, ∞).
  /// lo = upper bound of left ray, hi = lower bound of right ray.
  factory Iv.unbounded(double l, double h, bool closed) =>
      Iv(kind: IvKind.unbounded, lo: l, hi: h, clo: closed, chi: closed);

  factory Iv.halfLine(double b, String op) {
    final closed = op == '≥' || op == '≤';
    return (op == '>' || op == '≥')
        ? Iv(kind: IvKind.halfRight, lo: b, clo: closed)
        : Iv(kind: IvKind.halfLeft, hi: b, chi: closed);
  }

  // ── rendering ──────────────────────────────────────────────────────────────

  String toNotation(String Function(double) f) {
    switch (kind) {
      case IvKind.allReals:
        return '(-∞, ∞)';
      case IvKind.point:
        return '{${f(lo!)}}';
      case IvKind.bounded:
        return '${clo ? '[' : '('}${f(lo!)}, ${f(hi!)}${chi ? ']' : ')'}';
      case IvKind.unbounded:
        return '(-∞, ${f(lo!)}${clo ? ']' : ')'} ∪ ${chi ? '[' : '('}${f(hi!)}, ∞)';
      case IvKind.halfLeft:
        // BUG FIX: original appended an extra ')' then used replaceAll('))',')')
        // as a workaround — that hack produced '(-∞, X])' when chi=true.
        // Correct form: just close with the bracket/paren, no trailing ')'.
        return '(-∞, ${f(hi!)}${chi ? ']' : ')'})';
      case IvKind.halfRight:
        return '${clo ? '[' : '('}${f(lo!)}, ∞)';
    }
  }

  String toAnswer(String Function(double) f) {
    switch (kind) {
      case IvKind.allReals:
        return 'All real numbers';
      case IvKind.point:
        return 'x = ${f(lo!)}';
      case IvKind.bounded:
        return '${f(lo!)} ${clo ? '≤' : '<'} x ${chi ? '≤' : '<'} ${f(hi!)}';
      case IvKind.unbounded:
        return 'x ${clo ? '≤' : '<'} ${f(lo!)} or x ${chi ? '≥' : '>'} ${f(hi!)}';
      case IvKind.halfLeft:
        return 'x ${chi ? '≤' : '<'} ${f(hi!)}';
      case IvKind.halfRight:
        return 'x ${clo ? '≥' : '>'} ${f(lo!)}';
    }
  }
}

// ── Numeric span ──────────────────────────────────────────────────────────────
//
// Used by the numeric solver (Form F/G: radical vs quadratic).

class RadicalSpan {
  final double lo, hi;
  final bool clo, chi;

  const RadicalSpan(this.lo, this.hi, this.clo, this.chi);

  RadicalSpan withChi(bool v) => RadicalSpan(lo, hi, clo, v);

  RadicalSpan extendTo(double newHi, bool newChi) =>
      RadicalSpan(lo, newHi, clo, newChi);

  RadicalSpan merge(RadicalSpan o) => RadicalSpan(
        math.min(lo, o.lo),
        math.max(hi, o.hi),
        lo <= o.lo ? clo : o.clo,
        hi >= o.hi ? chi : o.chi,
      );

  String toNotation(String Function(double) f) {
    final ls = lo.isInfinite ? '-∞' : f(lo);
    final hs = hi.isInfinite ? '∞' : f(hi);
    final lb = lo.isInfinite ? '(' : (clo ? '[' : '(');
    final rb = hi.isInfinite ? ')' : (chi ? ']' : ')');
    return '$lb$ls, $hs$rb';
  }

  String toAnswer(String Function(double) f) {
    if (lo == hi && clo && chi) return 'x = ${f(lo)}';
    final ls = lo.isInfinite ? null : f(lo);
    final hs = hi.isInfinite ? null : f(hi);
    if (ls == null) return 'x ${chi ? '≤' : '<'} ${hs!}';
    if (hs == null) return 'x ${clo ? '≥' : '>'} $ls';
    return '$ls ${clo ? '≤' : '<'} x ${chi ? '≤' : '<'} $hs';
  }
}
