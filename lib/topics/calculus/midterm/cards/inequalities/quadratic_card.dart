import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';
import 'package:provider/provider.dart';

class QuadraticCard extends StatelessWidget {
  const QuadraticCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Quadratic Inequality',
      subtitle: 'Has a squared term. Requires factoring.',
      route: '/inequalities/quadratic',
      icon: Icons.ssid_chart_rounded,
      accentColor: {'strict': const Color(0xFF334155), 'non_strict': const Color(0xFF334155), 'absolute': const Color(0xFF334155)}['quadratic'] ?? const Color(0xFF334155),
    );
  }
}
