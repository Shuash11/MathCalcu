import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/module_card.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';

class SubstitutionCard extends StatelessWidget {
  const SubstitutionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      icon: Icons.input_rounded,
      title: 'Direct Substitution',
      subtitle: 'Plug in the value directly when function is continuous',
      accentColor: const Color(0xFF7F1D1D),
      onTap: () => Navigator.of(context).pushNamed('/topics/calculus/finals/limits/substitution'),
    );
  }
}
