import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/module_card.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';

class ConjugateCard extends StatelessWidget {
  const ConjugateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      icon: Icons.unfold_more_double_rounded,
      title: 'By Conjugate',
      subtitle: 'Multiply by the conjugate to eliminate indeterminate radicals',
      onTap: () => Navigator.of(context).pushNamed('/topics/calculus/finals/limits/conjugate'),
    );
  }
}
