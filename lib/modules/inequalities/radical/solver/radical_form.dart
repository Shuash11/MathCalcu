// radical_forms.dart
//
// Responsibility: solve each canonical radical-inequality form.
// One static method per form; all use RadicalHelpers for shared algorithms.

import 'dart:math' as math;

import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/modules/inequalities/core/inequality_core_solver.dart';

import 'radical_helpers.dart';
import 'radical_models.dart';

class RadicalForms {
  // ── Dispatcher ────────────────────────────────────────────────────────────

  static SolveResult solve(RadicalPrep p) {
    switch (p.rhsType) {
      case RhsType.constant:
        return _solveConstantRhs(p);
      case RhsType.radical:
        return _solveRadicalRhs(p);
      case RhsType.linear:
        return _solveLinearRhs(p);
      case RhsType.quadratic:
        return _solveQuadraticRhs(p);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Form A/B:  √(ia·x+ib)  op  k
  // ─────────────────────────────────────────────────────────────────────────

  static SolveResult _solveConstantRhs(RadicalPrep p) {
    final ia = p.ia, ib = p.ib, k = p.k!, op = p.op;
    const f = InequalityCoreSolver.fmt;

    // Constant radicand — evaluate directly.
    if (ia == 0) {
      if (ib < 0) return RadicalHelpers.noSolution();
      final sat = InequalityCoreSolver.evalOp(math.sqrt(ib), op, k);
      return sat ? RadicalHelpers.allReals() : RadicalHelpers.noSolution();
    }

    final domBound = -ib / ia;

    if (op == '<' || op == '≤') {
      if (k < 0) return RadicalHelpers.noSolution();
      if (k == 0) {
        return op == '<'
            ? RadicalHelpers.noSolution()
            : RadicalHelpers.singlePoint(domBound);
      }

      final k2 = k * k;
      final rawBound = (k2 - ib) / ia;
      final sqOp = ia > 0 ? op : InequalityCoreSolver.flipOp(op);

      if (ia > 0) {
        if (rawBound < domBound) return RadicalHelpers.noSolution();
        if (rawBound == domBound) {
          return sqOp == '<'
              ? RadicalHelpers.noSolution()
              : RadicalHelpers.singlePoint(domBound);
        }
        final rb = sqOp == '<' ? ')' : ']';
        return SolveResult(
          answer: '${f(domBound)} ≤ x $sqOp ${f(rawBound)}',
          points: [domBound, rawBound],
          intervalNotation: '[${f(domBound)}, ${f(rawBound)}$rb',
        );
      } else {
        if (rawBound > domBound) return RadicalHelpers.noSolution();
        if (rawBound == domBound) {
          return sqOp == '>'
              ? RadicalHelpers.noSolution()
              : RadicalHelpers.singlePoint(domBound);
        }
        final lb = sqOp == '>' ? '(' : '[';
        return SolveResult(
          answer: '${f(rawBound)} $sqOp x ≤ ${f(domBound)}',
          points: [rawBound, domBound],
          intervalNotation: '$lb${f(rawBound)}, ${f(domBound)}]',
        );
      }
    } else {
      // op is > or ≥
      if (k < 0) return RadicalHelpers.domainResult(ia, domBound);
      if (k == 0) {
        if (op == '≥') return RadicalHelpers.domainResult(ia, domBound);
        return ia > 0
            ? SolveResult(
                answer: 'x > ${f(domBound)}',
                points: [domBound],
                intervalNotation: '(${f(domBound)}, ∞)')
            : SolveResult(
                answer: 'x < ${f(domBound)}',
                points: [domBound],
                intervalNotation: '(-∞, ${f(domBound)})');
      }

      final k2 = k * k;
      final rawBound = (k2 - ib) / ia;
      final sqOp = ia > 0 ? op : InequalityCoreSolver.flipOp(op);

      if (ia > 0) {
        if (rawBound < domBound) {
          return RadicalHelpers.domainResult(ia, domBound);
        }
        final lb = sqOp == '>' ? '(' : '[';
        return SolveResult(
          answer: 'x $sqOp ${f(rawBound)}',
          points: [domBound, rawBound],
          intervalNotation: '$lb${f(rawBound)}, ∞)',
        );
      } else {
        if (rawBound > domBound) {
          return RadicalHelpers.domainResult(ia, domBound);
        }
        final rb = sqOp == '<' ? ')' : ']';
        return SolveResult(
          answer: 'x $sqOp ${f(rawBound)}',
          points: [rawBound, domBound],
          intervalNotation: '(-∞, ${f(rawBound)}$rb',
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Form E:  √(ia·x+ib)  op  √(rc·x+rd)
  // ─────────────────────────────────────────────────────────────────────────

  static SolveResult _solveRadicalRhs(RadicalPrep p) {
    final ia = p.ia, ib = p.ib, rc = p.rc!, rd = p.rd!, op = p.op;

    // Both sides ≥ 0 on combined domain → squaring preserves the inequality.
    // √(ia·x+ib) op √(rc·x+rd)  ⟺  ia·x+ib  op  rc·x+rd
    // Rearranged: (ia-rc)·x + (ib-rd)  op  0
    final la = ia - rc;
    final lb = ib - rd;

    final d1Bound = ia != 0 ? -ib / ia : double.negativeInfinity;
    final d2Bound = rc != 0 ? -rd / rc : double.negativeInfinity;

    String notation;
    List<double> points;

    if (la == 0) {
      final sat = InequalityCoreSolver.evalOp(lb.toDouble(), op, 0);
      if (!sat) return RadicalHelpers.noSolution();
      notation = RadicalHelpers.combinedDomainNotation(ia, ib, rc, rd);
      points = [if (ia != 0) d1Bound, if (rc != 0) d2Bound];
    } else {
      final linBound = -lb / la;
      final linOp = la > 0 ? op : InequalityCoreSolver.flipOp(op);
      notation = RadicalHelpers.intersectLinearWithDomains(
          linBound, linOp, ia, ib, rc, rd);
      points = [if (ia != 0) d1Bound, if (rc != 0) d2Bound, linBound]
          .where((v) => v.isFinite)
          .toSet()
          .toList()
        ..sort();
    }

    return SolveResult(
        answer: notation, points: points, intervalNotation: notation);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Form C/D:  √(ia·x+ib)  op  rc·x+rd
  // ─────────────────────────────────────────────────────────────────────────

  static SolveResult _solveLinearRhs(RadicalPrep p) {
    final ia = p.ia, ib = p.ib, rc = p.rc!, rd = p.rd!, op = p.op;

    final domBound = ia != 0 ? -ib / ia : double.negativeInfinity;
    final rhsZero = rc != 0 ? -rd / rc : double.infinity;

    if (op == '>' || op == '≥') {
      // Sub-case I : RHS < 0 → LHS ≥ 0 > RHS → auto-satisfied on domain ∩ {RHS<0}.
      final subI =
          RadicalHelpers.domainInterRhsNeg(ia, ib, rc, rd, strictOp: op == '>');
      // Sub-case II: RHS ≥ 0 → square both sides safely.
      final subII = RadicalHelpers.squaredLinearSolve(ia, ib, rc, rd, op);
      return RadicalHelpers.unionResults(subI, subII, [domBound, rhsZero]);
    } else {
      // < / ≤: LHS ≥ 0, so RHS must be ≥ 0. Restrict then square.
      return RadicalHelpers.squaredLinearSolve(ia, ib, rc, rd, op);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Form F/G:  √(ia·x+ib)  op  qe·x²+rc·x+rd
  // ─────────────────────────────────────────────────────────────────────────

  static SolveResult _solveQuadraticRhs(RadicalPrep p) {
    final ia = p.ia, ib = p.ib;
    final qe = p.qe!, rc = p.rc!, rd = p.rd!, op = p.op;

    final domBound = ia != 0 ? -ib / ia : double.negativeInfinity;
    final rhsRoots = RadicalHelpers.quadRoots(qe, rc, rd);

    if (op == '>' || op == '≥') {
      final subI = RadicalHelpers.domainInterQuadNeg(ia, ib, qe, rc, rd,
          strictOp: op == '>');
      final subII =
          _solveQuadRhsNumeric(ia, ib, qe, rc, rd, op, requireRhsNonNeg: true);
      return RadicalHelpers.unionResults(subI, subII, [domBound, ...rhsRoots]);
    } else {
      return _solveQuadRhsNumeric(ia, ib, qe, rc, rd, op,
          requireRhsNonNeg: true);
    }
  }

  // ── Numeric solver for Form F/G ───────────────────────────────────────────

  static SolveResult _solveQuadRhsNumeric(
      double ia, double ib, double qe, double rc, double rd, String op,
      {required bool requireRhsNonNeg}) {
    const f = InequalityCoreSolver.fmt;

    final domBound = ia != 0 ? -ib / ia : double.negativeInfinity;

    final crits = <double>{};
    if (ia != 0) crits.add(domBound);
    crits.addAll(RadicalHelpers.quadRoots(qe, rc, rd));
    crits.addAll(RadicalHelpers.numericIntersections(ia, ib, qe, rc, rd));

    final sorted = crits.where((x) => x.isFinite && x.abs() < 1e8).toList()
      ..sort();

    bool test(double x) {
      if (requireRhsNonNeg && qe * x * x + rc * x + rd < 0) return false;
      final radicand = ia * x + ib;
      if (radicand < 0) return false;
      return InequalityCoreSolver.evalOp(
          math.sqrt(radicand), op, qe * x * x + rc * x + rd);
    }

    bool boundaryIncluded(double x) => (op == '≤' || op == '≥') && test(x);

    final intervals = <RadicalSpan>[];

    void tryAdd(double lo, double hi, bool clo, bool chi) {
      if (lo > hi) return;
      intervals.add(RadicalSpan(lo, hi, clo, chi));
    }

    // Left ray.
    if (sorted.isNotEmpty && test(sorted.first - 1)) {
      tryAdd(double.negativeInfinity, sorted.first, false,
          boundaryIncluded(sorted.first));
    }

    for (int i = 0; i < sorted.length; i++) {
      final x = sorted[i];
      if (boundaryIncluded(x)) {
        if (intervals.isNotEmpty && intervals.last.hi == x) {
          intervals[intervals.length - 1] = intervals.last.withChi(true);
        } else {
          tryAdd(x, x, true, true);
        }
      }
      if (i < sorted.length - 1) {
        final mid = (sorted[i] + sorted[i + 1]) / 2;
        if (test(mid)) {
          final clo = boundaryIncluded(x);
          final chi = boundaryIncluded(sorted[i + 1]);
          if (intervals.isNotEmpty && intervals.last.hi == x) {
            intervals[intervals.length - 1] =
                intervals.last.extendTo(sorted[i + 1], chi);
          } else {
            tryAdd(x, sorted[i + 1], clo, chi);
          }
        }
      }
    }

    // Right ray.
    if (sorted.isNotEmpty && test(sorted.last + 1)) {
      final clo = boundaryIncluded(sorted.last);
      if (intervals.isNotEmpty && intervals.last.hi == sorted.last) {
        intervals[intervals.length - 1] =
            intervals.last.extendTo(double.infinity, false);
      } else {
        tryAdd(sorted.last, double.infinity, clo, false);
      }
    }

    if (sorted.isEmpty && test(0)) return RadicalHelpers.allReals();
    if (intervals.isEmpty) return RadicalHelpers.noSolution();

    final merged = RadicalHelpers.mergeSpans(intervals);
    final notation = merged.map((s) => s.toNotation(f)).join(' ∪ ');
    final answer = merged.map((s) => s.toAnswer(f)).join(' or ');

    return SolveResult(
        answer: answer, points: sorted, intervalNotation: notation);
  }
}
