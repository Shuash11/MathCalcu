import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';

class RationalCard extends StatelessWidget {
  const RationalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedInequalityCard(
      title: 'Rational Inequality',
      subtitle: 'Involves a fraction with variable in numerator/denominator.',
      route: '/inequalities/rational',
      icon: Icons.pie_chart_rounded,
    );
  }
}
