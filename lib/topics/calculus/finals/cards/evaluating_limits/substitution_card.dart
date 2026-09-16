import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calculus_system/shared/widgets/module_card.dart';

class SubstitutionCard extends StatelessWidget {
  const SubstitutionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      icon: Icons.input_rounded,
      title: 'Direct Substitution',
      subtitle: 'Plug in the value directly when function is continuous',
      onTap: () => context.push('/topics/calculus/finals/limits/substitution'),
    );
  }
}
