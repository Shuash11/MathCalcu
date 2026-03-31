// radical_helpers.dart
//
// Responsibility: reusable mathematical utilities shared by all form-solvers.
// No form-specific logic lives here — only algorithms.

import 'dart:math' as math;
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/modules/inequalities/core/inequality_core_solver.dart';

import 'radical_models.dart';

class RadicalHelpers {
  // ── SolveResult convenience builders ─────────────────────────────────────

  static SolveResult noSolution() => const SolveResult(
      answer: 'No solution', points: [], intervalNotation: '∅');

  static SolveResult allReals() => const SolveResult(
      answer: 'All real numbers', points: [], intervalNotation: '(-∞, ∞)');

  static SolveResult singlePoint(double x) {
    final s = InequalityCoreSolver.fmt(x);
    return SolveResult(answer: 'x = $s', points: [x], intervalNotation: '{$s}');
  }

  static SolveResult domainResult(double ia, double domBound) {
    const f = InequalityCoreSolver.fmt;
    return ia > 0
        ? SolveResult(
            answer: 'x ≥ ${f(domBound)}',
            points: [domBound],
            intervalNotation: '[${f(domBound)}, ∞)')
        : SolveResult(
            answer: 'x ≤ ${f(domBound)}',
            points: [domBound],
            intervalNotation: '(-∞, ${f(domBound)}]');
  }

  static SolveResult ivToResult(Iv iv, List<double> pts) => SolveResult(
        answer: iv.toAnswer(InequalityCoreSolver.fmt),
        points: pts.where((x) => x.isFinite).toList(),
        intervalNotation: iv.toNotation(InequalityCoreSolver.fmt),
      );

  // ── Union of two sub-case results (sign-split) ────────────────────────────

  static SolveResult unionResults(
      SolveResult a, SolveResult b, List<double> pts) {
    if (a.intervalNotation == '∅' && b.intervalNotation == '∅') {
      return noSolution();
    }
    if (a.intervalNotation == '∅') return b;
    if (b.intervalNotation == '∅') return a;
    if (a.intervalNotation == '(-∞, ∞)' || b.intervalNotation == '(-∞, ∞)') {
      return allReals();
    }
    final n = '${a.intervalNotation} ∪ ${b.intervalNotation}';
    final allP = {...a.points, ...b.points, ...pts.where((x) => x.isFinite)}
        .toList()
      ..sort();
    return SolveResult(answer: n, points: allP, intervalNotation: n);
  }

  // ── Quadratic inequality:  qa·x² + qb·x + qc  op  0 ─────────────────────

  static Iv? solveQuadIneq(double qa, double qb, double qc, String op) {
    // Degenerate: linear
    if (qa == 0) {
      if (qb == 0) {
        final sat = InequalityCoreSolver.evalOp(qc, op, 0);
        return sat ? Iv.allReals() : null;
      }
      final x = -qc / qb;
      final flipOp = qb < 0 ? InequalityCoreSolver.flipOp(op) : op;
      return Iv.halfLine(x, flipOp);
    }

    final disc = qb * qb - 4 * qa * qc;

    // No real roots → sign is constant (sign of qa).
    if (disc < 0) {
      final sat = qa > 0 ? (op == '>' || op == '≥') : (op == '<' || op == '≤');
      return sat ? Iv.allReals() : null;
    }

    final sqD = math.sqrt(disc);
    final r1 = (-qb - sqD) / (2 * qa);
    final r2 = (-qb + sqD) / (2 * qa);
    final lo = r1 < r2 ? r1 : r2;
    final hi = r1 < r2 ? r2 : r1;

    // Repeated root → parabola touches axis at one point.
    if (disc == 0) {
      if (op == '<' || op == '>') {
        return null; // strictly never zero except at point
      }
      final insideIsNeg = qa > 0;
      if ((op == '≤') == insideIsNeg) return Iv.point(-qb / (2 * qa));
      return Iv.allReals();
    }

    final strict = op == '<' || op == '>';
    final between = (op == '<' || op == '≤') ? qa > 0 : qa < 0;

    return between
        ? Iv.bounded(lo, hi, !strict)
        : Iv.unbounded(lo, hi, !strict);
  }

  // ── Intersect an Iv with a half-line  x ≥ b  (rightward=true) or x ≤ b ──

  static Iv? intersectIvHalfLine(Iv iv, double b, bool rightward, bool closed) {
    if (!b.isFinite) return iv;

    switch (iv.kind) {
      case IvKind.allReals:
        final op2 = rightward ? (closed ? '≥' : '>') : (closed ? '≤' : '<');
        return Iv.halfLine(b, op2);

      case IvKind.point:
        final x = iv.lo!;
        final ok =
            rightward ? (closed ? x >= b : x > b) : (closed ? x <= b : x < b);
        return ok ? iv : null;

      case IvKind.bounded:
        double lo = iv.lo!, hi = iv.hi!;
        bool clo = iv.clo, chi = iv.chi;
        if (rightward) {
          if (lo < b || (lo == b && !closed)) {
            lo = b;
            clo = closed;
          }
        } else {
          if (hi > b || (hi == b && !closed)) {
            hi = b;
            chi = closed;
          }
        }
        if (lo > hi || (lo == hi && (!clo || !chi))) return null;
        return Iv(kind: IvKind.bounded, lo: lo, hi: hi, clo: clo, chi: chi);

      case IvKind.unbounded:
        // BUG FIX: original code assumed lp/hp were always non-null and used
        // their fields without null checks when reassembling into Iv.unbounded.
        // Now we handle each null arm explicitly.
        final lp = intersectIvHalfLine(
            Iv(kind: IvKind.halfLeft, hi: iv.lo, chi: iv.clo),
            b,
            rightward,
            closed);
        final hp = intersectIvHalfLine(
            Iv(kind: IvKind.halfRight, lo: iv.hi, clo: iv.chi),
            b,
            rightward,
            closed);
        if (lp == null && hp == null) return null;
        if (lp == null) return hp;
        if (hp == null) return lp;
        // Both survived — reassemble as unbounded (two-ray) interval.
        return Iv(
          kind: IvKind.unbounded,
          lo: lp.hi,
          clo: lp.chi,
          hi: hp.lo,
          chi: hp.clo,
        );

      case IvKind.halfLeft:
        double hi = iv.hi!;
        bool chi = iv.chi;
        if (!rightward) {
          if (hi > b || (hi == b && !closed)) {
            hi = b;
            chi = closed;
          }
          return Iv(kind: IvKind.halfLeft, hi: hi, chi: chi);
        } else {
          if (b > hi) return null;
          return Iv(kind: IvKind.bounded, lo: b, hi: hi, clo: closed, chi: chi);
        }

      case IvKind.halfRight:
        double lo = iv.lo!;
        bool clo = iv.clo;
        if (rightward) {
          if (lo < b || (lo == b && !closed)) {
            lo = b;
            clo = closed;
          }
          return Iv(kind: IvKind.halfRight, lo: lo, clo: clo);
        } else {
          if (b < lo) return null;
          return Iv(kind: IvKind.bounded, lo: lo, hi: b, clo: clo, chi: closed);
        }
    }
  }

  // ── Squared-linear helper ─────────────────────────────────────────────────
  //
  // Solves √(ia·x+ib) op rc·x+rd  on the region {RHS ≥ 0} by squaring.
  // Squaring: ia·x+ib  op  (rc·x+rd)²
  // Rearranged: (-rc²)x² + (ia-2·rc·rd)x + (ib-rd²)  op  0

  static SolveResult squaredLinearSolve(
      double ia, double ib, double rc, double rd, String op) {
    final qa = -rc * rc;
    final qb = ia - 2 * rc * rd;
    final qc = ib - rd * rd;

    final domBound = ia != 0 ? -ib / ia : double.negativeInfinity;
    final rhsZero = rc != 0 ? -rd / rc : double.infinity;

    final quadIv = solveQuadIneq(qa, qb, qc, op);
    if (quadIv == null) return noSolution();

    // Intersect with domain: ia·x+ib ≥ 0.
    final withDom = intersectIvHalfLine(quadIv, domBound, ia > 0, true);
    if (withDom == null) return noSolution();

    // Intersect with {RHS ≥ 0}: rc·x+rd ≥ 0.
    if (rc != 0) {
      final withRhs = intersectIvHalfLine(withDom, rhsZero, rc > 0, true);
      if (withRhs == null) return noSolution();
      return ivToResult(withRhs, [domBound, rhsZero]);
    }

    return ivToResult(withDom, [domBound]);
  }

  // ── Domain ∩ {linear RHS < 0}  (sign-split sub-case I) ───────────────────

  static SolveResult domainInterRhsNeg(
      double ia, double ib, double rc, double rd,
      {required bool strictOp}) {
    const f = InequalityCoreSolver.fmt;

    if (rc == 0) {
      if (rd >= 0) return noSolution();
      return domainResult(ia, ia != 0 ? -ib / ia : 0);
    }

    final rhsZero = -rd / rc;
    double lo = double.negativeInfinity, hi = double.infinity;
    bool clo = false, chi = false;

    // Apply domain.
    if (ia > 0) {
      lo = -ib / ia;
      clo = true;
    } else if (ia < 0) {
      hi = -ib / ia;
      chi = true;
    }

    // Apply {rc·x+rd < 0}.
    if (rc > 0) {
      // x < rhsZero
      if (rhsZero < hi || (rhsZero == hi && chi)) {
        hi = rhsZero;
        chi = false;
      }
    } else {
      // x > rhsZero
      if (rhsZero > lo || (rhsZero == lo && clo)) {
        lo = rhsZero;
        clo = false;
      }
    }

    if (lo > hi || (lo == hi && (!clo || !chi))) return noSolution();

    final loS = lo.isInfinite ? '-∞' : f(lo);
    final hiS = hi.isInfinite ? '∞' : f(hi);
    final lb = lo.isInfinite ? '(' : (clo ? '[' : '(');
    final rb = hi.isInfinite ? ')' : (chi ? ']' : ')');
    final n = '$lb$loS, $hiS$rb';
    return SolveResult(
      answer: n,
      points: [if (lo.isFinite) lo, if (hi.isFinite) hi],
      intervalNotation: n,
    );
  }

  // ── Domain ∩ {quadratic RHS < 0}  (sign-split sub-case I) ────────────────

  static SolveResult domainInterQuadNeg(
      double ia, double ib, double qe, double rc, double rd,
      {required bool strictOp}) {
    final domBound = ia != 0 ? -ib / ia : double.negativeInfinity;

    final quadNegIv = solveQuadIneq(qe, rc, rd, '<');
    if (quadNegIv == null) return noSolution();

    final withDom = intersectIvHalfLine(quadNegIv, domBound, ia > 0, true);
    if (withDom == null) return noSolution();

    return ivToResult(withDom, [domBound]);
  }

  // ── Numeric helpers ───────────────────────────────────────────────────────

  static List<double> quadRoots(double a, double b, double c) {
    if (a == 0) {
      if (b == 0) return [];
      return [-c / b];
    }
    final d = b * b - 4 * a * c;
    if (d < 0) return [];
    if (d == 0) return [-b / (2 * a)];
    final sq = math.sqrt(d);
    return [(-b - sq) / (2 * a), (-b + sq) / (2 * a)];
  }

  /// Find x where √(ia·x+ib) = qe·x²+rc·x+rd via bisection.
  static List<double> numericIntersections(
      double ia, double ib, double qe, double rc, double rd) {
    double f(double x) {
      final rad = ia * x + ib;
      if (rad < 0) return double.nan;
      return math.sqrt(rad) - (qe * x * x + rc * x + rd);
    }

    const xLo = -1000.0, xHi = 1000.0, steps = 10000;
    final roots = <double>[];
    const dx = (xHi - xLo) / steps;

    for (int i = 0; i < steps; i++) {
      final x0 = xLo + i * dx, x1 = x0 + dx;
      final f0 = f(x0), f1 = f(x1);
      if (f0.isNaN || f1.isNaN) continue;
      if (f0 * f1 <= 0) {
        double a = x0, b = x1;
        for (int j = 0; j < 50; j++) {
          final m = (a + b) / 2;
          final fm = f(m);
          if (fm.isNaN) break;
          if (f(a) * fm <= 0) {
            b = m;
          } else {
            a = m;
          }
        }
        final r = (a + b) / 2;
        if (roots.isEmpty || (r - roots.last).abs() > 1e-6) roots.add(r);
      }
    }
    return roots;
  }

  static List<RadicalSpan> mergeSpans(List<RadicalSpan> spans) {
    if (spans.isEmpty) return spans;
    spans.sort((a, b) => a.lo.compareTo(b.lo));
    final out = [spans.first];
    for (int i = 1; i < spans.length; i++) {
      final last = out.last, cur = spans[i];
      if (cur.lo <= last.hi + 1e-9) {
        out[out.length - 1] = last.merge(cur);
      } else {
        out.add(cur);
      }
    }
    return out;
  }

  // ── Combined domain notation helpers (radical vs radical) ─────────────────

  static String combinedDomainNotation(
      double ia, double ib, double rc, double rd) {
    const f = InequalityCoreSolver.fmt;
    double lo = double.negativeInfinity, hi = double.infinity;
    bool clo = false, chi = false;

    if (ia > 0) {
      final b = -ib / ia;
      if (b > lo) {
        lo = b;
        clo = true;
      }
    } else if (ia < 0) {
      final b = -ib / ia;
      if (b < hi) {
        hi = b;
        chi = true;
      }
    }
    if (rc > 0) {
      final b = -rd / rc;
      if (b > lo) {
        lo = b;
        clo = true;
      }
    } else if (rc < 0) {
      final b = -rd / rc;
      if (b < hi) {
        hi = b;
        chi = true;
      }
    }

    if (lo > hi) return '∅';
    final loS = lo.isInfinite ? '-∞' : f(lo);
    final hiS = hi.isInfinite ? '∞' : f(hi);
    final lb = lo.isInfinite ? '(' : (clo ? '[' : '(');
    final rb = hi.isInfinite ? ')' : (chi ? ']' : ')');
    return '$lb$loS, $hiS$rb';
  }

  static String intersectLinearWithDomains(double linBound, String linOp,
      double ia, double ib, double rc, double rd) {
    const f = InequalityCoreSolver.fmt;
    double lo = double.negativeInfinity, hi = double.infinity;
    bool clo = false, chi = false;

    void applyLo(double b, bool c) {
      if (b > lo || (b == lo && !clo && c)) {
        lo = b;
        clo = c;
      }
    }

    void applyHi(double b, bool c) {
      if (b < hi || (b == hi && !chi && c)) {
        hi = b;
        chi = c;
      }
    }

    if (ia > 0) {
      applyLo(-ib / ia, true);
    } else if (ia < 0) {
      applyHi(-ib / ia, true);
    }
    if (rc > 0) {
      applyLo(-rd / rc, true);
    } else if (rc < 0) {
      applyHi(-rd / rc, true);
    }

    final cl = linOp == '≥' || linOp == '≤';
    if (linOp == '>' || linOp == '≥') {
      applyLo(linBound, cl);
    } else {
      applyHi(linBound, cl);
    }

    if (lo > hi || (lo == hi && (!clo || !chi))) return '∅';
    final loS = lo.isInfinite ? '-∞' : f(lo);
    final hiS = hi.isInfinite ? '∞' : f(hi);
    final lb = lo.isInfinite ? '(' : (clo ? '[' : '(');
    final rb = hi.isInfinite ? ')' : (chi ? ']' : ')');
    return '$lb$loS, $hiS$rb';
  }
}
