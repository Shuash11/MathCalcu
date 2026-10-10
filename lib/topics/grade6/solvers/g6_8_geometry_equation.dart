// ─────────────────────────────────────────────────────────────
// G6-8 GEOMETRY — perimeter/area for square, rectangle, triangle,
// parallelogram, trapezoid, circle + composite rects, with shape
// diagram data (shape + dims in customData). DepEd M6GE-IIIc-37.
// Offline, pure Dart. Prefer dropdown + numeric fields in UI;
// this solver also accepts compact text like `rect 6x4`.
// ─────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

import 'g6_support.dart';

enum _Shape {
  square,
  rectangle,
  triangleArea,
  triangleSides,
  parallelogram,
  trapezoid,
  circle,
  composite
}

class _GeoParsed {
  final _Shape shape;
  final List<double> dims;
  final String unit;
  final bool diameter;

  const _GeoParsed({
    required this.shape,
    required this.dims,
    required this.unit,
    required this.diameter,
  });
}

/// G6-8 solver.
class G6GeometryEquation extends BaseEquation {
  @override
  final String rawInput;

  String? _error;

  G6GeometryEquation(this.rawInput);

  static final RegExp _n = RegExp(r'-?\d+(?:\.\d+)?');

  static double _first(String s) => double.parse(_n.firstMatch(s)!.group(0)!);
  static List<double> _all(String s) =>
      _n.allMatches(s).map((m) => double.parse(m.group(0)!)).toList();

  String _unit(String t) {
    if (t.contains('mm')) {
      return 'mm';
    }
    // A unit suffix attached to a number ('6m', '4m') — the standalone-m
    // regex below misses it, so 'rect 6m x 4m' used to default to cm (BUG C).
    if (RegExp(r'\d\s*m(?![a-z])').hasMatch(t)) {
      return 'm';
    }
    if (RegExp(r'(^|[\s,=])m([\s,]|$)').hasMatch(t)) {
      return 'm';
    }
    return 'cm';
  }

  _GeoParsed? _parse() {
    final String t = rawInput.toLowerCase().replaceAll('−', '-');
    final String unit = _unit(t);
    if (t.startsWith('square')) {
      final List<double> d = _all(t);
      if (d.length == 1) {
        return _GeoParsed(
            shape: _Shape.square, dims: d, unit: unit, diameter: false);
      }
      return null;
    }
    if (t.startsWith('composite') ||
        t.startsWith('l-shape') ||
        t.startsWith('lshape')) {
      final List<List<double>> rects = RegExp(
              r'(-?\d+(?:\.\d+)?)\s*[x×*]\s*(-?\d+(?:\.\d+)?)')
          .allMatches(t)
          .map((m) => [double.parse(m.group(1)!), double.parse(m.group(2)!)])
          .toList();
      if (rects.length >= 2) {
        return _GeoParsed(
          shape: _Shape.composite,
          dims: [for (final r in rects) ...r],
          unit: unit,
          diameter: false,
        );
      }
      return null;
    }
    if (t.startsWith('rect')) {
      final List<List<double>> pair = RegExp(
              r'(-?\d+(?:\.\d+)?)\s*[x×*]\s*(-?\d+(?:\.\d+)?)')
          .allMatches(t)
          .map((m) => [double.parse(m.group(1)!), double.parse(m.group(2)!)])
          .toList();
      if (pair.length == 1) {
        return _GeoParsed(
            shape: _Shape.rectangle,
            dims: pair.first,
            unit: unit,
            diameter: false);
      }
      final List<double> d = _all(t);
      if (d.length == 2) {
        return _GeoParsed(
            shape: _Shape.rectangle, dims: d, unit: unit, diameter: false);
      }
      return null;
    }
    if (t.startsWith('triangle')) {
      if (RegExp(r'(\d+(?:\.\d+)?)\s*-\s*(\d+(?:\.\d+)?)\s*-\s*(\d+(?:\.\d+)?)')
          .hasMatch(t)) {
        final List<double> d = _all(t);
        return _GeoParsed(
            shape: _Shape.triangleSides,
            dims: d.sublist(0, 3),
            unit: unit,
            diameter: false);
      }
      final List<double> d = _all(t);
      if (d.length == 2) {
        return _GeoParsed(
            shape: _Shape.triangleArea, dims: d, unit: unit, diameter: false);
      }
      if (d.length == 3) {
        return _GeoParsed(
            shape: _Shape.triangleSides, dims: d, unit: unit, diameter: false);
      }
      return null;
    }
    if (t.startsWith('parallelogram')) {
      final List<double> d = _all(t);
      if (d.length == 2 || d.length == 3) {
        return _GeoParsed(
            shape: _Shape.parallelogram, dims: d, unit: unit, diameter: false);
      }
      return null;
    }
    if (t.startsWith('trapez')) {
      final List<double> d = _all(t);
      if (d.length == 3) {
        return _GeoParsed(
            shape: _Shape.trapezoid, dims: d, unit: unit, diameter: false);
      }
      return null;
    }
    if (t.startsWith('circle')) {
      final List<double> d = _all(t);
      if (d.isEmpty) {
        return null;
      }
      final bool dia =
          t.contains('d=') || t.contains('diameter') || t.contains('d ');
      final double v = d.length == 1 ? d.first : _first(t.split('=').last);
      return _GeoParsed(
          shape: _Shape.circle, dims: [v], unit: unit, diameter: dia);
    }
    return null;
  }

  static String? _positiveCheck(List<double> dims) {
    if (dims.any((d) => d <= 0)) {
      return 'Lengths must be positive (> 0).';
    }
    return null;
  }

  static String _u(String unit) => '\\text{$unit}';
  static String _u2(String unit) => '\\text{$unit}^{2}';

  /// Symbolic formula for the parsed shape (TeX, ASCII).
  static String _formulaTex(_GeoParsed p) {
    switch (p.shape) {
      case _Shape.square:
        return 'P = 4s, \\quad A = s^{2}';
      case _Shape.rectangle:
        return 'P = 2(l + w), \\quad A = l \\cdot w';
      case _Shape.triangleArea:
        return 'A = \\frac{1}{2} b h';
      case _Shape.triangleSides:
        return 'P = a + b + c';
      case _Shape.parallelogram:
        return p.dims.length == 3
            ? 'A = b h, \\quad P = 2(b + s)'
            : 'A = b h';
      case _Shape.trapezoid:
        return 'A = \\frac{a + b}{2} h';
      case _Shape.circle:
        return 'C = 2 \\pi r, \\quad A = \\pi r^{2}';
      case _Shape.composite:
        final int n = p.dims.length ~/ 2;
        return 'A = ${[
          for (var i = 1; i <= n; i++) "l_{$i} w_{$i}",
        ].join(' + ')}';
    }
  }

  /// The formula with the parsed dimensions substituted (TeX, ASCII).
  static String _substTex(_GeoParsed p) {
    final List<double> d = p.dims;
    switch (p.shape) {
      case _Shape.square:
        return 'P = 4(${G6Format.num(d[0])}), \\quad '
            'A = ${G6Format.num(d[0])}^{2}';
      case _Shape.rectangle:
        return 'P = 2(${G6Format.num(d[0])} + ${G6Format.num(d[1])}), '
            '\\quad A = ${G6Format.num(d[0])} \\cdot ${G6Format.num(d[1])}';
      case _Shape.triangleArea:
        return 'A = \\frac{1}{2} \\cdot ${G6Format.num(d[0])} \\cdot '
            '${G6Format.num(d[1])}';
      case _Shape.triangleSides:
        final List<double> s = List<double>.from(d)..sort();
        return 'P = ${G6Format.num(s[0])} + ${G6Format.num(s[1])} + '
            '${G6Format.num(s[2])}';
      case _Shape.parallelogram:
        final String base =
            'A = ${G6Format.num(d[0])} \\cdot ${G6Format.num(d[1])}';
        return d.length == 3
            ? '$base, \\quad P = 2(${G6Format.num(d[0])} + '
                '${G6Format.num(d[2])})'
            : base;
      case _Shape.trapezoid:
        return 'A = \\frac{${G6Format.num(d[0])} + ${G6Format.num(d[1])}}{2} '
            '\\cdot ${G6Format.num(d[2])}';
      case _Shape.circle:
        final double r = p.diameter ? d[0] / 2 : d[0];
        return 'C = 2 \\pi (${G6Format.num(r)}), \\quad '
            'A = \\pi (${G6Format.num(r)})^{2}';
      case _Shape.composite:
        return 'A = ${[
          for (var i = 0; i + 1 < d.length; i += 2)
            "${G6Format.num(d[i])} \\cdot ${G6Format.num(d[i + 1])}",
        ].join(' + ')}';
    }
  }

  /// The computed result with units (TeX, ASCII).
  static String _resultTex(_GeoParsed p) {
    final String u = p.unit;
    final List<double> d = p.dims;
    switch (p.shape) {
      case _Shape.square:
        return 'P = ${G6Format.num(4 * d[0])} ${_u(u)}, \\quad '
            'A = ${G6Format.num(d[0] * d[0])} ${_u2(u)}';
      case _Shape.rectangle:
        return 'P = ${G6Format.num(2 * (d[0] + d[1]))} ${_u(u)}, \\quad '
            'A = ${G6Format.num(d[0] * d[1])} ${_u2(u)}';
      case _Shape.triangleArea:
        return 'A = ${G6Format.num(d[0] * d[1] / 2)} ${_u2(u)}';
      case _Shape.triangleSides:
        final List<double> s = List<double>.from(d)..sort();
        return 'P = ${G6Format.num(s[0] + s[1] + s[2])} ${_u(u)}';
      case _Shape.parallelogram:
        final String base = 'A = ${G6Format.num(d[0] * d[1])} ${_u2(u)}';
        return d.length == 3
            ? '$base, \\quad P = ${G6Format.num(2 * (d[0] + d[2]))} ${_u(u)}'
            : base;
      case _Shape.trapezoid:
        return 'A = ${G6Format.num((d[0] + d[1]) / 2 * d[2])} ${_u2(u)}';
      case _Shape.circle:
        final double r = p.diameter ? d[0] / 2 : d[0];
        return 'C = ${G6Format.num(2 * math.pi * r)} ${_u(u)}, \\quad '
            'A = ${G6Format.num(math.pi * r * r)} ${_u2(u)}';
      case _Shape.composite:
        var area = 0.0;
        for (var i = 0; i + 1 < d.length; i += 2) {
          area += d[i] * d[i + 1];
        }
        return 'A = ${G6Format.num(area)} ${_u2(u)}';
    }
  }

  @override
  bool validate() {
    final String? empty = FieldValidators.notEmpty(
      rawInput,
      example: 'rect 6x4',
    );
    if (empty != null) {
      _error = empty;
      return false;
    }
    final _GeoParsed? p = _parse();
    if (p == null) {
      _error =
          'Pick a shape first — e.g. rect 6x4, triangle b=8 h=5, circle r=7.';
      return false;
    }
    final String? pos = _positiveCheck(p.dims);
    if (pos != null) {
      _error = pos;
      return false;
    }
    if (p.shape == _Shape.triangleSides) {
      final List<double> d = List<double>.from(p.dims)..sort();
      if (d[0] + d[1] <= d[2]) {
        _error = 'Not a triangle: sides fail the triangle inequality.';
        return false;
      }
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final _GeoParsed? p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Pick a shape — e.g. rect 6x4.');
    }
    final String? pos = _positiveCheck(p.dims);
    if (pos != null) {
      return SolveResult.error(pos);
    }
    final String u = p.unit;
    late final String answer;
    late final Map<String, dynamic> diagram;
    switch (p.shape) {
      case _Shape.square:
        final double s = p.dims[0];
        answer =
            'P = ${G6Format.num(4 * s)} $u, A = ${G6Format.num(s * s)} $u²';
        diagram = {
          'shape': 'square',
          'dims': {'s': s}
        };
      case _Shape.rectangle:
        final double l = p.dims[0], w = p.dims[1];
        answer =
            'P = ${G6Format.num(2 * (l + w))} $u, A = ${G6Format.num(l * w)} $u²';
        diagram = {
          'shape': 'rectangle',
          'dims': {'l': l, 'w': w}
        };
      case _Shape.triangleArea:
        final double b = p.dims[0], h = p.dims[1];
        answer =
            'A = ${G6Format.num(b * h / 2)} $u² (b = ${G6Format.num(b)}, h = ${G6Format.num(h)})';
        diagram = {
          'shape': 'triangle',
          'dims': {'b': b, 'h': h}
        };
      case _Shape.triangleSides:
        final List<double> d = List<double>.from(p.dims)..sort();
        if (d[0] + d[1] <= d[2]) {
          return SolveResult.error(
              'Not a triangle: sides fail the triangle inequality.');
        }
        final double per = d[0] + d[1] + d[2];
        answer = 'P = ${G6Format.num(per)} $u';
        diagram = {
          'shape': 'triangle',
          'dims': {'a': d[0], 'b': d[1], 'c': d[2]}
        };
      case _Shape.parallelogram:
        final double b = p.dims[0], h = p.dims[1];
        final String extra = p.dims.length == 3
            ? ', P = ${G6Format.num(2 * (b + p.dims[2]))} $u'
            : '';
        answer = 'A = ${G6Format.num(b * h)} $u²$extra';
        diagram = {
          'shape': 'parallelogram',
          'dims': {'b': b, 'h': h}
        };
      case _Shape.trapezoid:
        final double a = p.dims[0], b = p.dims[1], h = p.dims[2];
        answer = 'A = ${G6Format.num((a + b) / 2 * h)} $u²';
        diagram = {
          'shape': 'trapezoid',
          'dims': {'a': a, 'b': b, 'h': h}
        };
      case _Shape.circle:
        final double r = p.diameter ? p.dims[0] / 2 : p.dims[0];
        final double c = 2 * math.pi * r;
        final double a = math.pi * r * r;
        answer =
            'C = ${G6Format.num(c)} $u, A = ${G6Format.num(a)} $u² (r = ${G6Format.num(r)})';
        diagram = {
          'shape': 'circle',
          'dims': {'r': r}
        };
      case _Shape.composite:
        var area = 0.0;
        for (var i = 0; i + 1 < p.dims.length; i += 2) {
          area += p.dims[i] * p.dims[i + 1];
        }
        answer =
            'A total = ${G6Format.num(area)} $u² (${p.dims.length ~/ 2} rectangles)';
        diagram = {
          'shape': 'composite',
          'dims': {'parts': p.dims}
        };
    }
    return SolveResult(
      answer: answer,
      points: [p.dims.first],
      customData: [diagram],
    );
  }

  @override
  List<StepModel> getSteps() {
    final _GeoParsed? p = _parse();
    if (p == null) {
      return [
        const StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: 'Pick a shape — e.g. rect 6x4.')
      ];
    }
    final SolveResult r = solve();
    if (r.hasError) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: r.errorMessage ?? 'Invalid dimensions.')
      ];
    }
    return [
      StepModel(
          stepNumber: 1,
          title: 'Identify the shape',
          explanation: 'Shape diagram: ${r.customData?.first['shape']}.'),
      StepModel(
          stepNumber: 2,
          title: 'Write the formula',
          explanation: 'P/A formula for this shape.',
          latex: _formulaTex(p)),
      StepModel(
          stepNumber: 3,
          title: 'Substitute dimensions',
          explanation:
              'Given: ${p.dims.map(G6Format.num).join(', ')} ${p.unit}.',
          latex: _substTex(p)),
      StepModel(
          stepNumber: 4,
          title: 'Compute',
          explanation: r.answer,
          latex: _resultTex(p)),
      StepModel(
          stepNumber: 5,
          title: 'Attach units',
          explanation: 'Lengths in ${p.unit}, areas in ${p.unit}².'),
    ];
  }
}
