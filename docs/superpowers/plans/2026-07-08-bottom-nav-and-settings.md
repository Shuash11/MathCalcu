# Bottom Navigation & Settings — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a bottom navigation bar (Home + Settings tabs) and a new Settings screen with Theme, Support/Donate, GitHub, and About sections.

**Architecture:** Root GoRouter route renders an `AppShell` scaffold with `BottomNavigationBar` + `IndexedStack` containing `CategoryPickerScreen` (Home) and `SettingsScreen` (Settings). Topic routes push on top, hiding the nav bar automatically.

**Tech Stack:** Flutter, GoRouter, url_launcher, package_info_plus, shared_preferences, provider

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `lib/widgets/app_shell.dart` | **Create** | Scaffold + BottomNavigationBar + IndexedStack |
| `lib/screens/settings_screen.dart` | **Create** | Settings with 4 sections: Theme, Support, GitHub, About |
| `lib/app_router.dart` | **Modify** | Root route renders AppShell, add Settings as GoRouter route, add url_launcher import |
| `pubspec.yaml` | **Modify** | Add `url_launcher` dependency |
| `test/widget_test.dart` | **Modify** | Update test for new app structure |

---

### Task 1: Create AppShell widget

**Files:**
- Create: `lib/widgets/app_shell.dart`

- [ ] **Step 1: Write `app_shell.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:calculus_system/screens/category_picker_screen.dart';
import 'package:calculus_system/screens/settings_screen.dart';

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
      bottomNavigationBar: NavigationBar(
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
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/widgets/app_shell.dart
git commit -m "feat: add AppShell with bottom navigation bar"
```

---

### Task 2: Create Settings screen

**Files:**
- Create: `lib/screens/settings_screen.dart`

- [ ] **Step 1: Write `settings_screen.dart`**

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
      if (mounted) {
        setState(() => _appVersion = 'v${info.version}');
      }
    } catch (_) {
      if (mounted) setState(() => _appVersion = 'v1.1.0');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _sectionHeader('Appearance'),
          _SettingsTile(
            icon: themeProvider.isLight
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            title: 'Dark Mode',
            trailing: Switch.adaptive(
              value: themeProvider.isDark,
              onChanged: (_) => themeProvider.toggle(),
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader('Support'),
          _SettingsTile(
            icon: Icons.coffee_rounded,
            title: 'Donate',
            subtitle: 'Support the developer',
            onTap: () => showDonateSheet(context),
          ),
          const SizedBox(height: 24),
          _sectionHeader('GitHub'),
          _SettingsTile(
            icon: Icons.code_rounded,
            title: 'Shuash11',
            subtitle: 'View developer profile & repos',
            trailing: const Icon(Icons.open_in_new_rounded, size: 18),
            onTap: () async {
              final uri = Uri.parse('https://github.com/Shuash11');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(height: 24),
          _sectionHeader('About'),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'MathCalcu',
            subtitle: _appVersion,
          ),
          _SettingsTile(
            icon: Icons.person_rounded,
            title: 'Developer',
            subtitle: 'Joashua Marl Barimbao',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/screens/settings_screen.dart
git commit -m "feat: add Settings screen with Theme, Support, GitHub, About"
```

---

### Task 3: Update app_router.dart to use AppShell

**Files:**
- Modify: `lib/app_router.dart`

- [ ] **Step 1: Add import for AppShell**

Add at top of file:
```dart
import 'package:calculus_system/widgets/app_shell.dart';
```

- [ ] **Step 2: Replace root route builder**

Change the root route in the `router` GoRouter:
```dart
// Before:
GoRoute(
  path: '/',
  name: 'home',
  builder: (context, state) => const CategoryPickerScreen(),
),

// After:
GoRoute(
  path: '/',
  name: 'home',
  builder: (context, state) => const AppShell(),
),
```

Also update the same change in `router1` if still used, or remove `router1` entirely since it's unused.

- [ ] **Step 3: Commit**

```bash
git add lib/app_router.dart
git commit -m "feat: wire AppShell into GoRouter root route"
```

---

### Task 4: Add url_launcher dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add url_launcher**

Add under `dependencies:` section:
```yaml
  url_launcher: ^6.2.6
```

- [ ] **Step 2: Run flutter pub get**

Run: `flutter pub get`
Expected: success

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add url_launcher dependency"
```

---

### Task 5: Update widget test

**Files:**
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Update test**

```dart
import 'package:calculus_system/main.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App launches with bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: ThemeProvider(),
        child: const CalculusApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Should show home tab and bottom nav
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify**

Run: `flutter test`
Expected: All tests passed

- [ ] **Step 3: Commit**

```bash
git add test/widget_test.dart
git commit -m "test: update widget test for bottom nav"
```

---

### Self-Review

**Spec coverage check:**
- Bottom nav with Home + Settings → Task 1 (AppShell)
- Nav bar hides on topic screens → Automatic via GoRouter (topic routes push on top)
- Theme toggle → Task 2 (SettingsScreen dark mode switch)
- Donate → Task 2 (reuses existing showDonateSheet)
- GitHub → Task 2 (opens github.com/Shuash11 via url_launcher)
- About (version + developer) → Task 2 (package_info_plus + hardcoded credits)

**Placeholder check:** No TBD, TODOs, or incomplete sections.

**Type consistency:** All imports match existing codebase patterns. `url_launcher` `canLaunchUrl`/`launchUrl` signatures are correct for v6.x.
