import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';
import 'package:provider/provider.dart';

class RadicalCard extends StatelessWidget {
  const RadicalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Radical Inequality',
      subtitle: 'Has a square root. Check the domain constraints.',
      route: '/inequalities/radical',
      icon: Icons.square_foot_rounded,
      accentColor: {'strict': const Color(0xFF334155), 'non_strict': const Color(0xFF334155), 'absolute': const Color(0xFF334155)}['radical'] ?? const Color(0xFF334155),
    );
  }
}
