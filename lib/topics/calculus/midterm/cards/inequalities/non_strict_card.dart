import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';

class NonStrictCard extends StatelessWidget {
  const NonStrictCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedInequalityCard(
      title: 'Non-strict Inequality',
      subtitle: 'Uses = or =. The boundary IS included.',
      route: '/inequalities/non_strict',
      icon: Icons.drag_handle_rounded,
    );
  }
}
