import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/finals_latex.dart';
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
          latex: '\\int ${FinalsLatex.expr(f)} dx = ${bp.latex}',
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
    return _withLatex(super.solve());
  }

  /// Adds final-answer LaTeX to the promoted SHS result without
  /// touching the shared engine (G12/College also uses it).
  SolveResult _withLatex(SolveResult r) {
    if (r.hasError) return r;
    final data = r.customData?.first;
    final anti = data is Map ? data['antiderivative'] as String? : null;
    final isDef = _norm().toLowerCase().startsWith('def');
    if (isDef) {
      final a = data is Map ? data['a'] as num? : null;
      final b = data is Map ? data['b'] as num? : null;
      final f = data is Map ? data['f'] as String? : null;
      final area = data is Map ? data['area'] as num? : null;
      if (a == null || b == null || f == null || area == null) return r;
      return SolveResult(
        answer: r.answer,
        latex:
            '\\int_{${G6Format.num(a.toDouble())}}^{${G6Format.num(b.toDouble())}} '
            '${FinalsLatex.expr(f)} dx = ${G6Format.num(area.toDouble())}',
        points: r.points,
        intervalNotation: r.intervalNotation,
        customData: r.customData,
      );
    }
    if (anti == null) return r;
    return SolveResult(
      answer: r.answer,
      latex: '\\int ${FinalsLatex.expr(r.customData!.first['f'] as String)} dx '
          '= ${FinalsLatex.anti(anti)}',
      points: r.points,
      intervalNotation: r.intervalNotation,
      customData: r.customData,
    );
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
      latex: '\\int ${FinalsLatex.expr(f)} dx = ${FinalsLatex.num(c)}'
          '\\left(${FinalsLatex.expr('x^2${m.group(1) ?? ''}')}\\right)'
          '^{${pw + 1}} + C',
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
              latex: r'\int u\,dv = uv - \int v\,du',
              explanation:
                  'LIATE order: Log, Inverse trig, Algebraic, Trig, Exponential — pick the first function type that appears.'),
          const StepModel(
              stepNumber: 2,
              title: 'Apply ∫u dv = uv − ∫v du',
              latex: r'\int v\,du',
              explanation:
                  'dv is the remaining factor; integrate v, then subtract ∫v du.'),
          StepModel(
              stepNumber: 3,
              title: 'Simplify + C',
              latex: '\\int ${FinalsLatex.expr(f)} dx = ${bp.latex}',
              explanation: '∫ $f dx = ${bp.antiderivative}'),
        ];
      }
    }
    // Promoted SHS steps: attach the final-answer LaTeX to the
    // back-substitute / antiderivative step (title strings and
    // explanations stay byte-identical).
    final r = solve();
    final steps = super.getSteps();
    return [
      for (final s in steps)
        StepModel(
          stepNumber: s.stepNumber,
          title: s.title,
          explanation: s.explanation,
          hint: s.hint,
          latex:
              (s.explanation == r.answer && r.latex != null) ? r.latex : null,
        ),
    ];
  }
}
