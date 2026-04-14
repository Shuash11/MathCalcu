import 'package:calculus_system/Finals/finals_router.dart';
import 'package:calculus_system/modules/circles/center/screen/subscreens/center_screen.dart';
import 'package:calculus_system/modules/circles/raidus/screen/radiusui.dart';
import 'package:calculus_system/modules/y-intercept/ui/slope_intercept_scr.dart';
import 'package:calculus_system/modules/y-intercept/ui/parallel_perpendicular_screen.dart';
import 'package:flutter/material.dart';
import 'package:calculus_system/modules/Distance/ui/distancescreen.dart';
import 'package:go_router/go_router.dart';
import 'screens/category_picker_screen.dart';
import 'screens/activation_screen.dart'; 
import 'modules/inequalities/card_picker_screen.dart';
import 'modules/inequalities/strict/screen/strict_screen.dart';
import 'modules/inequalities/non_strict/screen/non_strict_screen.dart';
import 'modules/inequalities/absolute/screen/absolute_screen.dart';
import 'modules/inequalities/continued/screen/continued_screen.dart';
import 'modules/inequalities/simple/screen/simple_screen.dart';
import 'modules/inequalities/rational/screen/rational_screen.dart';
import 'modules/inequalities/quadratic/screen/quadratic_screen.dart';
import 'modules/inequalities/radical/screen/radical_screen.dart';
import 'modules/slope/ui/slopescreen.dart';
import 'modules/midpoint/ui/midpointscreen.dart';
import 'modules/pointslope/ui/pointslopescreen.dart';
import 'modules/two-point slope/ui/twopointslopescreen.dart';
import 'modules/circles/card_picker_screen.dart';
import 'modules/circles/center_raidus_form/screen/center_radiusui.dart';

class AppRouter {
  static CustomTransitionPage _fadeRoute(LocalKey key, Widget child) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static final GoRouter router1 = GoRouter(initialLocation: '/', routes: [
    // ── Home ────────────────────────────────────────────
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const ActivationGate(
        child: CategoryPickerScreen(),
      ),
    ),

    // ── Finals routes (mounted from finals_router.dart) ─
    ...finalsRoutes,

    // ..
  ]);

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // ── Home — wrapped with activation gate ────────────
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const ActivationGate(
          child: CategoryPickerScreen(), // ← WRAPPED HERE
        ),
      ),

      ...finalsRoutes,
      // ── JOASHUA's routes ──────────────────────────────
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

      // ── NASH's routes ─────────────────────────────────
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

      // ── Circle routes ─────────────────────────────────
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
  
    ],
  );
}
