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

enum _Shape { square, rectangle, triangleArea, triangleSides, parallelogram, trapezoid, circle, composite }

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
        return _GeoParsed(shape: _Shape.square, dims: d, unit: unit, diameter: false);
      }
      return null;
    }
    if (t.startsWith('composite') || t.startsWith('l-shape') || t.startsWith('lshape')) {
      final List<List<double>> rects = RegExp(r'(-?\d+(?:\.\d+)?)\s*[x×*]\s*(-?\d+(?:\.\d+)?)')
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
      final List<List<double>> pair = RegExp(r'(-?\d+(?:\.\d+)?)\s*[x×*]\s*(-?\d+(?:\.\d+)?)')
          .allMatches(t)
          .map((m) => [double.parse(m.group(1)!), double.parse(m.group(2)!)])
          .toList();
      if (pair.length == 1) {
        return _GeoParsed(shape: _Shape.rectangle, dims: pair.first, unit: unit, diameter: false);
      }
      final List<double> d = _all(t);
      if (d.length == 2) {
        return _GeoParsed(shape: _Shape.rectangle, dims: d, unit: unit, diameter: false);
      }
      return null;
    }
    if (t.startsWith('triangle')) {
      if (RegExp(r'(\d+(?:\.\d+)?)\s*-\s*(\d+(?:\.\d+)?)\s*-\s*(\d+(?:\.\d+)?)').hasMatch(t)) {
        final List<double> d = _all(t);
        return _GeoParsed(shape: _Shape.triangleSides, dims: d.sublist(0, 3), unit: unit, diameter: false);
      }
      final List<double> d = _all(t);
      if (d.length == 2) {
        return _GeoParsed(shape: _Shape.triangleArea, dims: d, unit: unit, diameter: false);
      }
      if (d.length == 3) {
        return _GeoParsed(shape: _Shape.triangleSides, dims: d, unit: unit, diameter: false);
      }
      return null;
    }
    if (t.startsWith('parallelogram')) {
      final List<double> d = _all(t);
      if (d.length == 2 || d.length == 3) {
        return _GeoParsed(shape: _Shape.parallelogram, dims: d, unit: unit, diameter: false);
      }
      return null;
    }
    if (t.startsWith('trapez')) {
      final List<double> d = _all(t);
      if (d.length == 3) {
        return _GeoParsed(shape: _Shape.trapezoid, dims: d, unit: unit, diameter: false);
      }
      return null;
    }
    if (t.startsWith('circle')) {
      final List<double> d = _all(t);
      if (d.isEmpty) {
        return null;
      }
      final bool dia = t.contains('d=') || t.contains('diameter') || t.contains('d ');
      final double v = d.length == 1 ? d.first : _first(t.split('=').last);
      return _GeoParsed(shape: _Shape.circle, dims: [v], unit: unit, diameter: dia);
    }
    return null;
  }

  static String? _positiveCheck(List<double> dims) {
    if (dims.any((d) => d <= 0)) {
      return 'Lengths must be positive (> 0).';
    }
    return null;
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
      _error = 'Pick a shape first — e.g. rect 6x4, triangle b=8 h=5, circle r=7.';
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
        answer = 'P = ${G6Format.num(4 * s)} $u, A = ${G6Format.num(s * s)} $u²';
        diagram = {'shape': 'square', 'dims': {'s': s}};
      case _Shape.rectangle:
        final double l = p.dims[0], w = p.dims[1];
        answer = 'P = ${G6Format.num(2 * (l + w))} $u, A = ${G6Format.num(l * w)} $u²';
        diagram = {'shape': 'rectangle', 'dims': {'l': l, 'w': w}};
      case _Shape.triangleArea:
        final double b = p.dims[0], h = p.dims[1];
        answer = 'A = ${G6Format.num(b * h / 2)} $u² (b = ${G6Format.num(b)}, h = ${G6Format.num(h)})';
        diagram = {'shape': 'triangle', 'dims': {'b': b, 'h': h}};
      case _Shape.triangleSides:
        final List<double> d = List<double>.from(p.dims)..sort();
        if (d[0] + d[1] <= d[2]) {
          return SolveResult.error('Not a triangle: sides fail the triangle inequality.');
        }
        final double per = d[0] + d[1] + d[2];
        answer = 'P = ${G6Format.num(per)} $u';
        diagram = {'shape': 'triangle', 'dims': {'a': d[0], 'b': d[1], 'c': d[2]}};
      case _Shape.parallelogram:
        final double b = p.dims[0], h = p.dims[1];
        final String extra = p.dims.length == 3
            ? ', P = ${G6Format.num(2 * (b + p.dims[2]))} $u'
            : '';
        answer = 'A = ${G6Format.num(b * h)} $u²$extra';
        diagram = {'shape': 'parallelogram', 'dims': {'b': b, 'h': h}};
      case _Shape.trapezoid:
        final double a = p.dims[0], b = p.dims[1], h = p.dims[2];
        answer = 'A = ${G6Format.num((a + b) / 2 * h)} $u²';
        diagram = {'shape': 'trapezoid', 'dims': {'a': a, 'b': b, 'h': h}};
      case _Shape.circle:
        final double r = p.diameter ? p.dims[0] / 2 : p.dims[0];
        final double c = 2 * math.pi * r;
        final double a = math.pi * r * r;
        answer = 'C = ${G6Format.num(c)} $u, A = ${G6Format.num(a)} $u² (r = ${G6Format.num(r)})';
        diagram = {'shape': 'circle', 'dims': {'r': r}};
      case _Shape.composite:
        var area = 0.0;
        for (var i = 0; i + 1 < p.dims.length; i += 2) {
          area += p.dims[i] * p.dims[i + 1];
        }
        answer = 'A total = ${G6Format.num(area)} $u² (${p.dims.length ~/ 2} rectangles)';
        diagram = {'shape': 'composite', 'dims': {'parts': p.dims}};
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
      return [const StepModel(stepNumber: 1, title: 'Invalid input', explanation: 'Pick a shape — e.g. rect 6x4.')];
    }
    final SolveResult r = solve();
    if (r.hasError) {
      return [StepModel(stepNumber: 1, title: 'Invalid input', explanation: r.errorMessage ?? 'Invalid dimensions.')];
    }
    return [
      StepModel(stepNumber: 1, title: 'Identify the shape', explanation: 'Shape diagram: ${r.customData?.first['shape']}.'),
      const StepModel(stepNumber: 2, title: 'Write the formula', explanation: 'P/A formula for this shape.'),      StepModel(stepNumber: 3, title: 'Substitute dimensions', explanation: 'Given: ${p.dims.map(G6Format.num).join(', ')} ${p.unit}.'),
      StepModel(stepNumber: 4, title: 'Compute', explanation: r.answer),
      StepModel(stepNumber: 5, title: 'Attach units', explanation: 'Lengths in ${p.unit}, areas in ${p.unit}².'),
    ];
  }
}
