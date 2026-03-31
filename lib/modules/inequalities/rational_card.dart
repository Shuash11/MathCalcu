import 'package:flutter/material.dart';
import 'core/animated_inequality_card.dart';
import 'theme/inequality_theme.dart';

class RationalCard extends StatelessWidget {
  const RationalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Rational Inequality',
      subtitle: 'Involves a fraction with variable in numerator/denominator.',
      route: '/inequalities/rational',
      icon: Icons.pie_chart_rounded, // or any fraction related icon
      accentColor: InequalityTheme.subtypeAccents['rational'] ?? InequalityTheme.accentColor,
      tags: const ['Fractions', 'Asymptotes', 'Signs'],
    );
  }
}
