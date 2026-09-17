// ─────────────────────────────────────────────────────────────
// M14 ADVANCED GRAPH THEORY — bipartite, greedy coloring, planarity
// bound, shortest path. e.g. 'V=4 E={(0,1),(1,2),(2,3)} bipartite',
// 'V=4 E={(0,1)} shortest 0->2', 'V=5 E={...} color'.
// Offline, pure Dart. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

/// One engine, four queries (default: full report).
class M14AdvancedGraphEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  M14AdvancedGraphEquation(this.rawInput);

  /// Returns [n, edges, query, src, dst].
  List<dynamic>? _parse() {
    final t = rawInput.replaceAll('−', '-');
    final tl = t.toLowerCase();
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
    if (n <= maxV || n > 64 || edges.length > 256) return null;
    final seen = <String>{};
    final clean = <List<int>>[];
    for (final e in edges) {
      if (e[0] == e[1]) continue;
      final key = e[0] < e[1] ? '${e[0]}-${e[1]}' : '${e[1]}-${e[0]}';
      if (seen.add(key)) clean.add([e[0], e[1]]);
    }
    var query = 'full';
    if (tl.contains('bipartite')) query = 'bipartite';
    if (tl.contains('color') || tl.contains('chroma')) query = 'color';
    if (tl.contains('planar')) query = 'planar';
    if (tl.contains('shortest') || tl.contains('path') || tl.contains('->')) {
      query = 'shortest';
    }
    var src = 0;
    var dst = 0;
    final sd = RegExp(r'(\d+)\s*->\s*(\d+)').firstMatch(t);
    if (sd != null) {
      src = int.parse(sd.group(1)!);
      dst = int.parse(sd.group(2)!);
      if (src >= n || dst >= n) return null;
    }
    return [n, clean, query, src, dst];
  }

  static List<List<int>> _adj(int n, List<List<int>> edges) {
    final adj = List<List<int>>.generate(n, (_) => []);
    for (final e in edges) {
      adj[e[0]].add(e[1]);
      adj[e[1]].add(e[0]);
    }
    for (final l in adj) {
      l.sort();
    }
    return adj;
  }

  /// Returns null when not bipartite, else 2-coloring.
  static List<int>? _bipartite(int n, List<List<int>> adj) {
    final color = List<int>.filled(n, -1);
    for (var s = 0; s < n; s++) {
      if (color[s] != -1) continue;
      color[s] = 0;
      final queue = [s];
      while (queue.isNotEmpty) {
        final v = queue.removeAt(0);
        for (final w in adj[v]) {
          if (color[w] == -1) {
            color[w] = 1 - color[v];
            queue.add(w);
          } else if (color[w] == color[v]) {
            return null;
          }
        }
      }
    }
    return color;
  }

  static List<int> _greedy(int n, List<List<int>> adj) {
    final color = List<int>.filled(n, -1);
    for (var v = 0; v < n; v++) {
      final used =
          adj[v].where((w) => color[w] != -1).map((w) => color[w]).toSet();
      var c = 0;
      while (used.contains(c)) {
        c++;
      }
      color[v] = c;
    }
    return color;
  }

  static List<int>? _bfsPath(int n, List<List<int>> adj, int src, int dst) {
    if (src == dst) return [src];
    final prev = List<int>.filled(n, -1);
    final seen = List<bool>.filled(n, false);
    final queue = [src];
    seen[src] = true;
    while (queue.isNotEmpty) {
      final v = queue.removeAt(0);
      for (final w in adj[v]) {
        if (seen[w]) continue;
        seen[w] = true;
        prev[w] = v;
        if (w == dst) {
          final path = [dst];
          var cur = dst;
          while (prev[cur] != -1) {
            cur = prev[cur];
            path.add(cur);
          }
          return path.reversed.toList();
        }
        queue.add(w);
      }
    }
    return null;
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(rawInput,
        example: 'V=4 E={(0,1),(1,2),(2,3)} bipartite');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_parse() == null) {
      _error = 'Use V=n E={(u,v),…} [bipartite|color|planar|shortest a->b].';
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
    final query = p[2] as String;
    final src = p[3] as int;
    final dst = p[4] as int;
    final adj = _adj(n, edges);
    final m = edges.length;
    final coloring = _bipartite(n, adj);
    final bip = coloring != null;
    final greedy = _greedy(n, adj);
    final chiUpper = greedy.toSet().length;
    final planarOk = n < 3 || m <= 3 * n - 6;
    final path = _bfsPath(n, adj, src, dst);

    switch (query) {
      case 'bipartite':
        return SolveResult(
          answer: bip
              ? 'Bipartite: yes (2-colorable, odd-cycle free).'
              : 'Bipartite: no (contains an odd cycle).',
          points: [bip ? 1.0 : 0.0],
          customData: [
            {
              'kind': 'adv-graph',
              'query': query,
              'bipartite': bip,
              'coloring': coloring
            }
          ],
        );
      case 'color':
        return SolveResult(
          answer:
              'Greedy coloring uses $chiUpper color${chiUpper == 1 ? '' : 's'} '
              '(χ ≤ $chiUpper; ordering 0…${n - 1}): [${greedy.join(', ')}].',
          points: [chiUpper.toDouble()],
          customData: [
            {
              'kind': 'adv-graph',
              'query': query,
              'colors': chiUpper,
              'assignment': greedy
            }
          ],
        );
      case 'planar':
        return SolveResult(
          answer: planarOk
              ? 'Planarity: maybe planar (m=$m ≤ ${3 * n - 6} = 3n−6 passes the necessary bound).'
              : 'Planarity: non-planar (m=$m > ${3 * n - 6} = 3n−6 violates the bound).',
          points: [planarOk ? 1.0 : 0.0],
          customData: [
            {
              'kind': 'adv-graph',
              'query': query,
              'm': m,
              'n': n,
              'passesBound': planarOk
            }
          ],
        );
      case 'shortest':
        if (path == null) {
          return SolveResult(
            answer: 'No path from $src to $dst (different components).',
            points: const [],
            customData: [
              {
                'kind': 'adv-graph',
                'query': query,
                'src': src,
                'dst': dst,
                'path': null
              }
            ],
          );
        }
        return SolveResult(
          answer:
              'Shortest $src → $dst has length ${path.length - 1}: ${path.join(' → ')} (BFS).',
          points: [(path.length - 1).toDouble()],
          customData: [
            {
              'kind': 'adv-graph',
              'query': query,
              'src': src,
              'dst': dst,
              'path': path
            }
          ],
        );
      default:
        return SolveResult(
          answer: 'n=$n m=$m: ${bip ? 'bipartite' : 'not bipartite'}, '
              'greedy χ ≤ $chiUpper, '
              '${planarOk ? 'passes' : 'violates'} planarity bound, '
              '${path == null ? 'no $src→$dst path' : '$src→$dst dist ${path.length - 1}'}.',
          points: [chiUpper.toDouble()],
          customData: [
            {
              'kind': 'adv-graph',
              'query': 'full',
              'n': n,
              'm': m,
              'bipartite': bip,
              'colors': chiUpper,
              'assignment': greedy,
              'passesBound': planarOk,
              'path': path,
            }
          ],
        );
    }
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
          title: 'Two-color the graph',
          explanation:
              'BFS 2-coloring: a clash means an odd cycle (not bipartite).'),
      const StepModel(
          stepNumber: 2,
          title: 'Greedy-color + bound checks',
          explanation:
              'Greedy gives χ upper bound; m ≤ 3n−6 is the planarity screen.'),
      StepModel(
          stepNumber: 3,
          title: 'Read the answer',
          explanation: r.hasError ? (r.errorMessage ?? '') : r.answer),
    ];
  }
}
