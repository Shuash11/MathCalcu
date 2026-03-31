import 'package:flutter/material.dart';
import 'core/animated_inequality_card.dart';
import 'theme/inequality_theme.dart';

class QuadraticCard extends StatelessWidget {
  const QuadraticCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Quadratic Inequality',
      subtitle: 'Has a squared term. Requires factoring.',
      route: '/inequalities/quadratic',
      icon: Icons.ssid_chart_rounded, // or any parabola icon
      accentColor: InequalityTheme.subtypeAccents['quadratic'] ?? InequalityTheme.accentColor,
      tags: const ['Parabola', 'Roots', 'Zeros'],
    );
  }
}
