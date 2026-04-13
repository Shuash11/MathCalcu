import 'package:calculus_system/Finals/finals_picker_screen.dart';
import 'package:go_router/go_router.dart';

final List<GoRoute> finalsRoutes = [
  GoRoute(
    path: '/second-sem',
    name: 'second-sem',
    builder: (context, state) => const FinalsPickerScreen(),

    routes: const [
      // Future routes go here
    ],
  ),
];