// ─────────────────────────────────────────────────────────────
// M8 RELATIONS & FUNCTIONS — properties of a relation on a finite set.
// e.g. 'R={(1,1),(2,2)} on {1,2}', '{(a,a),(b,b),(a,b)} on {a,b}'.
// Offline, pure Dart. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

/// Classifies reflexive / symmetric / antisymmetric / transitive,
/// then equivalence vs partial order vs neither.
class M8RelationsEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  M8RelationsEquation(this.rawInput);

  /// Returns [universe, pairs].
  List<dynamic>? _parse() {
    final t = rawInput.replaceAll('−', '-');
    final pairRe = RegExp(r'\(\s*([^(),{}\s]+)\s*,\s*([^(),{}\s]+)\s*\)');
    final pairs = pairRe
        .allMatches(t)
        .map((m) => [m.group(1)!.trim(), m.group(2)!.trim()])
        .toList();
    if (pairs.isEmpty) return null;
    final braceRe = RegExp(r'\{([^{}]*)\}');
    final braces = braceRe.allMatches(t).map((m) => m.group(1)!).toList();
    // Last brace group without parens is the universe ('on {...}').
    List<String> universe = [];
    for (final b in braces.reversed) {
      if (!b.contains('(') && !b.contains(')')) {
        universe = b
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        universe = universe.toSet().toList();
        break;
      }
    }
    if (universe.isEmpty) {
      // Infer universe from pair elements.
      universe = {for (final p in pairs) ...p}.toList();
    }
    if (universe.isEmpty) return null;
    return [universe, pairs];
  }

  static Map<String, bool> _props(List<String> u, List<List<String>> pairs) {
    final set = pairs.map((p) => '${p[0]}|${p[1]}').toSet();
    bool has(String a, String b) => set.contains('$a|$b');
    final reflexive = u.every((a) => has(a, a));
    var symmetric = true;
    var antisymmetric = true;
    for (final p in pairs) {
      if (!has(p[1], p[0])) symmetric = false;
      if (p[0] != p[1] && has(p[1], p[0])) antisymmetric = false;
    }
    var transitive = true;
    outer:
    for (final p in pairs) {
      for (final q in pairs) {
        if (p[1] == q[0] && !has(p[0], q[1])) {
          transitive = false;
          break outer;
        }
      }
    }
    return {
      'reflexive': reflexive,
      'symmetric': symmetric,
      'antisymmetric': antisymmetric,
      'transitive': transitive,
    };
  }

  @override
  bool validate() {
    final empty =
        FieldValidators.notEmpty(rawInput, example: 'R={(1,1),(2,2)} on {1,2}');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_parse() == null) {
      _error = 'Use R={(a,b),…} on {…} — e.g. R={(1,1),(2,2)} on {1,2}.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Use R={(1,1)} on {1,2}.');
    }
    final u = (p[0] as List).cast<String>();
    final pairs =
        (p[1] as List).map((e) => (e as List).cast<String>()).toList();
    final props = _props(u, pairs);
    final isEquiv =
        props['reflexive']! && props['symmetric']! && props['transitive']!;
    final isOrder =
        props['reflexive']! && props['antisymmetric']! && props['transitive']!;
    final kind = isEquiv
        ? 'equivalence relation'
        : isOrder
            ? 'partial order'
            : 'neither equivalence nor order';
    final flags = props.entries
        .map((e) => '${e.key}: ${e.value ? 'yes' : 'no'}')
        .join(', ');
    return SolveResult(
      answer: 'R on {${u.join(', ')}} — $flags → $kind.',
      points: [props.values.where((v) => v).length.toDouble()],
      customData: [
        {
          'kind': 'relation',
          'universe': u,
          'pairs': pairs,
          'properties': props,
          'classification': kind,
        }
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final p = _parse();
    if (p == null) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: _error ?? 'Use R={(1,1)} on {1,2}.')
      ];
    }
    final r = solve();
    return [
      const StepModel(
          stepNumber: 1,
          title: 'Check reflexive + symmetric',
          explanation: 'Reflexive: every (a,a) present. '
              'Symmetric: (a,b) forces (b,a).'),
      const StepModel(
          stepNumber: 2,
          title: 'Check antisymmetric + transitive',
          explanation: 'Antisymmetric: (a,b) and (b,a) force a = b. '
              'Transitive: (a,b) and (b,c) force (a,c).'),
      StepModel(
          stepNumber: 3,
          title: 'Classify',
          explanation: r.hasError ? (r.errorMessage ?? '') : r.answer),
    ];
  }
}
