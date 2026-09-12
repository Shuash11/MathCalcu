// ─────────────────────────────────────────────────────────────
// INTEREST — SHS GenMath. Simple / compound / annuity FV / loan
// amortization payment. e.g. 'P=10000 r=5% t=2 compound'. Pesos.
// ─────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

class InterestEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  InterestEquation(this.rawInput);

  String? _mode() {
    final t = rawInput.toLowerCase();
    if (t.contains('annuity')) return 'annuity';
    if (t.contains('loan') || t.contains('amort') || t.contains('payment')) {
      return 'loan';
    }
    if (t.contains('compound')) return 'compound';
    if (t.contains('simple')) return 'simple';
    // Default: compound when r + t present.
    if (t.contains('r') && t.contains('t')) return 'compound';
    return null;
  }

  double? _param(List<String> names) {
    final t = rawInput.toLowerCase().replaceAll('−', '-');
    for (final n in names) {
      final m = RegExp('$n\\s*=\\s*(-?\\d+(?:\\.\\d+)?)')
          .firstMatch(t);
      if (m != null) return double.parse(m.group(1)!);
    }
    return null;
  }

  double? _rate() {
    final t = rawInput.toLowerCase();
    // Prefer an explicit per-period 'i =' (annuity/loan) over 'r ='.
    final i = RegExp(r'\bi\s*=\s*(-?\d+(?:\.\d+)?)\s*(%?)').firstMatch(t);
    if (i != null) {
      var v = double.parse(i.group(1)!);
      if (i.group(2) == '%' || v.abs() > 1) v /= 100;
      return v;
    }
    final m = RegExp(r'\br\s*=\s*(-?\d+(?:\.\d+)?)\s*(%?)').firstMatch(t);
    if (m == null) return null;
    var v = double.parse(m.group(1)!);
    if (m.group(2) == '%' || v.abs() > 1) v /= 100;
    return v;
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(
        rawInput, example: 'P = 10000, r = 5%, t = 2, compound');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_mode() == null) {
      _error = 'Add a mode: simple, compound, annuity, or loan.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final mode = _mode();
    if (mode == null) {
      return SolveResult.error(_error ?? 'Add a mode: simple/compound/annuity/loan.');
    }
    final p = _param(['p']);
    final r = _rate();
    final t = _param(['t', 'n']);
    if (mode == 'simple') {
      if (p == null || r == null || t == null) {
        return SolveResult.error('Simple needs P, r, t — e.g. P = 10000, r = 5%, t = 2, simple.');
      }
      if (p < 0 || t < 0) return SolveResult.error('P and t must be ≥ 0.');
      final i = p * r * t;
      return SolveResult(
        answer: 'Interest = ${G6Format.money(i)}, Total = ${G6Format.money(p + i)}',
        points: [i, p + i],
        customData: [
          {'kind': 'interest', 'mode': 'simple', 'interest': i, 'total': p + i}
        ],
      );
    }
    if (mode == 'compound') {
      if (p == null || r == null || t == null) {
        return SolveResult.error('Compound needs P, r, t — e.g. P = 10000, r = 5%, t = 2, compound.');
      }
      if (p < 0 || t < 0) return SolveResult.error('P and t must be ≥ 0.');
      final m = _param(['m']);
      final freq = m ?? 1;
      if (freq <= 0 || freq != freq.roundToDouble()) {
        return SolveResult.error('m (compounds/year) must be a positive whole number.');
      }
      final fv = p * math.pow(1 + r / freq, freq * t);
      if (!fv.isFinite) return SolveResult.error('Value overflows.');
      return SolveResult(
        answer: 'FV = ${G6Format.money(fv.toDouble())}  (P(1 + r/m)^mt)',
        points: [fv.toDouble()],
        customData: [
          {'kind': 'interest', 'mode': 'compound', 'fv': fv, 'freq': freq}
        ],
      );
    }
    if (mode == 'annuity') {
      final pay = _param(['r', 'pmt', 'p']);
      final i = _rate();
      final n = _param(['n', 't']);
      if (pay == null || i == null || n == null) {
        return SolveResult.error('Annuity needs R, i, n — e.g. R = 1000, i = 1%, n = 12, annuity.');
      }
      if (n <= 0 || n != n.roundToDouble()) {
        return SolveResult.error('n must be a positive whole number.');
      }
      if (i.abs() < 1e-12) {
        final fv = pay * n;
        return SolveResult(
          answer: 'FV = ${G6Format.money(fv)} (i = 0)',
          points: [fv],
          customData: [
            {'kind': 'interest', 'mode': 'annuity', 'fv': fv}
          ],
        );
      }
      final fv = pay * (math.pow(1 + i, n) - 1) / i;
      final pv = pay * (1 - math.pow(1 + i, -n)) / i;
      if (!fv.isFinite || !pv.isFinite) {
        return SolveResult.error('Value overflows.');
      }
      return SolveResult(
        answer:
            'FV = ${G6Format.money(fv.toDouble())}, PV = ${G6Format.money(pv.toDouble())}',
        points: [fv.toDouble(), pv.toDouble()],
        customData: [
          {'kind': 'interest', 'mode': 'annuity', 'fv': fv, 'pv': pv}
        ],
      );
    }
    // Loan payment: loan L=..., i=..., n=... -> PMT.
    final loan = _param(['l', 'p']);
    final i = _rate();
    final n = _param(['n', 't']);
    if (loan == null || i == null || n == null) {
      return SolveResult.error('Loan needs L, i, n — e.g. loan L = 100000, i = 1%, n = 12.');
    }
    if (n <= 0 || n != n.roundToDouble()) {
      return SolveResult.error('n must be a positive whole number.');
    }
    if (loan < 0) return SolveResult.error('Loan amount must be ≥ 0.');
    double pmt;
    if (i.abs() < 1e-12) {
      pmt = loan / n;
    } else {
      pmt = loan * i / (1 - math.pow(1 + i, -n));
    }
    if (!pmt.isFinite) return SolveResult.error('Value overflows.');
    return SolveResult(
      answer: 'Payment = ${G6Format.money(pmt.toDouble())} per period',
      points: [pmt.toDouble()],
      customData: [
        {'kind': 'interest', 'mode': 'loan', 'payment': pmt, 'total': pmt * n}
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final mode = _mode();
    if (mode == null) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: _error ?? 'Add simple/compound/annuity/loan.')
      ];
    }
    final r = solve();
    final formula = mode == 'simple'
        ? 'I = Prt, F = P + I'
        : mode == 'compound'
            ? 'F = P(1 + r/m)^(mt)'
            : mode == 'annuity'
                ? 'FV = R[((1+i)^n − 1)/i], PV = R[(1 − (1+i)^−n)/i]'
                : 'PMT = Li/(1 − (1+i)^−n)';
    return [
      StepModel(stepNumber: 1, title: 'Formula', explanation: formula),
      const StepModel(
          stepNumber: 2, title: 'Rate as decimal', explanation: '5% → 0.05.'),
      StepModel(stepNumber: 3, title: 'Substitute + compute', explanation: r.answer),
    ];
  }
}
