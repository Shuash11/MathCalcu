import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';
import 'package:calculus_system/topics/calculus/midterm/theme/inequalities_theme/inequality_theme.dart';

class LinearCard extends StatelessWidget {
  const LinearCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Linear Inequality',
      subtitle: 'Supports <, >, ≤, ≥, and continued inequalities.',
      route: '/inequalities/simple',
      icon: Icons.functions_rounded,
      accentColor: InequalityTheme.subtypeAccents['strict'] ?? InequalityTheme.accentColor,
      tags: const ['Linear', 'Strict', 'Non-strict', 'Continued'],
    );
  }
}
