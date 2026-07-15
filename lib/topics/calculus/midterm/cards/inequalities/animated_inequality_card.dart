import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/module_card.dart';

class AnimatedInequalityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color accentColor;

  const AnimatedInequalityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      icon: icon,
      title: title,
      subtitle: subtitle,
      accentColor: accentColor,
      onTap: () => Navigator.of(context).pushNamed(route),
    );
  }
}
