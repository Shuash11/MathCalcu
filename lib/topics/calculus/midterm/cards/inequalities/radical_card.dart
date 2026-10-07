import 'package:material_ui/material_ui.dart';
import 'animated_inequality_card.dart';

class RadicalCard extends StatelessWidget {
  const RadicalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedInequalityCard(
      title: 'Radical Inequality',
      subtitle: 'Has a square root. Check the domain constraints.',
      route: '/inequalities/radical',
      icon: Icons.square_foot_rounded,
    );
  }
}
