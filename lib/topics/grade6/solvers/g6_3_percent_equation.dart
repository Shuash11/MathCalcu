// ─────────────────────────────────────────────────────────────
// G6-3 PERCENT — P = R × B triad + discount / tax / simple interest.
// DepEd M6NS-Ic-131. Reuses CalculatorEngine for the final multiply.
// Offline, pure Dart. hintText: 'e.g. 25% of 200'.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/calculator/calculator_engine.dart';
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

import 'g6_support.dart';

enum _PercentMode { of, findRate, findBase, findPart, discount, tax, interest }

class _PercentParsed {
  final _PercentMode mode;
  final double rate;
  final double base;
  final double part;
  final String label;

  const _PercentParsed({
    required this.mode,
    required this.rate,
    required this.base,
    required this.part,
    required this.label,
  });
}

/// G6-3 solver: `25% of 200`, `R=? P=50 B=200`, `₱500 less 20%`,
/// `500 + 12% tax`, `P=1000 R=5% T=2`.
class G6PercentEquation extends BaseEquation {
  @override
  final String rawInput;

  String? _error;

  G6PercentEquation(this.rawInput);

  String _normalized() {
    return rawInput
        .replaceAll('₱', '')
        .replaceAll('PHP', '')
        .replaceAll('php', '')
        .replaceAll(',', '')
        .replaceAll('−', '-')
        .trim();
  }

  static final RegExp _of =
      RegExp(r'^(-?\d+(?:\.\d+)?)\s*%\s*(?:of\s*)?(-?\d+(?:\.\d+)?)$');
  static final RegExp _findRate = RegExp(
    r'^(?:R\s*=\s*\?\s*P\s*=\s*(-?\d+(?:\.\d+)?)\s*B\s*=\s*(-?\d+(?:\.\d+)?)'
    r'|(-?\d+(?:\.\d+)?)\s+is\s+what\s+%?\s*of\s+(-?\d+(?:\.\d+)?)'
    r'|what\s+percent\s+of\s+(-?\d+(?:\.\d+)?)\s+is\s+(-?\d+(?:\.\d+)?))$',
    caseSensitive: false,
  );
  static final RegExp _findBase = RegExp(
    r'^B\s*=\s*\?\s*P\s*=\s*(-?\d+(?:\.\d+)?)\s*R\s*=\s*(-?\d+(?:\.\d+)?)\s*%?$',
    caseSensitive: false,
  );
  static final RegExp _findPart = RegExp(
    r'^P\s*=\s*\?\s*R\s*=\s*(-?\d+(?:\.\d+)?)\s*%?\s*B\s*=\s*(-?\d+(?:\.\d+)?)$',
    caseSensitive: false,
  );
  static final RegExp _discount = RegExp(
    r'^(?:discount\s+)?(-?\d+(?:\.\d+)?)\s*(?:less|minus|discount|-)\s*(-?\d+(?:\.\d+)?)\s*%?$',
  );
  static final RegExp _tax = RegExp(
    r'^(-?\d+(?:\.\d+)?)\s*(?:\+|plus|add)\s*(-?\d+(?:\.\d+)?)\s*%\s*(?:tax)?$',
  );
  static final RegExp _interest = RegExp(
    r'^P\s*=\s*(-?\d+(?:\.\d+)?)\s*R\s*=\s*(-?\d+(?:\.\d+)?)\s*%?\s*T\s*=\s*(-?\d+(?:\.\d+)?)$',
    caseSensitive: false,
  );

  _PercentParsed? _parse() {
    final String t = _normalized().toLowerCase();
    final RegExpMatch? interest = _interest.firstMatch(t);
    if (interest != null) {
      return _PercentParsed(
        mode: _PercentMode.interest,
        rate: double.parse(interest.group(2)!),
        base: double.parse(interest.group(1)!),
        part: double.parse(interest.group(3)!),
        label: 'Simple interest',
      );
    }
    final RegExpMatch? rate = _findRate.firstMatch(t);
    if (rate != null) {
      final String p = rate.group(1) ?? rate.group(3) ?? rate.group(6)!;
      final String b = rate.group(2) ?? rate.group(4) ?? rate.group(5)!;
      return _PercentParsed(
        mode: _PercentMode.findRate,
        rate: 0,
        base: double.parse(b),
        part: double.parse(p),
        label: 'Find the rate',
      );
    }
    final RegExpMatch? base = _findBase.firstMatch(t);
    if (base != null) {
      return _PercentParsed(
        mode: _PercentMode.findBase,
        rate: double.parse(base.group(2)!),
        base: 0,
        part: double.parse(base.group(1)!),
        label: 'Find the base',
      );
    }
    final RegExpMatch? part = _findPart.firstMatch(t);
    if (part != null) {
      return _PercentParsed(
        mode: _PercentMode.findPart,
        rate: double.parse(part.group(1)!),
        base: double.parse(part.group(2)!),
        part: 0,
        label: 'Find the percentage',
      );
    }
    final RegExpMatch? discount = _discount.firstMatch(t);
    if (discount != null) {
      return _PercentParsed(
        mode: _PercentMode.discount,
        rate: double.parse(discount.group(2)!),
        base: double.parse(discount.group(1)!),
        part: 0,
        label: 'Discount',
      );
    }
    final RegExpMatch? tax = _tax.firstMatch(t);
    if (tax != null) {
      return _PercentParsed(
        mode: _PercentMode.tax,
        rate: double.parse(tax.group(2)!),
        base: double.parse(tax.group(1)!),
        part: 0,
        label: 'Tax',
      );
    }
    final RegExpMatch? of = _of.firstMatch(t);
    if (of != null) {
      return _PercentParsed(
        mode: _PercentMode.of,
        rate: double.parse(of.group(1)!),
        base: double.parse(of.group(2)!),
        part: 0,
        label: 'Percent of a number',
      );
    }
    return null;
  }

  @override
  bool validate() {
    final String? empty = FieldValidators.notEmpty(
      rawInput,
      example: '25% of 200',
    );
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_parse() == null) {
      _error =
          'Use 25% of 200, R=? P=50 B=200, 500 less 20%, or P=1000 R=5% T=2.';
      return false;
    }
    _error = null;
    return true;
  }

  /// Core P = R × B evaluation (rate as percent number, e.g. 25).
  static double _ofValue(double rate, double base) {
    return CalculatorEngine.evaluate('$rate/100*($base)');
  }

  @override
  SolveResult solve() {
    final _PercentParsed? p = _parse();
    if (p == null) {
      return SolveResult.error(
        _error ?? 'Use 25% of 200, R=? P=50 B=200, or 500 less 20%.',
      );
    }
    if (p.mode == _PercentMode.findRate && p.base == 0) {
      return SolveResult.error('Base cannot be zero.');
    }
    if (p.mode == _PercentMode.findBase && p.rate == 0) {
      return SolveResult.error('Rate cannot be zero.');
    }
    late final String answer;
    late final double anchor;
    switch (p.mode) {
      case _PercentMode.of:
      case _PercentMode.findPart:
        final double v = _ofValue(p.rate, p.base);
        answer = 'P = ${G6Format.num(v)}';
        anchor = v;
      case _PercentMode.findRate:
        final double r = p.part / p.base * 100;
        answer = 'R = ${G6Format.num(r)}%';
        anchor = r;
      case _PercentMode.findBase:
        final double b = p.part / (p.rate / 100);
        answer = 'B = ${G6Format.num(b)}';
        anchor = b;
      case _PercentMode.discount:
        final double sale = p.base * (1 - p.rate / 100);
        answer = 'Sale = ${G6Format.money(sale)}';
        anchor = sale;
      case _PercentMode.tax:
        final double total = p.base * (1 + p.rate / 100);
        answer = 'Total = ${G6Format.money(total)}';
        anchor = total;
      case _PercentMode.interest:
        final double interest = p.base * (p.rate / 100) * p.part;
        final double amount = p.base + interest;
        answer = 'Interest = ${G6Format.money(interest)}, '
            'Amount = ${G6Format.money(amount)}';
        anchor = amount;
    }
    return SolveResult(
      answer: answer,
      points: [anchor],
      customData: [
        {
          'mode': p.label,
          'rate': p.rate,
          'base': p.base,
          'part': p.part,
        }
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final _PercentParsed? p = _parse();
    if (p == null) {
      return [
        StepModel(
          stepNumber: 1,
          title: 'Invalid input',
          explanation: _error ?? 'Use 25% of 200 — rate, base, percentage.',
        ),
      ];
    }
    final String warn =
        p.rate > 100 ? ' Note: rate exceeds 100% — check if intended.' : '';
    switch (p.mode) {
      case _PercentMode.of:
      case _PercentMode.findPart:
        final double v = _ofValue(p.rate, p.base);
        return [
          StepModel(
            stepNumber: 1,
            title: 'Rate to decimal',
            explanation: '${G6Format.num(p.rate)}% = ${p.rate}/100.',
          ),
          StepModel(
            stepNumber: 2,
            title: 'Multiply: P = R × B',
            explanation: 'P = ${p.rate}/100 × ${G6Format.num(p.base)}.',
          ),
          StepModel(
            stepNumber: 3,
            title: 'Label the answer',
            explanation: 'P = ${G6Format.num(v)}.$warn',
          ),
        ];
      case _PercentMode.findRate:
        final double r = p.part / p.base * 100;
        return [
          StepModel(
            stepNumber: 1,
            title: 'Write the triad',
            explanation:
                'P = ${G6Format.num(p.part)}, B = ${G6Format.num(p.base)}.',
          ),
          StepModel(
            stepNumber: 2,
            title: 'R = P ÷ B × 100%',
            explanation:
                'R = ${G6Format.num(p.part)} ÷ ${G6Format.num(p.base)} × 100%.',
          ),
          StepModel(
            stepNumber: 3,
            title: 'Label the answer',
            explanation: 'R = ${G6Format.num(r)}%.$warn',
          ),
        ];
      case _PercentMode.findBase:
        final double b = p.part / (p.rate / 100);
        return [
          StepModel(
            stepNumber: 1,
            title: 'Write the triad',
            explanation:
                'P = ${G6Format.num(p.part)}, R = ${G6Format.num(p.rate)}%.',
          ),
          StepModel(
            stepNumber: 2,
            title: 'B = P ÷ R',
            explanation: 'B = ${G6Format.num(p.part)} ÷ ${p.rate}/100.',
          ),
          StepModel(
            stepNumber: 3,
            title: 'Label the answer',
            explanation: 'B = ${G6Format.num(b)}.$warn',
          ),
        ];
      case _PercentMode.discount:
        final double sale = p.base * (1 - p.rate / 100);
        return [
          StepModel(
            stepNumber: 1,
            title: 'Discount to decimal',
            explanation: '${G6Format.num(p.rate)}% = ${p.rate}/100.',
          ),
          StepModel(
            stepNumber: 2,
            title: 'Discount amount',
            explanation: '${G6Format.money(p.base)} × ${p.rate}/100 = '
                '${G6Format.money(p.base * p.rate / 100)}.',
          ),
          StepModel(
            stepNumber: 3,
            title: 'Subtract from price',
            explanation: 'Sale = ${G6Format.money(sale)}.',
          ),
        ];
      case _PercentMode.tax:
        final double total = p.base * (1 + p.rate / 100);
        return [
          StepModel(
            stepNumber: 1,
            title: 'Tax to decimal',
            explanation: '${G6Format.num(p.rate)}% = ${p.rate}/100.',
          ),
          StepModel(
            stepNumber: 2,
            title: 'Tax amount',
            explanation: '${G6Format.money(p.base)} × ${p.rate}/100 = '
                '${G6Format.money(p.base * p.rate / 100)}.',
          ),
          StepModel(
            stepNumber: 3,
            title: 'Add to price',
            explanation: 'Total = ${G6Format.money(total)}.',
          ),
        ];
      case _PercentMode.interest:
        final double interest = p.base * (p.rate / 100) * p.part;
        return [
          StepModel(
            stepNumber: 1,
            title: 'Write I = P × R × T',
            explanation:
                'P = ${G6Format.money(p.base)}, R = ${G6Format.num(p.rate)}%, '
                'T = ${G6Format.num(p.part)}.',
          ),
          StepModel(
            stepNumber: 2,
            title: 'Rate to decimal',
            explanation: '${G6Format.num(p.rate)}% = ${p.rate}/100.',
          ),
          StepModel(
            stepNumber: 3,
            title: 'Multiply and add',
            explanation: 'Interest = ${G6Format.money(interest)}. '
                'Amount = ${G6Format.money(p.base + interest)}.',
          ),
        ];
    }
  }
}
