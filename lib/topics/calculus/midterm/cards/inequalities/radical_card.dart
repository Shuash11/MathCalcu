import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';
import 'package:calculus_system/topics/calculus/midterm/theme/inequalities_theme/inequality_theme.dart';

class RadicalCard extends StatelessWidget {
  const RadicalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Radical Inequality',
      subtitle: 'Has a square root. Check the domain constraints.',
      route: '/inequalities/radical',
      icon: Icons.square_foot_rounded,
      accentColor: InequalityTheme.subtypeAccents['radical'] ?? InequalityTheme.accentColor,
    );
  }
}
