// ─────────────────────────────────────────────────────────────
// M11 GRAPH THEORY BASICS — degrees, connectivity, tree + Euler test.
// e.g. 'V=4 E={(0,1),(1,2),(2,3)}'.
// Offline, pure Dart. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

/// Undirected simple-graph metrics from an edge list.
class M11GraphBasicsEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  M11GraphBasicsEquation(this.rawInput);

  /// Returns [n, edges].
  List<dynamic>? _parse() {
    final t = rawInput.replaceAll('−', '-');
    final nMatch =
        RegExp(r'v\s*(?:=|is|:)?\s*(\d+)', caseSensitive: false).firstMatch(t);
    final pairRe = RegExp(r'\(\s*(\d+)\s*,\s*(\d+)\s*\)');
    final edges = pairRe
        .allMatches(t)
        .map((m) => [int.parse(m.group(1)!), int.parse(m.group(2)!)])
        .toList();
    if (edges.isEmpty) return null;
    var n = nMatch == null ? 0 : int.parse(nMatch.group(1)!);
    var maxV = 0;
    for (final e in edges) {
      if (e[0] > maxV) maxV = e[0];
      if (e[1] > maxV) maxV = e[1];
      if (e[0] < 0 || e[1] < 0) return null;
    }
    if (n <= 0) n = maxV + 1;
    if (n <= maxV) return null;
    if (n > 64 || edges.length > 256) return null;
    // Drop self-loops/duplicates for simple-graph metrics.
    final seen = <String>{};
    final clean = <List<int>>[];
    for (final e in edges) {
      if (e[0] == e[1]) continue;
      final key = e[0] < e[1] ? '${e[0]}-${e[1]}' : '${e[1]}-${e[0]}';
      if (seen.add(key)) clean.add([e[0], e[1]]);
    }
    return [n, clean];
  }

  static List<List<int>> _adj(int n, List<List<int>> edges) {
    final adj = List<List<int>>.generate(n, (_) => []);
    for (final e in edges) {
      adj[e[0]].add(e[1]);
      adj[e[1]].add(e[0]);
    }
    return adj;
  }

  static int _components(int n, List<List<int>> adj) {
    final seen = List<bool>.filled(n, false);
    var count = 0;
    for (var s = 0; s < n; s++) {
      if (seen[s]) continue;
      count++;
      final stack = [s];
      seen[s] = true;
      while (stack.isNotEmpty) {
        final v = stack.removeLast();
        for (final w in adj[v]) {
          if (!seen[w]) {
            seen[w] = true;
            stack.add(w);
          }
        }
      }
    }
    return count;
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(rawInput,
        example: 'V=4 E={(0,1),(1,2),(2,3)}');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_parse() == null) {
      _error = 'Use V=n E={(u,v),…} — e.g. V=4 E={(0,1),(1,2),(2,3)}.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Use V=4 E={(0,1)}. ');
    }
    final n = p[0] as int;
    final edges = (p[1] as List).cast<List<int>>();
    final adj = _adj(n, edges);
    final degs = List<int>.generate(n, (i) => adj[i].length);
    final comps = _components(n, adj);
    final connected = comps == 1;
    final m = edges.length;
    final isTree = connected && m == n - 1;
    final odd = degs.where((d) => d.isOdd).length;
    final euler = !connected
        ? 'none (disconnected)'
        : odd == 0
            ? 'circuit + trail'
            : odd == 2
                ? 'trail only'
                : 'none';
    final sumDeg = degs.fold(0, (a, b) => a + b);
    return SolveResult(
      answer: 'n=$n, m=$m, degrees=[${degs.join(', ')}] (Σ=$sumDeg=2m), '
          'components=$comps, ${connected ? 'connected' : 'disconnected'}, '
          '${isTree ? 'is a tree' : 'not a tree'}, Euler: $euler.',
      points: degs.map((d) => d.toDouble()).toList(),
      customData: [
        {
          'kind': 'graph-basics',
          'n': n,
          'm': m,
          'degrees': degs,
          'components': comps,
          'connected': connected,
          'isTree': isTree,
          'oddCount': odd,
          'euler': euler,
          'edges': edges,
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
            explanation: _error ?? 'Use V=4 E={(0,1)}. ')
      ];
    }
    final r = solve();
    return [
      const StepModel(
          stepNumber: 1,
          title: 'Degree each vertex',
          explanation:
              'deg(v) counts incident edges; Σdeg = 2m (handshaking).'),
      const StepModel(
          stepNumber: 2,
          title: 'Walk the components',
          explanation:
              'BFS from each unvisited vertex; one sweep = connected.'),
      StepModel(
          stepNumber: 3,
          title: 'Tree + Euler read-off',
          explanation: r.hasError ? (r.errorMessage ?? '') : r.answer),
    ];
  }
}
