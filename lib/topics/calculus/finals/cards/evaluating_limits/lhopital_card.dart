import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calculus_system/shared/widgets/module_card.dart';

class LhopitalCard extends StatelessWidget {
  const LhopitalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      icon: Icons.rule_rounded,
      title: "By L'Hopital's Rule",
      subtitle: 'Differentiate numerator and denominator to resolve 0/0 or ∞/∞',
      onTap: () => context.push('/topics/calculus/finals/limits/lhopital'),
    );
  }
}
