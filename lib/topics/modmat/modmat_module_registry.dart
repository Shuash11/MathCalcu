import 'package:calculus_system/core/module_registry.dart';
import 'package:calculus_system/topics/modmat/modmat_theme.dart';
import 'package:flutter/material.dart';

class ModmatModuleRegistry {
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
}
