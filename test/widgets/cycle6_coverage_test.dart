// Cycle 6 P5: coverage expansion slice (deterministic, offline-first).
//
// Covers remaining midterm solver output edges (midpoint / distance /
// radius / two-point slope / point-slope / y-intercept), the shared
// input-validation layer, and web-deploy parity (manifest + index.html)
// plus PWA offline (service worker + icons). Pure group/test, no widget
// binding, no network — follows cycle5_coverage / drift_parity patterns.
import 'dart:convert';
import 'dart:io';

import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/circles_solver/radius_solver.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/distance_solver/distancesolver.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/midpoint_solver/midpointsolver.dart'
    as midpoint;
import 'package:calculus_system/topics/calculus/midterm/solvers/pointslope_solver/pointslopesolver.dart'
    as pointslope;
import 'package:calculus_system/topics/calculus/midterm/solvers/two_point_slope_solver/two_point_slope_solver.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/yintercept_solver/yi_solver.dart';
import 'package:flutter_test/flutter_test.dart';

String _readWeb(String name) =>
    File('web/$name').readAsStringSync(encoding: utf8);

void main() {
  group('MidpointSolver output edge (Cycle 6 P5)', () {
    test('integers midpoint (0,0)-(2,4) is (1,2)', () {
      final r = midpoint.MidpointSolver.solve(
        x1: '0',
        y1: '0',
        x2: '2',
        y2: '4',
      );
      expect(r.hasError, isFalse);
      expect(r.x.toString(), '1');
      expect(r.y.toString(), '2');
      expect(r.formulaX, contains('= 1'));
      expect(r.formulaY, contains('= 2'));
    });

    test('fraction inputs stay exact', () {
      final r = midpoint.MidpointSolver.solve(
        x1: '1/2',
        y1: '0',
        x2: '3/2',
        y2: '0',
      );
      expect(r.hasError, isFalse);
      expect(r.x.toString(), '1');
    });

    test('decimal input converts (2.5 -> 5/2)', () {
      final parsed = midpoint.MidpointSolver.parseFraction('2.5', 'x1');
      expect(parsed.hasError, isFalse);
      expect(parsed.fraction.toString(), '5/2');
    });

    test('empty input reports required', () {
      final r = midpoint.MidpointSolver.solve(
        x1: '',
        y1: '0',
        x2: '1',
        y2: '1',
      );
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('required'));
    });

    test('zero denominator is rejected', () {
      final parsed = midpoint.MidpointSolver.parseFraction('1/0', 'x1');
      expect(parsed.hasError, isTrue);
      expect(parsed.error, contains('denominator cannot be 0'));
    });

    test('findEndpointFromMidpoint doubles and subtracts', () {
      final r = midpoint.MidpointSolver.findEndpointFromMidpoint(
        midpointX: '1',
        midpointY: '2',
        knownX: '0',
        knownY: '0',
      );
      expect(r.hasError, isFalse);
      expect(r.x.toString(), '2');
      expect(r.y.toString(), '4');
    });

    test('simplify normalizes a negative denominator', () {
      final f = midpoint.MidpointSolver.simplify(2, -2);
      expect(f.toString(), '-1');
    });
  });

  group('DistanceSolver output edge (Cycle 6 P5)', () {
    test('1D zero distance for identical points', () {
      final r = DistanceSolver.solve(x1: '3', x2: '3', is2D: false);
      expect(r.hasError, isFalse);
      expect(r.distance, closeTo(0, 1e-9));
    });

    test('2D 3-4-5 triangle', () {
      final r = DistanceSolver.solve(
        x1: '0',
        x2: '3',
        y1: '0',
        y2: '4',
        is2D: true,
      );
      expect(r.hasError, isFalse);
      expect(r.distance, closeTo(5, 1e-9));
      expect(r.formula, contains('5'));
    });

    test('2D without Y coordinates errors', () {
      final r = DistanceSolver.solve(x1: '0', x2: '1', is2D: true);
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('Y coordinates required'));
    });

    test('non-numeric input errors', () {
      final r = DistanceSolver.solve(x1: 'abc', x2: '1', is2D: false);
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('must be a valid number'));
    });

    test('empty input reports required', () {
      final r = DistanceSolver.solve(x1: '', x2: '1', is2D: false);
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('required'));
    });
  });

  group('RadiusSolver output edge (Cycle 6 P5)', () {
    test('perfect square radius stays an integer', () {
      final r = RadiusSolver.solve(x: 3, y: 4, h: 0, k: 0);
      expect(r.radius, closeTo(5, 1e-9));
      expect(r.formattedRadius, '5');
    });

    test('prime radicand uses real radical, never ASCII v', () {
      final r = RadiusSolver.solve(x: 1, y: 2, h: 0, k: 0);
      expect(r.exactRadius, '√5');
      expect(r.formattedRadius, contains('√5'));
      expect(r.formattedRadius, contains('≈'));
      expect(r.formattedRadius, isNot(contains('v5')));
    });

    test('composite radicand uses coefficient form', () {
      final r = RadiusSolver.solve(x: 2, y: 4, h: 0, k: 0);
      expect(r.exactRadius, '2√5');
    });

    test('solveFromStrings keeps fraction raws and radius', () {
      final r = RadiusSolver.solveFromStrings(
        x: '1/2',
        y: '0',
        h: '0',
        k: '0',
      );
      expect(r.radius, closeTo(0.5, 1e-9));
      expect(r.steps, isNotEmpty);
    });

    test('invalid number throws ArgumentError', () {
      expect(
        () => RadiusSolver.solveFromStrings(
          x: 'abc',
          y: '0',
          h: '0',
          k: '0',
        ),
        throwsArgumentError,
      );
    });
  });

  group('TwoPointSlopeSolver output edge (Cycle 6 P5)', () {
    test('vertical line is undefined with x = const', () {
      final r = TwoPointSlopeSolver.solve(x1: 1, y1: 0, x2: 1, y2: 5);
      expect(r.isVertical, isTrue);
      expect(r.slope, isNull);
      expect(r.slopeDisplay, 'Undefined');
      expect(r.lineEquation, 'x = 1');
      expect(r.slopeType, 'Vertical Line');
      expect(r.steps, hasLength(3));
    });

    test('horizontal line reports m = 0', () {
      final r = TwoPointSlopeSolver.solve(x1: 0, y1: 2, x2: 5, y2: 2);
      expect(r.isHorizontal, isTrue);
      expect(r.slope, closeTo(0, 1e-9));
      expect(r.lineEquation, 'y = 2');
      expect(r.slopeType, contains('Horizontal'));
    });

    test('diagonal (0,0)-(2,2) is y = x, positive', () {
      final r = TwoPointSlopeSolver.solve(x1: 0, y1: 0, x2: 2, y2: 2);
      expect(r.slope, closeTo(1, 1e-9));
      expect(r.lineEquation, 'y = x');
      expect(r.slopeType, contains('Positive'));
      expect(r.steps, isNotEmpty);
    });

    test('falling line is negative', () {
      final r = TwoPointSlopeSolver.solve(x1: 0, y1: 0, x2: 2, y2: -2);
      expect(r.slope, closeTo(-1, 1e-9));
      expect(r.slopeType, contains('Negative'));
    });
  });

  group('PointSlope + YIntercept output edge (Cycle 6 P5)', () {
    test('point-slope tryParse builds intercept and steps', () {
      final s = pointslope.PointSlopeSolver.tryParse(
        mText: '2',
        x1Text: '1',
        y1Text: '3',
      );
      expect(s, isNotNull);
      expect(s!.b.toDouble(), closeTo(1, 1e-9));
      expect(s.direction, 'Rising ↗');
      expect(s.steps, hasLength(5));
    });

    test('point-slope tryParse rejects garbage without throwing', () {
      expect(
        pointslope.PointSlopeSolver.tryParse(
          mText: 'abc',
          x1Text: '1',
          y1Text: '1',
        ),
        isNull,
      );
    });

    test('point-slope zero slope is horizontal', () {
      final s = pointslope.PointSlopeSolver.fromDoubles(m: 0, x1: 1, y1: 2);
      expect(s.direction, 'Horizontal →');
    });

    test('y-intercept parses slope-intercept y=2x+3', () {
      final r = YInterceptSolver.tryParseAny('y=2x+3');
      expect(r, isNotNull);
      expect(r!.slope.toString(), '2');
      expect(r.yIntercept.toString(), '3');
    });

    test('degenerate 0=5 has no solution, 0=0 is all reals', () {
      expect(YInterceptSolver.tryParseAny('0=5')!.equation, 'No solution');
      expect(
        YInterceptSolver.tryParseAny('0=0')!.equation,
        'All real numbers',
      );
    });

    test('vertical x=2 keeps x-intercept only', () {
      final r = YInterceptSolver.tryParseAny('x=2')!;
      expect(r.equation, 'x = 2');
      expect(r.yIntercept, isNull);
      expect(r.xIntercept.toString(), '2');
    });

    test('fraction parser handles mixed number and rejects garbage', () {
      expect(parseFractionString('1 1/2').toString(), '3/2');
      expect(parseFractionString('3'), isNotNull);
      expect(parseFractionString('abc'), isNull);
    });
  });

  group('Input validation layer (Cycle 6 P5)', () {
    test('notEmpty guards blanks with actionable copy', () {
      expect(FieldValidators.notEmpty(''), isNotNull);
      expect(FieldValidators.notEmpty('   '), isNotNull);
      expect(FieldValidators.notEmpty('x^2'), isNull);
    });

    test('number accepts plain numbers only', () {
      expect(FieldValidators.number('3', 'x'), isNull);
      expect(FieldValidators.number('-2.5', 'x'), isNull);
      expect(FieldValidators.number('', 'x'), contains('required'));
      expect(FieldValidators.number('abc', 'x'), contains('must be a number'));
    });

    test('expression accepts math, rejects stray symbols', () {
      expect(FieldValidators.expression('x^2+3*x'), isNull);
      expect(FieldValidators.expression(''), contains('Enter'));
      expect(
        FieldValidators.expression('x@2'),
        contains('Could not parse'),
      );
    });

    test('numeric and point-pair patterns behave', () {
      expect(FieldValidators.numeric.hasMatch('3'), isTrue);
      expect(FieldValidators.numeric.hasMatch('-2.5'), isTrue);
      expect(FieldValidators.numeric.hasMatch('abc'), isFalse);
      expect(
        FieldValidators.pointPair.hasMatch('(0,0), (3,4)'),
        isTrue,
      );
      expect(FieldValidators.pointPair.hasMatch('nope'), isFalse);
    });

    test('input hints stay non-empty offline copy', () {
      expect(InputHints.expressionHint, isNotEmpty);
      expect(InputHints.calculatorHelper, isNotEmpty);
      expect(InputHints.distanceHelper2D, contains('(x1,y1)'));
    });
  });

  group('Web-deploy parity (Cycle 6 P5)', () {
    test('manifest is installable under /MathCalcu/', () {
      final manifest =
          jsonDecode(_readWeb('manifest.json')) as Map<String, dynamic>;
      expect(manifest['start_url'], '/MathCalcu/');
      expect(manifest['scope'], '/MathCalcu/');
      expect(manifest['display'], 'standalone');
      final icons = manifest['icons'] as List;
      final sizes = icons.map((e) => (e as Map)['sizes']).toList();
      expect(sizes, contains('192x192'));
      expect(sizes, contains('512x512'));
    });

    test('index.html keeps base-href placeholder and PWA wiring', () {
      final html = _readWeb('index.html');
      expect(html, contains(r'$FLUTTER_BASE_HREF'));
      expect(html, contains('manifest.json'));
      expect(html, contains('flutter_bootstrap.js'));
      expect(html, contains('mobile-web-app-capable'));
    });
  });

  group('PWA offline (Cycle 6 P5)', () {
    test('service worker caches core assets and handles fetch', () {
      final sw = _readWeb('flutter_service_worker.js');
      expect(sw, contains('CACHE_NAME'));
      expect(sw, contains("addEventListener('install'"));
      expect(sw, contains("addEventListener('activate'"));
      expect(sw, contains("addEventListener('fetch'"));
      expect(sw, contains('/MathCalcu/manifest.json'));
      expect(sw, contains('/MathCalcu/index.html'));
      expect(sw, contains('skipWaiting'));
    });

    test('PWA icons and favicon ship with the app', () {
      for (final asset in [
        'web/icons/Icon-192.png',
        'web/icons/Icon-512.png',
        'web/icons/Icon-maskable-192.png',
        'web/icons/Icon-maskable-512.png',
        'web/favicon.png',
      ]) {
        expect(File(asset).existsSync(), isTrue, reason: asset);
      }
    });
  });
}
