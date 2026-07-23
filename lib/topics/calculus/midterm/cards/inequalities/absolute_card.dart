import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';

class AbsoluteCard extends StatelessWidget {
  const AbsoluteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedInequalityCard(
      title: 'Absolute Value',
      subtitle: 'Uses |expression|. Handles both cases.',
      route: '/inequalities/absolute',
      icon: Icons.vertical_align_center_rounded,
    );
  }
}
