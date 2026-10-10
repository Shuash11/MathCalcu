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
  M13TopologyEquation('{1}'),
  M13TopologyEquation('[0,inf)'),
  M13TopologyEquation('(-inf,0]'),
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
        r'\text{compact, connected}',
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

  // ── Phase 10 CORRECTNESS Tier B regressions (false statements) ─────────────
  group('Phase10 Tier B correctness regressions', () {
    test('M13: the empty set IS connected (∅ admits no separation)', () {
      // Pre-fix: ∅ was reported 'disconnected'. That is FALSE — a separation
      // needs two disjoint NON-EMPTY open sets, and ∅ has none, so ∅ (like
      // every space with < 2 points and every indiscrete-looking case here) is
      // connected. The fix is scoped to the connectedness classification; the
      // clopen / compact / bounded readings were already correct.
      final eq = M13TopologyEquation('empty');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('connected'));
      expect(r.answer, isNot(contains('disconnected')));
      expect(r.answer, startsWith('∅ is clopen, compact, connected, bounded'));
      final data = r.customData!.first as Map;
      expect(data['connected'], isTrue);
      // Other ∅ properties are unchanged and correct.
      expect(data['open'], isTrue);
      expect(data['closed'], isTrue);
      expect(data['compact'], isTrue);
      expect(data['bounded'], isTrue);
      // TeX lockstep: the ∅ classification sub-line now agrees with the prose.
      final st = M13TopologyEquation('empty').getSteps();
      expect(st, hasLength(3));
      expect(st[2].latex, r'\emptyset');
      expect(st[2].subLatex, [
        r'\text{clopen}',
        r'\text{compact, connected}',
      ]);
      // The two other ∅ spellings agree.
      for (final alt in <String>['∅', '{}']) {
        final a = M13TopologyEquation(alt).solve().answer;
        expect(a, contains('connected'), reason: alt);
        expect(a, isNot(contains('disconnected')), reason: alt);
      }
    });

    test('M10: n=1 field verdict stays NOT a field, reason is the zero ring', () {
      // Adjudicated: the VERDICT is correct (the zero ring has 1 = 0, so it is
      // not a field) but the stated REASON was wrong — n=1 is neither prime nor
      // composite and there are NO zero divisors in Z1. Fix the reason only.
      final eq = M10AlgebraicStructuresEquation('Z1 field');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('NOT a field')); // verdict unchanged
      expect(r.answer, isNot(contains('composite'))); // wrong reason gone
      expect(r.answer, contains('zero ring')); // real reason present
      expect((r.customData!.first as Map)['holds'], isFalse);
      // The decide step prose mirrors the answer; TeX still reads 'not a field'.
      final st = eq.getSteps();
      expect(st, hasLength(3));
      expect(st[2].explanation, contains('zero ring'));
      expect(st[2].explanation, isNot(contains('composite')));
      expect(st[2].subLatex, [r'\text{not a field}']);
    });

    test('M10: prime n still reports a field', () {
      for (final n in <int>[2, 3, 5, 7, 13]) {
        final r = M10AlgebraicStructuresEquation('Z$n field').solve();
        expect(r.answer, contains('is a field'), reason: 'n=$n');
        expect(r.answer, isNot(contains('NOT a field')), reason: 'n=$n');
        expect((r.customData!.first as Map)['holds'], isTrue, reason: 'n=$n');
      }
    });

    test('M10: composite n>=4 still reports the zero-divisor reason', () {
      for (final n in <int>[4, 6, 8, 9, 10, 12]) {
        final r = M10AlgebraicStructuresEquation('Z$n field').solve();
        expect(r.answer, contains('NOT a field'), reason: 'n=$n');
        expect(r.answer, contains('composite'), reason: 'n=$n');
        expect(r.answer, contains('zero divisors'), reason: 'n=$n');
      }
    });

    test('M10: φ(1) = 1 takes the singular noun', () {
      final r = M10AlgebraicStructuresEquation('Z1 units').solve();
      expect(r.answer, contains('1 unit'));
      expect(r.answer, isNot(contains('1 units')));
      // Plural is preserved where it is genuinely plural.
      expect(
        M10AlgebraicStructuresEquation('Z10 units').solve().answer,
        contains('4 units'),
      );
    });

    // ── Phase 11 Tier B2 (false statements, root-level) ─────────────────────

    test('M13: singleton sets ARE connected (a one-point space admits no '
        'separation)', () {
      // ROOT CAUSE: the finite/brace branch hardcoded `connected = false` for
      // every brace-set, ignoring cardinality — the same root as the just-fixed
      // ∅ bug. In the subspace topology of R a finite set is connected iff it
      // has <= 1 point. RED on baseline: '{1}' printed
      // 'finite set is closed, compact, disconnected, bounded (standard
      // topology on R).' (a one-point set IS connected).
      for (final input in <String>['{1}', '{0}', '{-1}', '{1,1}']) {
        final eq = M13TopologyEquation(input);
        expect(eq.validate(), isTrue, reason: input);
        final r = eq.solve();
        expect(r.hasError, isFalse, reason: input);
        expect(
          r.answer,
          'finite set is closed, compact, connected, bounded '
          '(standard topology on R).',
          reason: input,
        );
        final d = r.customData!.first as Map;
        expect(d['connected'], isTrue, reason: input);
        // Other finite-set tags are unchanged and correct.
        expect(d['open'], isFalse, reason: input);
        expect(d['closed'], isTrue, reason: input);
        expect(d['compact'], isTrue, reason: input);
        expect(d['bounded'], isTrue, reason: input);
        // TeX lockstep: the singleton sub-line now reads 'connected', not
        // 'disconnected'. (RED on baseline: second line was
        // r'\text{compact, disconnected}'.)
        final st = eq.getSteps();
        expect(st, hasLength(3), reason: input);
        expect(st[2].latex, r'\text{finite set}', reason: input);
        expect(st[2].subLatex, [
          r'\text{closed}',
          r'\text{compact, connected}',
        ], reason: input);
      }
    });

    test('M13: {1,1} collapses to a singleton (set semantics) and IS connected',
        () {
      // Duplicate entries denote one point: {1,1} = {1}. Cardinality-based
      // connectedness must count DISTINCT elements, so this is connected.
      // (RED on baseline: reported disconnected with the other brace-sets.)
      final r = M13TopologyEquation('{1,1}').solve();
      expect(r.answer, contains('closed, compact, connected, bounded'));
      expect((r.customData!.first as Map)['connected'], isTrue);
    });

    test('M13: multi-element finite sets stay disconnected (each point is open '
        'in the subspace, giving a separation)', () {
      // {a,b} = {a} ⊔ {b} with both pieces open in the subspace topology, so
      // every finite set with >= 2 points is disconnected. This must NOT change
      // with the cardinality fix.
      for (final input in <String>['{1,2}', '{1,2,3}', '{0,1}', '{1,1,2}']) {
        final r = M13TopologyEquation(input).solve();
        expect(
          r.answer,
          'finite set is closed, compact, disconnected, bounded '
          '(standard topology on R).',
          reason: input,
        );
        expect((r.customData!.first as Map)['connected'], isFalse, reason: input);
        expect(M13TopologyEquation(input).getSteps()[2].subLatex, [
          r'\text{closed}',
          r'\text{compact, disconnected}',
        ], reason: input);
      }
    });

    test('M13: closed half-lines ARE closed (they contain their finite '
        'endpoint)', () {
      // [0,∞) = R \ (-∞,0) is closed; (-∞,0] = R \ (0,∞) is closed. The old
      // code zeroed the effective bracket flags at an infinite end and then
      // required BOTH flags for closedness, so it reported 'neither open nor
      // closed'. RED on baseline: '[0,inf)' -> '[0.0,Infinity) is neither open
      // nor closed, not compact, connected, unbounded ...'. An infinite end is
      // not an endpoint of the set, so it neither opens nor uncloses it.
      for (final input in <String>['[0,inf)', '[0,inf]', '(-inf,0]']) {
        final eq = M13TopologyEquation(input);
        expect(eq.validate(), isTrue, reason: input);
        final r = eq.solve();
        expect(r.answer, isNot(contains('neither open nor closed')), reason: input);
        expect(r.answer, contains('is closed,'), reason: input);
        final d = r.customData!.first as Map;
        expect(d['open'], isFalse, reason: input);
        expect(d['closed'], isTrue, reason: input);
        expect(d['compact'], isFalse, reason: input); // unbounded
        expect(d['connected'], isTrue, reason: input);
        final st = eq.getSteps();
        expect(st[2].subLatex!.first, r'\text{closed}', reason: input);
        expect(st[2].subLatex!.last, r'\text{not compact, connected}',
            reason: input);
      }
    });

    test('M13: open half-lines stay open (no finite endpoint included)', () {
      // Regression guard for the closedness fix: an excluded finite endpoint
      // still makes the half-line open and not closed.
      for (final input in <String>['(0,inf)', '(-inf,0)']) {
        final r = M13TopologyEquation(input).solve();
        expect(r.answer, contains('is open,'), reason: input);
        expect(r.answer, isNot(contains('closed')), reason: input);
        final d = r.customData!.first as Map;
        expect(d['open'], isTrue, reason: input);
        expect(d['closed'], isFalse, reason: input);
      }
      // (0,inf] and (-inf,0] are the SAME sets as (0,inf) and (-inf,0) up to
      // the meaningless ']' at infinity; the finite (excluded) end keeps them
      // open, not closed.
      expect(M13TopologyEquation('(0,inf]').solve().answer, contains('is open,'));
      expect(
        (M13TopologyEquation('(0,inf]').solve().customData!.first as Map)['closed'],
        isFalse,
      );
    });

    test('M13: (-inf,inf] degenerates to R and is clopen', () {
      // (-∞,∞] = (-∞,∞) = R: both ends infinite, so the whole set is R, which
      // is both open and closed. RED on baseline: reported merely 'open'
      // ('(-Infinity,Infinity) is open, not compact, connected, unbounded'),
      // which under the clopen-tag scheme asserts "not closed" — false. Note
      // the fully-open spelling '(-inf,inf)' already maps to the named R.
      final r = M13TopologyEquation('(-inf,inf]').solve();
      expect(r.answer, startsWith('(-Infinity,Infinity) is clopen'), reason: r.answer);
      final d = r.customData!.first as Map;
      expect(d['open'], isTrue);
      expect(d['closed'], isTrue);
      expect(d['connected'], isTrue);
      expect(d['bounded'], isFalse);
    });

    test('M13 audit anchors: R/Q/Z/∅/interval classifications are correct', () {
      // Anchors the rest of the m13 audit so a future refactor cannot silently
      // flip a tag that was verified correct in Phase 11.
      // R: clopen, unbounded, not compact, connected.
      var d = M13TopologyEquation('R').solve().customData!.first as Map;
      expect([d['open'], d['closed'], d['compact'], d['connected'], d['bounded']],
          [true, true, false, true, false]);
      // Q: neither open nor closed, not compact, TOTALLY DISCONNECTED, unbounded.
      d = M13TopologyEquation('Q').solve().customData!.first as Map;
      expect([d['open'], d['closed'], d['compact'], d['connected'], d['bounded']],
          [false, false, false, false, false]);
      // Z: closed, unbounded, not compact, TOTALLY DISCONNECTED.
      d = M13TopologyEquation('Z').solve().customData!.first as Map;
      expect([d['open'], d['closed'], d['compact'], d['connected'], d['bounded']],
          [false, true, false, false, false]);
      // ∅: clopen, compact, connected, bounded.
      d = M13TopologyEquation('empty').solve().customData!.first as Map;
      expect([d['open'], d['closed'], d['compact'], d['connected'], d['bounded']],
          [true, true, true, true, true]);
      // (0,1): open, not compact, connected, bounded.
      d = M13TopologyEquation('(0,1)').solve().customData!.first as Map;
      expect([d['open'], d['closed'], d['compact'], d['connected'], d['bounded']],
          [true, false, false, true, true]);
      // [0,1]: closed, compact, connected, bounded.
      d = M13TopologyEquation('[0,1]').solve().customData!.first as Map;
      expect([d['open'], d['closed'], d['compact'], d['connected'], d['bounded']],
          [false, true, true, true, true]);
      // (0,1]: neither open nor closed, not compact, connected, bounded.
      d = M13TopologyEquation('(0,1]').solve().customData!.first as Map;
      expect([d['open'], d['closed'], d['compact'], d['connected'], d['bounded']],
          [false, false, false, true, true]);
    });

    test('M10: the multiplicative-monoid line agrees in number (1 unit vs '
        'N units)', () {
      // Cosmetic grammar bug: the line hardcoded the plural, so n=2 (φ = 1)
      // printed '... its 1 units form an abelian group.' The claim is true; the
      // noun was wrong. RED on baseline: contains '1 units'.
      final two = M10AlgebraicStructuresEquation('Z2 * group').solve().answer;
      expect(two, contains('its 1 unit form an abelian group'), reason: two);
      expect(two, isNot(contains('1 units')), reason: two);
      // Plural is preserved where φ(n) > 1.
      final expectUnits = <int, int>{6: 2, 8: 4, 9: 6, 10: 4, 12: 4};
      expectUnits.forEach((n, units) {
        final a = M10AlgebraicStructuresEquation('Z$n * group').solve().answer;
        expect(a, contains('its $units units form an abelian group'),
            reason: 'n=$n');
        expect(a, isNot(contains('$units unit ')), reason: 'n=$n');
      });
      // TeX lockstep: the decide sub-line is count-free and unchanged.
      final st = M10AlgebraicStructuresEquation('Z2 * group').getSteps();
      expect(st[2].subLatex, [r'\text{monoid, not a group}']);
      expect(st[2].explanation, contains('its 1 unit form an abelian group'));
    });
  });
}
