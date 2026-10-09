// G6 Wave 3 tests: geometry, volume, pie + probability.
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Render [tex] with an explicit recording `onErrorFallback` and assert it was
/// NOT invoked, i.e. the TeX parses (Phase B technique for the LaTeX waves).
Future<void> _expectTexParses(WidgetTester tester, String tex) async {
  var fellBack = false;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Math.tex(
          tex,
          textStyle: const TextStyle(fontSize: 14),
          onErrorFallback: (e) {
            fellBack = true;
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  await tester.pump();
  expect(fellBack, isFalse, reason: 'TeX failed to parse: $tex');
}

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

  group('G6 wave3 LaTeX emission (Batch 2)', () {
    test('geometry: formula/substitute/compute carry TeX, shape+units prose', () {
      final rect = G6GeometryEquation('rect 6x4').getSteps();
      expect(rect, hasLength(5));
      expect(rect[0].latex, isNull); // identify-shape prose
      expect(rect[1].latex, contains(r'\cdot'));
      expect(rect[2].latex, contains('6'));
      expect(rect[3].latex, contains('24'));
      expect(rect[4].latex, isNull); // attach-units prose
      final circ = G6GeometryEquation('circle r=7').getSteps();
      expect(circ[1].latex, contains(r'\pi r^{2}'));
      expect(circ[3].latex, contains('43.98'));
      final tri = G6GeometryEquation('triangle b=8 h=5').getSteps();
      expect(tri[1].latex, contains(r'\frac{1}{2}'));
      expect(tri[3].latex, contains('20'));
    });

    test('volume: formula/substitute/result carry TeX, units step prose', () {
      final cube = G6VolumeEquation('cube s=4').getSteps();
      expect(cube, hasLength(4));
      expect(cube[0].latex, r'V = s^{3}');
      expect(cube[1].latex, r'V = 4^{3}');
      expect(cube[2].latex, contains('64'));
      expect(cube[3].latex, isNull);
      final cyl = G6VolumeEquation('cyl r=3 h=7').getSteps();
      expect(cyl[0].latex, contains(r'\pi r^{2} h'));
      final sph = G6VolumeEquation('sphere r=3').getSteps();
      expect(sph[0].latex, contains(r'\frac{4}{3}'));
    });

    test('pie & probability: math steps carry TeX, draw step stays prose', () {
      final pie = G6PieEquation('Math 40, Science 30, English 30').getSteps();
      expect(pie, hasLength(5));
      expect(pie[0].latex, contains('100'));
      expect(pie[1].latex, contains(r'\frac'));
      expect(pie[2].latex, contains('360'));
      expect(pie[3].latex, isNull); // draw-the-slices prose
      expect(pie[4].latex, contains('40'));
      final prob = G6ProbabilityEquation('P(red) in 3R + 2B').getSteps();
      expect(prob, hasLength(3));
      for (final s in prob) {
        expect(s.latex, isNotNull, reason: s.title);
        expect(s.latex!, isNotEmpty, reason: s.title);
      }
      expect(prob[2].latex, contains(r'\frac{3}{5}'));
      expect(prob[2].latex, contains('60'));
    });

    test('every emitted wave3-batch2 TeX line is ASCII (no unicode/control)', () {
      for (final eq in <BaseEquation>[
        G6GeometryEquation('rect 6x4'),
        G6GeometryEquation('square 5'),
        G6GeometryEquation('triangle b=8 h=5'),
        G6GeometryEquation('triangle 3-4-5'),
        G6GeometryEquation('parallelogram b=6 h=4'),
        G6GeometryEquation('parallelogram b=6 h=4 s=3'),
        G6GeometryEquation('trapezoid a=4 b=8 h=5'),
        G6GeometryEquation('circle r=7'),
        G6GeometryEquation('circle d=14'),
        G6GeometryEquation('composite 6x4 + 3x2'),
        G6VolumeEquation('cube s=4'),
        G6VolumeEquation('prism 5x3x2'),
        G6VolumeEquation('cyl r=3 h=7'),
        G6VolumeEquation('cone r=3 h=6'),
        G6VolumeEquation('pyramid 4x4 h=6'),
        G6VolumeEquation('sphere r=3'),
        G6PieEquation('Math 40, Science 30, English 30'),
        G6PieEquation('40, 30, 30'),
        G6ProbabilityEquation('P(red) in 3R + 2B'),
        G6ProbabilityEquation('3 out of 5'),
      ]) {
        for (final s in eq.getSteps()) {
          for (final tex in <String?>[s.latex, ...?s.subLatex]) {
            if (tex == null) {
              continue;
            }
            expect(tex.codeUnits.every((c) => c >= 0x20 && c <= 0x7e), isTrue,
                reason: '$tex (${s.title})');
          }
        }
      }
    });

    testWidgets('every emitted wave3-batch2 TeX line parses (recording fallback)',
        (tester) async {
      final cases = <BaseEquation>[
        G6GeometryEquation('rect 6x4'),
        G6GeometryEquation('square 5'),
        G6GeometryEquation('triangle b=8 h=5'),
        G6GeometryEquation('triangle 3-4-5'),
        G6GeometryEquation('parallelogram b=6 h=4'),
        G6GeometryEquation('parallelogram b=6 h=4 s=3'),
        G6GeometryEquation('trapezoid a=4 b=8 h=5'),
        G6GeometryEquation('circle r=7'),
        G6GeometryEquation('circle d=14'),
        G6GeometryEquation('composite 6x4 + 3x2'),
        G6VolumeEquation('cube s=4'),
        G6VolumeEquation('prism 5x3x2'),
        G6VolumeEquation('cyl r=3 h=7'),
        G6VolumeEquation('cone r=3 h=6'),
        G6VolumeEquation('pyramid 4x4 h=6'),
        G6VolumeEquation('sphere r=3'),
        G6PieEquation('Math 40, Science 30, English 30'),
        G6PieEquation('40, 30, 30'),
        G6ProbabilityEquation('P(red) in 3R + 2B'),
        G6ProbabilityEquation('3 out of 5'),
      ];
      var checked = 0;
      for (final eq in cases) {
        for (final s in eq.getSteps()) {
          if (s.latex != null && s.latex!.isNotEmpty) {
            await _expectTexParses(tester, s.latex!);
            checked++;
          }
          for (final line in s.subLatex ?? const <String>[]) {
            if (line.trim().isNotEmpty) {
              await _expectTexParses(tester, line);
              checked++;
            }
          }
        }
      }
      expect(checked, greaterThan(0));
    });
  });
}
