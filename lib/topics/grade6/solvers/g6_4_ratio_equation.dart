// ─────────────────────────────────────────────────────────────
// G6-4 RATIO & PROPORTION — simplify, missing term (cross-multiply),
// direct / inverse variation, partitive sharing + bar-strip data.
// DepEd M6NS-Id-140. Offline, pure Dart.
// hintText: 'e.g. 12:18 or 3/4 = x/20'.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

import 'g6_support.dart';

enum _RatioKind { simplify, proportion, direct, inverse, partitive }

class _RatioParsed {
  final _RatioKind kind;
  final List<double> values;
  final int unknownIndex;
  final List<double> parts;
  final double total;
  final String raw;

  const _RatioParsed({
    required this.kind,
    required this.values,
    required this.unknownIndex,
    required this.parts,
    required this.total,
    required this.raw,
  });
}

/// G6-4 solver.
class G6RatioEquation extends BaseEquation {
  @override
  final String rawInput;

  String? _error;

  G6RatioEquation(this.rawInput);

  static final RegExp _partitive =
      RegExp(r'^(?:divide\s+)?(-?\d+(?:\.\d+)?)\s+in(?:to)?(?:\s+ratio)?\s+([\d\s:.,;]+)$');
  static final RegExp _direct = RegExp(
    r'^direct\b.*?x\s*=\s*(-?\d+(?:\.\d+)?).*?y\s*=\s*(-?\d+(?:\.\d+)?)(?:.*?x\s*=\s*(-?\d+(?:\.\d+)?))?.*?$',
  );
  static final RegExp _inverse = RegExp(
    r'^inverse\b.*?x\s*=\s*(-?\d+(?:\.\d+)?).*?y\s*=\s*(-?\d+(?:\.\d+)?)(?:.*?x\s*=\s*(-?\d+(?:\.\d+)?))?.*?$',
  );

  String _normalized() {
    return rawInput.replaceAll('−', '-').trim();
  }

  /// Splits one side (`3:4`, `3/4`, `x/20`) into two tokens.
  static List<String>? _sideTokens(String side) {
    final String t = side.trim();
    if (t.contains(':')) {
      final List<String> parts = t.split(':');
      if (parts.length == 2) {
        return parts;
      }
      return null;
    }
    if (t.contains('/')) {
      final List<String> parts = t.split('/');
      if (parts.length == 2) {
        return parts;
      }
      return null;
    }
    return null;
  }

  static bool _isUnknown(String token) {
    return token.trim().toLowerCase() == 'x';
  }

  _RatioParsed? _parse() {
    final String t = _normalized().toLowerCase();
    if (t.startsWith('direct')) {
      final RegExpMatch? m = _direct.firstMatch(t);
      if (m == null) {
        return null;
      }
      return _RatioParsed(
        kind: _RatioKind.direct,
        values: [
          double.parse(m.group(1)!),
          double.parse(m.group(2)!),
          m.group(3) == null ? double.nan : double.parse(m.group(3)!),
        ],
        unknownIndex: -1,
        parts: const [],
        total: 0,
        raw: rawInput,
      );
    }
    if (t.startsWith('inverse')) {
      final RegExpMatch? m = _inverse.firstMatch(t);
      if (m == null) {
        return null;
      }
      return _RatioParsed(
        kind: _RatioKind.inverse,
        values: [
          double.parse(m.group(1)!),
          double.parse(m.group(2)!),
          m.group(3) == null ? double.nan : double.parse(m.group(3)!),
        ],
        unknownIndex: -1,
        parts: const [],
        total: 0,
        raw: rawInput,
      );
    }
    final RegExpMatch? part = _partitive.firstMatch(t);
    if (part != null && !t.contains('=')) {
      final double total = double.parse(part.group(1)!);
      final List<double> parts = RegExp(r'\d+(?:\.\d+)?')
          .allMatches(part.group(2)!)
          .map((m) => double.parse(m.group(0)!))
          .toList();
      if (parts.length >= 2) {
        return _RatioParsed(
          kind: _RatioKind.partitive,
          values: const [],
          unknownIndex: -1,
          parts: parts,
          total: total,
          raw: rawInput,
        );
      }
      return null;
    }
    if (t.contains('=')) {
      final List<String> sides = t.split('=');
      if (sides.length == 2) {
        final List<String>? left = _sideTokens(sides[0]);
        final List<String>? right = _sideTokens(sides[1]);
        if (left != null && right != null) {
          final List<String> all = [...left, ...right];
          final int unknowns =
              all.where((tok) => _isUnknown(tok)).length;
          if (unknowns == 1) {
            final List<double> values = all.map((tok) {
              if (_isUnknown(tok)) {
                return double.nan;
              }
              return double.parse(tok.trim());
            }).toList();
            return _RatioParsed(
              kind: _RatioKind.proportion,
              values: values,
              unknownIndex: all.indexWhere((tok) => _isUnknown(tok)),
              parts: const [],
              total: 0,
              raw: rawInput,
            );
          }
        }
      }
      return null;
    }
    final List<String>? simple = _sideTokens(t);
    if (simple != null && !_isUnknown(simple[0]) && !_isUnknown(simple[1])) {
      return _RatioParsed(
        kind: _RatioKind.simplify,
        values: [
          double.parse(simple[0].trim()),
          double.parse(simple[1].trim()),
        ],
        unknownIndex: -1,
        parts: const [],
        total: 0,
        raw: rawInput,
      );
    }
    return null;
  }

  /// Scales decimals to whole numbers, then simplifies by GCD.
  static List<int> _simplifyPair(double a, double b) {
    var scale = 1;
    while ((a * scale) != (a * scale).truncateToDouble() ||
        (b * scale) != (b * scale).truncateToDouble()) {
      scale *= 10;
      if (scale > 1000000) {
        break;
      }
    }
    final int ai = (a * scale).round();
    final int bi = (b * scale).round();
    final int g = G6Math.gcd(ai, bi);
    return [ai ~/ g, bi ~/ g, g];
  }

  @override
  bool validate() {
    final String? empty = FieldValidators.notEmpty(
      rawInput,
      example: '12:18 or 3/4 = x/20',
    );
    if (empty != null) {
      _error = empty;
      return false;
    }
    final _RatioParsed? p = _parse();
    if (p == null) {
      _error = 'Use a:b, a/b = x/d, direct/inverse x/y, or 120 in 2:3.';
      return false;
    }
    if (p.kind == _RatioKind.simplify &&
        (p.values[0] <= 0 || p.values[1] <= 0)) {
      _error = 'Ratio terms must be positive — e.g. 12:18.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final _RatioParsed? p = _parse();
    if (p == null) {
      return SolveResult.error(
        _error ?? 'Use a:b or a/b = x/d — e.g. 12:18.',
      );
    }
    switch (p.kind) {
      case _RatioKind.simplify:
        final List<int> s = _simplifyPair(p.values[0], p.values[1]);
        return SolveResult(
          answer: '${s[0]}:${s[1]}',
          points: [s[0].toDouble(), s[1].toDouble()],
          customData: [
            {
              'bars': [
                {'label': 'A', 'value': s[0]},
                {'label': 'B', 'value': s[1]},
              ],
              'gcd': s[2],
            }
          ],
        );
      case _RatioKind.proportion:
        final List<double> v = List<double>.from(p.values);
        // a/b = c/d with one unknown: cross-multiply.
        final double a = v[0], b = v[1], c = v[2], d = v[3];
        late final double x;
        if (p.unknownIndex == 0) {
          if (d == 0) {
            return SolveResult.error('Denominator cannot be zero.');
          }
          x = b * c / d;
        } else if (p.unknownIndex == 1) {
          if (c == 0) {
            return SolveResult.error('Cannot divide by zero.');
          }
          x = a * d / c;
        } else if (p.unknownIndex == 2) {
          if (b == 0) {
            return SolveResult.error('Denominator cannot be zero.');
          }
          x = a * d / b;
        } else {
          if (a == 0) {
            return SolveResult.error('Cannot divide by zero.');
          }
          x = b * c / a;
        }
        v[p.unknownIndex] = x;
        return SolveResult(
          answer: 'x = ${G6Format.num(x)}',
          points: [x],
          customData: [
            {
              'bars': [
                {'label': 'A', 'value': v[0].isNaN ? 0 : v[0]},
                {'label': 'B', 'value': v[1].isNaN ? 0 : v[1]},
                {'label': 'C', 'value': v[2].isNaN ? 0 : v[2]},
                {'label': 'D', 'value': v[3].isNaN ? 0 : v[3]},
              ],
              'check': G6Format.num(v[0] * v[3]) == G6Format.num(v[1] * v[2]),
            }
          ],
        );
      case _RatioKind.direct:
        final double x = p.values[0], y = p.values[1];
        if (x == 0) {
          return SolveResult.error('x cannot be zero for direct variation.');
        }
        final double k = y / x;
        final double target = p.values[2];
        final String answer = target.isNaN
            ? 'k = ${G6Format.num(k)} (y = kx)'
            : 'k = ${G6Format.num(k)}, y = ${G6Format.num(k * target)} when x = ${G6Format.num(target)}';
        return SolveResult(
          answer: answer,
          points: [k],
          customData: [
            {
              'bars': [
                {'label': 'x', 'value': x},
                {'label': 'y', 'value': y},
              ],
              'k': k,
            }
          ],
        );
      case _RatioKind.inverse:
        final double x = p.values[0], y = p.values[1];
        final double k = x * y;
        final double target = p.values[2];
        final String answer = target.isNaN
            ? 'k = ${G6Format.num(k)} (xy = k)'
            : 'k = ${G6Format.num(k)}, y = ${G6Format.num(k / target)} when x = ${G6Format.num(target)}';
        if (!target.isNaN && target == 0) {
          return SolveResult.error('x cannot be zero for inverse variation.');
        }
        return SolveResult(
          answer: answer,
          points: [k],
          customData: [
            {
              'bars': [
                {'label': 'x', 'value': x},
                {'label': 'y', 'value': y},
              ],
              'k': k,
            }
          ],
        );
      case _RatioKind.partitive:
        final double sum = p.parts.reduce((a, b) => a + b);
        if (sum == 0) {
          return SolveResult.error('Ratio parts cannot all be zero.');
        }
        final List<double> shares =
            p.parts.map((part) => p.total * part / sum).toList();
        final String answer = shares
            .map((s) => G6Format.num(s))
            .join(' : ');
        return SolveResult(
          answer: answer,
          points: shares,
          customData: [
            {
              'bars': [
                for (var i = 0; i < shares.length; i++)
                  {'label': 'Part ${i + 1}', 'value': shares[i]},
              ],
              'sum': sum,
            }
          ],
        );
    }
  }

  @override
  List<StepModel> getSteps() {
    final _RatioParsed? p = _parse();
    if (p == null) {
      return [
        StepModel(
          stepNumber: 1,
          title: 'Invalid input',
          explanation: _error ?? 'Use a:b or a/b = x/d.',
        ),
      ];
    }
    switch (p.kind) {
      case _RatioKind.simplify:
        final List<int> s = _simplifyPair(p.values[0], p.values[1]);
        return [
          StepModel(
            stepNumber: 1,
            title: 'Write as a fraction',
            explanation:
                '${G6Format.num(p.values[0])}:${G6Format.num(p.values[1])} = '
                '${p.values[0].truncate()}/${p.values[1].truncate()}.',
          ),
          StepModel(
            stepNumber: 2,
            title: 'Find the GCD',
            explanation: 'GCD is ${s[2]}.',
          ),
          StepModel(
            stepNumber: 3,
            title: 'Divide both terms',
            explanation: '${s[0]}:${s[1]}.',
          ),
          StepModel(
            stepNumber: 4,
            title: 'Verify with bar strips',
            explanation:
                'Bars of length ${s[0]} and ${s[1]} keep the same proportion.',
          ),
        ];
      case _RatioKind.proportion:
        final SolveResult r = solve();
        return [
          const StepModel(
            stepNumber: 1,
            title: 'Write as fractions',
            explanation: 'Both sides as fractions with x in place.',
          ),
          const StepModel(
            stepNumber: 2,
            title: 'Simplify known side',
            explanation: 'Reduce if both terms share a GCD.',
          ),
          const StepModel(
            stepNumber: 3,
            title: 'Cross-multiply',
            explanation: 'Opposite products are equal — solve for x.',
          ),
          StepModel(
            stepNumber: 4,
            title: 'Verify',
            explanation: '${r.answer}; cross-products match.',
          ),
        ];
      case _RatioKind.direct:
        return [
          const StepModel(
            stepNumber: 1,
            title: 'Direct form y = kx',
            explanation: 'Direct variation passes through the origin.',
          ),
          StepModel(
            stepNumber: 2,
            title: 'k = y ÷ x',
            explanation: '${solve().answer}.',
          ),
          const StepModel(
            stepNumber: 3,
            title: 'Use k for new values',
            explanation: 'Substitute x to predict y.',
          ),
        ];
      case _RatioKind.inverse:
        return [
          const StepModel(
            stepNumber: 1,
            title: 'Inverse form xy = k',
            explanation: 'As x grows, y shrinks.',
          ),
          StepModel(
            stepNumber: 2,
            title: 'k = x × y',
            explanation: '${solve().answer}.',
          ),
          const StepModel(
            stepNumber: 3,
            title: 'Use k for new values',
            explanation: 'y = k ÷ x for any new x.',
          ),
        ];
      case _RatioKind.partitive:
        final SolveResult r = solve();
        return [
          const StepModel(
            stepNumber: 1,
            title: 'Add the parts',
            explanation: 'Total parts share the whole amount.',
          ),
          const StepModel(
            stepNumber: 2,
            title: 'One part = total ÷ parts',
            explanation: 'Unit share first.',
          ),
          StepModel(
            stepNumber: 3,
            title: 'Multiply per part',
            explanation: '${r.answer}.',
          ),
          const StepModel(
            stepNumber: 4,
            title: 'Check the sum',
            explanation: 'Shares add back to the total.',
          ),
        ];
    }
  }
}
