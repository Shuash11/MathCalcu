import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/module_card.dart';
import 'package:go_router/go_router.dart';

class FindingCenterRadiusCard extends StatelessWidget {
  const FindingCenterRadiusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      icon: Icons.blur_circular_rounded,
      title: 'Finding the Center & Radius',
      subtitle: 'Combined center and radius from equations',
      accentColor: const Color(0xFF7F1D1D),
      onTap: () => context.push('/circle/finding-center-radius'),
    );
  }
}
