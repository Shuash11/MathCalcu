# Settings Screen Restyle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restyle the Settings screen to match the Home screen header's visual design (circular icon containers, purple accent) and add a Website link in the About section.

**Architecture:** Single file change to `lib/screens/settings_screen.dart`. Replace the current `Card` + `ListTile` layout with custom styled rows using the Home screen's circular icon pattern. Add one new row under About for the website link.

**Tech Stack:** Flutter, provider, url_launcher, package_info_plus

---

### Task 1: Rewrite settings_screen.dart

**Files:**
- Modify: `lib/screens/settings_screen.dart` (full rewrite)

- [ ] **Step 1: Write the complete restyled Settings screen**

Replace the entire content of `lib/screens/settings_screen.dart` with the following code:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/widgets/donate_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _appVersion = 'v${info.version}');
    } catch (_) {
      if (mounted) setState(() => _appVersion = 'v1.2.0');
    }
  }

  static const _accent = Color(0xFF6C63FF);

  Widget _iconCircle(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: context.watch<ThemeProvider>().card,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: _accent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: theme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _sectionHeader('Theme'),
          _SettingsRow(
            icon: theme.isLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            label: 'Dark Mode',
            trailing: Switch.adaptive(
              value: !theme.isLight,
              onChanged: (_) => theme.toggle(),
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader('Support'),
          _SettingsRow(
            icon: Icons.coffee_rounded,
            label: 'Donate',
            subtitle: 'Support the developer',
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _accent.withValues(alpha: 0.6)),
            onTap: () => showDonateSheet(context),
          ),
          const SizedBox(height: 24),
          _sectionHeader('GitHub'),
          _SettingsRow(
            icon: Icons.code_rounded,
            label: 'Shuash11',
            subtitle: 'View developer profile & repos',
            trailing: Icon(Icons.open_in_new_rounded, size: 16, color: _accent),
            onTap: () async {
              final uri = Uri.parse('https://github.com/Shuash11');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(height: 24),
          _sectionHeader('About'),
          _SettingsRow(
            icon: Icons.info_outline_rounded,
            label: 'MathCalcu',
            subtitle: _appVersion,
          ),
          const SizedBox(height: 12),
          _SettingsRow(
            icon: Icons.person_rounded,
            label: 'Developer',
            subtitle: 'Joashua Marl Barimbao',
          ),
          const SizedBox(height: 12),
          _SettingsRow(
            icon: Icons.email_outlined,
            label: 'Contact',
            subtitle: 'joashuabarimbao10@gmail.com',
            onTap: () async {
              final uri = Uri.parse('mailto:joashuabarimbao10@gmail.com');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          const SizedBox(height: 12),
          _SettingsRow(
            icon: Icons.language_rounded,
            label: 'Website',
            subtitle: 'mathcalc-calculus.netlify.app',
            trailing: Icon(Icons.open_in_new_rounded, size: 16, color: _accent),
            onTap: () async {
              final uri = Uri.parse('https://mathcalc-calculus.netlify.app/');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _accent,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.card,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF6C63FF)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify with flutter analyze**

Run: `cd C:\projects\mathcalcu && flutter analyze lib/screens/settings_screen.dart`
Expected: No errors (warnings/infos from other files may appear)

- [ ] **Step 3: Run tests**

Run: `cd C:\projects\mathcalcu && flutter test`
Expected: All tests pass

- [ ] **Step 4: Commit**

```bash
git add lib/screens/settings_screen.dart
git commit -m "feat: restyle settings screen with Home screen visual design"
```

---

### Task 2: Verify with full analyze and test

**Files:** (no file changes — verification only)

- [ ] **Step 1: Run full project analyze**

Run: `cd C:\projects\mathcalcu && flutter analyze`
Expected: No errors in settings_screen.dart

- [ ] **Step 2: Run all tests**

Run: `cd C:\projects\mathcalcu && flutter test`
Expected: All tests pass
