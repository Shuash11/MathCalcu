import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';
import 'package:provider/provider.dart';

class SimpleCard extends StatelessWidget {
  const SimpleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Basic Inequality',
      subtitle: 'Linear inequalities with one variable.',
      route: '/inequalities/simple',
      icon: Icons.functions_rounded,
      accentColor: {'strict': const Color(0xFF334155), 'non_strict': const Color(0xFF334155), 'absolute': const Color(0xFF334155)}['simple'] ?? const Color(0xFF334155),
    );
  }
}
