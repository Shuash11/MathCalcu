// radical_forms.dart
//
// Shared logic for solving different forms of radical inequalities.
// This file focuses on the mathematical cases (Linear on RHS, Constant on RHS, etc.)

import 'dart:math' as math;
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/modules/inequalities/core/inequality_core_solver.dart';
import 'radical_helpers.dart';
import 'radical_models.dart';

class RadicalForms {
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

  static SolveResult _solveConstantRhs(RadicalPrep p) {
    final ia = p.ia, ib = p.ib, k = p.k!, op = p.op;
    const f = InequalityCoreSolver.fmt;

    if (ia == 0) {
      if (ib < 0) return RadicalHelpers.noSolution();
      final sat = InequalityCoreSolver.evalOp(math.sqrt(ib), op, k);
      return sat ? RadicalHelpers.allReals() : RadicalHelpers.noSolution();
    }

    final domBound = -ib / ia;

    if (k < 0) {
      if (op == '>' || op == '≥') {
        return RadicalHelpers.domainResult(ia, domBound);
      } else {
        return RadicalHelpers.noSolution();
      }
    }

    final k2 = k * k;
    final rawBound = (k2 - ib) / ia;

    if (ia > 0) {
      if (op == '>' || op == '≥') {
        if (rawBound < domBound) {
          return RadicalHelpers.domainResult(ia, domBound);
        }
        final strict = op == '>';
        return _buildResult(rawBound, double.infinity, !strict, false, f);
      } else {
        if (rawBound < domBound) return RadicalHelpers.noSolution();
        if ((rawBound - domBound).abs() < 1e-9) {
          return op == '<'
              ? RadicalHelpers.noSolution()
              : RadicalHelpers.singlePoint(domBound);
        }
        final strict = op == '<';
        return _buildResult(domBound, rawBound, true, !strict, f);
      }
    } else {
      if (op == '>' || op == '≥') {
        if (rawBound > domBound) {
          return RadicalHelpers.domainResult(ia, domBound);
        }
        final strict = op == '>';
        return _buildResult(
            double.negativeInfinity, rawBound, false, !strict, f);
      } else {
        if (rawBound > domBound) return RadicalHelpers.noSolution();
        if ((rawBound - domBound).abs() < 1e-9) {
          return op == '<'
              ? RadicalHelpers.noSolution()
              : RadicalHelpers.singlePoint(domBound);
        }
        final strict = op == '<';
        return _buildResult(rawBound, domBound, !strict, true, f);
      }
    }
  }

  static SolveResult _solveRadicalRhs(RadicalPrep p) {
    final ia = p.ia, ib = p.ib, rc = p.rc!, rd = p.rd!, op = p.op;

    final la = ia - rc;
    final lb = ib - rd;

    if (la == 0) {
      final sat = InequalityCoreSolver.evalOp(lb.toDouble(), op, 0);
      if (!sat) return RadicalHelpers.noSolution();
      final notation = RadicalHelpers.combinedDomainNotation(ia, ib, rc, rd);
      // Hard to get spans for combined domain notation in one go, but we can try
      return SolveResult(
          answer: notation, points: [], intervalNotation: notation);
    } else {
      final linBound = -lb / la;
      final linOp = la > 0 ? op : InequalityCoreSolver.flipOp(op);
      final notation = RadicalHelpers.intersectLinearWithDomains(
          linBound, linOp, ia, ib, rc, rd);
      return SolveResult(
          answer: notation, points: [linBound], intervalNotation: notation);
    }
  }

  static SolveResult _solveLinearRhs(RadicalPrep p) {
    final ia = p.ia, ib = p.ib, rc = p.rc!, rd = p.rd!, op = p.op;
    final wasFlipped = p.wasFlipped;
    const f = InequalityCoreSolver.fmt;

    final domBound = ia != 0 ? -ib / ia : double.negativeInfinity;
    final rhsZero = rc != 0 ? -rd / rc : double.infinity;

    final originalOp = wasFlipped ? InequalityCoreSolver.flipOp(op) : op;

    final bool rhsNegAutoSatisfies = wasFlipped
        ? (originalOp == '<' || originalOp == '≤')
        : (op == '>' || op == '≥');

    SolveResult rhsNegResult;
    if (rhsNegAutoSatisfies) {
      rhsNegResult = RadicalHelpers.domainInterRhsNeg(ia, ib, rc, rd,
          strictOp: wasFlipped ? (originalOp == '<') : (op == '>'));
    } else {
      rhsNegResult = RadicalHelpers.noSolution();
    }

    final qa = -rc * rc;
    final qb = ia - 2 * rc * rd;
    final qc = ib - rd * rd;
    final quadIv = RadicalHelpers.solveQuadIneq(qa, qb, qc, op);
    if (quadIv == null) {
      return rhsNegResult;
    }
    final squaredResult = _intersectAndBuild(
      quadIv,
      ia,
      domBound,
      rc,
      rhsZero,
      f,
    );

    return RadicalHelpers.unionResults(
        rhsNegResult, squaredResult, [domBound, rhsZero]);
  }

  static SolveResult _intersectAndBuild(
    Iv iv,
    double ia,
    double domBound,
    double rc,
    double rhsZero,
    String Function(double) f,
  ) {
    switch (iv.kind) {
      case IvKind.allReals:
        return _handleAllReals(ia, domBound, rc, rhsZero, f);
      case IvKind.point:
        return _handlePoint(iv, ia, domBound, rc, rhsZero, f);
      case IvKind.bounded:
        return _handleBounded(iv, ia, domBound, rc, rhsZero, f);
      case IvKind.unbounded:
        return _handleUnbounded(iv, ia, domBound, rc, rhsZero, f);
      case IvKind.halfLeft:
        return _handleHalfLeft(iv, ia, domBound, rc, rhsZero, f);
      case IvKind.halfRight:
        return _handleHalfRight(iv, ia, domBound, rc, rhsZero, f);
    }
  }

  static SolveResult _handleAllReals(double ia, double domBound, double rc,
      double rhsZero, String Function(double) f) {
    double lo = double.negativeInfinity, hi = double.infinity;
    bool clo = false, chi = false;

    if (ia > 0) {
      lo = domBound;
      clo = true;
    } else if (ia < 0) {
      hi = domBound;
      chi = true;
    }

    if (rc > 0) {
      if (rhsZero > lo || (rhsZero == lo && !clo)) {
        lo = rhsZero;
        clo = true;
      }
    } else if (rc < 0) {
      if (rhsZero < hi || (rhsZero == hi && !chi)) {
        hi = rhsZero;
        chi = true;
      }
    }

    if (lo > hi || (lo == hi && (!clo || !chi))) {
      return RadicalHelpers.noSolution();
    }
    return _buildResult(lo, hi, clo, chi, f);
  }

  static SolveResult _handlePoint(Iv iv, double ia, double domBound, double rc,
      double rhsZero, String Function(double) f) {
    final x = iv.lo!;
    if (ia > 0 && x < domBound - 1e-9) return RadicalHelpers.noSolution();
    if (ia < 0 && x > domBound + 1e-9) return RadicalHelpers.noSolution();
    if (rc > 0 && x < rhsZero - 1e-9) return RadicalHelpers.noSolution();
    if (rc < 0 && x > rhsZero + 1e-9) return RadicalHelpers.noSolution();
    return RadicalHelpers.singlePoint(x, symbolic: iv.symbolicLo);
  }

  static SolveResult _handleBounded(Iv iv, double ia, double domBound,
      double rc, double rhsZero, String Function(double) f) {
    double lo = iv.lo!, hi = iv.hi!;
    bool clo = iv.clo, chi = iv.chi;
    String? symLo = iv.symbolicLo, symHi = iv.symbolicHi;

    if (ia > 0) {
      if (domBound > hi + 1e-9) return RadicalHelpers.noSolution();
      if (domBound > lo - 1e-9) {
        lo = domBound;
        clo = true;
        symLo = null;
      }
    } else if (ia < 0) {
      if (domBound < lo - 1e-9) return RadicalHelpers.noSolution();
      if (domBound < hi + 1e-9) {
        hi = domBound;
        chi = true;
        symHi = null;
      }
    }

    if (rc > 0) {
      if (rhsZero > hi + 1e-9) return RadicalHelpers.noSolution();
      if (rhsZero > lo - 1e-9) {
        lo = rhsZero;
        clo = true;
        symLo = null;
      }
    } else if (rc < 0) {
      if (rhsZero < lo - 1e-9) return RadicalHelpers.noSolution();
      if (rhsZero < hi + 1e-9) {
        hi = rhsZero;
        chi = true;
        symHi = null;
      }
    }

    return _buildResult(lo, hi, clo, chi, f, symLo: symLo, symHi: symHi);
  }

  static SolveResult _handleUnbounded(Iv iv, double ia, double domBound,
      double rc, double rhsZero, String Function(double) f) {
    final leftRay = _intersectRay(double.negativeInfinity, iv.lo!, false,
        iv.clo, ia, domBound, rc, rhsZero, f,
        symHi: iv.symbolicLo);
    final rightRay = _intersectRay(
        iv.hi!, double.infinity, iv.chi, false, ia, domBound, rc, rhsZero, f,
        symLo: iv.symbolicHi);

    if (leftRay != null && rightRay != null) {
      return RadicalHelpers.unionResults(leftRay, rightRay, []);
    }
    return leftRay ?? rightRay ?? RadicalHelpers.noSolution();
  }

  static SolveResult _handleHalfLeft(Iv iv, double ia, double domBound,
      double rc, double rhsZero, String Function(double) f) {
    double hi = iv.hi!;
    bool chi = iv.chi;
    String? symHi = iv.symbolicHi;

    if (ia < 0 && domBound < hi + 1e-9) {
      hi = domBound;
      chi = true;
      symHi = null;
    }
    if (rc > 0) {
      if (rhsZero > hi + 1e-9) return RadicalHelpers.noSolution();
      return _buildResult(rhsZero, hi, true, chi, f, symHi: symHi);
    } else if (rc < 0) {
      if (rhsZero < hi + 1e-9) {
        hi = rhsZero;
        chi = true;
        symHi = null;
      }
    }
    return _buildResult(double.negativeInfinity, hi, false, chi, f,
        symHi: symHi);
  }

  static SolveResult _handleHalfRight(Iv iv, double ia, double domBound,
      double rc, double rhsZero, String Function(double) f) {
    double lo = iv.lo!;
    bool clo = iv.clo;
    String? symLo = iv.symbolicLo;

    if (ia > 0 && domBound > lo - 1e-9) {
      lo = domBound;
      clo = true;
      symLo = null;
    }
    if (rc > 0 && rhsZero > lo - 1e-9) {
      lo = rhsZero;
      clo = true;
      symLo = null;
    } else if (rc < 0) {
      if (rhsZero < lo - 1e-9) return RadicalHelpers.noSolution();
      return _buildResult(lo, rhsZero, clo, true, f, symLo: symLo);
    }
    return _buildResult(lo, double.infinity, clo, false, f, symLo: symLo);
  }

  static SolveResult? _intersectRay(
      double rayLo,
      double rayHi,
      bool rayClo,
      bool rayChi,
      double ia,
      double domBound,
      double rc,
      double rhsZero,
      String Function(double) f,
      {String? symLo,
      String? symHi}) {
    double lo = rayLo, hi = rayHi;
    bool clo = rayClo, chi = rayChi;
    String? sLo = symLo, sHi = symHi;

    if (ia > 0) {
      if (domBound > hi + 1e-9) return null;
      if (domBound > lo - 1e-9) {
        lo = domBound;
        clo = true;
        sLo = null;
      }
    } else if (ia < 0) {
      if (domBound < lo - 1e-9) return null;
      if (domBound < hi + 1e-9) {
        hi = domBound;
        chi = true;
        sHi = null;
      }
    }
    if (rc > 0) {
      if (rhsZero > hi + 1e-9) return null;
      if (rhsZero > lo - 1e-9) {
        lo = rhsZero;
        clo = true;
        sLo = null;
      }
    } else if (rc < 0) {
      if (rhsZero < lo - 1e-9) return null;
      if (rhsZero < hi + 1e-9) {
        hi = rhsZero;
        chi = true;
        sHi = null;
      }
    }

    if (lo > hi + 1e-9 || (lo == hi && (!clo || !chi))) return null;
    return _buildResult(lo, hi, clo, chi, f, symLo: sLo, symHi: sHi);
  }

  static SolveResult _buildResult(
      double lo, double hi, bool clo, bool chi, String Function(double) f,
      {String? symLo, String? symHi}) {
    final span =
        RadicalSpan(lo, hi, clo, chi, symbolicLo: symLo, symbolicHi: symHi);
    return SolveResult(
      answer: span.toAnswer(f),
      points: [if (lo.isFinite) lo, if (hi.isFinite) hi],
      intervalNotation: span.toNotation(f),
      customData: [span],
    );
  }

  static SolveResult _solveQuadraticRhs(RadicalPrep p) {
    // Already uses unionResults which respects spans
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
      if (requireRhsNonNeg && qe * x * x + rc * x + rd < -1e-9) return false;
      final radicand = ia * x + ib;
      if (radicand < -1e-9) return false;
      return InequalityCoreSolver.evalOp(
          math.sqrt(math.max(0, radicand)), op, qe * x * x + rc * x + rd);
    }

    bool boundaryIncluded(double x) => (op == '≤' || op == '≥') && test(x);
    final intervals = <RadicalSpan>[];

    if (sorted.isNotEmpty && test(sorted.first - 1)) {
      intervals.add(RadicalSpan(double.negativeInfinity, sorted.first, false,
          boundaryIncluded(sorted.first)));
    }
    for (int i = 0; i < sorted.length; i++) {
      final x = sorted[i];
      if (boundaryIncluded(x)) {
        if (intervals.isNotEmpty && (intervals.last.hi - x).abs() < 1e-9) {
          intervals[intervals.length - 1] = intervals.last.withChi(true);
        } else {
          intervals.add(RadicalSpan(x, x, true, true));
        }
      }
      if (i < sorted.length - 1) {
        if (test((sorted[i] + sorted[i + 1]) / 2)) {
          final clo = boundaryIncluded(x);
          final chi = boundaryIncluded(sorted[i + 1]);
          if (intervals.isNotEmpty && (intervals.last.hi - x).abs() < 1e-9) {
            intervals[intervals.length - 1] =
                intervals.last.extendTo(sorted[i + 1], chi);
          } else {
            intervals.add(RadicalSpan(x, sorted[i + 1], clo, chi));
          }
        }
      }
    }
    if (sorted.isNotEmpty && test(sorted.last + 1)) {
      final clo = boundaryIncluded(sorted.last);
      if (intervals.isNotEmpty &&
          (intervals.last.hi - sorted.last).abs() < 1e-9) {
        intervals[intervals.length - 1] =
            intervals.last.extendTo(double.infinity, false);
      } else {
        intervals.add(RadicalSpan(sorted.last, double.infinity, clo, false));
      }
    }

    if (sorted.isEmpty && test(0)) return RadicalHelpers.allReals();
    if (intervals.isEmpty) return RadicalHelpers.noSolution();

    final merged = RadicalHelpers.mergeSpans(intervals);
    final notation = merged.map((s) => s.toNotation(f)).join(' ∪ ');
    final answer = merged.map((s) => s.toAnswer(f)).join(' or ');

    return SolveResult(
        answer: answer,
        points: sorted,
        intervalNotation: notation,
        customData: merged);
  }
}
