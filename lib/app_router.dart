import 'package:calculus_system/topics/modmat/modmat_picker_screen.dart';
import 'package:calculus_system/topics/modmat/midterm/modmat_foundations_screen.dart';
import 'package:calculus_system/topics/modmat/midterm/modmat_advanced_screen.dart';
import 'package:calculus_system/topics/modmat/screens/modmat_propositional_screen.dart';
import 'package:calculus_system/topics/modmat/screens/modmat_sets_screen.dart';
import 'package:calculus_system/topics/modmat/screens/modmat_combinatorics_screen.dart';
import 'package:calculus_system/topics/modmat/screens/modmat_bases_screen.dart';
import 'package:calculus_system/topics/modmat/screens/modmat_matrices_screen.dart';
import 'package:calculus_system/topics/modmat/screens/modmat_modular_screen.dart';
import 'package:calculus_system/topics/modmat/screens/modmat_predicate_screen.dart';
import 'package:calculus_system/topics/modmat/screens/modmat_relations_screen.dart';
import 'package:calculus_system/topics/modmat/screens/modmat_proof_screen.dart';
import 'package:calculus_system/topics/modmat/screens/modmat_graph_basics_screen.dart';
import 'package:calculus_system/topics/modmat/screens/modmat_advanced_graph_screen.dart';
import 'package:calculus_system/topics/modmat/screens/modmat_algebraic_screen.dart';
import 'package:calculus_system/topics/modmat/screens/modmat_real_analysis_screen.dart';
import 'package:calculus_system/topics/modmat/screens/modmat_topology_screen.dart';
import 'package:calculus_system/topics/quadratics/screens/quadratics_quadratic_screen.dart';
import 'package:calculus_system/topics/quadratics/screens/quadratics_radical_screen.dart';
import 'package:calculus_system/topics/quadratics/screens/quadratics_variation_screen.dart';
import 'package:calculus_system/topics/quadratics/screens/quadratics_sequences_screen.dart';
import 'package:calculus_system/topics/quadratics/screens/quadratics_poly_division_screen.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'topics/calculus/midterm/screens/circles_screen/center/center_screen.dart';
import 'topics/calculus/midterm/screens/circles_screen/radius/radiusui.dart';
import 'package:calculus_system/topics/calculus/midterm/screens/yintercept_screen/slope_intercept_scr.dart';
import 'package:calculus_system/topics/calculus/midterm/screens/yintercept_screen/parallel_perpendicular_screen.dart';
import 'package:flutter/material.dart';
import 'package:calculus_system/topics/calculus/midterm/screens/distance_screen/distancescreen.dart';
import 'package:go_router/go_router.dart';
import 'package:calculus_system/widgets/app_shell.dart';
import 'package:calculus_system/screens/developers_screen.dart';
import 'package:calculus_system/screens/category_picker_screen.dart';
import 'package:calculus_system/screens/settings_screen.dart';

import 'topics/calculus/midterm/screens/inequalities_screen/card_picker_screen.dart';
import 'topics/calculus/midterm/screens/inequalities_screen/strict_screen.dart';
import 'topics/calculus/midterm/screens/inequalities_screen/non_strict_screen.dart';
import 'topics/calculus/midterm/screens/inequalities_screen/absolute_screen.dart';
import 'topics/calculus/midterm/screens/inequalities_screen/continued_screen.dart';
import 'topics/calculus/midterm/screens/inequalities_screen/simple_screen.dart';
import 'topics/calculus/midterm/screens/inequalities_screen/rational_screen.dart';
import 'topics/calculus/midterm/screens/inequalities_screen/quadratic_screen.dart';
import 'topics/calculus/midterm/screens/inequalities_screen/radical_screen.dart';
import 'topics/calculus/midterm/screens/slope_screen/slopescreen.dart';
import 'topics/calculus/midterm/screens/midpoint_screen/midpointscreen.dart';
import 'topics/calculus/midterm/screens/pointslope_screen/pointslopescreen.dart';
import 'topics/calculus/midterm/screens/two_point_slope_screen/twopointslopescreen.dart';
import 'topics/calculus/midterm/cards/circles/card_picker_screen.dart';
import 'topics/calculus/midterm/screens/circles_screen/center_radius_form/center_radiusui.dart';
import 'package:calculus_system/topics/calculus/finals/finals_picker_screen.dart';
import 'package:calculus_system/topics/calculus/finals/screens/derivatives_screen/derivatives_screen.dart';
import 'package:calculus_system/topics/calculus/finals/screens/slope_using_derivatives_screen/slope_solver_screen.dart';
import 'package:calculus_system/topics/calculus/finals/screens/limits_infinity_screen/limits_infinity_screen.dart';
import 'package:calculus_system/topics/calculus/finals/screens/evaluating_limits_screen/evaluating_limits_picker.dart';
import 'package:calculus_system/topics/calculus/finals/screens/evaluating_limits_screen/by_substitution/substitution_limit_screen.dart';
import 'package:calculus_system/topics/calculus/finals/screens/evaluating_limits_screen/by_conjugate/conjugate_limit_screen.dart';
import 'package:calculus_system/topics/calculus/finals/screens/evaluating_limits_screen/by_factoring/factoring_limit_screen.dart';
import 'package:calculus_system/topics/calculus/finals/screens/evaluating_limits_screen/by_lcd/lcd_limit_screen.dart';
import 'package:calculus_system/topics/calculus/calculus_picker_screen.dart';
import 'package:calculus_system/search/global_search_screen.dart';
import 'package:calculus_system/topics/grade6/grade6_picker_screen.dart';
import 'package:calculus_system/topics/grade6/screens/fractions_screen.dart';
import 'package:calculus_system/topics/grade6/screens/decimals_screen.dart';
import 'package:calculus_system/topics/grade6/screens/percent_screen.dart';
import 'package:calculus_system/topics/grade6/screens/ratio_screen.dart';
import 'package:calculus_system/topics/grade6/screens/gemdas_screen.dart';
import 'package:calculus_system/topics/grade6/screens/algebra_screen.dart';
import 'package:calculus_system/topics/grade6/screens/integers_screen.dart';
import 'package:calculus_system/topics/grade6/screens/geometry_screen.dart';
import 'package:calculus_system/topics/grade6/screens/volume_screen.dart';
import 'package:calculus_system/topics/grade6/screens/pie_screen.dart';
import 'package:calculus_system/topics/grade6/screens/probability_screen.dart';
import 'package:calculus_system/topics/shs/shs_picker_screen.dart';
import 'package:calculus_system/topics/shs/screens/logarithms_screen.dart';
import 'package:calculus_system/topics/shs/screens/interest_screen.dart';
import 'package:calculus_system/topics/shs/screens/inverse_functions_screen.dart';
import 'package:calculus_system/topics/shs/screens/rational_inequality_screen.dart';
import 'package:calculus_system/topics/shs/screens/trig_equations_screen.dart';
import 'package:calculus_system/topics/shs/screens/trig_identities_screen.dart';
import 'package:calculus_system/topics/shs/screens/trig_ratios_screen.dart';
import 'package:calculus_system/topics/shs/screens/definite_integral_screen.dart';
import 'package:calculus_system/topics/shs/screens/optimization_screen.dart';
import 'package:calculus_system/topics/shs/screens/lhopital_screen.dart';
import 'package:calculus_system/topics/topic_hub_screen.dart';
import 'package:calculus_system/home/home_screen.dart';
import 'package:calculus_system/topics/topics_screen.dart';
import 'package:calculus_system/calculator/calculator_screen.dart';
import 'package:calculus_system/notes/notes_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'mainNav');

  static CustomTransitionPage _fadeRoute(LocalKey key, Widget child) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    // Cycle 8 never-dead-end: any push to an unknown location (stale
    // history entry, deep link, or a route whose screen has not
    // landed) renders the coming-soon screen instead of the default
    // GoRouter error page.
    errorBuilder: (context, state) =>
        _RouteNotFoundScreen(location: state.uri.toString()),
    routes: [
      // ── Shell with bottom nav (Home / Topics / Notes / Calculator / Settings) ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // Branch 0 — Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 1 — Topics
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/topics',
                builder: (context, state) => const TopicsScreen(),
                routes: [
                  GoRoute(
                    path: 'calculus',
                    builder: (context, state) => const CalculusPickerScreen(),
                    routes: [
                      GoRoute(
                        path: 'midterm',
                        builder: (context, state) =>
                            const CategoryPickerScreen(),
                      ),
                      GoRoute(
                        path: 'finals',
                        builder: (context, state) => const FinalsPickerScreen(),
                        routes: [
                          GoRoute(
                            path: 'derivatives',
                            builder: (context, state) =>
                                const DerivativeScreen(),
                          ),
                          GoRoute(
                            path: 'slope-derivative',
                            builder: (context, state) =>
                                const SlopeSolverScreen(),
                          ),
                          GoRoute(
                            path: 'infinity',
                            builder: (context, state) =>
                                const LimitsInfinityScreen(),
                          ),
                          GoRoute(
                            path: 'limits',
                            builder: (context, state) =>
                                const EvaluatingLimitsPicker(),
                            routes: [
                              GoRoute(
                                path: 'substitution',
                                builder: (context, state) =>
                                    const SubstitutionLimitScreen(),
                              ),
                              GoRoute(
                                path: 'conjugate',
                                builder: (context, state) =>
                                    const ConjugateLimitScreen(),
                              ),
                              GoRoute(
                                path: 'factoring',
                                builder: (context, state) =>
                                    const FactoringLimitScreen(),
                              ),
                              GoRoute(
                                path: 'lcd',
                                builder: (context, state) =>
                                    const LCDLimitScreen(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'modmat',
                    builder: (context, state) => const ModmatPickerScreen(),
                    routes: [
                      GoRoute(
                        path: 'foundations',
                        builder: (context, state) =>
                            const ModmatFoundationsScreen(),
                      ),
                      GoRoute(
                        path: 'advanced',
                        builder: (context, state) =>
                            const ModmatAdvancedScreen(),
                      ),
                    ],
                  ),
                  // Cycle 8: SHS picker (thin solver screens below).
                  GoRoute(
                    path: 'shs',
                    builder: (context, state) => const ShsPickerScreen(),
                  ),
                  // Cycle 8: topic-first hub (subject cards + filters).
                  GoRoute(
                    path: 'hub',
                    builder: (context, state) => const TopicHubScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Branch 2 — Notes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notes',
                builder: (context, state) => const NotesScreen(),
              ),
            ],
          ),
          // Branch 3 — Calculator
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calculator',
                builder: (context, state) => const CalculatorScreen(),
              ),
            ],
          ),
          // Branch 4 — Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── JOASHUA's routes ─────────────────────────────────────────────
      GoRoute(
        path: '/inequalities',
        name: 'inequalities',
        builder: (context, state) => const InequalityCardPickerScreen(),
        routes: [
          GoRoute(
            path: 'strict',
            name: 'strict',
            pageBuilder: (context, state) =>
                _fadeRoute(state.pageKey, const StrictScreen()),
          ),
          GoRoute(
            path: 'non_strict',
            name: 'non_strict',
            pageBuilder: (context, state) =>
                _fadeRoute(state.pageKey, const NonStrictScreen()),
          ),
          GoRoute(
            path: 'absolute',
            name: 'absolute',
            pageBuilder: (context, state) =>
                _fadeRoute(state.pageKey, const AbsoluteScreen()),
          ),
          GoRoute(
            path: 'continued',
            name: 'continued',
            pageBuilder: (context, state) =>
                _fadeRoute(state.pageKey, const ContinuedScreen()),
          ),
          GoRoute(
            path: 'simple',
            name: 'simple',
            pageBuilder: (context, state) =>
                _fadeRoute(state.pageKey, const SimpleScreen()),
          ),
          GoRoute(
            path: 'rational',
            name: 'rational',
            pageBuilder: (context, state) =>
                _fadeRoute(state.pageKey, const RationalScreen()),
          ),
          GoRoute(
            path: 'quadratic',
            name: 'quadratic',
            pageBuilder: (context, state) =>
                _fadeRoute(state.pageKey, const QuadraticScreen()),
          ),
          GoRoute(
            path: 'radical',
            name: 'radical',
            pageBuilder: (context, state) =>
                _fadeRoute(state.pageKey, const RadicalScreen()),
          ),
        ],
      ),

      // ── NASH's routes ────────────────────────────────────────────────
      GoRoute(
        path: '/slope',
        name: 'slope',
        builder: (context, state) => const SlopeScreen(),
      ),
      GoRoute(
        path: '/distance',
        name: 'distance',
        builder: (context, state) => const Distancescreen(),
      ),
      GoRoute(
        path: '/midpoint',
        name: 'midpoint',
        builder: (context, state) => const MidpointScreen(),
      ),
      GoRoute(
        path: '/point-slope',
        name: 'point-slope',
        builder: (context, state) => const PointSlopeScreen(),
      ),
      GoRoute(
        path: '/slope-intercept-form',
        name: 'slope-intercept-form',
        builder: (context, state) => const YInterceptScreen(),
      ),
      GoRoute(
        path: '/parallel-perpendicular',
        name: 'parallel-perpendicular',
        builder: (context, state) => const ParallelPerpendicularScreen(),
      ),
      GoRoute(
        path: '/two-point-slope',
        name: 'two-point-slope',
        builder: (context, state) => const TwoPointSlopeScreen(),
      ),

      // ── Circle routes ────────────────────────────────────────────────
      GoRoute(
        path: '/circle',
        name: 'circle',
        builder: (context, state) => const CircleCardPickerScreen(),
        routes: [
          GoRoute(
            path: 'finding-radius',
            name: 'finding-radius',
            pageBuilder: (context, state) => _fadeRoute(
              state.pageKey,
              const FindingRadiusScreen(),
            ),
          ),
          GoRoute(
            path: 'finding-center',
            name: 'finding-center',
            pageBuilder: (context, state) => _fadeRoute(
              state.pageKey,
              const FindingCenterScreen(),
            ),
          ),
          GoRoute(
            path: 'finding-center-radius',
            name: 'finding-center-radius',
            pageBuilder: (context, state) => _fadeRoute(
              state.pageKey,
              const FindingCenterRadiusScreen(),
            ),
          ),
        ],
      ),

      // ── Global search (Task 3: unified offline index) ──────────────
      GoRoute(
        path: '/search',
        name: 'search',
        parentNavigatorKey: navigatorKey,
        pageBuilder: (context, state) =>
            _fadeRoute(state.pageKey, const GlobalSearchScreen()),
      ),

      // ── Grade 6 (Task 5: Phase-1 UI, paths match CurriculumRegistry) ──
      GoRoute(
        path: '/grade6',
        name: 'grade6',
        builder: (context, state) => const Grade6PickerScreen(),
        routes: [
          GoRoute(
            path: 'fractions',
            builder: (context, state) => const Grade6FractionsScreen(),
          ),
          GoRoute(
            path: 'decimals',
            builder: (context, state) => const Grade6DecimalsScreen(),
          ),
          GoRoute(
            path: 'percent',
            builder: (context, state) => const Grade6PercentScreen(),
          ),
          GoRoute(
            path: 'ratio',
            builder: (context, state) => const Grade6RatioScreen(),
          ),
          GoRoute(
            path: 'gemdas',
            builder: (context, state) => const Grade6GemdasScreen(),
          ),
          GoRoute(
            path: 'algebra',
            builder: (context, state) => const Grade6AlgebraScreen(),
          ),
          GoRoute(
            path: 'integers',
            builder: (context, state) => const Grade6IntegersScreen(),
          ),
          GoRoute(
            path: 'geometry',
            builder: (context, state) => const Grade6GeometryScreen(),
          ),
          GoRoute(
            path: 'volume',
            builder: (context, state) => const Grade6VolumeScreen(),
          ),
          GoRoute(
            path: 'pie',
            builder: (context, state) => const Grade6PieScreen(),
          ),
          GoRoute(
            path: 'probability',
            builder: (context, state) => const Grade6ProbabilityScreen(),
          ),
        ],
      ),

      // ── Settings sub-routes ──────────────────────────────────────────
      GoRoute(
        path: '/developers',
        name: 'developers',
        parentNavigatorKey: navigatorKey,
        pageBuilder: (context, state) =>
            _fadeRoute(state.pageKey, const DevelopersScreen()),
      ),

      // ── SHS (Cycle 8: paths match CurriculumRegistry /shs/*) ────────
      GoRoute(
        path: '/shs',
        name: 'shs',
        builder: (context, state) => const ShsPickerScreen(),
        routes: [
          GoRoute(
            path: 'trig-ratios',
            builder: (context, state) => const ShsTrigRatiosScreen(),
          ),
          GoRoute(
            path: 'logarithms',
            builder: (context, state) => const ShsLogarithmsScreen(),
          ),
          GoRoute(
            path: 'interest',
            builder: (context, state) => const ShsInterestScreen(),
          ),
          GoRoute(
            path: 'inverse-functions',
            builder: (context, state) => const ShsInverseFunctionsScreen(),
          ),
          GoRoute(
            path: 'rational-inequality',
            builder: (context, state) => const ShsRationalInequalityScreen(),
          ),
          GoRoute(
            path: 'trig-equations',
            builder: (context, state) => const ShsTrigEquationsScreen(),
          ),
          GoRoute(
            path: 'trig-identities',
            builder: (context, state) => const ShsTrigIdentitiesScreen(),
          ),
          GoRoute(
            path: 'definite-integral',
            builder: (context, state) => const ShsDefiniteIntegralScreen(),
          ),
          GoRoute(
            path: 'optimization',
            builder: (context, state) => const ShsOptimizationScreen(),
          ),
          GoRoute(
            path: 'lhopital',
            builder: (context, state) => const ShsLHopitalScreen(),
          ),
        ],
      ),

      // ── ModMat leaves (Cycle 9 F1: paths match ModmatModuleRegistry
      // wiredLeafRoutes; picker + section screens mirror /topics/modmat
      // the way /shs mirrors /topics/shs) ──────────────────────────
      GoRoute(
        path: '/modmat',
        name: 'modmat',
        builder: (context, state) => const ModmatPickerScreen(),
        routes: [
          GoRoute(
            path: 'foundations',
            builder: (context, state) => const ModmatFoundationsScreen(),
            routes: [
              GoRoute(
                path: 'propositional_logic',
                builder: (context, state) => const ModmatPropositionalScreen(),
              ),
              GoRoute(
                path: 'set_theory',
                builder: (context, state) => const ModmatSetsScreen(),
              ),
              GoRoute(
                path: 'number_systems',
                builder: (context, state) => const ModmatBasesScreen(),
              ),
              GoRoute(
                path: 'combinatorics_basics',
                builder: (context, state) => const ModmatCombinatoricsScreen(),
              ),
              GoRoute(
                path: 'predicate_logic',
                builder: (context, state) => const ModmatPredicateScreen(),
              ),
              GoRoute(
                path: 'relations_functions',
                builder: (context, state) => const ModmatRelationsScreen(),
              ),
              GoRoute(
                path: 'proof_techniques',
                builder: (context, state) => const ModmatProofScreen(),
              ),
              GoRoute(
                path: 'graph_theory_basics',
                builder: (context, state) => const ModmatGraphBasicsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'advanced',
            builder: (context, state) => const ModmatAdvancedScreen(),
            routes: [
              GoRoute(
                path: 'linear_algebra',
                builder: (context, state) => const ModmatMatricesScreen(),
              ),
              GoRoute(
                path: 'number_theory',
                builder: (context, state) => const ModmatModularScreen(),
              ),
              GoRoute(
                path: 'advanced_graph_theory',
                builder: (context, state) => const ModmatAdvancedGraphScreen(),
              ),
              GoRoute(
                path: 'algebraic_structures',
                builder: (context, state) => const ModmatAlgebraicScreen(),
              ),
              GoRoute(
                path: 'real_analysis',
                builder: (context, state) => const ModmatRealAnalysisScreen(),
              ),
              GoRoute(
                path: 'topology_basics',
                builder: (context, state) => const ModmatTopologyScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Quadratics (Cycle 9 F1: paths match CurriculumRegistry
      // /grade9/* + /grade10/* wired topics) ───────────────────────
      GoRoute(
        path: '/grade9/quadratic-formula',
        builder: (context, state) => const QuadraticsQuadraticScreen(),
      ),
      GoRoute(
        path: '/grade9/radical-equations',
        builder: (context, state) => const QuadraticsRadicalScreen(),
      ),
      GoRoute(
        path: '/grade9/variation',
        builder: (context, state) => const QuadraticsVariationScreen(),
      ),
      GoRoute(
        path: '/grade10/sequences',
        builder: (context, state) => const QuadraticsSequencesScreen(),
      ),
      GoRoute(
        path: '/grade10/polynomial-division',
        builder: (context, state) => const QuadraticsPolyDivisionScreen(),
      ),
    ],
  );
}

/// Fallback for unknown locations (see [AppRouter] errorBuilder).
///
/// Friendly coming-soon screen with a way back — never a dead-end.
/// Styling via ThemeProvider only.
class _RouteNotFoundScreen extends StatelessWidget {
  final String location;

  const _RouteNotFoundScreen({required this.location});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final accent = theme.accentColor;
    return Scaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.construction_rounded,
                    color: accent,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Topic coming soon',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '“$location” isn\'t available in this version yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.go('/topics'),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to Topics'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
