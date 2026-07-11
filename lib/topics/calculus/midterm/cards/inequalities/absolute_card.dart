import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';
import 'package:calculus_system/topics/calculus/midterm/theme/inequalities_theme/inequality_theme.dart';

class AbsoluteCard extends StatelessWidget {
  const AbsoluteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Absolute Value',
      subtitle: 'Uses |expression|. Handles both cases.',
      route: '/inequalities/absolute',
      icon: Icons.vertical_align_center_rounded,
      accentColor: InequalityTheme.subtypeAccents['absolute'] ?? InequalityTheme.accentColor,
      tags: const ['Absolute', 'Distance', 'Split'],
    );
  }
}
