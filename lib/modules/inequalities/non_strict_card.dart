import 'package:flutter/material.dart';
import 'core/animated_inequality_card.dart';
import 'theme/inequality_theme.dart';

class NonStrictCard extends StatelessWidget {
  const NonStrictCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Non-strict Inequality',
      subtitle: 'Uses ≤ or ≥. The boundary IS included.',
      route: '/inequalities/non_strict',
      icon: Icons.drag_handle_rounded,
      accentColor: InequalityTheme.subtypeAccents['non_strict'] ?? InequalityTheme.accentColor,
      tags: const ['Linear', 'Inclusive', 'Basic'],
    );
  }
}
