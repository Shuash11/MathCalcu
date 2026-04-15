import 'package:calculus_system/Finals/Joashua/Derivatives/UI/derivatives_screen.dart';
import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_Factoring/UI/factoring_limit_screen.dart';
import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_LCD/UI/lcd_limit_screen.dart';
import 'package:calculus_system/Finals/Joashua/Evaluating_limits/evaluating_limits_picker.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/Ui/limits_infinity_scr.dart';
import 'package:calculus_system/Finals/Joashua/Slope_Using_derivatives/UI/slope_solver_screen.dart';
import 'package:calculus_system/Finals/finals_picker_screen.dart';
import 'package:flutter/material.dart';
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
              builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Substitution Screen')))),
          GoRoute(
              path: 'conjugate',
              builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Conjugate Screen')))),
          GoRoute(
              path: 'factoring',
              builder: (context, state) => const FactoringLimitScreen()),
          GoRoute(
              path: 'lcd',
              builder: (context, state) => const LCDLimitScreen()),
        ],
      ),

      // Future routes go here (e.g., Integrals, Limits)
    ],
  ),
];
