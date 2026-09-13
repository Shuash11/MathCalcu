// ─────────────────────────────────────────────────────────────
// GCF / LCM — listing + Euclidean method for whole numbers.
// Companions the G6-5 GEMDAS solver (factors wave). Offline.
// hintText: 'e.g. GCF(12, 18)'.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

import 'g6_support.dart';

/// GCF/LCM solver: `GCF(12, 18)`, `lcm 4 6`, `gcd 20, 30`.
class G6GcfLcmEquation extends BaseEquation {
  @override
  final String rawInput;

  String? _error;

  G6GcfLcmEquation(this.rawInput);

  static final RegExp _expr = RegExp(
    r'^\s*(gcf|gcd|lcm)\s*\(?\s*(-?\d[\d\s,;]*?)\)?\s*$',
  );

  bool get _isLcm => rawInput.toLowerCase().contains('lcm');

  List<int>? _numbers() {
    final RegExpMatch? m = _expr.firstMatch(rawInput.toLowerCase());
    if (m == null) {
      return null;
    }
    return RegExp(r'-?\d+')
        .allMatches(m.group(2)!)
        .map((n) => int.parse(n.group(0)!))
        .toList();
  }

  /// All divisors of [n] (listing method, DepEd-style).
  static List<int> factors(int n) {
    final List<int> out = [];
    for (var i = 1; i * i <= n; i++) {
      if (n % i == 0) {
        out.add(i);
        if (i * i != n) {
          out.add(n ~/ i);
        }
      }
    }
    out.sort();
    return out;
  }

  @override
  bool validate() {
    final String? empty = FieldValidators.notEmpty(
      rawInput,
      example: 'GCF(12, 18)',
    );
    if (empty != null) {
      _error = empty;
      return false;
    }
    final List<int>? numbers = _numbers();
    if (numbers == null || numbers.length < 2) {
      _error = 'Use GCF or LCM with two numbers — e.g. GCF(12, 18).';
      return false;
    }
    if (numbers.any((n) => n <= 0)) {
      _error = 'Use positive whole numbers — e.g. LCM(4, 6).';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final List<int>? numbers = _numbers();
    if (numbers == null || numbers.length < 2) {
      return SolveResult.error(
        _error ?? 'Use GCF or LCM with two numbers.',
      );
    }
    if (numbers.any((n) => n <= 0)) {
      return SolveResult.error('Use positive whole numbers.');
    }
    final int value =
        _isLcm ? G6Math.lcmList(numbers) : G6Math.gcdList(numbers);
    return SolveResult(
      answer: '${_isLcm ? 'LCM' : 'GCF'} = $value',
      points: [value.toDouble()],
      customData: [
        {'numbers': numbers, 'value': value, 'isLcm': _isLcm}
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final List<int>? numbers = _numbers();
    if (numbers == null || numbers.length < 2) {
      return [
        StepModel(
          stepNumber: 1,
          title: 'Invalid input',
          explanation: _error ?? 'Use GCF(12, 18) or LCM(4, 6).',
        ),
      ];
    }
    final int value =
        _isLcm ? G6Math.lcmList(numbers) : G6Math.gcdList(numbers);
    final String listed =
        numbers.map((n) => '$n: ${factors(n).join(', ')}').join(' | ');
    return [
      StepModel(
        stepNumber: 1,
        title: 'List the numbers',
        explanation: 'Numbers: ${numbers.join(', ')}.',
      ),
      StepModel(
        stepNumber: 2,
        title: 'List the factors',
        explanation: listed,
      ),
      StepModel(
        stepNumber: 3,
        title: _isLcm
            ? 'Take the least common multiple'
            : 'Take the greatest common factor',
        explanation: _isLcm
            ? 'Smallest number in all lists: $value.'
            : 'Largest number in all lists: $value.',
      ),
      StepModel(
        stepNumber: 4,
        title: 'Check with division',
        explanation: '${_isLcm ? 'LCM' : 'GCF'} = $value; verify by division.',
      ),
    ];
  }
}
