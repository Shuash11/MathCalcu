import 'package:flutter/material.dart';
import 'core/animated_inequality_card.dart';
import 'theme/inequality_theme.dart';

class RadicalCard extends StatelessWidget {
  const RadicalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Radical Inequality',
      subtitle: 'Has a square root. Check the domain constraints.',
      route: '/inequalities/radical',
      icon: Icons.square_foot_rounded, // or any appropriate math icon
      accentColor: InequalityTheme.subtypeAccents['radical'] ?? InequalityTheme.accentColor,
      tags: const ['Roots', 'Domain', 'Squaring'],
    );
  }
}
