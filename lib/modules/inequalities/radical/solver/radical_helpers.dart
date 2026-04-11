// radical_helpers.dart

import 'dart:math' as math;
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/modules/inequalities/core/inequality_core_solver.dart';
import 'radical_models.dart';

class RadicalHelpers {
  static SolveResult noSolution() => const SolveResult(
      answer: 'No solution', points: [], intervalNotation: '∅');

  static SolveResult allReals() => const SolveResult(
      answer: 'All real numbers', points: [], intervalNotation: '(-\\infty, \\infty)');

  static String formatIsolationLatex(double a, double b, String op) {
    const f = InequalityCoreSolver.fmt;
    final bMove = -b;
    final opL = op == '≥' ? '\\geq' : (op == '≤' ? '\\leq' : op);
    return '${f(a)}x + ${f(b)} $opL 0 \\quad \\Rightarrow \\quad ${f(a)}x $opL ${f(bMove)}';
  }

  static String expandLinearSquaredLatex(double a, double b) {
    const f = InequalityCoreSolver.fmt;
    final a2 = a * a;
    final ab2 = 2 * a * b;
    final b2 = b * b;
    final s1 = ab2 >= 0 ? '+' : '';
    final s2 = b2 >= 0 ? '+' : '';
    return '(${f(a)}x + ${f(b)})^2 = ${f(a2)}x^2 $s1 ${f(ab2)}x $s2 ${f(b2)}';
  }

  static SolveResult singlePoint(double x, {String? symbolic}) {
    final s = symbolic ?? InequalityCoreSolver.fmt(x);
    return SolveResult(answer: 'x = $s', points: [x], intervalNotation: '{$s}');
  }

  static SolveResult domainResult(double ia, double domBound,
      {String? symbolicBound}) {
    const f = InequalityCoreSolver.fmt;
    final span = ia > 0
        ? RadicalSpan(domBound, double.infinity, true, false, symbolicLo: symbolicBound)
        : RadicalSpan(double.negativeInfinity, domBound, false, true, symbolicHi: symbolicBound);

    return SolveResult(
      answer: span.toAnswer(f),
      points: [domBound],
      intervalNotation: span.toNotation(f),
      customData: [span],
    );
  }

  static SolveResult unionResults(
      SolveResult a, SolveResult b, List<double> pts) {
    if (a.intervalNotation == '∅' && b.intervalNotation == '∅') {
      return noSolution();
    }
    if (a.intervalNotation == '∅') return b;
    if (b.intervalNotation == '∅') return a;
    if (a.intervalNotation == '(-\\infty, \\infty)' || b.intervalNotation == '(-\\infty, \\infty)') {
      return allReals();
    }

    final allSpans = <RadicalSpan>[];
    if (a.customData != null) {
      allSpans.addAll(a.customData!.cast<RadicalSpan>());
    }
    if (b.customData != null) {
      allSpans.addAll(b.customData!.cast<RadicalSpan>());
    }

    if (allSpans.isEmpty) {
      final n = '${a.intervalNotation} ∪ ${b.intervalNotation}';
      return SolveResult(answer: n, points: pts, intervalNotation: n);
    }

    final merged = mergeSpans(allSpans);
    const f = InequalityCoreSolver.fmt;
    final notation = merged.map((s) => s.toNotation(f)).join(' ∪ ');
    final answer = merged.map((s) => s.toAnswer(f)).join(' or ');

    return SolveResult(
      answer: answer,
      points: pts,
      intervalNotation: notation,
      customData: merged,
    );
  }

  static Iv? solveQuadIneq(double qa, double qb, double qc, String op) {
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
    if (disc < 0) {
      final sat = qa > 0 ? (op == '>' || op == '≥') : (op == '<' || op == '≤');
      return sat ? Iv.allReals() : null;
    }

    final sqD = math.sqrt(disc);
    final r1 = (-qb - sqD) / (2 * qa);
    final r2 = (-qb + sqD) / (2 * qa);
    final lo = r1 < r2 ? r1 : r2;
    final hi = r1 < r2 ? r2 : r1;

    final symbolicLo = _formatSymbolicRoot(-qb, -sqD, 2 * qa);
    final symbolicHi = _formatSymbolicRoot(-qb, sqD, 2 * qa);

    if (disc == 0) {
      if (op == '<' || op == '>') {
        final sat = (op == '>') ? qa > 0 : qa < 0;
        return sat ? Iv.allReals() : null;
      }
      final vertexValue = qa > 0 ? (op == '≤') : (op == '≥');
      if (vertexValue) return Iv.point(-qb / (2 * qa), symbolic: symbolicLo);
      return Iv.allReals();
    }

    final isGreaterOp = op == '>' || op == '≥';
    final between = (qa > 0) != isGreaterOp;
    final strict = op == '<' || op == '>';

    return between
        ? Iv.bounded(lo, hi, !strict, symbolicLo: symbolicLo, symbolicHi: symbolicHi)
        : Iv.unbounded(lo, hi, !strict, symbolicLo: symbolicLo, symbolicHi: symbolicHi);
  }

  static String quadFormulaLatex(double a, double b, double c) {
    const f = InequalityCoreSolver.fmt;
    final bS = f(b), aS = f(a), cS = f(c);
    return 'x = \\frac{-($bS) \\pm \\sqrt{($bS)^2 - 4($aS)($cS)}}{2($aS)}';
  }

  static String? _formatSymbolicRoot(double num, double sqrtTerm, double den, {bool asLatex = false}) {
    if (den == 0) return null;
    double nVal = num, sVal = sqrtTerm, dVal = den;
    if (dVal < 0) { nVal = -nVal; sVal = -sVal; dVal = -dVal; }
    final disc = sVal * sVal;
    final discInt = disc.round();
    if (disc == discInt) {
      final sqrtInt = math.sqrt(discInt).round();
      if (sqrtInt * sqrtInt == discInt) return InequalityCoreSolver.fmt((nVal + sVal) / dVal);
    }
    final numInt = nVal.round(), denInt = dVal.round();
    if (asLatex) {
      final signS = sVal >= 0 ? '+' : '-';
      final absSqrt = sVal.abs().round();
      final sqrtPart = '\\sqrt{${absSqrt * absSqrt}}';
      if (nVal == 0) return denInt == 1 ? sqrtPart : '\\frac{$sqrtPart}{$denInt}';
      return '\\frac{${numInt.round()} $signS $sqrtPart}{$denInt}';
    }
    if (nVal == 0) {
      final discVal = (sVal * sVal).round();
      return denInt == 1 ? '√$discVal' : '√$discVal/$denInt';
    }
    final sign = sVal > 0 ? '+' : '-';
    final absNum = nVal.abs();
    final discVal = (sVal * sVal).round();
    if (nVal < 0) return '(-${absNum.round()} $sign √$discVal)/$denInt';
    return '($numInt $sign √$discVal)/$denInt';
  }

  static SolveResult domainInterRhsNeg(double ia, double ib, double rc, double rd, {required bool strictOp}) {
    const f = InequalityCoreSolver.fmt;
    if (rc == 0) {
      if (rd >= 0) return noSolution();
      return domainResult(ia, ia != 0 ? -ib / ia : 0);
    }
    final rhsZero = -rd / rc;
    double lo = double.negativeInfinity, hi = double.infinity;
    bool clo = false, chi = false;
    if (ia > 0) { lo = -ib / ia; clo = true; }
    else if (ia < 0) { hi = -ib / ia; chi = true; }
    if (rc > 0) { if (rhsZero < hi || (rhsZero == hi && chi)) { hi = rhsZero; chi = false; } }
    else { if (rhsZero > lo || (rhsZero == lo && clo)) { lo = rhsZero; clo = false; } }

    if (lo > hi || (lo == hi && (!clo || !chi))) return noSolution();
    final span = RadicalSpan(lo, hi, clo, chi);
    return SolveResult(answer: span.toAnswer(f), points: [if (lo.isFinite) lo, if (hi.isFinite) hi], intervalNotation: span.toNotation(f), customData: [span]);
  }

  static SolveResult domainInterQuadNeg(double ia, double ib, double qe, double rc, double rd, {required bool strictOp}) {
    final domBound = ia != 0 ? -ib / ia : double.negativeInfinity;
    final quadNegIv = solveQuadIneq(qe, rc, rd, '<');
    if (quadNegIv == null) return noSolution();
    final withDom = _intersectWithDomain(quadNegIv, domBound, ia > 0);
    if (withDom == null) return noSolution();
    const f = InequalityCoreSolver.fmt;
    final span = withDom.toSpan();
    return SolveResult(answer: span.toAnswer(f), points: [domBound], intervalNotation: span.toNotation(f), customData: [span]);
  }

  static Iv? _intersectWithDomain(Iv iv, double domBound, bool domainIsLower) {
    switch (iv.kind) {
      case IvKind.allReals: return domainIsLower ? Iv.halfLine(domBound, '≥') : Iv.halfLine(domBound, '≤');
      case IvKind.point:
        final x = iv.lo!;
        return (domainIsLower ? x >= domBound : x <= domBound) ? iv : null;
      case IvKind.bounded:
        double lo = iv.lo!, hi = iv.hi!; bool clo = iv.clo, chi = iv.chi;
        if (domainIsLower) {
          if (domBound > hi) return null;
          if (domBound > lo) { lo = domBound; clo = true; }
        } else {
          if (domBound < lo) return null;
          if (domBound < hi) { hi = domBound; chi = true; }
        }
        return Iv(kind: IvKind.bounded, lo: lo, hi: hi, clo: clo, chi: chi);
      case IvKind.unbounded:
        if (domainIsLower) {
          if (iv.hi! >= domBound) return Iv(kind: IvKind.halfRight, lo: math.max(iv.hi!, domBound), clo: true);
          return null;
        } else {
          if (iv.lo! <= domBound) return Iv(kind: IvKind.halfLeft, hi: math.min(iv.lo!, domBound), chi: true);
          return null;
        }
      case IvKind.halfLeft:
        double hi = iv.hi!; bool chi = iv.chi;
        if (!domainIsLower) {
          if (domBound < hi) { hi = domBound; chi = true; }
          return Iv(kind: IvKind.halfLeft, hi: hi, chi: chi);
        } else {
          if (domBound > hi) return null;
          return Iv(kind: IvKind.bounded, lo: domBound, hi: hi, clo: true, chi: chi);
        }
      case IvKind.halfRight:
        double lo = iv.lo!; bool clo = iv.clo;
        if (domainIsLower) {
          if (domBound > lo) { lo = domBound; clo = true; }
          return Iv(kind: IvKind.halfRight, lo: lo, clo: clo);
        } else {
          if (domBound < lo) return null;
          return Iv(kind: IvKind.bounded, lo: lo, hi: domBound, clo: clo, chi: true);
        }
    }
  }

  static List<double> quadRoots(double a, double b, double c) {
    if (a == 0) return b == 0 ? [] : [-c / b];
    final d = b * b - 4 * a * c;
    if (d < 0) return [];
    if (d == 0) return [-b / (2 * a)];
    final sq = math.sqrt(d);
    return [(-b - sq) / (2 * a), (-b + sq) / (2 * a)];
  }

  static List<double> numericIntersections(double ia, double ib, double qe, double rc, double rd) {
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
          final m = (a + b) / 2, fm = f(m);
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
    final out = <RadicalSpan>[spans.first];
    for (int i = 1; i < spans.length; i++) {
      final last = out.last; final cur = spans[i];
      bool canMerge = cur.lo < last.hi - 1e-9;
      if (!canMerge && (cur.lo - last.hi).abs() < 1e-9) canMerge = last.chi || cur.clo;
      if (canMerge) {
        out[out.length - 1] = last.merge(cur);
      } else {
        out.add(cur);
      }
    }
    return out;
  }

  static String combinedDomainNotation(double ia, double ib, double rc, double rd) {
    const f = InequalityCoreSolver.fmt;
    double lo = double.negativeInfinity, hi = double.infinity; bool clo = false, chi = false;
    if (ia > 0) { final b = -ib / ia; if (b > lo) { lo = b; clo = true; } }
    else if (ia < 0) { final b = -ib / ia; if (b < hi) { hi = b; chi = true; } }
    if (rc > 0) { final b = -rd / rc; if (b > lo) { lo = b; clo = true; } }
    else if (rc < 0) { final b = -rd / rc; if (b < hi) { hi = b; chi = true; } }
    if (lo > hi) return '∅';
    final lDec = lo.isInfinite ? '-∞' : f(lo);
    final hDec = hi.isInfinite ? '∞' : f(hi);
    return '${lo.isInfinite ? '(' : (clo ? '[' : '(')}$lDec, $hDec${hi.isInfinite ? ')' : (chi ? ']' : ')')}';
  }

  static String intersectLinearWithDomains(double linBound, String linOp, double ia, double ib, double rc, double rd) {
    const f = InequalityCoreSolver.fmt;
    double lo = double.negativeInfinity, hi = double.infinity; bool clo = false, chi = false;
    void applyLo(double b, bool c) { if (b > lo || (b == lo && !clo && c)) { lo = b; clo = c; } }
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
    final lDec = lo.isInfinite ? '-∞' : f(lo);
    final hDec = hi.isInfinite ? '∞' : f(hi);
    return '${lo.isInfinite ? '(' : (clo ? '[' : '(')}$lDec, $hDec${hi.isInfinite ? ')' : (chi ? ']' : ')')}';
  }
}
