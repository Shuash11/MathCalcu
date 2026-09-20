import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';
import '../../../../shs/solvers/integral_sub_equation.dart';
import 'integration_by_parts.dart';

/// Finals-period Integration Techniques solver.
/// Promotes the proven SHS u-substitution engine (u-sub, power fallback,
/// definite + FTC via Simpson, getSteps) into the calculus/finals module,
/// then layers finals-only additions on top — the shared SHS engine stays
/// untouched (G12/College also uses it):
/// - integration by parts (LIATE) for x*ln(x), x*e^x, x*sin(x), x*cos(x)
/// - coefficient-1 chain 'x*(x^2+c)^n' (delegates to u-sub with implicit k=1)
class IntegrationTechniquesEquation extends IntegralSubEquation {
  IntegrationTechniquesEquation(super.rawInput);

  /// Normalized input: spaces stripped, minus/X folded (mirrors SHS `_n`).
  String _norm() =>
      rawInput.replaceAll(' ', '').replaceAll('−', '-').replaceAll('X', 'x');

  /// Integrand with 'int' / 'dx' stripped (indefinite inputs only).
  String _integrand() => _norm()
      .replaceFirst(RegExp(r'^int', caseSensitive: false), '')
      .replaceFirst(RegExp(r'dx$', caseSensitive: false), '');

  @override
  SolveResult solve() {
    if (!_norm().toLowerCase().startsWith('def')) {
      final f = _integrand();
      final bp = ByPartsIntegration(f).solve();
      if (bp != null) {
        return SolveResult(
          answer: '∫ $f dx = ${bp.antiderivative}',
          points: const [],
          customData: [
            {
              'kind': 'indefinite',
              'f': f,
              'antiderivative': bp.antiderivative,
              'rule': bp.rule,
            }
          ],
        );
      }
      final chain = _solveImplicitOneChain(f);
      if (chain != null) return chain;
    }
    return super.solve();
  }

  /// Coefficient-1 chain: 'int x(x^2+c)^n dx'. The promoted SHS chain
  /// regex requires an explicit numeric coefficient, so integrate directly
  /// with implicit k = 1 — same result as u-sub with coefficient 1.
  SolveResult? _solveImplicitOneChain(String f) {
    final m =
        RegExp(r'^x\*?\(x\^2([+-]\d+(?:\.\d+)?)?\)\^(\d+)$').firstMatch(f);
    if (m == null) return null;
    final pw = int.parse(m.group(2)!);
    final c = 1.0 / (2 * (pw + 1));
    final anti = '${G6Format.num(c)}(x^2${m.group(1) ?? ''})^${pw + 1} + C';
    return SolveResult(
      answer: '∫ $f dx = $anti',
      points: const [],
      customData: [
        {
          'kind': 'indefinite',
          'f': f,
          'antiderivative': anti,
          'rule': 'u-substitution (chain, implicit coefficient 1)',
        }
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    if (!_norm().toLowerCase().startsWith('def')) {
      final f = _integrand();
      final bp = ByPartsIntegration(f).solve();
      if (bp != null) {
        return [
          const StepModel(
              stepNumber: 1,
              title: 'Choose u by LIATE',
              explanation:
                  'LIATE order: Log, Inverse trig, Algebraic, Trig, Exponential — pick the first function type that appears.'),
          const StepModel(
              stepNumber: 2,
              title: 'Apply ∫u dv = uv − ∫v du',
              explanation:
                  'dv is the remaining factor; integrate v, then subtract ∫v du.'),
          StepModel(
              stepNumber: 3,
              title: 'Simplify + C',
              explanation: '∫ $f dx = ${bp.antiderivative}'),
        ];
      }
    }
    return super.getSteps();
  }
}
