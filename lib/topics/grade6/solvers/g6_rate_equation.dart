// ─────────────────────────────────────────────────────────────
// G6 RATE — speed D = R × T triad, best-buy unit price, meter reading.
// Supplements G6-4/G6-5 exam coverage (DepEd speed + consumer math).
// Offline, pure Dart. hintText: 'e.g. R=? D=120 T=2'.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

import 'g6_support.dart';

enum _RateKind { distance, speed, time, bestBuy, meter }

class _RateParsed {
  final _RateKind kind;
  final double first;
  final double second;
  final String unitA;
  final double third;
  final double fourth;
  final String unitB;

  const _RateParsed({
    required this.kind,
    required this.first,
    required this.second,
    required this.unitA,
    required this.third,
    required this.fourth,
    required this.unitB,
  });
}

/// G6 rate solver.
class G6RateEquation extends BaseEquation {
  @override
  final String rawInput;

  String? _error;

  G6RateEquation(this.rawInput);

  static final RegExp _triad = RegExp(
    r'^(D|R|T)\s*=\s*\?\s*(?:(D|R|T)\s*=\s*(-?\d+(?:\.\d+)?)\s*(D|R|T)\s*=\s*(-?\d+(?:\.\d+)?)|(D|R|T)\s*=\s*(-?\d+(?:\.\d+)?)\s*(D|R|T)\s*=\s*(-?\d+(?:\.\d+)?))\s*$',
  );
  static final RegExp _bestBuy = RegExp(
    r'^compare\s+(-?\d+(?:\.\d+)?)\s*(g|kg|ml|l|pcs)\s*(?:₱|p|php)?\s*(-?\d+(?:\.\d+)?)\s+vs\s+(-?\d+(?:\.\d+)?)\s*(g|kg|ml|l|pcs)\s*(?:₱|p|php)?\s*(-?\d+(?:\.\d+)?)\s*$',
  );
  static final RegExp _meter = RegExp(
    r'^(?:prev|previous)\s*=\s*(-?\d+(?:\.\d+)?)\s*(?:pres|present)\s*=\s*(-?\d+(?:\.\d+)?)\s*rate\s*=\s*(-?\d+(?:\.\d+)?)\s*$',
  );

  String _normalized() {
    return rawInput
        .replaceAll('₱', '')
        .replaceAll(',', '')
        .replaceAll('−', '-')
        .trim()
        .toLowerCase();
  }

  _RateParsed? _parse() {
    final String t = _normalized();
    final RegExpMatch? triad = _triad.firstMatch(t.toUpperCase());
    if (triad != null) {
      final String unknown = triad.group(1)!;
      final Map<String, double> known = {};
      for (final List<int> pair in [
        [2, 3],
        [4, 5],
        [6, 7],
        [8, 9],
      ]) {
        final String? key = triad.group(pair[0]);
        final String? val = triad.group(pair[1]);
        if (key != null && val != null) {
          known[key] = double.parse(val);
        }
      }
      if (unknown == 'D' && known.containsKey('R') && known.containsKey('T')) {
        return _RateParsed(
          kind: _RateKind.distance,
          first: known['R']!,
          second: known['T']!,
          unitA: '',
          third: 0,
          fourth: 0,
          unitB: '',
        );
      }
      if (unknown == 'R' && known.containsKey('D') && known.containsKey('T')) {
        if (known['T'] == 0) {
          return null;
        }
        return _RateParsed(
          kind: _RateKind.speed,
          first: known['D']!,
          second: known['T']!,
          unitA: '',
          third: 0,
          fourth: 0,
          unitB: '',
        );
      }
      if (unknown == 'T' && known.containsKey('D') && known.containsKey('R')) {
        if (known['R'] == 0) {
          return null;
        }
        return _RateParsed(
          kind: _RateKind.time,
          first: known['D']!,
          second: known['R']!,
          unitA: '',
          third: 0,
          fourth: 0,
          unitB: '',
        );
      }
      return null;
    }
    final RegExpMatch? buy = _bestBuy.firstMatch(t);
    if (buy != null) {
      return _RateParsed(
        kind: _RateKind.bestBuy,
        first: double.parse(buy.group(1)!),
        second: double.parse(buy.group(3)!),
        unitA: buy.group(2)!,
        third: double.parse(buy.group(4)!),
        fourth: double.parse(buy.group(6)!),
        unitB: buy.group(5)!,
      );
    }
    final RegExpMatch? meter = _meter.firstMatch(t);
    if (meter != null) {
      return _RateParsed(
        kind: _RateKind.meter,
        first: double.parse(meter.group(1)!),
        second: double.parse(meter.group(2)!),
        unitA: '',
        third: double.parse(meter.group(3)!),
        fourth: 0,
        unitB: '',
      );
    }
    return null;
  }

  /// Normalizes g/kg and ml/L to a base unit before comparing.
  static double _toBase(double qty, String unit) {
    if (unit == 'kg') {
      return qty * 1000;
    }
    if (unit == 'l') {
      return qty * 1000;
    }
    return qty;
  }

  @override
  bool validate() {
    final String? empty = FieldValidators.notEmpty(
      rawInput,
      example: 'R=? D=120 T=2',
    );
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_parse() == null) {
      _error = 'Use R=? D=120 T=2, compare 500g 120 vs 1kg 220, or prev=1250 pres=1380 rate=12.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final _RateParsed? p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Use D = R × T or best-buy compare.');
    }
    switch (p.kind) {
      case _RateKind.distance:
        final double d = p.first * p.second;
        return SolveResult(
          answer: 'D = ${G6Format.num(d)}',
          points: [d],
          customData: [
            {'mode': 'distance', 'value': d}
          ],
        );
      case _RateKind.speed:
        final double r = p.first / p.second;
        return SolveResult(
          answer: 'R = ${G6Format.num(r)} per hour',
          points: [r],
          customData: [
            {'mode': 'speed', 'value': r}
          ],
        );
      case _RateKind.time:
        final double t = p.first / p.second;
        return SolveResult(
          answer: 'T = ${G6Format.num(t)} hours',
          points: [t],
          customData: [
            {'mode': 'time', 'value': t}
          ],
        );
      case _RateKind.bestBuy:
        if (p.first <= 0 || p.third <= 0) {
          return SolveResult.error('Quantities must be positive.');
        }
        final double q1 = _toBase(p.first, p.unitA);
        final double q2 = _toBase(p.third, p.unitB);
        final double u1 = p.second / q1;
        final double u2 = p.fourth / q2;
        final String winner = u1 < u2 ? 'First' : u2 < u1 ? 'Second' : 'Tie';
        return SolveResult(
          answer: '$winner is cheaper '
              '(${G6Format.money(u1)} vs ${G6Format.money(u2)} per unit)',
          points: [u1, u2],
          customData: [
            {
              'mode': 'best-buy',
              'bars': [
                {'label': 'Offer 1', 'value': u1},
                {'label': 'Offer 2', 'value': u2},
              ],
            }
          ],
        );
      case _RateKind.meter:
        if (p.second < p.first) {
          return SolveResult.error(
            'Present reading cannot be less than previous.',
          );
        }
        if (p.third < 0) {
          return SolveResult.error('Rate cannot be negative.');
        }
        final double use = p.second - p.first;
        final double bill = use * p.third;
        return SolveResult(
          answer: 'Use = ${G6Format.num(use)} kWh, '
              'Bill = ${G6Format.money(bill)}',
          points: [use, bill],
          customData: [
            {'mode': 'meter', 'use': use, 'bill': bill}
          ],
        );
    }
  }

  @override
  List<StepModel> getSteps() {
    final _RateParsed? p = _parse();
    if (p == null) {
      return [
        StepModel(
          stepNumber: 1,
          title: 'Invalid input',
          explanation: _error ?? 'Use R=? D=120 T=2.',
        ),
      ];
    }
    switch (p.kind) {
      case _RateKind.distance:
        return [
          const StepModel(stepNumber: 1, title: 'Write D = R × T', explanation: 'Distance equals rate times time.'),          StepModel(stepNumber: 2, title: 'Substitute', explanation: 'D = ${G6Format.num(p.first)} × ${G6Format.num(p.second)}.'),
          StepModel(stepNumber: 3, title: 'Multiply with units', explanation: '${solve().answer}.'),
        ];
      case _RateKind.speed:
        return [
          const StepModel(stepNumber: 1, title: 'Write R = D ÷ T', explanation: 'Speed equals distance over time.'),          StepModel(stepNumber: 2, title: 'Substitute', explanation: 'R = ${G6Format.num(p.first)} ÷ ${G6Format.num(p.second)}.'),
          StepModel(stepNumber: 3, title: 'Divide with units', explanation: '${solve().answer}.'),
        ];
      case _RateKind.time:
        return [
          const StepModel(stepNumber: 1, title: 'Write T = D ÷ R', explanation: 'Time equals distance over rate.'),          StepModel(stepNumber: 2, title: 'Substitute', explanation: 'T = ${G6Format.num(p.first)} ÷ ${G6Format.num(p.second)}.'),
          StepModel(stepNumber: 3, title: 'Divide with units', explanation: '${solve().answer}.'),
        ];
      case _RateKind.bestBuy:
        return [
          const StepModel(stepNumber: 1, title: 'Convert to same units', explanation: 'g/kg and ml/L to one base unit.'),
          const StepModel(stepNumber: 2, title: 'Unit price each', explanation: 'Price ÷ quantity per offer.'),          StepModel(stepNumber: 3, title: 'Compare', explanation: '${solve().answer}.'),
        ];
      case _RateKind.meter:
        return [
          const StepModel(stepNumber: 1, title: 'Subtract readings', explanation: 'Use = present − previous.'),
          const StepModel(stepNumber: 2, title: 'Multiply by rate', explanation: 'Bill = use × rate.'),          StepModel(stepNumber: 3, title: 'Label kWh and pesos', explanation: '${solve().answer}.'),
        ];
    }
  }
}
