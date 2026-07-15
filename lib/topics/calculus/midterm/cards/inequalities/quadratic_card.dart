import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';
import 'package:calculus_system/topics/calculus/midterm/theme/inequalities_theme/inequality_theme.dart';

class QuadraticCard extends StatelessWidget {
  const QuadraticCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Quadratic Inequality',
      subtitle: 'Has a squared term. Requires factoring.',
      route: '/inequalities/quadratic',
      icon: Icons.ssid_chart_rounded,
      accentColor: InequalityTheme.subtypeAccents['quadratic'] ?? InequalityTheme.accentColor,
    );
  }
}
