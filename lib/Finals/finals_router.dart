import 'package:calculus_system/Finals/screens/evaluating_limits_screen/by_substitution/substitution_limit_screen.dart';
import 'package:calculus_system/Finals/screens/derivatives_screen/derivatives_screen.dart';
import 'package:calculus_system/Finals/screens/evaluating_limits_screen/by_factoring/factoring_limit_screen.dart';
import 'package:calculus_system/Finals/screens/evaluating_limits_screen/by_lcd/lcd_limit_screen.dart';
import 'package:calculus_system/Finals/screens/evaluating_limits_screen/by_conjugate/conjugate_limit_screen.dart';
import 'package:calculus_system/Finals/screens/evaluating_limits_screen/evaluating_limits_picker.dart';
import 'package:calculus_system/Finals/screens/limits_infinity_screen/limits_infinity_screen.dart';
import 'package:calculus_system/Finals/screens/slope_using_derivatives_screen/slope_solver_screen.dart';
import 'package:calculus_system/Finals/finals_picker_screen.dart';

import 'package:go_router/go_router.dart';

final List<GoRoute> finalsRoutes = [
  GoRoute(
    path: '/second-sem',
    name: 'second-sem',
    builder: (context, state) => const FinalsPickerScreen(),
    routes: [
      // ── Derivatives Feature ──────────────────────────────
      GoRoute(
        path: 'derivatives',
        name: 'derivatives',
        builder: (context, state) => const DerivativeScreen(),
      ),
      GoRoute(
        path: 'slope-derivative',
        name: 'slope-derivative',
        builder: (context, state) => const SlopeSolverScreen(),
      ),
      GoRoute(
        path: 'infinity',
        name: 'infinity',
        builder: (context, state) => const LimitsInfinityScreen(),
      ),
      GoRoute(
        path: 'limits',
        name: 'limits',
        builder: (context, state) => const EvaluatingLimitsPicker(),
        routes: [
          GoRoute(
              path: 'substitution',
              builder: (context, state) => const SubstitutionLimitScreen()),
          GoRoute(
              path: 'conjugate',
              builder: (context, state) => const ConjugateLimitScreen()),
          GoRoute(
              path: 'factoring',
              builder: (context, state) => const FactoringLimitScreen()),
          GoRoute(
              path: 'lcd', builder: (context, state) => const LCDLimitScreen()),
        ],
      ),

      // Future routes go here (e.g., Integrals, Limits)
    ],
  ),
];
