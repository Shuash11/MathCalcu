import 'package:flutter/material.dart';
import 'core/animated_inequality_card.dart';
import 'theme/inequality_theme.dart';

class SimpleCard extends StatelessWidget {
  const SimpleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Basic Inequality',
      subtitle: 'Linear inequalities with one variable.',
      route: '/inequalities/simple',
      icon: Icons.functions_rounded,
      accentColor: InequalityTheme.subtypeAccents['simple'] ?? InequalityTheme.accentColor,
      tags: const ['Linear', 'Algebra', 'Simple'],
    );
  }
}
