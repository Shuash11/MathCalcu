import 'package:calculus_system/Finals/Joashua/Derivatives/UI/derivatives_screen.dart';
import 'package:calculus_system/Finals/Joashua/Slope_Using_derivatives/UI/slope_solver_screen.dart';
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

      // Future routes go here (e.g., Integrals, Limits)
    ],
  ),
];
