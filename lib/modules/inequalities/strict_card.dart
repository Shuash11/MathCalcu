import 'package:flutter/material.dart';
import 'core/animated_inequality_card.dart';
import 'theme/inequality_theme.dart';

class StrictCard extends StatelessWidget {
  const StrictCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Strict Inequality',
      subtitle: 'Uses < or >. The boundary is NOT included.',
      route: '/inequalities/strict',
      icon: Icons.code_rounded,
      accentColor: InequalityTheme.subtypeAccents['strict'] ?? InequalityTheme.accentColor,
      tags: const ['Linear', 'Exclusive', 'Basic'],
    );
  }
}
