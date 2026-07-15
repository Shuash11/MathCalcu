import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: FinalsTheme.primary.withValues(alpha: 0.10),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: FinalsTheme.primary.withValues(alpha: 0.05),
              blurRadius: AppDesign.shadowBlur,
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: FinalsTheme.card(context),
            indicatorColor: FinalsTheme.primary.withValues(alpha: 0.20),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(color: FinalsTheme.primary);
              }
              return IconThemeData(color: FinalsTheme.textSecondary(context));
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: FinalsTheme.primary,
                );
              }
              return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: FinalsTheme.textSecondary(context),
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.book_outlined),
                selectedIcon: Icon(Icons.book_rounded),
                label: 'Topics',
              ),
              NavigationDestination(
                icon: Icon(Icons.sticky_note_2_outlined),
                selectedIcon: Icon(Icons.sticky_note_2_rounded),
                label: 'Notes',
              ),
              NavigationDestination(
                icon: Icon(Icons.calculate_outlined),
                selectedIcon: Icon(Icons.calculate_rounded),
                label: 'Calculator',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
