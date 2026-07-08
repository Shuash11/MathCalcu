import 'package:calculus_system/Finals/finals_router.dart';
import 'midterm/screens/circles_screen/center/center_screen.dart';
import 'midterm/screens/circles_screen/radius/radiusui.dart';
import 'package:calculus_system/midterm/screens/yintercept_screen/slope_intercept_scr.dart';
import 'package:calculus_system/midterm/screens/yintercept_screen/parallel_perpendicular_screen.dart';
import 'package:flutter/material.dart';
import 'package:calculus_system/midterm/screens/distance_screen/distancescreen.dart';
import 'package:go_router/go_router.dart';
import 'package:calculus_system/widgets/app_shell.dart';

import 'midterm/screens/inequalities_screen/card_picker_screen.dart';
import 'midterm/screens/inequalities_screen/strict_screen.dart';
import 'midterm/screens/inequalities_screen/non_strict_screen.dart';
import 'midterm/screens/inequalities_screen/absolute_screen.dart';
import 'midterm/screens/inequalities_screen/continued_screen.dart';
import 'midterm/screens/inequalities_screen/simple_screen.dart';
import 'midterm/screens/inequalities_screen/rational_screen.dart';
import 'midterm/screens/inequalities_screen/quadratic_screen.dart';
import 'midterm/screens/inequalities_screen/radical_screen.dart';
import 'midterm/screens/slope_screen/slopescreen.dart';
import 'midterm/screens/midpoint_screen/midpointscreen.dart';
import 'midterm/screens/pointslope_screen/pointslopescreen.dart';
import 'midterm/screens/two_point_slope_screen/twopointslopescreen.dart';
import 'midterm/cards/circles/card_picker_screen.dart';
import 'midterm/screens/circles_screen/center_radius_form/center_radiusui.dart';

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
    routes: [
      // ── Home — AppShell with bottom nav ───────────────
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const AppShell(),
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
