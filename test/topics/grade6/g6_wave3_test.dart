// G6 Wave 3 tests: geometry, volume, pie + probability.
import 'dart:math' as math;

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

    // CORRECTED (Phase 14): this assertion used to pass for the WRONG REASON.
    // _all()'s `-?\d+` read the hyphenated triple '1-2-10' as [1, -2, -10], so
    // the POSITIVITY guard rejected it and the triangle-INEQUALITY guard its
    // name implies never ran. The sides now parse as positives; pin the reason.
    test('degenerate triangle rejected by the triangle inequality', () {
      final eq = G6GeometryEquation('triangle 1-2-10');
      expect(eq.validate(), isFalse);
      expect(eq.solve().hasError, isTrue);
      expect(
        eq.solve().errorMessage,
        'Not a triangle: sides fail the triangle inequality.',
      );
    });

    // PHASE 14 — a space-less hyphenated triple is a SIDE LIST, not signed
    // numbers ('triangle 3-4-5' used to fail positivity and emit a single
    // latex-null step).
    test('space-less hyphenated triangle sides parse as positive sides', () {
      for (final MapEntry<String, String> e in const <String, String>{
        'triangle 3-4-5': 'P = 12 cm',
        'triangle 6-8-10': 'P = 24 cm',
        'triangle 5-4-3': 'P = 12 cm',
        'triangle 4-4-4': 'P = 12 cm',
        'triangle 3.5-4-5': 'P = 12.5 cm',
        'triangle 1-2-2': 'P = 5 cm',
      }.entries) {
        final eq = G6GeometryEquation(e.key);
        expect(eq.validate(), isTrue, reason: e.key);
        final r = eq.solve();
        expect(r.hasError, isFalse, reason: e.key);
        expect(r.answer, e.value, reason: e.key);
        expect(eq.getSteps(), hasLength(5), reason: e.key);
      }
      // The spaced form was already fine and must stay fine.
      expect(
        G6GeometryEquation('triangle 3 - 4 - 5').solve().answer,
        'P = 12 cm',
      );
      // Degenerate hyphenated triples now fail the INEQUALITY guard.
      final degenerate = G6GeometryEquation('triangle 2-2-4');
      expect(degenerate.validate(), isFalse);
      expect(
        degenerate.solve().errorMessage,
        'Not a triangle: sides fail the triangle inequality.',
      );
      // A leading sign is not a side list: still parsed as signed numbers and
      // still rejected by the positivity guard (unchanged behaviour).
      final signed = G6GeometryEquation('triangle -3-4-5');
      expect(signed.validate(), isFalse);
      expect(signed.solve().errorMessage, 'Lengths must be positive (> 0).');
      expect(
        G6GeometryEquation('triangle -3 - 4 - 5').solve().errorMessage,
        'Lengths must be positive (> 0).',
      );
      // Bare space-separated sides are untouched.
      expect(G6GeometryEquation('triangle 3 4 5').solve().answer, 'P = 12 cm');
    });

    // PHASE 15 (issue 1) — the hyphen-triple matcher accepted TRAILING JUNK
    // and silently truncated: 'triangle 3-4-5-6' answered 'P = 12 cm', quietly
    // dropping '-6'. The three sides must now be the whole shape clause.
    test('hyphenated triangle sides must be the whole clause', () {
      const String message =
          'Not a valid triangle side list — give exactly three '
          'hyphen-separated sides, e.g. triangle 3-4-5.';
      for (final String input in const <String>[
        'triangle 3-4-5-6',
        'triangle 3-4-5-',
        'triangle abc 3-4-5',
        'triangle 3-4-5 extra',
        'triangle x3-4-5',
        'triangle b=3-4-5',
        'triangle 3-4-5e',
        'triangle 3-4-5 cmx',
        'triangle 3cm-4cm-5cm-6cm',
        'triangle 3cm-4cm-5cm extra',
      ]) {
        final eq = G6GeometryEquation(input);
        expect(eq.validate(), isFalse, reason: input);
        final r = eq.solve();
        expect(r.hasError, isTrue, reason: input);
        expect(r.errorMessage, message, reason: input);
        expect(r.answer, '', reason: input);
        // The refusal is reported as a single honest step, not a truncated
        // answer with a P = ... value.
        expect(eq.getSteps(), hasLength(1), reason: input);
        expect(eq.getSteps().single.title, 'Invalid input', reason: input);
      }
    });

    // PHASE 15 (issues 1b + 3) — the forms Phase 14 made work, the guards they
    // route through, and the comma/space-separated forms stay unchanged.
    test('Phase 15 keeps the working triangle forms and guards', () {
      for (final MapEntry<String, String> e in const <String, String>{
        'triangle 3-4-5': 'P = 12 cm',
        'triangle 6-8-10': 'P = 24 cm',
        'triangle 5-4-3': 'P = 12 cm',
        'triangle 4-4-4': 'P = 12 cm',
        'triangle 3.5-4-5': 'P = 12.5 cm',
        'triangle 1-2-2': 'P = 5 cm',
        'triangle 03-4-5': 'P = 12 cm',
        'triangle 3- 4- 5': 'P = 12 cm',
        'triangle 3 - 4 - 5': 'P = 12 cm',
        'triangle 3,4,5': 'P = 12 cm',
        'triangle 3, 4, 5': 'P = 12 cm',
        'triangle 3 4 5': 'P = 12 cm',
        'triangle 0.5-0.5-0.5': 'P = 1.5 cm',
        'triangle 3-4cm-5': 'P = 12 cm',
      }.entries) {
        final eq = G6GeometryEquation(e.key);
        expect(eq.validate(), isTrue, reason: e.key);
        expect(eq.solve().answer, e.value, reason: e.key);
      }
      // Triangle-inequality guard unchanged.
      for (final String input in const <String>[
        'triangle 1-2-10',
        'triangle 2-2-4',
        'triangle 1-1-2',
      ]) {
        final eq = G6GeometryEquation(input);
        expect(eq.validate(), isFalse, reason: input);
        expect(
          eq.solve().errorMessage,
          'Not a triangle: sides fail the triangle inequality.',
          reason: input,
        );
      }
      // Positivity guard unchanged: a leading sign is not a side list, a
      // doubled separator is not a side list, and a non-positive side is
      // refused whether or not the sides carry units.
      const String positive = 'Lengths must be positive (> 0).';
      for (final String input in const <String>[
        'triangle -3-4-5',
        'triangle -3 - 4 - 5',
        'triangle 3--4--5',
        'triangle 3-4--5',
        'triangle 3-4',
        'triangle 0-4-5',
        'triangle 3-0-5',
        'triangle 0cm-4cm-5cm',
      ]) {
        final eq = G6GeometryEquation(input);
        expect(eq.validate(), isFalse, reason: input);
        expect(eq.solve().errorMessage, positive, reason: input);
      }
    });

    // PHASE 15 (issue 2) — a unit-suffixed hyphenated triple used to be
    // refused with the misleading 'Lengths must be positive (> 0).' (_all()
    // read '-4'/'-5' out of 'cm-'). The unit now comes through and the sides
    // parse as three POSITIVE lengths.
    test('unit-suffixed hyphenated triangles honour the unit', () {
      for (final MapEntry<String, String> e in const <String, String>{
        'triangle 3cm-4cm-5cm': 'P = 12 cm',
        'triangle 3m-4m-5m': 'P = 12 m',
        'triangle 3mm-4mm-5mm': 'P = 12 mm',
        'triangle 6m-8m-10m': 'P = 24 m',
        'triangle 3cm - 4cm - 5cm': 'P = 12 cm',
        'triangle 3cm-4cm-5cm ': 'P = 12 cm',
        'triangle 03cm-4cm-5cm': 'P = 12 cm',
        'triangle 3.5cm-4cm-5cm': 'P = 12.5 cm',
      }.entries) {
        final eq = G6GeometryEquation(e.key);
        expect(eq.validate(), isTrue, reason: e.key);
        final r = eq.solve();
        expect(r.hasError, isFalse, reason: e.key);
        expect(r.answer, e.value, reason: e.key);
        expect(r.customData?.first['shape'], 'triangle', reason: e.key);
        expect(eq.getSteps(), hasLength(5), reason: e.key);
        expect(eq.getSteps()[3].latex, isNotNull, reason: e.key);
      }
      // Consistent with the spaced/suffixed forms that were already fine.
      expect(
        G6GeometryEquation('triangle 3cm 4cm 5cm').solve().answer,
        'P = 12 cm',
      );
      expect(
        G6GeometryEquation('triangle 3 cm 4 cm 5 cm').solve().answer,
        'P = 12 cm',
      );
      // The suffixed degenerate triple reaches the INEQUALITY guard (on
      // baseline it never got past positivity).
      final degenerate = G6GeometryEquation('triangle 2cm-2cm-4cm');
      expect(degenerate.validate(), isFalse);
      expect(
        degenerate.solve().errorMessage,
        'Not a triangle: sides fail the triangle inequality.',
      );
    });

    // PHASE 15 (issue 2b) — a hyphenated triple that MIXES units is refused by
    // the existing mixed-unit guard, exactly like the rectangle case.
    test('mixed-unit hyphenated triangle is refused', () {
      const String message =
          'Use one unit for all lengths — this input mixes cm and m.';
      final eq = G6GeometryEquation('triangle 3cm-4m-5cm');
      expect(eq.validate(), isFalse);
      final r = eq.solve();
      expect(r.hasError, isTrue);
      expect(r.errorMessage, message);
      expect(eq.getSteps().single.title, 'Invalid input');
      expect(
        G6GeometryEquation('triangle 3m-4cm-5mm').solve().errorMessage,
        'Use one unit for all lengths — this input mixes mm and cm and m.',
      );
    });

    // PHASE 15 (issue 3) — _unit() used a loose contains('mm')/contains('cm')
    // test while the mixed-unit guard used a strict regex, so they disagreed:
    // 'rect 6 mmm x 4m' answered 'P = 20 mm, A = 24 mm2' while the guard saw
    // only m. Both now read the SAME detector, so a unit is claimed only where
    // the guard would see it (and a unit written before the × operator is seen
    // by both).
    test('unit detection agrees with the mixed-unit guard', () {
      // 'mmm' is not a unit: the 6 mmm dimension is read as 6 m (the unit the
      // guard also sees), not silently as 6 mm.
      expect(
        G6GeometryEquation('rect 6 mmm x 4m').solve().answer,
        'P = 20 m, A = 24 m²',
      );
      // A unit suffix written against the × operator is now seen.
      expect(
        G6GeometryEquation('rect 6mx4').solve().answer,
        'P = 20 m, A = 24 m²',
      );
      expect(
        G6GeometryEquation('rect 5mx5').solve().answer,
        'P = 20 m, A = 25 m²',
      );
      // ... and therefore a genuinely mixed input of that shape is refused
      // instead of being collapsed into one unit.
      final mixed = G6GeometryEquation('rect 6mmx4cm');
      expect(mixed.validate(), isFalse);
      expect(
        mixed.solve().errorMessage,
        'Use one unit for all lengths — this input mixes mm and cm.',
      );
      // Junk that merely CONTAINS the letters 'mm' is not a unit.
      expect(
        G6GeometryEquation('rect 6x4 hmm').solve().answer,
        'P = 20 cm, A = 24 cm²',
      );
      // The documented unit forms are untouched.
      for (final MapEntry<String, String> e in const <String, String>{
        'rect 6mm x 4mm': 'P = 20 mm, A = 24 mm²',
        'rect 6m x 4m': 'P = 20 m, A = 24 m²',
        'rect 6cm x 4cm': 'P = 20 cm, A = 24 cm²',
        'rect 6x4': 'P = 20 cm, A = 24 cm²',
        'rect 6 x 4m': 'P = 20 m, A = 24 m²',
        'square 5 mm': 'P = 20 mm, A = 25 mm²',
      }.entries) {
        expect(
          G6GeometryEquation(e.key).solve().answer,
          e.value,
          reason: e.key,
        );
      }
    });

    // PHASE 14 (2b) — the solver carries ONE unit per shape, so an input that
    // mixes units is refused honestly instead of being reported in a single
    // one ('rect 6cm x 4m' used to answer 'P = 20 m, A = 24 m2').
    test('mixed length units are refused instead of collapsed', () {
      const String message =
          'Use one unit for all lengths — this input mixes cm and m.';
      final eq = G6GeometryEquation('rect 6cm x 4m');
      expect(eq.validate(), isFalse);
      final r = eq.solve();
      expect(r.hasError, isTrue);
      expect(r.errorMessage, message);
      final steps = eq.getSteps();
      expect(steps, hasLength(1));
      expect(steps.single.title, 'Invalid input');
      expect(steps.single.explanation, message);
      expect(steps.single.latex, isNull);
      expect(G6GeometryEquation('rect 6m x 4cm').solve().errorMessage, message);
      // Single-unit inputs are unchanged.
      expect(
        G6GeometryEquation('square 5 m').solve().answer,
        'P = 20 m, A = 25 m²',
      );
      expect(
        G6GeometryEquation('rect 6 x 4m').solve().answer,
        'P = 20 m, A = 24 m²',
      );
      expect(
        G6GeometryEquation('rect 6m x 4m').solve().answer,
        'P = 20 m, A = 24 m²',
      );
      expect(
        G6GeometryEquation('rect 6cm x 4cm').solve().answer,
        'P = 20 cm, A = 24 cm²',
      );
      expect(
        G6GeometryEquation('rect 6mm x 4mm').solve().answer,
        'P = 20 mm, A = 24 mm²',
      );
      expect(G6GeometryEquation('circle r=7cm').solve().answer, contains('cm'));
      expect(
        G6GeometryEquation('rect 6x4').solve().answer,
        'P = 20 cm, A = 24 cm²',
      );
    });

    test('negative length rejected', () {
      expect(G6GeometryEquation('rect -6x4').solve().hasError, isTrue);
    });

    // BUG C: a unit suffix attached to a number ('6m', '4m') is not detected,
    // so 'rect 6m x 4m' silently defaults to cm (a wrong unit in the answer).
    test('BUG C: rect 6m x 4m detects the metre suffix', () {
      final r = G6GeometryEquation('rect 6m x 4m').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('20 m'));
      expect(r.answer, contains('24 m'));
      expect(r.answer, isNot(contains('cm')));
      final steps = G6GeometryEquation('rect 6m x 4m').getSteps();
      expect(steps[4].explanation, contains(' m'));
    });

    // BUG C regression: cm stays cm, mm stays mm, bare numbers stay cm.
    test('BUG C regression: cm/mm/bare units unchanged', () {
      final cm = G6GeometryEquation('rect 6cm x 4cm').solve();
      expect(cm.answer, contains('20 cm'));
      final mm = G6GeometryEquation('rect 6mm x 4mm').solve();
      expect(mm.answer, contains('20 mm'));
      final bare = G6GeometryEquation('rect 6x4').solve();
      expect(bare.answer, contains('20 cm'));
      final standalone = G6GeometryEquation('rect 6 m x 4 m').solve();
      expect(standalone.answer, contains('20 m'));
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

    // BUG B: dimensions are read positionally and the r=/h=/l=/w=/s= labels are
    // ignored, so 'cyl h=7 r=3' computes r=7, h=3 (a numerically WRONG volume).
    test('BUG B: cyl h=7 r=3 equals cyl r=3 h=7 (labels honoured)', () {
      final a = G6VolumeEquation('cyl h=7 r=3').solve();
      final b = G6VolumeEquation('cyl r=3 h=7').solve();
      expect(a.hasError, isFalse);
      expect(a.points.single, closeTo(math.pi * 3 * 3 * 7, 1e-9));
      expect(a.points.single, closeTo(b.points.single, 1e-12));
      expect(a.customData?.first['dims'], [3.0, 7.0]);
    });

    // BUG B: labelled inputs are read by label for every supported solid, and
    // the value itself is right (computed independently with math.pi).
    test('BUG B: labels honoured for every supported solid', () {
      expect(
        G6VolumeEquation('cyl h=7 r=3').solve().points.single,
        closeTo(G6VolumeEquation('cyl r=3 h=7').solve().points.single, 1e-12),
      );
      expect(
        G6VolumeEquation('cone r=3 h=6').solve().points.single,
        closeTo(math.pi * 3 * 3 * 6 / 3, 1e-9),
      );
      expect(
        G6VolumeEquation('cone h=6 r=3').solve().points.single,
        closeTo(math.pi * 3 * 3 * 6 / 3, 1e-9),
      );
      expect(
        G6VolumeEquation('prism h=2 w=3 l=5').solve().points.single,
        closeTo(30, 1e-9),
      );
      expect(
        G6VolumeEquation('prism h=2 w=3 l=5').solve().points.single,
        closeTo(
          G6VolumeEquation('prism l=5 w=3 h=2').solve().points.single,
          1e-12,
        ),
      );
      expect(
        G6VolumeEquation('pyramid h=6 s=4').solve().points.single,
        closeTo(32, 1e-9),
      );
      expect(
        G6VolumeEquation('pyramid h=6 s=4').solve().points.single,
        closeTo(
          G6VolumeEquation('pyramid s=4 h=6').solve().points.single,
          1e-12,
        ),
      );
      expect(
        G6VolumeEquation('cube s=4').solve().points.single,
        closeTo(64, 1e-9),
      );
      expect(
        G6VolumeEquation('sphere r=3').solve().points.single,
        closeTo(4 / 3 * math.pi * 27, 1e-9),
      );
    });

    // BUG B regression: positional inputs keep working.
    test('BUG B regression: positional inputs unchanged', () {
      expect(
        G6VolumeEquation('prism 5x3x2').solve().points.single,
        closeTo(30, 1e-9),
      );
      expect(
        G6VolumeEquation('cyl 3 7').solve().points.single,
        closeTo(math.pi * 9 * 7, 1e-9),
      );
      expect(
        G6VolumeEquation('pyramid 4x4 h=6').solve().points.single,
        closeTo(32, 1e-9),
      );
      expect(
        G6VolumeEquation('cube s=4').solve().points.single,
        closeTo(64, 1e-9),
      );
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
    test(
      'geometry: formula/substitute/compute carry TeX, shape+units prose',
      () {
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
      },
    );

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

    test(
      'every emitted wave3-batch2 TeX line is ASCII (no unicode/control)',
      () {
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
          G6GeometryEquation('rect 6m x 4m'),
          G6VolumeEquation('cube s=4'),
          G6VolumeEquation('prism 5x3x2'),
          G6VolumeEquation('cyl r=3 h=7'),
          G6VolumeEquation('cyl h=7 r=3'),
          G6VolumeEquation('cone r=3 h=6'),
          G6VolumeEquation('cone h=6 r=3'),
          G6VolumeEquation('pyramid 4x4 h=6'),
          G6VolumeEquation('pyramid s=4 h=6'),
          G6VolumeEquation('sphere r=3'),
          G6PieEquation('Math 40, Science 30, English 30'),
          G6PieEquation('40, 30, 30'),
          G6ProbabilityEquation('P(red) in 3R + 2B'),
          G6ProbabilityEquation('3 out of 5'),
        ]) {
          // NON-VACUITY (Phase 14): 'triangle 3-4-5' used to be rejected, so
          // it emitted a single latex-null step and every inner assertion was
          // skipped for it. Require a real chain with at least one TeX line.
          final steps = eq.getSteps();
          expect(eq.validate(), isTrue, reason: eq.rawInput);
          expect(steps.length, greaterThan(1), reason: eq.rawInput);
          expect(
            steps.any((s) => s.latex != null && s.latex!.isNotEmpty),
            isTrue,
            reason: eq.rawInput,
          );
          for (final s in steps) {
            for (final tex in <String?>[s.latex, ...?s.subLatex]) {
              if (tex == null) {
                continue;
              }
              expect(
                tex.codeUnits.every((c) => c >= 0x20 && c <= 0x7e),
                isTrue,
                reason: '$tex (${s.title})',
              );
            }
          }
        }
      },
    );

    testWidgets(
      'every emitted wave3-batch2 TeX line parses (recording fallback)',
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
          G6GeometryEquation('rect 6m x 4m'),
          G6VolumeEquation('cube s=4'),
          G6VolumeEquation('prism 5x3x2'),
          G6VolumeEquation('cyl r=3 h=7'),
          G6VolumeEquation('cyl h=7 r=3'),
          G6VolumeEquation('cone r=3 h=6'),
          G6VolumeEquation('cone h=6 r=3'),
          G6VolumeEquation('pyramid 4x4 h=6'),
          G6VolumeEquation('pyramid s=4 h=6'),
          G6VolumeEquation('sphere r=3'),
          G6PieEquation('Math 40, Science 30, English 30'),
          G6PieEquation('40, 30, 30'),
          G6ProbabilityEquation('P(red) in 3R + 2B'),
          G6ProbabilityEquation('3 out of 5'),
        ];
        var checked = 0;
        for (final eq in cases) {
          final int before = checked;
          final steps = eq.getSteps();
          // NON-VACUITY (Phase 14): 'triangle 3-4-5' used to emit a single
          // latex-null step, so nothing was rendered for it and 'checked'
          // never grew — the case was silently unasserted.
          expect(eq.validate(), isTrue, reason: eq.rawInput);
          expect(steps.length, greaterThan(1), reason: eq.rawInput);
          for (final s in steps) {
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
          // Every case must contribute at least one parsed TeX line, so no
          // case can pass by emitting nothing (Phase 14 non-vacuity).
          expect(checked, greaterThan(before), reason: eq.rawInput);
        }
        expect(checked, greaterThan(0));
      },
    );
  });
}
