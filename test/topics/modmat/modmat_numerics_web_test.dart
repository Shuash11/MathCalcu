// Web-TARGET numerics regression tests for the modmat solvers (m3 / m4 / m12).
//
// These defects are INVISIBLE to the default VM test platform: on the VM `int`
// is a true 64-bit integer, so `1 << 32` == 2^32 and every value up to 2^63-1
// is exact. On the WEB target dart2js models `int` as a JS double, which is
// where the bugs live (32-bit `int <<`, and rounding above 2^53). Run this file
// ON THE WEB TARGET:
//
//   flutter test --platform chrome test/topics/modmat/modmat_numerics_web_test.dart
//
// The web BUILD (`flutter build web --release`, already run by pr-ci.yml) does
// NOT catch this semantic class either — it only catches compile-time breakage
// such as an out-of-range int literal. Only a web-TARGET test observes it.
import 'package:calculus_system/topics/modmat/solvers/m12_proof_equation.dart';
import 'package:calculus_system/topics/modmat/solvers/m3_combinatorics_equation.dart';
import 'package:calculus_system/topics/modmat/solvers/m4_base_conversion_equation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('m12 2^k shifts are exact on the web target', () {
    test('n=31 -> 4294967294 and verifies (shift operand >= 32)', () {
      final r = M12ProofEquation('induction sum 2^k n=31').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('4294967294'));
      expect(r.answer, contains('✓'));
      expect(r.answer, isNot(contains('✗')));
      expect(r.answer, isNot(contains('= -2')));
    });

    test('n=32 -> 8589934590; n=40 -> 2199023255550', () {
      expect(M12ProofEquation('induction sum 2^k n=32').solve().answer,
          contains('8589934590'));
      expect(M12ProofEquation('induction sum 2^k n=40').solve().answer,
          contains('2199023255550'));
    });

    test('n=60 -> 2305843009213693950 (> 2^53, exact digits)', () {
      final r = M12ProofEquation('induction sum 2^k n=60').solve();
      expect(r.answer, contains('2305843009213693950'));
      expect(r.answer, contains('✓'));
    });
  });

  group('m3 combinatorics displays BigInt exactly on the web target', () {
    test('C(94,18) = 9007607943130625829 (not the rounded ...626000)', () {
      final r = M3CombinatoricsEquation('C(94,18)').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, 'C(94,18) = 9007607943130625829');
    });

    test('C(65,32) = 3609714217008132870 (not the rounded ...133000)', () {
      expect(M3CombinatoricsEquation('C(65,32)').solve().answer,
          'C(65,32) = 3609714217008132870');
    });
  });

  group('m4 base conversion is exact on the web target', () {
    test('2^53 + 1 hex converts exactly (no off-by-one)', () {
      final r = M4BaseConversionEquation('20000000000001 hex to dec').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('9007199254740993 (base 10)'));
      expect(r.answer, isNot(contains('9007199254740992')));
    });

    test('2^62 exact; 2^62 + 1 rejected with the magnitude error', () {
      final on = M4BaseConversionEquation('4000000000000000 hex to dec').solve();
      expect(on.hasError, isFalse);
      expect(on.answer, contains('4611686018427387904 (base 10)'));
      final over = M4BaseConversionEquation('4000000000000001 hex to dec');
      expect(over.validate(), isFalse);
      final r = over.solve();
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('exceeds the largest integer'));
    });
  });
}
