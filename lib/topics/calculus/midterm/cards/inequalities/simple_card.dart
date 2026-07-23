import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';

class SimpleCard extends StatelessWidget {
  const SimpleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedInequalityCard(
      title: 'Basic Inequality',
      subtitle: 'Linear inequalities with one variable.',
      route: '/inequalities/simple',
      icon: Icons.functions_rounded,
    );
  }
}
