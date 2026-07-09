import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/screens/category_picker_screen.dart';
import 'package:calculus_system/screens/settings_screen.dart';
import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:calculus_system/theme/theme_provider.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    CategoryPickerScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: FinalsTheme.card(context),
          indicatorColor: FinalsTheme.primary.withValues(alpha: 0.20),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return IconThemeData(color: FinalsTheme.primary);
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
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
