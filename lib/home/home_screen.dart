import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calculus_system/home/widgets/home_card.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final width = MediaQuery.of(context).size.width;

    // Responsive columns
    int crossAxisCount;
    if (width < 600) {
      crossAxisCount = 2;
    } else if (width < 900) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 3;
    }

    return Scaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Logo
                  Icon(
                    Icons.calculate_rounded,
                    size: 64,
                    color: theme.accentColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'MathCalcu',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your math companion',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                      children: [
                        HomeCard(
                          icon: Icons.school_rounded,
                          label: 'Topics',
                          onTap: () => context.push('/topics'),
                        ),
                        HomeCard(
                          icon: Icons.note_alt_rounded,
                          label: 'Notes',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Coming soon!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        HomeCard(
                          icon: Icons.calculate_rounded,
                          label: 'Calculator',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Coming soon!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
