import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';

class ContinuedCard extends StatelessWidget {
  const ContinuedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedInequalityCard(
      title: 'Continued Inequality',
      subtitle: 'A value sandwiched between two bounds.',
      route: '/inequalities/continued',
      icon: Icons.compare_arrows_rounded,
    );
  }
}
