// ─────────────────────────────────────────────────────────────
// CURRICULUM REGISTRY — PH Grade 6 → College topic index
//
// Offline-first, in-memory. No network, no DB.
// Merges the existing hardcoded registries (Module / Finals /
// ModMat) with the new DepEd-aligned Grade 6 (G6-1..G6-10) seed
// plus stub entries for G7–College for future solvers.
//
// Task 2 scope only: data model + search. Routes are NOT wired
// here (Task 3 / Phase 1 will add GoRouter `/grade6` entries).
//
// Search reuses the ModMat pattern:
//   modmat_module_registry.dart:137 — lowercase contains filter.
// Styling: accent defaults to AppDesign.app.accent (no hardcoded
// hex in this file).
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/module_registry.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:flutter/material.dart';

/// One curriculum topic (solver-backed or future stub).
///
/// Field names follow Section E.1 of
/// `docs/plans/ph-grade6-college-enhancement-plan.md`.
class CurriculumTopic {
  /// Stable id, e.g. 'g6-4-ratio'.
  final String id;

  /// 'G6' | 'G7' | 'G8' | 'G9' | 'G10' | 'G11' | 'G12' | 'College'.
  final String gradeLevel;

  /// Human subject group, e.g. 'Fractions', 'Algebra', 'Geometry'.
  final String subject;

  /// Picker card title.
  final String label;

  /// Picker card subtitle / example hint.
  final String subtitle;

  /// Future GoRouter path, e.g. '/grade6/ratio'. Not wired yet.
  final String route;

  /// Material icon for picker cards (no new packages).
  final IconData icon;

  /// Search keywords (English + Filipino + code fragments).
  final List<String> tags;

  /// 'intro' | 'standard' | 'challenge'.
  final String difficulty;

  /// DepEd MELC shorthand, e.g. 'M6NS-Id-140'. Empty for stubs.
  final String depedCode;

  /// False for G7–College placeholders with no solver yet.
  final bool solverAvailable;

  const CurriculumTopic({
    required this.id,
    required this.gradeLevel,
    required this.subject,
    required this.label,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.tags,
    required this.difficulty,
    required this.depedCode,
    this.solverAvailable = true,
  });

  /// Bridge back to the existing picker model.
  ModuleEntry toModuleEntry() => ModuleEntry(
        label: label,
        subtitle: subtitle,
        route: route,
        icon: icon,
        accent: AppDesign.app.accent,
      );
}

/// Search hit mirroring [ModmatSearchHit] shape.
class CurriculumSearchHit {
  final String gradeLevel;
  final CurriculumTopic topic;

  const CurriculumSearchHit({required this.gradeLevel, required this.topic});
}

/// Central index over all curriculum topics.
class CurriculumRegistry {
  static Color get _accent => AppDesign.app.accent;

  // ── G6 (DepEd-aligned, solver-backed) ──────────────────────
  // G6-1..G6-10 (+ probability nice-to-have). Engines to reuse:
  // G6-1 Fraction (yintercept_solver/fraction.dart),
  // G6-1..G6-6 CalculatorEngine (calculator/calculator_engine.dart).
  static final List<CurriculumTopic> grade6Topics = [
    const CurriculumTopic(
      id: 'g6-1-fractions',
      gradeLevel: 'G6',
      subject: 'Fractions',
      label: 'Fractions: Add & Subtract',
      subtitle: 'e.g. 2 1/3 + 1 1/2 — mixed & improper',
      route: '/grade6/fractions',
      icon: Icons.pie_chart_outline_rounded,
      tags: ['fraction', 'mixed', 'praksiyon', 'add', 'subtract', 'M6NS', 'lcd'],
      difficulty: 'intro',
      depedCode: 'M6NS-Ia-86',
    ),
    const CurriculumTopic(
      id: 'g6-2-decimals',
      gradeLevel: 'G6',
      subject: 'Decimals',
      label: 'Decimals: Multiply & Divide',
      subtitle: 'e.g. 3.25 × 1.2 — place value & rounding',
      route: '/grade6/decimals',
      icon: Icons.exposure_rounded,
      tags: ['decimal', 'desimal', 'multiply', 'divide', 'rounding', 'M6NS'],
      difficulty: 'intro',
      depedCode: 'M6NS-Ib-106',
    ),
    const CurriculumTopic(
      id: 'g6-3-percent',
      gradeLevel: 'G6',
      subject: 'Percent',
      label: 'Percent of a Number & Discount',
      subtitle: 'e.g. 25% of 200 — rate × base, ₱ discount',
      route: '/grade6/percent',
      icon: Icons.percent_rounded,
      tags: ['percent', 'porsyento', 'discount', 'of', 'rate', 'base', 'M6NS'],
      difficulty: 'intro',
      depedCode: 'M6NS-Ic-131',
    ),
    const CurriculumTopic(
      id: 'g6-4-ratio',
      gradeLevel: 'G6',
      subject: 'Ratio & Proportion',
      label: 'Ratio & Proportion',
      subtitle: 'e.g. 12:18 or 3/4 = x/20 — bar strips',
      route: '/grade6/ratio',
      icon: Icons.balance_rounded,
      tags: ['ratio', 'proportion', 'proporsiyon', 'missing term', 'M6NS', 'bar'],
      difficulty: 'standard',
      depedCode: 'M6NS-Id-140',
    ),
    const CurriculumTopic(
      id: 'g6-5-gemdas',
      gradeLevel: 'G6',
      subject: 'Order of Operations',
      label: 'Order of Operations (GEMDAS)',
      subtitle: 'e.g. 8 + 2 × (5-3)^2 — grouping first',
      route: '/grade6/gemdas',
      icon: Icons.format_list_numbered_rounded,
      tags: ['gemdas', 'pemdas', 'order', 'operations', 'exponent', 'M6NS'],
      difficulty: 'standard',
      depedCode: 'M6NS-IIa-148',
    ),
    const CurriculumTopic(
      id: 'g6-6-algebra',
      gradeLevel: 'G6',
      subject: 'Simple Algebra',
      label: 'Simple Algebra (One Step)',
      subtitle: 'e.g. x + 7 = 15 — inverse operations',
      route: '/grade6/algebra',
      icon: Icons.functions_rounded,
      tags: ['algebra', 'equation', 'variable', 'one-step', 'M6AL', 'x'],
      difficulty: 'standard',
      depedCode: 'M6AL-IIIa-28',
    ),
    const CurriculumTopic(
      id: 'g6-7-integers',
      gradeLevel: 'G6',
      subject: 'Integers',
      label: 'Integers & Number Line',
      subtitle: 'e.g. -5 + 8 — compare, add, subtract',
      route: '/grade6/integers',
      icon: Icons.straighten_rounded,
      tags: ['integer', 'number line', 'negative', 'compare', 'M6NS'],
      difficulty: 'standard',
      depedCode: 'M6NS-IIIb-150',
    ),
    const CurriculumTopic(
      id: 'g6-8-geometry',
      gradeLevel: 'G6',
      subject: 'Geometry',
      label: 'Perimeter, Area & Angles',
      subtitle: 'e.g. rect 6×4 — shape diagram + units',
      route: '/grade6/geometry',
      icon: Icons.crop_square_rounded,
      tags: ['geometry', 'heometriya', 'perimeter', 'area', 'angle', 'shape', 'M6GE'],
      difficulty: 'standard',
      depedCode: 'M6GE-IIIc-37',
    ),
    const CurriculumTopic(
      id: 'g6-9-volume',
      gradeLevel: 'G6',
      subject: 'Volume',
      label: 'Volume: Cube & Prism',
      subtitle: 'e.g. 5 × 3 × 2 — 3D wireframe, cubic units',
      route: '/grade6/volume',
      icon: Icons.view_in_ar_rounded,
      tags: ['volume', 'cube', 'prism', '3d', 'wireframe', 'M6ME'],
      difficulty: 'challenge',
      depedCode: 'M6ME-IVa-95',
    ),
    const CurriculumTopic(
      id: 'g6-10-pie',
      gradeLevel: 'G6',
      subject: 'Data & Graphs',
      label: 'Pie Chart & Data',
      subtitle: 'e.g. Math 40, Science 30 — % to degrees',
      route: '/grade6/pie',
      icon: Icons.pie_chart_rounded,
      tags: ['pie', 'chart', 'data', 'statistics', 'percent', 'M6SP'],
      difficulty: 'standard',
      depedCode: 'M6SP-IVe-1',
    ),
    const CurriculumTopic(
      id: 'g6-10-probability',
      gradeLevel: 'G6',
      subject: 'Probability',
      label: 'Simple Probability (Intro)',
      subtitle: 'e.g. P(red) in 3R + 2B — favorable / total',
      route: '/grade6/probability',
      icon: Icons.casino_outlined,
      tags: ['probability', 'probabilidad', 'chance', 'favorable', 'M6SP'],
      difficulty: 'challenge',
      depedCode: 'M6SP-IVg-2',
    ),
  ];

  // ── Stubs: G7 → College (no solvers yet) ───────────────────
  // Representative placeholders so pickers/search can grow
  // without dead-link surprises. Full solver specs are deferred
  // to the Phase 2 plan (§D).
  static final List<CurriculumTopic> futureTopics = [
    // G7
    const CurriculumTopic(
      id: 'g7-signed-numbers',
      gradeLevel: 'G7',
      subject: 'Integers',
      label: 'Signed Numbers',
      subtitle: 'e.g. −8 − (−3) — number line',
      route: '/grade7/signed-numbers',
      icon: Icons.remove_circle_outline_rounded,
      tags: ['signed', 'integer', 'negative', 'G7'],
      difficulty: 'intro',
      depedCode: '',
      solverAvailable: false,
    ),
    const CurriculumTopic(
      id: 'g7-linear-equations',
      gradeLevel: 'G7',
      subject: 'Algebra',
      label: 'Linear Equations',
      subtitle: 'e.g. 2x − 5 = 9 — two steps',
      route: '/grade7/linear-equations',
      icon: Icons.linear_scale_rounded,
      tags: ['linear', 'equation', 'two-step', 'G7'],
      difficulty: 'standard',
      depedCode: '',
      solverAvailable: false,
    ),
    const CurriculumTopic(
      id: 'g7-inequalities',
      gradeLevel: 'G7',
      subject: 'Inequalities',
      label: 'Inequalities Intro',
      subtitle: 'e.g. 3x < 12 — shaded number line',
      route: '/grade7/inequalities',
      icon: Icons.compare_arrows_rounded,
      tags: ['inequality', 'less than', 'shading', 'G7'],
      difficulty: 'standard',
      depedCode: '',
      solverAvailable: false,
    ),
    // G8
    const CurriculumTopic(
      id: 'g8-factoring',
      gradeLevel: 'G8',
      subject: 'Factoring',
      label: 'Factoring Quadratics',
      subtitle: 'e.g. x² + 5x + 6 — parabola',
      route: '/grade8/factoring',
      icon: Icons.extension_rounded,
      tags: ['factoring', 'quadratic', 'parabola', 'G8'],
      difficulty: 'standard',
      depedCode: '',
      solverAvailable: false,
    ),
    const CurriculumTopic(
      id: 'g8-systems',
      gradeLevel: 'G8',
      subject: 'Systems',
      label: 'Linear Systems',
      subtitle: 'e.g. x + y = 5, x − y = 1 — intersection',
      route: '/grade8/systems',
      icon: Icons.grid_on_rounded,
      tags: ['system', 'simultaneous', 'intersection', 'G8'],
      difficulty: 'standard',
      depedCode: '',
      solverAvailable: false,
    ),
    const CurriculumTopic(
      id: 'g8-slope-intercept',
      gradeLevel: 'G8',
      subject: 'Linear Graphs',
      label: 'Slope & Intercept',
      subtitle: 'e.g. m = 2, b = −1 — line graph',
      route: '/grade8/slope-intercept',
      icon: Icons.show_chart_rounded,
      tags: ['slope', 'intercept', 'line', 'graph', 'G8'],
      difficulty: 'intro',
      depedCode: '',
      solverAvailable: false,
    ),
    // G9
    const CurriculumTopic(
      id: 'g9-quadratic-formula',
      gradeLevel: 'G9',
      subject: 'Quadratics',
      label: 'Quadratic Formula',
      subtitle: 'e.g. x² − 5x + 6 = 0 — roots + parabola',
      route: '/grade9/quadratic-formula',
      icon: Icons.square_foot_rounded,
      tags: ['quadratic', 'formula', 'roots', 'discriminant', 'G9'],
      difficulty: 'standard',
      depedCode: '',
      solverAvailable: false,
    ),
    const CurriculumTopic(
      id: 'g9-trig-ratios',
      gradeLevel: 'G9',
      subject: 'Trigonometry',
      label: 'Trig Ratios (SOH-CAH-TOA)',
      subtitle: 'e.g. sin 30° — right triangle',
      route: '/shs/trig-ratios',
      icon: Icons.change_history_rounded,
      tags: ['trigonometry', 'sohcahtoa', 'sine', 'triangle', 'G9', 'shs'],
      difficulty: 'intro',
      depedCode: '',
    ),
    const CurriculumTopic(
      id: 'g9-variation',
      gradeLevel: 'G9',
      subject: 'Variation',
      label: 'Direct & Inverse Variation',
      subtitle: 'e.g. y = kx, y = 10, x = 2 — find k',
      route: '/grade9/variation',
      icon: Icons.swap_calls_rounded,
      tags: ['variation', 'direct', 'inverse', 'constant', 'G9'],
      difficulty: 'standard',
      depedCode: '',
      solverAvailable: false,
    ),
    // G10
    const CurriculumTopic(
      id: 'g10-sequences',
      gradeLevel: 'G10',
      subject: 'Sequences',
      label: 'Arithmetic Sequences',
      subtitle: 'e.g. aₙ = 3n + 1 — dot plot',
      route: '/grade10/sequences',
      icon: Icons.more_horiz_rounded,
      tags: ['sequence', 'arithmetic', 'series', 'pattern', 'G10'],
      difficulty: 'standard',
      depedCode: '',
      solverAvailable: false,
    ),
    const CurriculumTopic(
      id: 'g10-circle-equation',
      gradeLevel: 'G10',
      subject: 'Circles',
      label: 'Circle Equation',
      subtitle: 'e.g. (x−1)² + (y+2)² = 9 — center + radius',
      route: '/grade10/circle-equation',
      icon: Icons.radio_button_unchecked_rounded,
      tags: ['circle', 'center', 'radius', 'G10'],
      difficulty: 'standard',
      depedCode: '',
      solverAvailable: false,
    ),
    const CurriculumTopic(
      id: 'g10-combinatorics',
      gradeLevel: 'G10',
      subject: 'Counting',
      label: 'Permutations & Combinations',
      subtitle: 'e.g. C(5,2) — counting',
      route: '/grade10/combinatorics',
      icon: Icons.calculate_rounded,
      tags: ['permutation', 'combination', 'counting', 'G10'],
      difficulty: 'standard',
      depedCode: '',
      solverAvailable: false,
    ),
    // G11 (SHS GenMath / PreCalc)
    const CurriculumTopic(
      id: 'g11-logarithms',
      gradeLevel: 'G11',
      subject: 'Logarithms',
      label: 'Logarithms & Exponents',
      subtitle: 'e.g. log₂ 32 — log curve',
      route: '/shs/logarithms',
      icon: Icons.trending_up_rounded,
      tags: ['logarithm', 'exponent', 'G11', 'genmath', 'shs'],
      difficulty: 'standard',
      depedCode: '',
    ),
    const CurriculumTopic(
      id: 'g11-interest',
      gradeLevel: 'G11',
      subject: 'Interest',
      label: 'Simple & Compound Interest',
      subtitle: 'e.g. P = 10k, r = 5%, t = 2 — growth bars',
      route: '/shs/interest',
      icon: Icons.savings_outlined,
      tags: ['interest', 'compound', 'annuity', 'peso', 'G11', 'shs'],
      difficulty: 'standard',
      depedCode: '',
    ),
    const CurriculumTopic(
      id: 'g11-inverse-functions',
      gradeLevel: 'G11',
      subject: 'Functions',
      label: 'Inverse Functions',
      subtitle: 'e.g. f(x) = 2x + 3 — swap x and y',
      route: '/shs/inverse-functions',
      icon: Icons.swap_horiz_rounded,
      tags: ['inverse', 'function', 'one-to-one', 'G11', 'genmath', 'shs'],
      difficulty: 'standard',
      depedCode: '',
    ),
    const CurriculumTopic(
      id: 'g11-rational-inequality',
      gradeLevel: 'G11',
      subject: 'Inequalities',
      label: 'Rational Inequalities',
      subtitle: 'e.g. (x-1)/(x+2) > 0 — sign chart',
      route: '/shs/rational-inequality',
      icon: Icons.compare_arrows_rounded,
      tags: ['rational', 'inequality', 'sign chart', 'asymptote', 'G11', 'shs'],
      difficulty: 'standard',
      depedCode: '',
    ),
    const CurriculumTopic(
      id: 'g11-trig-equations',
      gradeLevel: 'G11',
      subject: 'Trigonometry',
      label: 'Trig Equations',
      subtitle: 'e.g. sin x = 1/2 — solutions on [0, 2π)',
      route: '/shs/trig-equations',
      icon: Icons.show_chart_rounded,
      tags: ['trigonometry', 'equation', 'sine', 'cosine', 'G11', 'precalc', 'shs'],
      difficulty: 'standard',
      depedCode: '',
    ),
    const CurriculumTopic(
      id: 'g11-trig-identities',
      gradeLevel: 'G11',
      subject: 'Trigonometry',
      label: 'Trig Identities',
      subtitle: 'e.g. prove sin² + cos² = 1 — proof steps',
      route: '/shs/trig-identities',
      icon: Icons.verified_rounded,
      tags: ['trigonometry', 'identity', 'proof', 'pythagorean', 'G11', 'precalc', 'shs'],
      difficulty: 'standard',
      depedCode: '',
    ),
    const CurriculumTopic(
      id: 'g11-limits-intro',
      gradeLevel: 'G11',
      subject: 'Limits',
      label: 'Limits Intro',
      subtitle: 'e.g. lim x→2 (x²−4)/(x−2) — hole in curve',
      route: '/grade11/limits-intro',
      icon: Icons.compress_rounded,
      tags: ['limit', 'continuity', 'hole', 'G11', 'precalc'],
      difficulty: 'challenge',
      depedCode: '',
      solverAvailable: false,
    ),
    // G12 (Basic Calculus)
    const CurriculumTopic(
      id: 'g12-derivatives',
      gradeLevel: 'G12',
      subject: 'Derivatives',
      label: 'Derivatives (Power/Chain)',
      subtitle: 'e.g. d/dx x³ — tangent line',
      route: '/grade12/derivatives',
      icon: Icons.show_chart_rounded,
      tags: ['derivative', 'chain', 'power', 'tangent', 'G12'],
      difficulty: 'standard',
      depedCode: '',
      solverAvailable: false,
    ),
    const CurriculumTopic(
      id: 'g12-definite-integral',
      gradeLevel: 'G12',
      subject: 'Integrals',
      label: 'Definite Integrals & FTC',
      subtitle: 'e.g. ∫₀² x² dx — shaded area',
      route: '/shs/definite-integral',
      icon: Icons.area_chart_outlined,
      tags: ['integral', 'definite', 'area', 'ftc', 'G12', 'shs'],
      difficulty: 'standard',
      depedCode: '',
    ),
    const CurriculumTopic(
      id: 'g12-optimization',
      gradeLevel: 'G12',
      subject: 'Applications',
      label: 'Max / Min & Related Rates',
      subtitle: 'e.g. maximize area — graph + diagram',
      route: '/shs/optimization',
      icon: Icons.insights_rounded,
      tags: ['optimization', 'maximum', 'minimum', 'related rates', 'G12', 'shs'],
      difficulty: 'challenge',
      depedCode: '',
    ),
    // College
    const CurriculumTopic(
      id: 'college-lhopital',
      gradeLevel: 'College',
      subject: 'Limits',
      label: "L'Hôpital's Rule",
      subtitle: 'e.g. 0/0 indeterminate — limit curve',
      route: '/shs/lhopital',
      icon: Icons.functions_rounded,
      tags: ['lhospital', 'indeterminate', 'limit', 'college', 'shs'],
      difficulty: 'challenge',
      depedCode: '',
    ),
    const CurriculumTopic(
      id: 'college-matrices',
      gradeLevel: 'College',
      subject: 'Matrices',
      label: 'Matrices & Determinants',
      subtitle: 'e.g. 2×2 det & inverse',
      route: '/college/matrices',
      icon: Icons.grid_view_rounded,
      tags: ['matrix', 'determinant', 'inverse', 'college'],
      difficulty: 'standard',
      depedCode: '',
      solverAvailable: false,
    ),
    const CurriculumTopic(
      id: 'college-stats',
      gradeLevel: 'College',
      subject: 'Statistics',
      label: 'Hypothesis Testing & Regression',
      subtitle: 'e.g. z-test, y = mx + b — scatter + line',
      route: '/college/statistics',
      icon: Icons.scatter_plot_outlined,
      tags: ['statistics', 'hypothesis', 'regression', 'z-test', 'college'],
      difficulty: 'challenge',
      depedCode: '',
      solverAvailable: false,
    ),
  ];

  /// Every topic: G6 seed + G7–College stubs.
  static List<CurriculumTopic> allTopics() => [...grade6Topics, ...futureTopics];

  /// Topics for one grade ('G6' … 'G12', 'College').
  /// Case-insensitive; unknown grade returns [].
  static List<CurriculumTopic> getByGrade(String gradeLevel) {
    final normalized = gradeLevel.trim().toLowerCase();
    return allTopics()
        .where((t) => t.gradeLevel.toLowerCase() == normalized)
        .toList();
  }

  /// Alias kept for picker call-sites.
  static List<CurriculumTopic> byGrade(String gradeLevel) => getByGrade(gradeLevel);

  /// Find a topic by its future route path. Null when unknown.
  static CurriculumTopic? getByRoute(String route) {
    final normalized = route.trim();
    try {
      return allTopics().firstWhere((t) => t.route == normalized);
    } catch (_) {
      return null;
    }
  }

  /// In-memory search over label + subtitle + tags + DepEd code
  /// (+ subject/grade). Same pattern as ModMat `search()`.
  static List<CurriculumSearchHit> search(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return [];

    return [
      for (final topic in allTopics())
        if (_matches(topic, normalizedQuery))
          CurriculumSearchHit(gradeLevel: topic.gradeLevel, topic: topic),
    ];
  }

  static bool _matches(CurriculumTopic topic, String normalizedQuery) {
    return topic.label.toLowerCase().contains(normalizedQuery) ||
        topic.subtitle.toLowerCase().contains(normalizedQuery) ||
        topic.subject.toLowerCase().contains(normalizedQuery) ||
        topic.gradeLevel.toLowerCase().contains(normalizedQuery) ||
        topic.depedCode.toLowerCase().contains(normalizedQuery) ||
        topic.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
  }

  /// Grade levels offered, in display order.
  static List<String> get grades => const [
        'G6',
        'G7',
        'G8',
        'G9',
        'G10',
        'G11',
        'G12',
        'College',
      ];

  /// Shared accent for curriculum cards (single token source).
  static Color get accent => _accent;
}

/// Grade-6-only view for the future `Grade6PickerScreen`.
///
/// Thin delegate over [CurriculumRegistry] so Phase 1 screens do
/// not need to know about G7–College stubs.
class Grade6ModuleRegistry {
  static List<CurriculumTopic> get modules => CurriculumRegistry.grade6Topics;

  static List<ModuleEntry> get moduleEntries =>
      modules.map((t) => t.toModuleEntry()).toList();

  static CurriculumTopic? getByRoute(String route) {
    try {
      return modules.firstWhere((t) => t.route == route.trim());
    } catch (_) {
      return null;
    }
  }

  static List<CurriculumSearchHit> search(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return [];
    return [
      for (final topic in modules)
        if (topic.label.toLowerCase().contains(normalizedQuery) ||
            topic.subtitle.toLowerCase().contains(normalizedQuery) ||
            topic.subject.toLowerCase().contains(normalizedQuery) ||
            topic.depedCode.toLowerCase().contains(normalizedQuery) ||
            topic.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery)))
          CurriculumSearchHit(gradeLevel: topic.gradeLevel, topic: topic),
    ];
  }
}
