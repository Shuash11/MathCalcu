// ─────────────────────────────────────────────────────────────
// M5 MATRICES — determinant + inverse for 2×2 / 3×3. Kills the
// college-matrices stub. Offline, pure Dart. Never throws.
// e.g. 'det [[1,2],[3,4]]', 'inv [[2,0],[0,2]]'.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

/// Determinant / inverse solver for 2×2 and 3×3 matrices.
class M5MatrixEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  M5MatrixEquation(this.rawInput);

  String _norm() =>
      rawInput.replaceAll('−', '-').replaceAll(' ', '').toLowerCase();

  /// Returns [mode, matrix].
  List<dynamic>? _parse() {
    final t = _norm();
    final m =
        RegExp(r'^(det|determinant|inv|inverse)\[?(\[.*\])\]?$').firstMatch(t);
    if (m == null) return null;
    final word = m.group(1)!;
    final mode = word.startsWith('det') ? 'det' : 'inv';
    final mat = _matrixOf(m.group(2)!);
    if (mat == null) return null;
    if (mat.length != 2 && mat.length != 3) return null;
    for (final row in mat) {
      if (row.length != mat.length) return null;
    }
    return [mode, mat];
  }

  /// Parses `[[1,2],[3,4]]` into rows.
  static List<List<double>>? _matrixOf(String s) {
    if (!s.startsWith('[') || !s.endsWith(']')) return null;
    final rows = <List<double>>[];
    final rowRe = RegExp(r'\[([^\[\]]*)\]');
    final matches = rowRe.allMatches(s).toList();
    if (matches.isEmpty) return null;
    for (final m in matches) {
      final body = m.group(1)!.trim();
      if (body.isEmpty) return null;
      final row = <double>[];
      for (final part in body.split(',')) {
        final v = double.tryParse(part.trim());
        if (v == null || !v.isFinite) return null;
        row.add(v);
      }
      rows.add(row);
    }
    // Ensure the whole string was rows (no stray numbers outside).
    final stripped = s.replaceAll(rowRe, '').replaceAll(',', '').trim();
    if (stripped != '[[]]' &&
        stripped.replaceAll('[', '').replaceAll(']', '').isNotEmpty) {
      return null;
    }
    return rows;
  }

  /// Determinant for 2×2 / 3×3.
  static double determinant(List<List<double>> m) {
    if (m.length == 2) {
      return m[0][0] * m[1][1] - m[0][1] * m[1][0];
    }
    final a = m[0][0], b = m[0][1], c = m[0][2];
    final d = m[1][0], e = m[1][1], f = m[1][2];
    final g = m[2][0], h = m[2][1], k = m[2][2];
    return a * (e * k - f * h) - b * (d * k - f * g) + c * (d * h - e * g);
  }

  /// Inverse via adjugate / det. Null when singular.
  static List<List<double>>? inverse(List<List<double>> m) {
    final det = determinant(m);
    if (det.abs() < 1e-12) return null;
    if (m.length == 2) {
      final a = m[0][0], b = m[0][1], c = m[1][0], d = m[1][1];
      return [
        [d / det, -b / det],
        [-c / det, a / det],
      ];
    }
    // 3×3 cofactor transpose.
    double co(int r, int c) {
      final rows = [0, 1, 2].where((i) => i != r).toList();
      final cols = [0, 1, 2].where((i) => i != c).toList();
      final minor = m[rows[0]][cols[0]] * m[rows[1]][cols[1]] -
          m[rows[0]][cols[1]] * m[rows[1]][cols[0]];
      return ((r + c) % 2 == 0 ? 1 : -1) * minor;
    }

    return [
      for (var r = 0; r < 3; r++) [for (var c = 0; c < 3; c++) co(c, r) / det],
    ];
  }

  static String fmtMat(List<List<double>> m) {
    String row(List<double> r) =>
        '[${r.map((v) => G6Format.num(v)).join(', ')}]';
    return '[${m.map(row).join(', ')}]';
  }

  @override
  bool validate() {
    final empty =
        FieldValidators.notEmpty(rawInput, example: 'det [[1,2],[3,4]]');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_parse() == null) {
      _error = 'Use det [[1,2],[3,4]] or inv [[2,0],[0,2]] (2×2 / 3×3).';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Use det [[1,2],[3,4]].');
    }
    final mode = p[0] as String;
    final mat = p[1] as List<List<double>>;
    final det = determinant(mat);
    if (mode == 'det') {
      return SolveResult(
        answer: 'det = ${G6Format.num(det)}',
        points: [det],
        customData: [
          {
            'kind': 'matrix',
            'mode': 'det',
            'size': mat.length,
            'det': det,
            'matrix': mat,
          }
        ],
      );
    }
    final inv = inverse(mat);
    if (inv == null) {
      return SolveResult.error(
          'Singular matrix (det = 0) — no inverse exists.');
    }
    return SolveResult(
      answer: 'inv = ${fmtMat(inv)} (det = ${G6Format.num(det)})',
      points: [det],
      customData: [
        {
          'kind': 'matrix',
          'mode': 'inv',
          'size': mat.length,
          'det': det,
          'matrix': mat,
          'inverse': inv,
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
            explanation: _error ?? 'Use det [[1,2],[3,4]].')
      ];
    }
    final r = solve();
    final n = (p[1] as List).length;
    final isDet = p[0] == 'det';
    final steps = [
      StepModel(
          stepNumber: 1,
          title: n == 2 ? 'Write ad − bc' : 'Write the Sarrus/cofactor sum',
          explanation: n == 2
              ? 'det = a·d − b·c for [[a,b],[c,d]].'
              : 'det = a(ei−fh) − b(di−fg) + c(dh−eg).'),
      StepModel(
          stepNumber: 2,
          title: isDet ? 'Evaluate the determinant' : 'Check det ≠ 0',
          explanation: isDet
              ? (r.hasError ? (r.errorMessage ?? '') : r.answer)
              : 'det = ${G6Format.num(determinant(p[1] as List<List<double>>))}; '
                  'zero means singular (no inverse).'),
      if (!isDet)
        StepModel(
            stepNumber: 3,
            title: 'Adjugate ÷ det',
            explanation: r.hasError ? (r.errorMessage ?? '') : r.answer),
      StepModel(
          stepNumber: isDet ? 3 : 4,
          title: 'Verify',
          explanation: 'Multiply A·A⁻¹ — the identity confirms it.'),
    ];
    return steps;
  }
}
