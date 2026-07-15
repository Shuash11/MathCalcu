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
    final surface = isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A2E);
    final card = isLight ? const Color(0xFFF4F4F1) : const Color(0xFF232340);
    final accent = isLight ? const Color(0xFF334155) : const Color(0xFFE9ECEF);
    final textMuted = isLight
        ? const Color(0xFF64748B).withValues(alpha: 0.5)
        : const Color(0xFFF4F4F1).withValues(alpha: 0.4);

    return Scaffold(
      body: navigationShell,
      backgroundColor: surface,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surface,
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              height: 60,
              constraints: const BoxConstraints(maxWidth: 420),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accent.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    context: context,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                    isSelected: navigationShell.currentIndex == 0,
                    accent: accent,
                    textMuted: textMuted,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.book_outlined,
                    activeIcon: Icons.book_rounded,
                    label: 'Topics',
                    index: 1,
                    isSelected: navigationShell.currentIndex == 1,
                    accent: accent,
                    textMuted: textMuted,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.sticky_note_2_outlined,
                    activeIcon: Icons.sticky_note_2_rounded,
                    label: 'Notes',
                    index: 2,
                    isSelected: navigationShell.currentIndex == 2,
                    accent: accent,
                    textMuted: textMuted,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.calculate_outlined,
                    activeIcon: Icons.calculate_rounded,
                    label: 'Calc',
                    index: 3,
                    isSelected: navigationShell.currentIndex == 3,
                    accent: accent,
                    textMuted: textMuted,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    label: 'Settings',
                    index: 4,
                    isSelected: navigationShell.currentIndex == 4,
                    accent: accent,
                    textMuted: textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isSelected,
    required Color accent,
    required Color textMuted,
  }) {
    return GestureDetector(
      onTap: () {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? accent : textMuted,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? accent : textMuted,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
