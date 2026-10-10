// ModMath wave-1 tests (Cycle 8): M1 propositional, M2 sets,
// M3 nPr/nCr, M4 bases, M5 det/inverse, M6 mod arithmetic.
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/topics/modmat/solvers/modmat_equations.dart';
import 'package:calculus_system/topics/modmat/solvers/modmat_solver_registry.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Render [tex] with an explicit recording `onErrorFallback` and assert it was
/// NOT invoked, i.e. the TeX parses (Phase B technique for the LaTeX waves).
/// A count/presence-only check cannot catch a parse failure.
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
  group('ModmatSolverRegistry wiring', () {
    test('14 specs, unique ids, byId round-trip', () {
      expect(ModmatSolverRegistry.specs, hasLength(14));
      final ids = ModmatSolverRegistry.specs.map((s) => s.id).toList();
      expect(ids.toSet(), hasLength(14));
      for (final s in ModmatSolverRegistry.specs) {
        expect(ModmatSolverRegistry.byId(s.id), isNotNull);
      }
      expect(ModmatSolverRegistry.byId('nope'), isNull);
    });
  });

  group('M1 propositional (truth tables)', () {
    test('p -> q is a contingency with 4 rows', () {
      final eq = M1PropositionalEquation('p -> q');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('contingency'));
      expect(r.points, hasLength(4));
      expect(eq.getSteps(), hasLength(4));
    });

    test('p OR NOT p is a tautology', () {
      final r = M1PropositionalEquation('p OR NOT p').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('tautology'));
    });

    test('p AND NOT p is a contradiction', () {
      final r = M1PropositionalEquation('p AND NOT p').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('contradiction'));
    });

    test('garbage + empty never throw', () {
      final eq = M1PropositionalEquation('hello');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
      expect(M1PropositionalEquation('   ').validate(), isFalse);
    });
  });

  group('M2 sets', () {
    test('{1,2,3} UNION {3,4} = {1,2,3,4}', () {
      final eq = M2SetsEquation('A={1,2,3} B={3,4} UNION');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('1, 2, 3, 4'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('INTERSECT keeps shared elements', () {
      final r = M2SetsEquation('{1,2,3} INTERSECT {2,3,9}').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('2, 3'));
    });

    test('DIFF drops B elements', () {
      final r = M2SetsEquation('{1,2,3} DIFF {2}').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('1, 3'));
    });

    test('SUBSET True case', () {
      final r = M2SetsEquation('{1,2} SUBSET {1,2,3}').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('True'));
    });

    test('CARD counts, POWER sizes 2^n', () {
      expect(M2SetsEquation('{1,2,3} CARD').solve().answer, contains('3'));
      expect(M2SetsEquation('{1,2,3} POWER').solve().answer, contains('8'));
    });

    test('bare input without braces rejected', () {
      final eq = M2SetsEquation('hello world');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
    });
  });

  group('M3 combinatorics (kills g10-combinatorics stub)', () {
    test('C(5,2) = 10', () {
      final eq = M3CombinatoricsEquation('C(5,2)');
      expect(eq.validate(), isTrue);
      expect(eq.solve().answer, 'C(5,2) = 10');
      expect(eq.getSteps(), hasLength(3));
    });

    test('P(5,2) = 20', () {
      expect(M3CombinatoricsEquation('P(5,2)').solve().answer, 'P(5,2) = 20');
    });

    test('5! = 120', () {
      expect(M3CombinatoricsEquation('5!').solve().answer, contains('120'));
    });

    test('r > n rejected', () {
      expect(M3CombinatoricsEquation('C(3,5)').validate(), isFalse);
    });

    test('garbage never throws', () {
      final eq = M3CombinatoricsEquation('xyz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });

    // ── BUG A (pre-existing, silent int64 overflow) ──────────────────────
    // validate() had no magnitude guard, so nCr/nPr results were accumulated
    // in 64-bit int and silently wrapped. These inputs are well-formed and
    // inside the solver's stated domain (n <= 100, 0 <= r <= n), so validate()
    // still returns true — but solve() must now return an EXPLICIT error for
    // any value that cannot be represented exactly, never a wrapped number.
    test('BUG A: overflowing C/P never return a wrapped (wrong) value', () {
      for (final input in ['C(67,33)', 'C(100,50)', 'P(30,15)', 'P(100,50)']) {
        final eq = M3CombinatoricsEquation(input);
        expect(eq.validate(), isTrue,
            reason: '$input is well-formed and within 0 <= r <= n <= 100');
        final r = eq.solve();
        expect(r.hasError, isTrue,
            reason: '$input silently overflowed instead of erroring');
        expect(r.errorMessage, isNotNull);
        expect(r.errorMessage, contains('exceeds the largest integer'));
        // An error result carries no answer — never the old wrapped value.
        expect(r.answer.trim(), isEmpty);
        expect(r.answer, isNot(contains('-')));
        expect(() => eq.getSteps(), returnsNormally);
      }
    });

    test('BUG A regression: values that fit int64 stay exact', () {
      // Small cases must be byte-identical to before the fix.
      expect(M3CombinatoricsEquation('C(5,2)').solve().answer, 'C(5,2) = 10');
      expect(M3CombinatoricsEquation('P(5,2)').solve().answer, 'P(5,2) = 20');
      expect(M3CombinatoricsEquation('C(20,10)').solve().answer,
          'C(20,10) = 184756');
      expect(M3CombinatoricsEquation('5!').solve().answer, contains('120'));
      // Large-but-representable cases: the 64-bit multiplicative recurrence
      // overflowed its intermediate product even though the final value fits,
      // so these were silently wrong too and are now exact.
      expect(M3CombinatoricsEquation('C(65,32)').solve().answer,
          'C(65,32) = 3609714217008132870');
      expect(M3CombinatoricsEquation('C(66,33)').solve().answer,
          'C(66,33) = 7219428434016265740');
    });

    // ── Phase 5/6 regression: the exactness bound is EXACTLY 2^63 − 1 ──────
    // _maxExact is held as `BigInt.parse('9223372036854775807')`, NOT the int
    // literal `9223372036854775807`: that literal is not representable as a JS
    // number, so dart2js hard-fails the compile and the WEB build breaks —
    // while `flutter analyze` and this VM suite (where the literal is a valid
    // int64) stay green. pr-ci.yml already runs `flutter build web --release`,
    // so that COMPILE-time breakage is gated; but the build cannot see the
    // silent SEMANTIC class these numerics suffer from (32-bit shifts, >2^53
    // rounding), and no VM test can observe it either — that needs a web-TARGET
    // test (see modmat_numerics_web_test.dart). These cases pin the OBSERVABLE
    // boundary so any drift in the constant (e.g. lowering it to a web-safe
    // 2^53) is caught here.
    test('boundary 2^63-1: largest fitting C(94,18) is accepted exactly', () {
      // C(94,18) = 9007607943130625829 is the largest nCr with n <= 100 that
      // fits; it must be accepted with its exact value.
      final r = M3CombinatoricsEquation('C(94,18)').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, 'C(94,18) = 9007607943130625829');
    });

    test('boundary 2^63-1: smallest overflow C(71,25) errors, never wraps', () {
      // C(71,25) = 9964327949818248552 is the smallest nCr with n <= 100 to
      // exceed 2^63 − 1; it must error, not return a wrapped/negative value.
      final eq = M3CombinatoricsEquation('C(71,25)');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('exceeds the largest integer'));
      expect(r.answer, isNot(contains('-')));
    });

    test('boundary 2^63-1: C(65,32) stays exact at 3609714217008132870', () {
      expect(M3CombinatoricsEquation('C(65,32)').solve().answer,
          'C(65,32) = 3609714217008132870');
    });

    // ── Phase 6 regression: >2^53 nCr must never round through `int` ────────
    // On the web target `int` is a JS double, so narrowing the BigInt to int
    // for display rounded C(94,18) to ...626000 and C(65,32) to ...133000
    // (exact values end ...625829 / ...132870). solve() now formats via
    // BigInt.toString(). These assertions are VM-observable (the VM int64 is
    // exact, so they pass before and after) — the defect itself is invisible
    // to this VM suite; modmat_numerics_web_test.dart is what actually pins it
    // on the web target.
    test('Phase6: >2^53 nCr renders exact digits (BigInt, not int)', () {
      final a = M3CombinatoricsEquation('C(94,18)').solve();
      expect(a.hasError, isFalse);
      expect(a.answer, 'C(94,18) = 9007607943130625829');
      expect(a.answer, isNot(contains('626000')));
      final b = M3CombinatoricsEquation('C(65,32)').solve();
      expect(b.answer, 'C(65,32) = 3609714217008132870');
      expect(b.answer, isNot(contains('133000')));
    });
  });

  group('M4 base conversion', () {
    test('1011 base2 to base10 = 11', () {
      final eq = M4BaseConversionEquation('1011 base2 to base10');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('11 (base 10)'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('FF hex to dec = 255', () {
      final r = M4BaseConversionEquation('FF hex to dec').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('255'));
    });

    test('255 dec to hex = FF', () {
      final r = M4BaseConversionEquation('255 dec to hex').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('FF'));
    });

    test('binary digits 2 rejected', () {
      expect(
          M4BaseConversionEquation('102 base2 to base10').validate(), isFalse);
    });

    test('garbage never throws', () {
      final eq = M4BaseConversionEquation('hello');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
    });

    // ── BUG B (pre-existing, guard bypass -> empty answer) ───────────────
    // toDecimal's guard was one-sided ('value > 1<<62'), which is false once
    // the int64 accumulator has WRAPPED NEGATIVE, so a huge hex literal slid
    // through validate() and produced an EMPTY answer with hasError == false.
    test('BUG B: out-of-range hex magnitude is rejected, never empty', () {
      const hex = 'FFFFFFFFFFFFFFFFFF'; // 18 F's == 2^72 - 1
      final eq = M4BaseConversionEquation('$hex hex to dec');
      expect(eq.validate(), isFalse);
      final r = eq.solve();
      expect(r.hasError, isTrue);
      expect(r.answer.trim(), isEmpty); // no bogus '... =  (base 10)' line
      expect(r.errorMessage, contains('exceeds the largest integer'));
      // A size problem must NOT be reported as a bad digit.
      expect(r.errorMessage, isNot(contains('do not fit')));
      expect(() => eq.getSteps(), returnsNormally);
    });

    test('BUG B sibling: value just over 1<<62 gets the magnitude message',
        () {
      // 16 hex F's (2^64 - 1) wrapped to -1 and slipped through entirely;
      // 2^62 + 1 was caught but reported with the misleading 'digits' message.
      for (final hex in ['FFFFFFFFFFFFFFFF', '4000000000000001']) {
        final eq = M4BaseConversionEquation('$hex hex to dec');
        expect(eq.validate(), isFalse);
        final r = eq.solve();
        expect(r.hasError, isTrue);
        expect(r.errorMessage, contains('exceeds the largest integer'));
        expect(r.errorMessage, isNot(contains('do not fit')));
      }
    });

    test('BUG B regression: in-range conversions stay exact', () {
      expect(M4BaseConversionEquation('1011 base2 to base10').solve().answer,
          contains('11 (base 10)'));
      expect(M4BaseConversionEquation('FF hex to dec').solve().answer,
          contains('255 (base 10)'));
      expect(M4BaseConversionEquation('255 dec to hex').solve().answer,
          contains('FF (base 16)'));
      // Exactly on the bound (2^62 = 4611686018427387904) still converts.
      expect(
          M4BaseConversionEquation('4000000000000000 hex to dec')
              .solve()
              .answer,
          contains('4611686018427387904 (base 10)'));
      // A genuine bad-digit input keeps the digits message (not the size one).
      final bad = M4BaseConversionEquation('102 base2 to base10');
      expect(bad.validate(), isFalse);
      expect(bad.solve().errorMessage, contains('do not fit'));
    });

    // ── Phase 5 regression: the 2^62 guard bound must be web-safe ──────────
    // `_maxValue` was written as `1 << 62`. dart2js models int bitwise shifts
    // as 32-bit, so on the WEB target `1 << 62` evaluates to 0 (not 2^62) —
    // the guard `value > (_maxValue - d) ~/ base` then rejects every
    // non-trivial conversion, silently breaking M4 on web while this VM suite
    // (where `1 << 62` == 2^62) stayed green. The bound is now the explicit
    // literal 0x4000000000000000 (== 2^62, exactly representable as a JS
    // number). These cases pin the observable behaviour at the bound.
    test('Phase5: 2^62 bound converts exactly; 2^62+1 rejects (web-safe)', () {
      // 4000000000000000 hex == 2^62 == 4611686018427387904 (in range).
      final on = M4BaseConversionEquation('4000000000000000 hex to dec').solve();
      expect(on.hasError, isFalse);
      expect(on.answer, contains('4611686018427387904 (base 10)'));
      // 4000000000000001 hex == 2^62 + 1 must be rejected as out of range.
      final over = M4BaseConversionEquation('4000000000000001 hex to dec');
      expect(over.validate(), isFalse);
      final r = over.solve();
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('exceeds the largest integer'));
      // A small conversion still resolves — the bound must not over-reject.
      expect(M4BaseConversionEquation('1011 base2 to base10').solve().answer,
          contains('11 (base 10)'));
    });

    // ── Phase 6 regression: the CONVERSION and guard are exact on both targets
    // Phase 5 fixed only the CONSTANT `_maxValue` (the int literal was exact,
    // but the accumulator, the `~/` guard test and the digit extraction still
    // ran in `int`). Above 2^53 the web target therefore rounded: `2^53 + 1 hex`
    // came back off-by-one and `2^62 + 1 hex` could NOT be rejected because the
    // guard's `~/` was itself inexact. toDecimal/fromDecimal now run entirely
    // in BigInt. These assertions pass on the VM before and after (VM int is
    // exact) — the defect is invisible to this VM suite; the web target run in
    // modmat_numerics_web_test.dart is what actually pins it.
    test('Phase6: 2^53+1 hex converts exactly (no web rounding)', () {
      final r = M4BaseConversionEquation('20000000000001 hex to dec').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('9007199254740993 (base 10)'));
      expect(r.answer, isNot(contains('9007199254740992')));
    });

    test('Phase6: 2^62 exact; 2^62+1 rejected; 2^62-1 exact', () {
      // Exactly on the bound still converts, with exact digits on both targets.
      final on =
          M4BaseConversionEquation('4000000000000000 hex to dec').solve();
      expect(on.hasError, isFalse);
      expect(on.answer, contains('4611686018427387904 (base 10)'));
      // 2^62 + 1 must be rejected — the web guard's `~/` used to round, so this
      // slipped through with a bogus value.
      final over = M4BaseConversionEquation('4000000000000001 hex to dec');
      expect(over.validate(), isFalse);
      final r = over.solve();
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('exceeds the largest integer'));
      // 2^62 - 1 (0x3FFFFFFFFFFFFFFF) is in range and exact.
      final under =
          M4BaseConversionEquation('3FFFFFFFFFFFFFFF hex to dec').solve();
      expect(under.hasError, isFalse);
      expect(under.answer, contains('4611686018427387903 (base 10)'));
    });
  });

  group('M5 matrices (kills college-matrices stub)', () {
    test('det [[1,2],[3,4]] = -2', () {
      final eq = M5MatrixEquation('det [[1,2],[3,4]]');
      expect(eq.validate(), isTrue);
      expect(eq.solve().answer, contains('-2'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('inv [[2,0],[0,2]] halves', () {
      final r = M5MatrixEquation('inv [[2,0],[0,2]]').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('0.5'));
    });

    test('3x3 det of identity = 1', () {
      final r = M5MatrixEquation('det [[1,0,0],[0,1,0],[0,0,1]]').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('1'));
    });

    test('singular matrix has no inverse', () {
      final r = M5MatrixEquation('inv [[1,2],[2,4]]').solve();
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('Singular'));
    });

    test('garbage never throws', () {
      final eq = M5MatrixEquation('blah');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });

  group('M6 modular (extends g6_gcf_lcm)', () {
    test('17 mod 5 = 2', () {
      final eq = M6ModularEquation('17 mod 5');
      expect(eq.validate(), isTrue);
      expect(eq.solve().answer, contains('2'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('3^4 mod 5 = 1', () {
      final r = M6ModularEquation('3^4 mod 5').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('1'));
    });

    test('inv 3 mod 7 = 5', () {
      final r = M6ModularEquation('inv 3 mod 7').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('5'));
    });

    test('(12 + 30) mod 7 = 0', () {
      final r = M6ModularEquation('(12 + 30) mod 7').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('0'));
    });

    test('no inverse when gcd != 1', () {
      final r = M6ModularEquation('inv 2 mod 4').solve();
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('No inverse'));
    });

    test('modulus 1 rejected', () {
      expect(M6ModularEquation('5 mod 1').validate(), isFalse);
    });

    test('garbage never throws', () {
      final eq = M6ModularEquation('xyz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });

  group('Modmat wave1 LaTeX emission (batch 1 of 2)', () {
    test('M1 propositional: variable + result steps carry TeX, rules stay prose',
        () {
      final steps = M1PropositionalEquation('p -> q').getSteps();
      expect(steps, hasLength(4));
      expect(steps[0].latex, 'p, q'); // variables
      expect(steps[1].latex, isNull); // precedence rule
      expect(steps[2].latex, r'\text{contingency (true in 3 of 4 rows)}');
      expect(steps[3].latex, isNull); // classification rule
    });

    test('M2 sets: element list + result carry TeX, op label stays prose', () {
      final union = M2SetsEquation('A={1,2,3} B={3,4} UNION').getSteps();
      expect(union, hasLength(3));
      expect(union[0].latex, r'A = \{1, 2, 3\}, \quad B = \{3, 4\}');
      expect(union[1].latex, isNull); // operation description
      expect(union[2].latex, r'A \cup B = \{1, 2, 3, 4\}');
      expect(M2SetsEquation('{1,2,3} INTERSECT {2,3,9}').getSteps()[2].latex,
          r'A \cap B = \{2, 3\}');
      expect(M2SetsEquation('{1,2,3} DIFF {2}').getSteps()[2].latex,
          r'A \setminus B = \{1, 3\}');
      final sub = M2SetsEquation('{1,2} SUBSET {1,2,3}').getSteps();
      expect(sub[2].latex, r'A \subseteq B');
      expect(sub[2].subLatex, [r'\text{is True}']);
      expect(M2SetsEquation('{1,2,3} CARD').getSteps()[2].latex, r'|A| = 3');
      expect(M2SetsEquation('{1,2,3} POWER').getSteps()[2].latex,
          r'|\mathcal{P}(A)| = 2^{3} = 8');
    });

    test('M3 combinatorics: form + compute carry TeX, range rule stays prose',
        () {
      final comb = M3CombinatoricsEquation('C(5,2)').getSteps();
      expect(comb, hasLength(3));
      expect(comb[0].latex, r'\binom{n}{r} = \frac{n!}{r!\,(n - r)!}');
      expect(comb[1].latex, isNull); // 0 <= r <= n rejection rule
      expect(comb[2].latex, r'\binom{5}{2} = 10');
      final perm = M3CombinatoricsEquation('P(5,2)').getSteps();
      expect(perm[0].latex, r'P(n, r) = \frac{n!}{(n - r)!}');
      expect(perm[2].latex, r'P(5, 2) = 20');
      final fact = M3CombinatoricsEquation('5!').getSteps();
      expect(fact[0].latex, r'n! = 1 \times 2 \times \cdots \times n');
      expect(fact[2].latex, r'5! = 120');
    });

    test('M4 bases: expand + result carry TeX, division rule stays prose', () {
      final bin = M4BaseConversionEquation('1011 base2 to base10').getSteps();
      expect(bin, hasLength(3));
      expect(bin[0].latex, r'1011_{2} = 11_{10}');
      expect(bin[1].latex, isNull); // repeated-division rule
      expect(bin[2].latex, r'1011_{2} = 11_{10}');
      final hex = M4BaseConversionEquation('255 dec to hex').getSteps();
      expect(hex[0].latex, r'255_{10} = 255_{10}');
      expect(hex[2].latex, r'255_{10} = FF_{16}');
    });

    test('M5 matrices: pmatrix + det + inverse carry TeX, verify stays prose',
        () {
      final det = M5MatrixEquation('det [[1,2],[3,4]]').getSteps();
      expect(det, hasLength(3));
      expect(det[0].latex, r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}');
      expect(det[0].subLatex, [r'\det = a \cdot d - b \cdot c']);
      expect(det[1].latex, r'\det = -2');
      expect(det[2].latex, isNull); // verify rule
      final det3 =
          M5MatrixEquation('det [[1,0,0],[0,1,0],[0,0,1]]').getSteps();
      expect(
          det3[0].latex,
          r'\begin{pmatrix} 1 & 0 & 0 \\ 0 & 1 & 0 \\ 0 & 0 & 1 \end{pmatrix}');
      expect(det3[0].subLatex,
          [r'\det = a(ei - fh) - b(di - fg) + c(dh - eg)']);
      expect(det3[1].latex, r'\det = 1');
      final inv = M5MatrixEquation('inv [[2,0],[0,2]]').getSteps();
      expect(inv, hasLength(4));
      expect(inv[1].latex, r'\det = 4');
      expect(inv[2].latex, startsWith(r'A^{-1} = \begin{pmatrix}'));
      expect(inv[2].latex, contains('0.5'));
      expect(inv[3].latex, isNull); // verify rule
    });

    test('M6 modular: residue carries TeX, reduce/operate guidance stays prose',
        () {
      final norm = M6ModularEquation('17 mod 5').getSteps();
      expect(norm, hasLength(3));
      expect(norm[0].latex, isNull); // reduce-into-range rule
      expect(norm[1].latex, isNull); // operate rule
      expect(norm[2].latex, r'17 \equiv 2 \pmod{5}');
      expect(M6ModularEquation('3^4 mod 5').getSteps()[2].latex,
          r'3^{4} \bmod 5 = 1');
      expect(M6ModularEquation('inv 3 mod 7').getSteps()[2].latex,
          r'3^{-1} \equiv 5 \pmod{7}');
      expect(M6ModularEquation('(12 + 30) mod 7').getSteps()[2].latex,
          r'(12 + 30) \bmod 7 = 0');
    });

    test('M7 predicate: statement carries TeX, quantifier/test guidance prose',
        () {
      final fa = M7PredicateEquation('forall x in {1,2,3}: x > 0').getSteps();
      expect(fa, hasLength(3));
      expect(fa[0].latex, isNull); // quantifier semantics rule
      expect(fa[1].latex, isNull); // substitution rule
      expect(fa[2].latex, r'\forall x \in \{1, 2, 3\}: x > 0');
      expect(fa[2].subLatex, [r'\text{is True}']);
      final ex = M7PredicateEquation('exists x in {1,2}: x > 5').getSteps();
      expect(ex[2].latex, r'\exists x \in \{1, 2\}: x > 5');
      expect(ex[2].subLatex, [r'\text{is False}']);
    });

    test('every emitted wave1-modmat TeX line is ASCII (no unicode/control)', () {
      for (final eq in <BaseEquation>[
        M1PropositionalEquation('p -> q'),
        M1PropositionalEquation('p OR NOT p'),
        M2SetsEquation('A={1,2,3} B={3,4} UNION'),
        M2SetsEquation('{1,2,3} INTERSECT {2,3,9}'),
        M2SetsEquation('{1,2,3} DIFF {2}'),
        M2SetsEquation('{1,2} SUBSET {1,2,3}'),
        M2SetsEquation('{1,2,3} CARD'),
        M2SetsEquation('{1,2,3} POWER'),
        M3CombinatoricsEquation('C(5,2)'),
        M3CombinatoricsEquation('P(5,2)'),
        M3CombinatoricsEquation('5!'),
        M4BaseConversionEquation('1011 base2 to base10'),
        M4BaseConversionEquation('FF hex to dec'),
        M4BaseConversionEquation('255 dec to hex'),
        M5MatrixEquation('det [[1,2],[3,4]]'),
        M5MatrixEquation('inv [[2,0],[0,2]]'),
        M5MatrixEquation('det [[1,0,0],[0,1,0],[0,0,1]]'),
        M6ModularEquation('17 mod 5'),
        M6ModularEquation('3^4 mod 5'),
        M6ModularEquation('inv 3 mod 7'),
        M6ModularEquation('(12 + 30) mod 7'),
        M7PredicateEquation('forall x in {1,2,3}: x > 0'),
        M7PredicateEquation('exists x in {1,2}: x > 5'),
      ]) {
        for (final s in eq.getSteps()) {
          for (final tex in <String?>[s.latex, ...?s.subLatex]) {
            if (tex == null) continue;
            expect(tex.codeUnits.every((c) => c >= 0x20 && c <= 0x7e), isTrue,
                reason: '$tex (${s.title})');
          }
        }
      }
    });

    testWidgets(
        'every emitted wave1-modmat TeX line parses (recording fallback)',
        (tester) async {
      final cases = <BaseEquation>[
        M1PropositionalEquation('p -> q'),
        M1PropositionalEquation('p OR NOT p'),
        M2SetsEquation('A={1,2,3} B={3,4} UNION'),
        M2SetsEquation('{1,2,3} INTERSECT {2,3,9}'),
        M2SetsEquation('{1,2,3} DIFF {2}'),
        M2SetsEquation('{1,2} SUBSET {1,2,3}'),
        M2SetsEquation('{1,2,3} CARD'),
        M2SetsEquation('{1,2,3} POWER'),
        M3CombinatoricsEquation('C(5,2)'),
        M3CombinatoricsEquation('P(5,2)'),
        M3CombinatoricsEquation('5!'),
        M4BaseConversionEquation('1011 base2 to base10'),
        M4BaseConversionEquation('FF hex to dec'),
        M4BaseConversionEquation('255 dec to hex'),
        M5MatrixEquation('det [[1,2],[3,4]]'),
        M5MatrixEquation('inv [[2,0],[0,2]]'),
        M5MatrixEquation('det [[1,0,0],[0,1,0],[0,0,1]]'),
        M6ModularEquation('17 mod 5'),
        M6ModularEquation('3^4 mod 5'),
        M6ModularEquation('inv 3 mod 7'),
        M6ModularEquation('(12 + 30) mod 7'),
        M7PredicateEquation('forall x in {1,2,3}: x > 0'),
        M7PredicateEquation('exists x in {1,2}: x > 5'),
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
