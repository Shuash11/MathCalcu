// G6 Wave 3 tests: geometry, volume, pie + probability.
import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('G6-8 geometry (M6GE-IIIc-37)', () {
    test('rect 6x4 gives P=20 A=24', () {
      final eq = G6GeometryEquation('rect 6x4');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('20'));
      expect(r.answer, contains('24'));
      expect(r.customData?.first['shape'], 'rectangle');
      expect(eq.getSteps(), hasLength(5));
    });

    test('triangle b=8 h=5 gives A=20', () {
      final r = G6GeometryEquation('triangle b=8 h=5').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('20'));
    });

    test('parallelogram b=6 h=4 gives A=24', () {
      final r = G6GeometryEquation('parallelogram b=6 h=4').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('24'));
    });

    test('trapezoid a=4 b=8 h=5 gives A=30', () {
      final r = G6GeometryEquation('trapezoid a=4 b=8 h=5').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('30'));
    });

    test('circle r=7 gives C and A', () {
      final r = G6GeometryEquation('circle r=7').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('43.98'));
      expect(r.customData?.first['dims']['r'], closeTo(7, 1e-9));
    });

    test('composite sums two rectangles', () {
      final r = G6GeometryEquation('composite 6x4 + 3x2').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('30'));
    });

    test('degenerate triangle rejected', () {
      final eq = G6GeometryEquation('triangle 1-2-10');
      expect(eq.validate(), isFalse);
    });

    test('negative length rejected', () {
      expect(G6GeometryEquation('rect -6x4').solve().hasError, isTrue);
    });
  });

  group('G6-9 volume (M6ME-IVa-95)', () {
    test('cube s=4 gives 64', () {
      final eq = G6VolumeEquation('cube s=4');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('64'));
      expect(r.answer, contains('unit³'));
      expect(eq.getSteps(), hasLength(4));
    });

    test('prism 5x3x2 gives 30', () {
      final r = G6VolumeEquation('prism 5x3x2').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('30'));
    });

    test('cylinder r=3 h=7 uses pi', () {
      final r = G6VolumeEquation('cyl r=3 h=7').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('197.92'));
      expect(r.customData?.first['solid'], 'cylinder');
    });

    test('cone is third of cylinder', () {
      final r = G6VolumeEquation('cone r=3 h=6').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('56.54'));
    });

    test('pyramid 4x4 h=6 gives 32', () {
      final r = G6VolumeEquation('pyramid 4x4 h=6').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('32'));
    });

    test('sphere r=3 gives 113.1', () {
      final r = G6VolumeEquation('sphere r=3').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('113.09'));
    });

    test('zero dimension rejected', () {
      expect(G6VolumeEquation('cube s=0').validate(), isFalse);
    });
  });

  group('G6-10 pie & probability (M6SP)', () {
    test('pie splits 40/30/30 with degrees', () {
      final eq = G6PieEquation('Math 40, Science 30, English 30');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('144'));
      expect(r.customData?.first['slices'], hasLength(3));
      expect(eq.getSteps(), hasLength(5));
    });

    test('bare values auto-label', () {
      final r = G6PieEquation('40, 30, 30').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('Total = 100'));
    });

    test('all-zero pie rejected', () {
      expect(G6PieEquation('A 0, B 0').validate(), isFalse);
    });

    test('P(red) in 3R+2B = 3/5', () {
      final eq = G6ProbabilityEquation('P(red) in 3R + 2B');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('3/5'));
      expect(r.answer, contains('60%'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('3 out of 5 form', () {
      final r = G6ProbabilityEquation('3 out of 5').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('3/5'));
    });

    test('favorable above total rejected', () {
      expect(G6ProbabilityEquation('7 out of 5').validate(), isFalse);
    });
  });
}
