// ─────────────────────────────────────────────────────────────
// M13 TOPOLOGY BASICS — classify subsets of R (standard topology).
// e.g. '(0,1)', '[0,1]', '(0,1]', '{1,2}', 'R', 'empty', 'Q'.
// Offline, pure Dart. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

/// Open / closed / compact / connected read-off for intervals + named sets.
class M13TopologyEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  M13TopologyEquation(this.rawInput);

  /// Returns [kind, leftClosed, rightClosed, bounded, extra].
  List<dynamic>? _parse() {
    final t = rawInput.replaceAll(' ', '').toLowerCase();
    if (t == 'r' || t == 'reals' || t == '(−inf,inf)' || t == '(-inf,inf)') {
      return ['named', false, false, false, 'R'];
    }
    if (t == 'empty' || t == '∅' || t == '{}') {
      return ['named', true, true, true, '∅'];
    }
    if (t == 'q' || t == 'rationals') {
      return ['named', false, false, false, 'Q'];
    }
    if (t == 'z' || t == 'integers') return ['named', false, true, false, 'Z'];
    if (RegExp(r'^\{[^}]*\}$').hasMatch(t)) {
      return ['named', false, true, true, 'finite'];
    }
    final m = RegExp(
      r'^([(\[])\s*(-?(?:\d+(?:\.\d+)?|inf))\s*,\s*(-?(?:\d+(?:\.\d+)?|inf))\s*([)\]])$',
    ).firstMatch(t.replaceAll('−', '-'));
    if (m == null) return null;
    final lc = m.group(1) == '[';
    final rc = m.group(4) == ']';
    double parseEnd(String s) {
      if (s.contains('inf')) {
        return s.startsWith('-') ? double.negativeInfinity : double.infinity;
      }
      return double.parse(s);
    }

    final a = parseEnd(m.group(2)!);
    final b = parseEnd(m.group(3)!);
    if (!(a < b)) return null;
    final bounded = a.isFinite && b.isFinite;
    // Unbounded ends are never closed at infinity.
    final lEff = a.isFinite ? lc : false;
    final rEff = b.isFinite ? rc : false;
    return ['interval', lEff, rEff, bounded, '$a,$b'];
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(rawInput, example: '(0,1)');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_parse() == null) {
      _error = 'Use (a,b), [a,b], R, Q, Z, {…}, or empty — e.g. (0,1).';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Use (0,1).');
    }
    final kind = p[0] as String;
    final extra = p[4] as String;
    late bool open, closed, bounded, compact, connected;
    late String label;
    if (kind == 'named') {
      switch (extra) {
        case 'R':
          open = true;
          closed = true;
          bounded = false;
          compact = false;
          connected = true;
          label = 'R';
        case '∅':
          open = true;
          closed = true;
          bounded = true;
          compact = true;
          connected = false;
          label = '∅';
        case 'Q':
          open = false;
          closed = false;
          bounded = false;
          compact = false;
          connected = false;
          label = 'Q';
        case 'Z':
          open = false;
          closed = true;
          bounded = false;
          compact = false;
          connected = false;
          label = 'Z';
        default:
          open = false;
          closed = true;
          bounded = true;
          compact = true;
          connected = false;
          label = 'finite set';
      }
    } else {
      final lc = p[1] as bool;
      final rc = p[2] as bool;
      bounded = p[3] as bool;
      open = !lc && !rc;
      closed = lc && rc;
      compact = closed && bounded;
      connected = true; // intervals are connected.
      label = '${lc ? '[' : '('}$extra${rc ? ']' : ')'}';
    }
    final tags = [
      if (open && closed)
        'clopen'
      else if (open)
        'open'
      else if (closed)
        'closed'
      else
        'neither open nor closed',
      compact ? 'compact' : 'not compact',
      connected ? 'connected' : 'disconnected',
      bounded ? 'bounded' : 'unbounded',
    ];
    final score = (open ? 1 : 0) +
        (closed ? 1 : 0) +
        (compact ? 1 : 0) +
        (connected ? 1 : 0);
    return SolveResult(
      answer: '$label is ${tags.join(', ')} (standard topology on R).',
      points: [score.toDouble()],
      customData: [
        {
          'kind': 'topology',
          'set': label,
          'open': open,
          'closed': closed,
          'compact': compact,
          'connected': connected,
          'bounded': bounded,
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
            explanation: _error ?? 'Use (0,1).')
      ];
    }
    final r = solve();
    return [
      const StepModel(
          stepNumber: 1,
          title: 'Open vs closed endpoints',
          explanation: '( ) exclude the endpoint (open side); [ ] include it.'),
      const StepModel(
          stepNumber: 2,
          title: 'Heine–Borel for compactness',
          explanation: 'In R: compact ⟺ closed + bounded.'),
      StepModel(
          stepNumber: 3,
          title: 'Read the classification',
          explanation: r.hasError ? (r.errorMessage ?? '') : r.answer),
    ];
  }
}
