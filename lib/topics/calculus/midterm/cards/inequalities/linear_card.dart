import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';
import 'package:provider/provider.dart';

class LinearCard extends StatelessWidget {
  const LinearCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Linear Inequality',
      subtitle: 'Supports <, >, =, =, and continued inequalities.',
      route: '/inequalities/simple',
      icon: Icons.functions_rounded,
      accentColor: {'strict': const Color(0xFF334155), 'non_strict': const Color(0xFF334155), 'absolute': const Color(0xFF334155)}['strict'] ?? const Color(0xFF334155),
    );
  }
}
