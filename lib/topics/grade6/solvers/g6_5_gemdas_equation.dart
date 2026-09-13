// ─────────────────────────────────────────────────────────────
// G6-5 GEMDAS — order-of-operations tracer over CalculatorEngine.
// DepEd M6NS-IIa-148. Validates balanced parens + allowed chars,
// evaluates with the engine, explains G→E→M/D→A/S order. Offline.
// hintText: 'e.g. 8 + 2 × (5-3)^2'.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/calculator/calculator_engine.dart';
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

import 'g6_support.dart';

/// Evaluation trace grouped by GEMDAS stage.
class GemdasTrace {
  final List<String> groups;
  final List<String> exponents;
  final List<String> mulDiv;
  final List<String> addSub;
  final double value;

  const GemdasTrace({
    required this.groups,
    required this.exponents,
    required this.mulDiv,
    required this.addSub,
    required this.value,
  });
}

/// G6-5 solver: `8 + 2 × 5`, `(10 - 2)^2 ÷ 4`.
class G6GemdasEquation extends BaseEquation {
  @override
  final String rawInput;

  String? _error;

  G6GemdasEquation(this.rawInput);

  static final RegExp _allowed = RegExp(r'^[0-9+\-*/^()×÷\s.]+$');
  static final RegExp _group = RegExp(r'\([^()]+\)');
  static final RegExp _exponent =
      RegExp(r'-?\d+(?:\.\d+)?\s*\^\s*-?\d+(?:\.\d+)?');

  String _normalized() {
    return rawInput
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-');
  }

  static bool _balanced(String s) {
    var depth = 0;
    for (final int c in s.codeUnits) {
      if (c == 0x28) {
        depth++;
      } else if (c == 0x29) {
        depth--;
        if (depth < 0) {
          return false;
        }
      }
    }
    return depth == 0;
  }

  /// Scans [stage] pattern matches and evaluates each with the engine.
  static List<String> _scan(String expr, RegExp stage) {
    final List<String> out = [];
    for (final RegExpMatch m in stage.allMatches(expr)) {
      try {
        final double v = CalculatorEngine.evaluate(m.group(0)!);
        out.add('${m.group(0)} = ${G6Format.num(v)}');
      } catch (_) {
        // Skip fragments the engine cannot evaluate alone.
      }
    }
    return out;
  }

  /// Builds the GEMDAS trace; throws FormatException on bad input.
  /// Spaces are stripped for stage scanning; CalculatorEngine also
  /// tolerates spaces via _skipSpaces.
  static GemdasTrace trace(String expression) {
    final String compact = expression.replaceAll(' ', '');
    final double value = CalculatorEngine.evaluate(compact);
    final List<String> groups = _scan(compact, _group);
    final List<String> exponents = _scan(compact, _exponent);
    final List<String> mulDiv = [];
    final List<String> addSub = [];
    final RegExp md = RegExp(r'-?\d+(?:\.\d+)?\s*[*/]\s*-?\d+(?:\.\d+)?');
    final RegExp as = RegExp(r'-?\d+(?:\.\d+)?\s*[+\-]\s*-?\d+(?:\.\d+)?');
    mulDiv.addAll(_scan(compact, md));
    addSub.addAll(_scan(compact, as));
    return GemdasTrace(
      groups: groups,
      exponents: exponents,
      mulDiv: mulDiv,
      addSub: addSub,
      value: value,
    );
  }

  @override
  bool validate() {
    final String? empty = FieldValidators.notEmpty(
      rawInput,
      example: '8 + 2 × (5-3)^2',
    );
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (!_allowed.hasMatch(rawInput)) {
      _error = 'Use numbers with ( ) ^ * / + - only — e.g. 8 + 2 × 5.';
      return false;
    }
    if (!_balanced(rawInput)) {
      _error = 'Parentheses are unbalanced — check ( and ).';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    if (!validate()) {
      return SolveResult.error(_error ?? 'Invalid GEMDAS expression.');
    }
    try {
      final GemdasTrace t = trace(_normalized());
      return SolveResult(
        answer: G6Format.num(t.value),
        points: [t.value],
        customData: [
          {
            'groups': t.groups,
            'exponents': t.exponents,
            'mulDiv': t.mulDiv,
            'addSub': t.addSub,
          }
        ],
      );
    } on FormatException {
      return SolveResult.error(
        'Could not parse — check ^ and parentheses.',
      );
    }
  }

  @override
  List<StepModel> getSteps() {
    if (!validate()) {
      return [
        StepModel(
          stepNumber: 1,
          title: 'Invalid input',
          explanation: _error ?? 'Use ( ) ^ * / + - — e.g. 8 + 2 × 5.',
        ),
      ];
    }
    try {
      final GemdasTrace t = trace(_normalized());
      final String groups = t.groups.isEmpty
          ? 'No grouping symbols — skip to exponents.'
          : t.groups.join('; ');
      final String exponents = t.exponents.isEmpty
          ? 'No exponents — skip to ×/÷.'
          : t.exponents.join('; ');
      final String mulDiv = t.mulDiv.isEmpty
          ? 'No ×/÷ — skip to +/−.'
          : t.mulDiv.take(3).join('; ');
      return [
        StepModel(
          stepNumber: 1,
          title: 'G — Grouping first',
          explanation: groups,
        ),
        StepModel(
          stepNumber: 2,
          title: 'E — Exponents next',
          explanation: exponents,
        ),
        StepModel(
          stepNumber: 3,
          title: 'M/D — Multiply and divide left to right',
          explanation: mulDiv,
        ),
        StepModel(
          stepNumber: 4,
          title: 'A/S — Add and subtract left to right',
          explanation: '= ${G6Format.num(t.value)}.',
        ),
      ];
    } on FormatException {
      return [
        const StepModel(
          stepNumber: 1,
          title: 'Invalid input',
          explanation: 'Could not parse — check ^ and parentheses.',
        ),
      ];
    }
  }
}
