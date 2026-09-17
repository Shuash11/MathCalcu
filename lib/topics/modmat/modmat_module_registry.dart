import 'package:calculus_system/core/module_registry.dart';
import 'package:calculus_system/topics/modmat/modmat_theme.dart';
import 'package:flutter/material.dart';

class ModmatSearchHit {
  final String section;
  final ModuleEntry module;

  const ModmatSearchHit({required this.section, required this.module});
}

class ModmatModuleRegistry {
  /// Leaf topic routes with a landed solver screen (Cycle 9 F1+F2
  /// wiring: M1–M6 wave 1 + M7–M14 wave 2). Each entry has a thin
  /// [Grade6SolverScreen]-backed screen plus a top-level GoRouter
  /// destination under `/modmat/...` matching the module [route]
  /// string exactly.
  static const Set<String> wiredLeafRoutes = {
    '/modmat/foundations/propositional_logic',
    '/modmat/foundations/predicate_logic',
    '/modmat/foundations/set_theory',
    '/modmat/foundations/relations_functions',
    '/modmat/foundations/proof_techniques',
    '/modmat/foundations/number_systems',
    '/modmat/foundations/combinatorics_basics',
    '/modmat/foundations/graph_theory_basics',
    '/modmat/advanced/advanced_graph_theory',
    '/modmat/advanced/algebraic_structures',
    '/modmat/advanced/real_analysis',
    '/modmat/advanced/linear_algebra',
    '/modmat/advanced/number_theory',
    '/modmat/advanced/topology_basics',
  };

  /// Leaf topic routes have a GoRouter destination only when wired
  /// (see [wiredLeafRoutes]). Cycle 9 middle-end invariant: taps on
  /// unwired leaf routes must be gated via [isRouteAvailable]
  /// (coming-soon SnackBar) until the leaf screens land — never a
  /// push to a missing route.
  static bool isLeafRoute(String route) {
    final normalized = route.trim();
    return normalized.startsWith('/modmat/foundations/') ||
        normalized.startsWith('/modmat/advanced/');
  }

  /// True when [route] resolves to a registered GoRouter destination:
  /// section/picker routes plus wired leaf routes. Unwired leaves
  /// stay gated (coming-soon SnackBar, never a dead push).
  static bool isRouteAvailable(String route) {
    final normalized = route.trim();
    if (isLeafRoute(normalized)) return wiredLeafRoutes.contains(normalized);
    return true;
  }

  static final List<ModuleEntry> foundationsModules = [
    const ModuleEntry(
      label: 'Propositional Logic',
      subtitle: 'Truth tables, connectives, equivalences',
      route: '/modmat/foundations/propositional_logic',
      icon: Icons.functions_rounded,
      accent: ModmatTheme.primary,
    ),
    const ModuleEntry(
      label: 'Predicate Logic',
      subtitle: 'Quantifiers, predicates, validity',
      route: '/modmat/foundations/predicate_logic',
      icon: Icons.code_rounded,
      accent: ModmatTheme.primary,
    ),
    const ModuleEntry(
      label: 'Set Theory',
      subtitle: 'Operations, power sets, relations',
      route: '/modmat/foundations/set_theory',
      icon: Icons.category_rounded,
      accent: ModmatTheme.primary,
    ),
    const ModuleEntry(
      label: 'Relations & Functions',
      subtitle: 'Equivalence, order, compositions',
      route: '/modmat/foundations/relations_functions',
      icon: Icons.swap_horiz_rounded,
      accent: ModmatTheme.primary,
    ),
    const ModuleEntry(
      label: 'Proof Techniques',
      subtitle: 'Direct, contradiction, induction',
      route: '/modmat/foundations/proof_techniques',
      icon: Icons.verified_rounded,
      accent: ModmatTheme.primary,
    ),
    const ModuleEntry(
      label: 'Number Systems',
      subtitle: 'N, Z, Q, R, C construction',
      route: '/modmat/foundations/number_systems',
      icon: Icons.numbers_rounded,
      accent: ModmatTheme.primary,
    ),
    const ModuleEntry(
      label: 'Combinatorics Basics',
      subtitle: 'Counting, permutations, combinations',
      route: '/modmat/foundations/combinatorics_basics',
      icon: Icons.calculate_rounded,
      accent: ModmatTheme.primary,
    ),
    const ModuleEntry(
      label: 'Graph Theory Basics',
      subtitle: 'Vertices, edges, paths, trees',
      route: '/modmat/foundations/graph_theory_basics',
      icon: Icons.account_tree_rounded,
      accent: ModmatTheme.primary,
    ),
  ];

  static final List<ModuleEntry> advancedModules = [
    const ModuleEntry(
      label: 'Advanced Graph Theory',
      subtitle: 'Coloring, planarity, algorithms',
      route: '/modmat/advanced/advanced_graph_theory',
      icon: Icons.insights_rounded,
      accent: ModmatTheme.secondary,
    ),
    const ModuleEntry(
      label: 'Algebraic Structures',
      subtitle: 'Groups, rings, fields',
      route: '/modmat/advanced/algebraic_structures',
      icon: Icons.science_rounded,
      accent: ModmatTheme.secondary,
    ),
    const ModuleEntry(
      label: 'Real Analysis',
      subtitle: 'Sequences, limits, continuity',
      route: '/modmat/advanced/real_analysis',
      icon: Icons.trending_up_rounded,
      accent: ModmatTheme.secondary,
    ),
    const ModuleEntry(
      label: 'Linear Algebra',
      subtitle: 'Vector spaces, eigenvalues',
      route: '/modmat/advanced/linear_algebra',
      icon: Icons.grid_on_rounded,
      accent: ModmatTheme.secondary,
    ),
    const ModuleEntry(
      label: 'Number Theory',
      subtitle: 'Primes, congruences, theorems',
      route: '/modmat/advanced/number_theory',
      icon: Icons.pin_rounded,
      accent: ModmatTheme.secondary,
    ),
    const ModuleEntry(
      label: 'Topology Basics',
      subtitle: 'Open sets, continuity, compactness',
      route: '/modmat/advanced/topology_basics',
      icon: Icons.tune_rounded,
      accent: ModmatTheme.secondary,
    ),
  ];

  static List<ModuleEntry> getModulesForSection(String section) {
    switch (section) {
      case 'foundations':
        return foundationsModules;
      case 'advanced':
        return advancedModules;
      default:
        return [];
    }
  }

  static ModuleEntry? getModule(String section, String label) {
    final modules = getModulesForSection(section);
    try {
      return modules.firstWhere((m) => m.label == label);
    } catch (_) {
      return null;
    }
  }

  static List<ModmatSearchHit> search(String query) {
    final tokens = query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) {
      return [];
    }

    return [
      for (final module in foundationsModules)
        if (_matches(module, tokens))
          ModmatSearchHit(section: 'Foundations', module: module),
      for (final module in advancedModules)
        if (_matches(module, tokens))
          ModmatSearchHit(section: 'Advanced', module: module),
    ];
  }

  static bool _matches(ModuleEntry module, List<String> tokens) {
    final haystack = '${module.label} ${module.subtitle}'.toLowerCase();
    return tokens.every(haystack.contains);
  }
}
