import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calculus_system/home/widgets/home_card.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class TopicsScreen extends StatelessWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final width = MediaQuery.of(context).size.width;

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Topics',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: theme.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
          children: [
            HomeCard(
              icon: Icons.functions_rounded,
              label: 'Midterm',
              onTap: () => context.push('/topics/midterm'),
            ),
            HomeCard(
              icon: Icons.timeline_rounded,
              label: 'Finals',
              onTap: () => context.push('/topics/finals'),
            ),
          ],
        ),
      ),
    );
  }
}
