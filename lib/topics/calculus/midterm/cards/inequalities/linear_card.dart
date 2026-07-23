import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';

class LinearCard extends StatelessWidget {
  const LinearCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedInequalityCard(
      title: 'Linear Inequality',
      subtitle: 'Supports <, >, =, =, and continued inequalities.',
      route: '/inequalities/simple',
      icon: Icons.functions_rounded,
    );
  }
}
