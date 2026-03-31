import 'package:flutter/material.dart';
import 'core/animated_inequality_card.dart';
import 'theme/inequality_theme.dart';

class ContinuedCard extends StatelessWidget {
  const ContinuedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Continued Inequality',
      subtitle: 'A value sandwiched between two bounds.',
      route: '/inequalities/continued',
      icon: Icons.compare_arrows_rounded,
      accentColor: InequalityTheme.subtypeAccents['continued'] ?? InequalityTheme.accentColor,
      tags: const ['Compound', 'Range', 'Dual'],
    );
  }
}
