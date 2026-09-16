import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calculus_system/shared/widgets/module_card.dart';

class FactoringCard extends StatelessWidget {
  const FactoringCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      icon: Icons.category_rounded,
      title: 'By Factoring',
      subtitle: 'Factor expressions to cancel common terms',
      onTap: () => context.push('/topics/calculus/finals/limits/factoring'),
    );
  }
}
