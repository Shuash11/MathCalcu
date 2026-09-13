// G6 Wave 2 tests: percent, ratio/proportion, rate (speed/best-buy/meter).
import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('G6-3 percent (M6NS-Ic-131)', () {
    test('25% of 200 = 50', () {
      final eq = G6PercentEquation('25% of 200');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('50'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('R=? P=50 B=200 gives 25%', () {
      final r = G6PercentEquation('R=? P=50 B=200').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('25%'));
    });

    test('B=? P=50 R=25% gives 200', () {
      final r = G6PercentEquation('B=? P=50 R=25%').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('200'));
    });

    test('500 less 20% discounts to 400', () {
      final r = G6PercentEquation('500 less 20%').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('400'));
    });

    test('500 + 12% tax totals 560', () {
      final r = G6PercentEquation('500 + 12% tax').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('560'));
    });

    test('P=1000 R=5% T=2 interest', () {
      final r = G6PercentEquation('P=1000 R=5% T=2').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('100'));
      expect(r.answer, contains('1100.00'));
    });

    test('zero base rate lookup errors', () {
      expect(G6PercentEquation('R=? P=50 B=0').solve().hasError, isTrue);
    });
  });

  group('G6-4 ratio & proportion (M6NS-Id-140)', () {
    test('12:18 simplifies to 2:3', () {
      final eq = G6RatioEquation('12:18');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, '2:3');
      expect(r.customData?.first['bars'], hasLength(2));
      expect(eq.getSteps(), hasLength(4));
    });

    test('3/4 = x/20 gives x=15', () {
      final eq = G6RatioEquation('3/4 = x/20');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('15'));
      expect(eq.getSteps(), hasLength(4));
    });

    test('direct variation finds k', () {
      final r = G6RatioEquation('direct x=4 y=12').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('k = 3'));
    });

    test('inverse variation finds k', () {
      final r = G6RatioEquation('inverse x=4 y=6').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('k = 24'));
    });

    test('partitive 120 in 2:3', () {
      final r = G6RatioEquation('divide 120 in 2:3').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('48'));
      expect(r.answer, contains('72'));
    });

    test('non-positive ratio rejected', () {
      expect(G6RatioEquation('0:5').validate(), isFalse);
    });
  });

  group('G6-6 algebra (M6AL-IIIa-28)', () {
    test('x + 7 = 15 gives x=8', () {
      final eq = G6AlgebraEquation('x + 7 = 15');
      expect(eq.validate(), isTrue);
      expect(eq.solve().answer, contains('8'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('3n = 21 gives n=7', () {
      expect(G6AlgebraEquation('3n = 21').solve().answer, contains('7'));
    });

    test('x/4 = 5 gives x=20', () {
      expect(G6AlgebraEquation('x/4 = 5').solve().answer, contains('20'));
    });

    test('two equals signs rejected', () {
      expect(G6AlgebraEquation('x = 2 = 3').validate(), isFalse);
    });
  });

  group('G6 rate: speed, best-buy, meter', () {
    test('R=? D=120 T=2 gives 60', () {
      final eq = G6RateEquation('R=? D=120 T=2');
      expect(eq.validate(), isTrue);
      expect(eq.solve().answer, contains('60'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('D=? R=60 T=2 gives 120', () {
      expect(G6RateEquation('D=? R=60 T=2').solve().answer, contains('120'));
    });

    test('best-buy picks cheaper unit price', () {
      final r = G6RateEquation('compare 500g 120 vs 1kg 220').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('Second'));
    });

    test('meter reading bills use x rate', () {
      final r = G6RateEquation('prev=1250 pres=1380 rate=12').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('130'));
      expect(r.answer, contains('1560.00'));
    });

    test('reversed meter errors', () {
      expect(G6RateEquation('prev=1380 pres=1250 rate=12').solve().hasError,
          isTrue);
    });
  });
}
