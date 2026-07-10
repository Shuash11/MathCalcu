import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calculus_system/home/widgets/home_card.dart';
import 'package:calculus_system/topics/finals/finals_theme.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount;
    if (width < 600) {
      crossAxisCount = 2;
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
                  const SizedBox(height: 16),
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: FinalsTheme.headerGradient,
                      boxShadow: [
                        BoxShadow(
                          color: FinalsTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'MathCalcu',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: theme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your math companion',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
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
                          subtitle: 'Midterm · Finals',
                          accent: FinalsTheme.primary,
                          onTap: () => context.push('/topics'),
                        ),
                        HomeCard(
                          icon: Icons.note_alt_rounded,
                          label: 'Notes',
                          subtitle: 'Coming soon',
                          accent: FinalsTheme.secondary,
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
                          subtitle: 'Coming soon',
                          accent: FinalsTheme.tertiary,
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
