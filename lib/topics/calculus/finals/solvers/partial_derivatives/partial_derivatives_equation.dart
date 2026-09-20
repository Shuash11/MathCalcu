import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/derivatives_solver/derivatives_solver.dart';

// ─────────────────────────────────────────────────────────────
// PARTIAL DERIVATIVES EQUATION — finals period.
//
// Thin wrapper around the proven DerivativesSolver CAS engine
// (derivatives_solver.dart): the input's first token selects the
// differentiation variable ('d/dx' or 'd/dy'), the remainder is
// the expression. Differentiating in one variable while treating
// every other variable as a constant IS the partial derivative —
// so d/dx x^2*y = 2xy and d/dy x^2*y = x^2 fall out for free.
// ─────────────────────────────────────────────────────────────

/// Finals-period Partial Derivatives solver.
class PartialDerivativesEquation extends BaseEquation {
  /// Leading token that selects the variable, e.g. 'd/dx' or 'd/dy'.
  static final RegExp _prefix = RegExp(r'^d/d([a-z])\s*(.*)$');

  PartialDerivativesEquation(this.rawInput);

  /// The raw string the user typed.
  @override
  final String rawInput;

  /// Normalized input: trimmed, minus folded, lowercased (the
  /// derivatives engine itself lowercases idents too).
  String _norm() => rawInput.trim().toLowerCase().replaceAll('−', '-');

  /// Differentiation variable from the leading token, e.g. 'x'.
  String? get variable => _prefix.firstMatch(_norm())?.group(1);

  /// Expression after the leading token is stripped.
  String? get expression => _prefix.firstMatch(_norm())?.group(2);

  @override
  bool validate() {
    final expr = expression;
    return expr != null && expr.isNotEmpty;
  }

  @override
  SolveResult solve() {
    if (!validate()) {
      return SolveResult.error(
        'Enter a partial derivative — e.g. d/dx x^2*y or d/dy sin(x)*y',
      );
    }
    try {
      final v = variable!;
      final f = expression!;
      final result = DerivativeSolver.solve(f, v);
      return SolveResult(
        answer: '∂f/∂$v = $result',
        points: const [],
        customData: [
          {
            'kind': 'partial',
            'variable': v,
            'f': f,
            'derivative': result.toString(),
          }
        ],
      );
    } on ParseException catch (e) {
      return SolveResult.error(
          e.toString().replaceFirst('ParseException: ', ''));
    } catch (e) {
      return SolveResult.error('Could not solve: $e');
    }
  }

  @override
  List<StepModel> getSteps() {
    if (!validate()) return const [];
    final v = variable!;
    final raw = DerivativeSolver.getSteps(expression!, v);

    final steps = <StepModel>[
      StepModel(
        stepNumber: 1,
        title: 'Identify the partial derivative',
        explanation: '∂f/∂$v: f = ${raw.original} — treat all other '
            'variables as constants.',
      ),
    ];

    var n = 2;
    for (final s in raw.steps.skip(1)) {
      final isFinal = s.type == StepType.finalResult;
      steps.add(StepModel(
        stepNumber: n++,
        title: isFinal ? 'Final answer' : s.description,
        explanation:
            isFinal ? '∂f/∂$v = ${s.expression}' : s.expression.toString(),
        hint: s.rule,
      ));
    }
    return steps;
  }
}
