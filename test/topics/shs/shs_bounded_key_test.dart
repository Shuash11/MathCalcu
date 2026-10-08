// Bounded-key regression tests (Cycle 17 Phase 1).
//
// A key/parameter RegExp like `a\s*=` with no LEFT word boundary also
// matches inside a longer word ("area", "beta", "asin"), silently reading
// a WRONG value from valid free-text. Each fix prepends `\b` to the
// pattern. Every negative assertion below fails against the pre-fix code
// (pre-fix values noted in comments).
import 'package:calculus_system/topics/shs/solvers/shs_equations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InterestEquation — bounded parameter keys', () {
    test('loan: "l" inside "total" is not read as the loan amount', () {
      // Pre-fix: `l\s*=` matched the "l = 5000" inside "total = 5000",
      // so the loan read 5000 -> Payment = PHP 444.24 (wrong).
      // Post-fix: no bounded 'l =' / 'p =' anchor exists -> error.
      final r = InterestEquation(
              'loan total = 5000, principal = 100000, i = 1%, n = 12')
          .solve();
      expect(r.hasError, isTrue,
          reason: 'must not fabricate a loan from the "l" in "total"');
      expect(r.hasError ? r.errorMessage : '', contains('Loan'));
    });

    test('annuity R = 1000, i = 1%, n = 12 still solves', () {
      final eq = InterestEquation('annuity R = 1000, i = 1%, n = 12');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      final cd = r.customData!.first as Map;
      expect(cd['mode'], 'annuity');
      // FV = 1000*((1.01^12 - 1)/0.01) = 12682.50.
      expect((cd['fv'] as num).toDouble(), closeTo(12682.50, 0.5));
    });
  });

  group("LHopitalEquation — bounded 'a' key", () {
    test('phantom "a" inside "area" does not fabricate an anchor', () {
      // Pre-fix: `a\s*=` matched the "a = 9" inside "area = 9"; the body
      // split then failed, so this input errored as well but for the WRONG
      // reason (a phantom anchor was accepted first). Post-fix: the pattern
      // finds no real 'a =' at all.
      final eq = LHopitalEquation('f = x^2, g = x, area = 9');
      final r = eq.solve();
      expect(r.hasError, isTrue);
      expect(r.customData, isNull, reason: 'must never read a = 9');
    });

    test('"(x^2 - 1)/(x - 1), area = 3" no longer anchors on the "a" of "area"',
        () {
      // Regressive: pre-fix THIS input validated TRUE (the "a" in "area"
      // was accepted as the anchor a = 3); post-fix there is no real 'a ='
      // so validation fails.
      final eq = LHopitalEquation('(x^2 - 1)/(x - 1), area = 3');
      expect(eq.validate(), isFalse);
    });

    test('a genuine bounded "a =" is still accepted', () {
      // The \b must not break a legitimate 'a ='.
      final eq = LHopitalEquation('(x^2 - 1)/(x - 1), a = 3');
      expect(eq.validate(), isTrue);
    });

    test('canonical lim form still solves', () {
      final r = LHopitalEquation('lim x->0 sin(x)/x').solve();
      expect(r.hasError, isFalse);
      expect(r.points.single, closeTo(1, 1e-3));
    });
  });

  group('IntegralSubEquation — bounded a / b / f keys', () {
    test('"a" inside "beta" is not read as the lower limit', () {
      // Pre-fix: `a\s*=` matched the "a = 5" inside "beta = 5", so a = 5
      // and Area = -39. Post-fix: a = 0, b = 2, Area = 8/3.
      final r =
          IntegralSubEquation('def beta = 5, a = 0, b = 2, f = x^2').solve();
      expect(r.hasError, isFalse);
      final cd = r.customData!.first as Map;
      expect((cd['a'] as num).toDouble(), 0.0);
      expect((cd['b'] as num).toDouble(), 2.0);
      expect((cd['area'] as num).toDouble(), closeTo(8 / 3, 1e-2));
    });

    test('plain def a = 0, b = 2, f = x^2 still solves', () {
      final r = IntegralSubEquation('def a = 0, b = 2, f = x^2').solve();
      expect(r.hasError, isFalse);
      final cd = r.customData!.first as Map;
      expect((cd['area'] as num).toDouble(), closeTo(8 / 3, 1e-2));
    });
  });

  group('TrigRatioEquation — bounded sin/cos/tan keys', () {
    test('"sin" inside "asin" does not silently parse sin = 0.5', () {
      // Pre-fix: `(sin|cos|tan)\s*=` matched the "sin=" inside "asin=",
      // returning theta = 30 degrees for a malformed input. Post-fix: no
      // bounded trig token -> error.
      final r = TrigRatioEquation('asin=0.5 find angle').solve();
      expect(r.hasError, isTrue);
      expect(r.customData, isNull);
    });

    test('explicit sin=0.5 still solves to 30 degrees', () {
      final r = TrigRatioEquation('sin=0.5').solve();
      expect(r.hasError, isFalse);
      expect(r.points.single, closeTo(30, 1e-6));
    });
  });
}
