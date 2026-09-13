// ─────────────────────────────────────────────────────────────
// G6-9 VOLUME — cube, rectangular prism, cylinder, cone, square
// pyramid, sphere + unit³ + wireframe data for the graph layer.
// DepEd M6ME-IVa-95. Offline, pure Dart.
// hintText: 'e.g. 5 x 3 x 2'.
// ─────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

import 'g6_support.dart';

enum _Solid { cube, prism, cylinder, cone, pyramid, sphere }

class _VolParsed {
  final _Solid solid;
  final List<double> dims;

  const _VolParsed({required this.solid, required this.dims});
}

/// G6-9 solver: `cube s=4`, `prism 5x3x2`, `cyl r=3 h=7`,
/// `cone r=3 h=6`, `pyramid 4x4 h=6`, `sphere r=3`.
class G6VolumeEquation extends BaseEquation {
  @override
  final String rawInput;

  String? _error;

  G6VolumeEquation(this.rawInput);

  static final RegExp _n = RegExp(r'-?\d+(?:\.\d+)?');
  static List<double> _all(String s) =>
      _n.allMatches(s).map((m) => double.parse(m.group(0)!)).toList();

  _VolParsed? _parse() {
    final String t = rawInput.toLowerCase().replaceAll('−', '-');
    if (t.startsWith('cube')) {
      final List<double> d = _all(t);
      if (d.length == 1) {
        return _VolParsed(solid: _Solid.cube, dims: d);
      }
      return null;
    }
    if (t.startsWith('prism') || t.startsWith('box') || t.startsWith('rect')) {
      final List<double> d = _all(t);
      if (d.length == 3) {
        return _VolParsed(solid: _Solid.prism, dims: d);
      }
      return null;
    }
    if (t.startsWith('cyl')) {
      final List<double> d = _all(t);
      if (d.length == 2) {
        return _VolParsed(solid: _Solid.cylinder, dims: d);
      }
      return null;
    }
    if (t.startsWith('cone')) {
      final List<double> d = _all(t);
      if (d.length == 2) {
        return _VolParsed(solid: _Solid.cone, dims: d);
      }
      return null;
    }
    if (t.startsWith('pyr')) {
      final List<double> d = _all(t);
      if (d.length == 2) {
        return _VolParsed(solid: _Solid.pyramid, dims: [d[0], d[0], d[1]]);
      }
      if (d.length == 3) {
        return _VolParsed(solid: _Solid.pyramid, dims: d);
      }
      return null;
    }
    if (t.startsWith('sph')) {
      final List<double> d = _all(t);
      if (d.length == 1) {
        return _VolParsed(solid: _Solid.sphere, dims: d);
      }
      return null;
    }
    return null;
  }

  static String _name(_Solid s) {
    switch (s) {
      case _Solid.cube:
        return 'cube';
      case _Solid.prism:
        return 'rectangular prism';
      case _Solid.cylinder:
        return 'cylinder';
      case _Solid.cone:
        return 'cone';
      case _Solid.pyramid:
        return 'square pyramid';
      case _Solid.sphere:
        return 'sphere';
    }
  }

  static String _formula(_Solid s) {
    switch (s) {
      case _Solid.cube:
        return 'V = s³';
      case _Solid.prism:
        return 'V = l × w × h';
      case _Solid.cylinder:
        return 'V = πr²h';
      case _Solid.cone:
        return 'V = πr²h ÷ 3';
      case _Solid.pyramid:
        return 'V = l × w × h ÷ 3';
      case _Solid.sphere:
        return 'V = 4/3 πr³';
    }
  }

  @override
  bool validate() {
    final String? empty = FieldValidators.notEmpty(
      rawInput,
      example: '5 x 3 x 2',
    );
    if (empty != null) {
      _error = empty;
      return false;
    }
    final _VolParsed? p = _parse();
    if (p == null) {
      _error = 'Use L x W x H in same units — e.g. prism 5x3x2, cyl r=3 h=7.';
      return false;
    }
    if (p.dims.any((d) => d <= 0)) {
      _error = 'Lengths must be positive (> 0).';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final _VolParsed? p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Use L x W x H — e.g. 5 x 3 x 2.');
    }
    if (p.dims.any((d) => d <= 0)) {
      return SolveResult.error('Lengths must be positive (> 0).');
    }
    late final double v;
    switch (p.solid) {
      case _Solid.cube:
        v = p.dims[0] * p.dims[0] * p.dims[0];
      case _Solid.prism:
        v = p.dims[0] * p.dims[1] * p.dims[2];
      case _Solid.cylinder:
        v = math.pi * p.dims[0] * p.dims[0] * p.dims[1];
      case _Solid.cone:
        v = math.pi * p.dims[0] * p.dims[0] * p.dims[1] / 3;
      case _Solid.pyramid:
        v = p.dims[0] * p.dims[1] * p.dims[2] / 3;
      case _Solid.sphere:
        v = 4 / 3 * math.pi * p.dims[0] * p.dims[0] * p.dims[0];
    }
    return SolveResult(
      answer: 'V = ${G6Format.num(v)} unit³ (${_name(p.solid)})',
      points: [v],
      customData: [
        {
          'solid': _name(p.solid),
          'dims': p.dims,
          'formula': _formula(p.solid),
        }
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final _VolParsed? p = _parse();
    if (p == null) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: _error ?? 'Use L x W x H — e.g. 5 x 3 x 2.'),
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
          title: 'Write the formula',
          explanation: _formula(p.solid)),
      StepModel(
          stepNumber: 2,
          title: 'Substitute',
          explanation: 'Given: ${p.dims.map(G6Format.num).join(', ')}.'),
      StepModel(stepNumber: 3, title: 'Multiply', explanation: r.answer),
      const StepModel(
          stepNumber: 4,
          title: 'Attach cubic units',
          explanation: 'Volume is in unit³ (cm³).'),
    ];
  }
}
