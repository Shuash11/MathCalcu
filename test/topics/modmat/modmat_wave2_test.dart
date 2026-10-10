// ModMath wave-2 tests (Cycle 9 F2): M7 predicate, M8 relations,
// M9 real analysis, M10 algebraic structures, M11 graph basics,
// M12 proof, M13 topology, M14 advanced graph + college-stats (F4).
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/topics/college/solvers/college_solver_registry.dart';
import 'package:calculus_system/topics/modmat/solvers/modmat_equations.dart';
import 'package:calculus_system/topics/modmat/solvers/modmat_solver_registry.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Render [tex] with a recording `onErrorFallback` and assert it was NOT
/// invoked, i.e. the TeX parsed. The horizontal scroll gives the math line
/// unbounded width so a long line cannot raise a (non-parse) overflow error.
Future<void> _expectTexParses(WidgetTester tester, String tex) async {
  var fellBack = false;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Math.tex(
            tex,
            textStyle: const TextStyle(fontSize: 14),
            onErrorFallback: (e) {
              fellBack = true;
              return const SizedBox();
            },
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  expect(fellBack, isFalse, reason: 'TeX failed to parse: $tex');
}

/// Every solver input exercised by the wave-2 LaTeX emission checks.
List<BaseEquation> _wave2Cases() => <BaseEquation>[
  M8RelationsEquation('R={(1,1),(2,2)} on {1,2}'),
  M8RelationsEquation('R={(1,1),(2,2),(1,2)} on {1,2}'),
  M9RealAnalysisEquation('lim (2n+1)/(n+3)'),
  M9RealAnalysisEquation('lim 1/n'),
  M9RealAnalysisEquation('lim 5'),
  M9RealAnalysisEquation('lim n^2'),
  M10AlgebraicStructuresEquation('Z5 + group'),
  M10AlgebraicStructuresEquation('Z4 * group'),
  M10AlgebraicStructuresEquation('Z7 field'),
  M10AlgebraicStructuresEquation('Z8 ring'),
  M10AlgebraicStructuresEquation('Z10 units'),
  M11GraphBasicsEquation('V=4 E={(0,1),(1,2),(2,3)}'),
  M11GraphBasicsEquation('V=3 E={(0,1),(1,2),(0,2)}'),
  M12ProofEquation('induction sum k n=5'),
  M12ProofEquation('induction sum k^2 n=3'),
  M12ProofEquation('induction sum k^3 n=4'),
  M12ProofEquation('induction sum 2^k n=5'),
  M13TopologyEquation('(0,1)'),
  M13TopologyEquation('[0,1]'),
  M13TopologyEquation('R'),
  M13TopologyEquation('empty'),
  M13TopologyEquation('{1,2}'),
  M14AdvancedGraphEquation('V=4 E={(0,1),(1,2),(2,3)} bipartite'),
  M14AdvancedGraphEquation('V=5 E={(0,1),(1,2),(2,3),(3,0),(0,2)} color'),
  M14AdvancedGraphEquation('V=4 E={(0,1),(1,2),(2,3)} planar'),
  M14AdvancedGraphEquation('V=4 E={(0,1),(1,2),(2,3)} shortest 0->3'),
  M14AdvancedGraphEquation('V=4 E={(0,1)} shortest 0->3'),
  M14AdvancedGraphEquation('V=4 E={(0,1),(1,2),(2,3)}'),
];

void main() {
  group('ModmatSolverRegistry wave 2 wiring', () {
    test('14 specs, unique ids, byId round-trip', () {
      expect(ModmatSolverRegistry.specs, hasLength(14));
      final ids = ModmatSolverRegistry.specs.map((s) => s.id).toList();
      expect(ids.toSet(), hasLength(14));
      for (final s in ModmatSolverRegistry.specs) {
        expect(ModmatSolverRegistry.byId(s.id), isNotNull);
      }
      expect(ModmatSolverRegistry.byId('nope'), isNull);
    });

    test('college-stats registry resolves', () {
      expect(CollegeSolverRegistry.specs, hasLength(1));
      expect(CollegeSolverRegistry.byId('college-stats'), isNotNull);
      expect(CollegeSolverRegistry.byId('nope'), isNull);
    });
  });

  group('M7 predicate', () {
    test('forall x in {1,2,3}: x > 0 is True', () {
      final eq = M7PredicateEquation('forall x in {1,2,3}: x > 0');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('True'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('exists finds a witness', () {
      final r = M7PredicateEquation('exists x in {1,2}: x > 5').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('False'));
    });

    test('garbage + empty never throw', () {
      final eq = M7PredicateEquation('hello');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
      expect(M7PredicateEquation('   ').validate(), isFalse);
    });
  });

  group('M8 relations', () {
    test('identity on {1,2} is an equivalence relation', () {
      final eq = M8RelationsEquation('R={(1,1),(2,2)} on {1,2}');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('equivalence'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('<= style relation is a partial order', () {
      final r = M8RelationsEquation('R={(1,1),(2,2),(1,2)} on {1,2}').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('partial order'));
    });

    test('garbage never throws', () {
      final eq = M8RelationsEquation('hello');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });

  group('M9 real analysis', () {
    test('lim (2n+1)/(n+3) = 2', () {
      final eq = M9RealAnalysisEquation('lim (2n+1)/(n+3)');
      expect(eq.validate(), isTrue);
      expect(eq.solve().answer, contains('2'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('lim 1/n = 0', () {
      expect(M9RealAnalysisEquation('lim 1/n').solve().answer, contains('0'));
    });

    test('garbage never throws', () {
      final eq = M9RealAnalysisEquation('xyz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });

  group('M10 algebraic structures', () {
    test('(Z5,+) is an abelian group', () {
      final eq = M10AlgebraicStructuresEquation('Z5 + group');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('abelian group'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('(Z4,x) is NOT a group; Z7 is a field', () {
      expect(
        M10AlgebraicStructuresEquation('Z4 * group').solve().answer,
        contains('NOT a group'),
      );
      expect(
        M10AlgebraicStructuresEquation('Z7 field').solve().answer,
        contains('is a field'),
      );
    });

    test('garbage never throws', () {
      final eq = M10AlgebraicStructuresEquation('xyz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
    });
  });

  group('M11 graph basics', () {
    test('path P4 metrics', () {
      final eq = M11GraphBasicsEquation('V=4 E={(0,1),(1,2),(2,3)}');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('is a tree'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('triangle has Euler circuit', () {
      final r = M11GraphBasicsEquation('V=3 E={(0,1),(1,2),(0,2)}').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('circuit'));
    });

    test('word-embedded "v" is not read as the vertex count', () {
      // Pre-fix: `v\s*=` had no left word boundary, so the "v=1" inside
      // "conv=1" was read as n=1; the n <= maxV(3) guard then made this
      // VALID edge list error instead of defaulting to n = maxV + 1 = 4.
      // Post-fix: no bounded 'v' -> n defaults to 4 and it solves.
      final eq = M11GraphBasicsEquation('conv=1 E={(0,1),(1,2),(2,3)}');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('n=4'));
    });

    test('legitimate bounded v=5 still parses', () {
      final r = M11GraphBasicsEquation('v=5 E={(0,1),(1,2),(2,3)}').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('n=5'));
    });

    test('garbage never throws', () {
      final eq = M11GraphBasicsEquation('xyz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
    });
  });

  group('M12 proof (induction)', () {
    test('sum k at n=5 is 15', () {
      final eq = M12ProofEquation('induction sum k n=5');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('15'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('sum k^2 at n=3 is 14', () {
      expect(
        M12ProofEquation('induction sum k^2 n=3').solve().answer,
        contains('14'),
      );
    });

    // ── Phase 6 regression: 2^k at n >= 31 and above 2^53 ──────────────────
    // dart2js models `int <<` as a 32-bit JS shift, so the closed form
    // `(1 << (n + 1)) - 2` collapsed to −2 on the web target for EVERY n >= 31
    // (sum 2^k at n=31/60 printed 'both sides = -2 ✗'); and for n >= 53 the
    // value exceeds 2^53 and cannot round-trip through `int` for display. Both
    // the closed form and the direct sum are now BigInt, so the answer is exact
    // and the two sides self-consistently agree. NOTE: these pass on the VM
    // before and after the fix (the VM `<<` and int64 are exact) — the defect
    // is invisible to this VM suite; modmat_numerics_web_test.dart is what
    // actually pins it on the web target.
    test('Phase6: 2^k at n=31 is 4294967294 and verifies', () {
      final r = M12ProofEquation('induction sum 2^k n=31').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('4294967294'));
      expect(r.answer, contains('✓'));
      expect(r.answer, isNot(contains('✗')));
    });

    test('Phase6: 2^k at n=32 and n=60 (n=60 exceeds 2^53)', () {
      expect(
        M12ProofEquation('induction sum 2^k n=32').solve().answer,
        contains('8589934590'),
      );
      final r = M12ProofEquation('induction sum 2^k n=60').solve();
      expect(r.answer, contains('2305843009213693950'));
      expect(r.answer, contains('✓'));
    });

    test('garbage never throws', () {
      final eq = M12ProofEquation('xyz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
    });
  });

  group('M13 topology', () {
    test('(0,1) is open, not compact', () {
      final eq = M13TopologyEquation('(0,1)');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('open'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('[0,1] is compact', () {
      expect(M13TopologyEquation('[0,1]').solve().answer, contains('compact'));
    });

    test('garbage never throws', () {
      final eq = M13TopologyEquation('a to b');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
    });
  });

  group('M14 advanced graph', () {
    test('path is bipartite', () {
      final eq = M14AdvancedGraphEquation(
        'V=4 E={(0,1),(1,2),(2,3)} bipartite',
      );
      expect(eq.validate(), isTrue);
      expect(eq.solve().answer, contains('yes'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('word-embedded "v" is not read as the vertex count', () {
      // Pre-fix: `v\s*=` matched the "v=1" inside "conv=1" as n=1;
      // n <= maxV(3) then returned null so this VALID edge list errored.
      // Post-fix: no bounded 'v' -> n defaults to maxV + 1 = 4.
      final eq = M14AdvancedGraphEquation('conv=1 E={(0,1),(1,2),(2,3)}');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('n=4'));
    });

    test('legitimate bounded V=5 still parses', () {
      final r = M14AdvancedGraphEquation('V=5 E={(0,1),(1,2),(2,3)} bipartite')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('yes'));
    });

    test('shortest path BFS', () {
      final r = M14AdvancedGraphEquation(
        'V=4 E={(0,1),(1,2),(2,3)} shortest 0->3',
      ).solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('length 3'));
    });

    test('garbage never throws', () {
      final eq = M14AdvancedGraphEquation('xyz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
    });
  });

  group('College stats (F4)', () {
    test('4,7,9 descriptive stats', () {
      final eq = CollegeStatsEquation('4,7,9 stats');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('mean='));
      expect(r.answer, contains('median=7'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('regression y=2x line', () {
      final r = CollegeStatsEquation('x:1,2,3 y:2,4,6 regress').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('r = 1'));
    });

    test('z-test rejects far mean', () {
      final r = CollegeStatsEquation('ztest mean=72 mu=70 sd=10 n=25').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('z = 1 (SE = 2)'));
    });

    test('garbage never throws', () {
      final eq = CollegeStatsEquation('xyz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });

  group('Modmat wave2 LaTeX emission (batch 2 of 2)', () {
    test('M8 relations: classify carries TeX, property rules stay prose', () {
      final st = M8RelationsEquation('R={(1,1),(2,2)} on {1,2}').getSteps();
      expect(st, hasLength(3));
      expect(st[0].latex, isNull); // reflexive + symmetric rule
      expect(st[1].latex, isNull); // antisymmetric + transitive rule
      expect(st[2].latex, r'R \subseteq \{1, 2\} \times \{1, 2\}');
      expect(st[2].subLatex, [
        r'R = \{(1, 1), (2, 2)\}',
        r'\text{reflexive: yes, symmetric: yes, antisymmetric: yes, transitive: yes}',
        r'\text{equivalence relation}',
      ]);
      final po = M8RelationsEquation('R={(1,1),(2,2),(1,2)} on {1,2}')
          .getSteps();
      expect(po[2].subLatex![1], contains('symmetric: no'));
      expect(po[2].subLatex!.last, r'\text{partial order}');
    });

    test('M9 real analysis: limit carries TeX, degree rules stay prose', () {
      final st = M9RealAnalysisEquation('lim (2n+1)/(n+3)').getSteps();
      expect(st, hasLength(3));
      expect(st[0].latex, isNull); // degree-comparison rule
      expect(st[1].latex, isNull); // divide-by-top-power rule
      expect(st[2].latex, r'\lim_{n \to \infty} \frac{2n + 1}{n + 3} = 2');
      expect(
        M9RealAnalysisEquation('lim 1/n').getSteps()[2].latex,
        r'\lim_{n \to \infty} \frac{1}{n} = 0',
      );
      expect(
        M9RealAnalysisEquation('lim 5').getSteps()[2].latex,
        r'\lim_{n \to \infty} 5 = 5',
      );
      expect(
        M9RealAnalysisEquation('lim n^2').getSteps()[2].latex,
        r'\lim_{n \to \infty} n^{2} = +\infty',
      );
    });

    test('M10 algebraic structures: decide carries TeX, axioms stay prose', () {
      final g = M10AlgebraicStructuresEquation('Z5 + group').getSteps();
      expect(g, hasLength(3));
      expect(g[0].latex, isNull); // closure + identity guidance
      expect(g[1].latex, isNull); // inverses + commutativity guidance
      expect(g[2].latex, r'(\mathbb{Z}_{5}, +)');
      expect(g[2].subLatex, [r'\text{abelian group of order } 5']);
      final grp = M10AlgebraicStructuresEquation('Z4 * group').getSteps();
      expect(grp[2].latex, r'(\mathbb{Z}_{4}, \times)');
      expect(grp[2].subLatex, [r'\text{monoid, not a group}']);
      final f = M10AlgebraicStructuresEquation('Z7 field').getSteps();
      expect(f[2].latex, r'(\mathbb{Z}_{7}, +, \times)');
      expect(f[2].subLatex, [r'\text{field}']);
      expect(M10AlgebraicStructuresEquation('Z8 ring').getSteps()[2].subLatex, [
        r'\text{commutative ring}',
      ]);
      expect(
        M10AlgebraicStructuresEquation('Z10 units').getSteps()[2].subLatex,
        [r'\text{units } \varphi(10) = 4'],
      );
    });

    test(
      'M11 graph basics: handshake + read-off carry TeX, rules stay prose',
      () {
        final st = M11GraphBasicsEquation('V=4 E={(0,1),(1,2),(2,3)}')
            .getSteps();
        expect(st, hasLength(3));
        expect(st[0].latex, isNull); // degree rule
        expect(st[1].latex, isNull); // components rule
        expect(st[2].latex, r'\sum_{v} \deg(v) = 6 = 2|E|');
        expect(st[2].subLatex, [
          r'\deg(v) = [1, 2, 2, 1]',
          r'|V| = 4, |E| = 3',
          r'\text{trail only}',
        ]);
        final tri = M11GraphBasicsEquation('V=3 E={(0,1),(1,2),(0,2)}')
            .getSteps();
        expect(tri[2].subLatex!.last, r'\text{circuit + trail}');
      },
    );

    test(
      'M12 proof: base/inductive/instance all carry TeX (no prose step)',
      () {
        final st = M12ProofEquation('induction sum k n=5').getSteps();
        expect(st, hasLength(3));
        expect(st[0].latex, r'\sum_{k=1}^{1} k = \frac{1(1 + 1)}{2} = 1');
        expect(st[0].subLatex, [r'\sum_{k=1}^{n} k = \frac{n(n + 1)}{2}']);
        expect(st[1].latex, r'P(k) \implies P(k + 1)');
        expect(st[2].latex, r'\sum_{k=1}^{5} k = \frac{5(5 + 1)}{2} = 15');
        expect(
          M12ProofEquation('induction sum k^2 n=3').getSteps()[2].latex,
          r'\sum_{k=1}^{3} k^{2} = \frac{3(3 + 1)(2 \cdot 3 + 1)}{6} = 14',
        );
        expect(
          M12ProofEquation('induction sum k^3 n=4').getSteps()[2].latex,
          r'\sum_{k=1}^{4} k^{3} = [\frac{4(4 + 1)}{2}]^{2} = 100',
        );
        expect(
          M12ProofEquation('induction sum 2^k n=5').getSteps()[2].latex,
          r'\sum_{k=1}^{5} 2^{k} = 2^{5 + 1} - 2 = 62',
        );
      },
    );

    test('M13 topology: classification carries TeX, rules stay prose', () {
      final o = M13TopologyEquation('(0,1)').getSteps();
      expect(o, hasLength(3));
      expect(o[0].latex, isNull); // endpoints rule
      expect(o[1].latex, isNull); // Heine-Borel rule
      expect(o[2].latex, '(0, 1)');
      expect(o[2].subLatex, [r'\text{open}', r'\text{not compact, connected}']);
      final cl = M13TopologyEquation('[0,1]').getSteps();
      expect(cl[2].latex, '[0, 1]');
      expect(cl[2].subLatex, [r'\text{closed}', r'\text{compact, connected}']);
      expect(M13TopologyEquation('R').getSteps()[2].latex, r'\mathbb{R}');
      final e = M13TopologyEquation('empty').getSteps();
      expect(e[2].latex, r'\emptyset');
      expect(e[2].subLatex, [
        r'\text{clopen}',
        r'\text{compact, disconnected}',
      ]);
      expect(
        M13TopologyEquation('{1,2}').getSteps()[2].latex,
        r'\text{finite set}',
      );
    });

    test(
      'M14 advanced graph: result carries TeX per query, rules stay prose',
      () {
        final bi = M14AdvancedGraphEquation(
          'V=4 E={(0,1),(1,2),(2,3)} bipartite',
        ).getSteps();
        expect(bi, hasLength(3));
        expect(bi[0].latex, isNull); // two-color rule
        expect(bi[1].latex, isNull); // greedy + bound rule
        expect(bi[2].latex, r'\chi(G) \leq 2');
        expect(bi[2].subLatex, [r'\text{bipartite}']);
        final col = M14AdvancedGraphEquation(
          'V=5 E={(0,1),(1,2),(2,3),(3,0),(0,2)} color',
        ).getSteps();
        expect(col[2].latex, r'\chi(G) \leq 3');
        expect(col[2].subLatex, [r'\text{colors } [0, 1, 2, 1, 0]']);
        expect(
          M14AdvancedGraphEquation('V=4 E={(0,1),(1,2),(2,3)} planar')
              .getSteps()[2]
              .latex,
          r'|E| = 3 \leq 3|V| - 6 = 6',
        );
        final sp = M14AdvancedGraphEquation(
          'V=4 E={(0,1),(1,2),(2,3)} shortest 0->3',
        ).getSteps();
        expect(sp[2].latex, r'd(0, 3) = 3');
        expect(sp[2].subLatex, [r'0 \to 1 \to 2 \to 3']);
        expect(
          M14AdvancedGraphEquation('V=4 E={(0,1)} shortest 0->3')
              .getSteps()[2]
              .subLatex,
          [r'\text{no path}'],
        );
        final full = M14AdvancedGraphEquation('V=4 E={(0,1),(1,2),(2,3)}')
            .getSteps();
        expect(full[2].latex, r'\chi(G) \leq 2');
        expect(full[2].subLatex, [r'|V| = 4, |E| = 3', r'\text{bipartite}']);
      },
    );

    test(
      'math steps carry non-empty TeX; deliberate prose steps stay null',
      () {
        // Result step (index 2) is math for every solver; steps 0-1 are prose
        // rules/guidance except M12, whose whole proof outline is mathematical.
        final resultMath = <BaseEquation>[
          M8RelationsEquation('R={(1,1),(2,2)} on {1,2}'),
          M9RealAnalysisEquation('lim (2n+1)/(n+3)'),
          M10AlgebraicStructuresEquation('Z5 + group'),
          M11GraphBasicsEquation('V=4 E={(0,1),(1,2),(2,3)}'),
          M13TopologyEquation('(0,1)'),
          M14AdvancedGraphEquation('V=4 E={(0,1),(1,2),(2,3)} bipartite'),
        ];
        for (final eq in resultMath) {
          final steps = eq.getSteps();
          expect(steps, hasLength(3));
          expect(steps[0].latex, isNull, reason: '${eq.runtimeType} step 1');
          expect(steps[1].latex, isNull, reason: '${eq.runtimeType} step 2');
          expect(steps[2].latex, isNotNull, reason: '${eq.runtimeType} step 3');
          expect(
            steps[2].latex,
            isNotEmpty,
            reason: '${eq.runtimeType} step 3',
          );
        }
        for (final eq in <BaseEquation>[
          M12ProofEquation('induction sum k n=5'),
          M12ProofEquation('induction sum k^2 n=3'),
        ]) {
          for (final s in eq.getSteps()) {
            expect(s.latex, isNotNull);
            expect(s.latex, isNotEmpty);
          }
        }
      },
    );

    test(
      'every emitted wave2 modmat TeX line is ASCII (no unicode/control)',
      () {
        for (final eq in _wave2Cases()) {
          for (final s in eq.getSteps()) {
            for (final tex in <String?>[s.latex, ...?s.subLatex]) {
              if (tex == null) continue;
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

    testWidgets('every emitted wave2 modmat TeX line parses '
        '(recording fallback)', (tester) async {
      var checked = 0;
      for (final eq in _wave2Cases()) {
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
