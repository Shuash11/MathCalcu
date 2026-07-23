import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';

class QuadraticCard extends StatelessWidget {
  const QuadraticCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedInequalityCard(
      title: 'Quadratic Inequality',
      subtitle: 'Has a squared term. Requires factoring.',
      route: '/inequalities/quadratic',
      icon: Icons.ssid_chart_rounded,
    );
  }
}
