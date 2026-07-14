import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'animated_inequality_card.dart';
import 'package:calculus_system/topics/calculus/midterm/theme/inequalities_theme/inequality_theme.dart';

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
