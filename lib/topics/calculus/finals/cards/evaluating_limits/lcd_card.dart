import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/module_card.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';

class LcdCard extends StatelessWidget {
  const LcdCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      icon: Icons.calculate_rounded,
      title: 'By LCD',
      subtitle: 'Find least common denominator to combine fractions',
      onTap: () => Navigator.of(context).pushNamed('/topics/calculus/finals/limits/lcd'),
    );
  }
}
