import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isLight = themeProvider.isLight;
    final card = isLight ? const Color(0xFFF4F4F1) : const Color(0xFF232340);
    final accent = isLight ? const Color(0xFF334155) : const Color(0xFFE9ECEF);
    final textMuted = isLight
        ? const Color(0xFF64748B).withValues(alpha: 0.5)
        : const Color(0xFFF4F4F1).withValues(alpha: 0.4);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: card,
          border: Border(
            top: BorderSide(
              color: accent.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 72,
            backgroundColor: card,
            indicatorColor: accent.withValues(alpha: 0.12),
            elevation: 0,
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(color: accent, size: 24);
              }
              return IconThemeData(color: textMuted, size: 24);
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: accent,
                  letterSpacing: 0.2,
                );
              }
              return TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textMuted,
                letterSpacing: 0.2,
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
                label: 'Calc',
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
