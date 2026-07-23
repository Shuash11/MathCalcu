import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';

class StrictCard extends StatelessWidget {
  const StrictCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedInequalityCard(
      title: 'Strict Inequality',
      subtitle: 'Uses < or >. The boundary is NOT included.',
      route: '/inequalities/strict',
      icon: Icons.code_rounded,
    );
  }
}
