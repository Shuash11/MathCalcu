import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calculus_system/shared/widgets/module_card.dart';

class LcdCard extends StatelessWidget {
  const LcdCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      icon: Icons.calculate_rounded,
      title: 'By LCD',
      subtitle: 'Find least common denominator to combine fractions',
      onTap: () => context.push('/topics/calculus/finals/limits/lcd'),
    );
  }
}
