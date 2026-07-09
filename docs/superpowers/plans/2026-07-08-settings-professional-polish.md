# Settings Professional Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the Settings screen a professional feel with staggered animations, card-based rows, gradient dividers, and a dedicated full-screen Developers page listing all 6 contributors.

**Architecture:** Extract shared Developer model and tile widget from `about_sheets.dart` into reusable files. Create new `DevelopersScreen` with expandable cards and staggered animation. Enhance `SettingsScreen` with card containers, tap animations, entrance stagger, and gradient section dividers. Add `/developers` route.

**Tech Stack:** Flutter, provider, GoRouter

---

### Task 1: Extract Developer model and tile widget

**Files:**
- Create: `lib/models/developer.dart`
- Create: `lib/widgets/developer_tile.dart`
- Modify: `lib/screens/about_sheets.dart`

- [ ] **Step 1: Create `lib/models/developer.dart`**

Extract the `_Developer` class and `_developers` list from `about_sheets.dart` as public `Developer` and `developers`:

```dart
class Developer {
  final String name;
  final String program;
  final String role;
  final String email;
  final String contribution;
  final String phone;
  final String groups;
  final String facebook;

  const Developer({
    required this.name,
    required this.program,
    required this.role,
    this.email = '',
    this.contribution = '',
    required this.phone,
    this.groups = '',
    this.facebook = '',
  });
}

const developers = [
  Developer(
    name: 'Joashua Marl Barimbao',
    program: 'BS Computer Science',
    role: 'Lead\nDeveloper',
    email: 'joashuabarimbao10@gmail.com',
    facebook: 'Joashua Marl Barimbao',
    contribution:
        'Wiring, Debugging, Deploying, Absolute , Strict , Non Strict, Radical , Continued , Finding the Center , Finding the Radius',
    phone: '09639201328',
    groups:
        'Mary Chris Malinao\nKym Alinsonorin\nAljhun Gallego(gwapo)\nCresa Delacruz(Documentation)\nJoseph Rebamonte\nMerjohn Pagente',
  ),
  Developer(
    name: 'Michaela Denise Ong',
    program: 'BS Computer Science',
    role: 'Developer 2 / Docs',
    facebook: 'Michaela Denise Ong',
    email: 'michaeladenis11@gmail.com',
    contribution: 'Slope, Distance , Midpoint, Documentation',
    phone: '09452238406',
    groups:
        'Marie Joy Sebusana\nSusan Rhea Tamboboy\nVenus Caliguid\nAlche Paye\nVincent Padillio\nStephen Mark Maluto',
  ),
  Developer(
    name: 'Nash Bruce Quiros',
    program: 'BS Computer Science',
    role: 'Developer 3',
    email: 'quirosnash2@gmail.com',
    facebook: 'Nash Bruce Quiros',
    contribution: 'Basic , Quadratic, Rational',
    phone: '09953941510',
    groups:
        'Cabrera Carl Edward\nTyrus Regine\nRhea Mae Bustamante\nJoshua Barientos',
  ),
  Developer(
    name: 'John Carlo Legaste',
    program: 'BS Computer Science',
    role: 'Developer 4',
    email: 'johncarlolegaste@gmail.com',
    facebook: 'John Carlo legaste',
    contribution: 'Parallel & Perpendicular(Slope), Two-Point Slope',
    phone: '09639201328',
    groups:
        'Anjelyn Campos\nAlthea Sumalpong\nHearty Abugatal\nRafol Shayne Lowelle\nNoel Sale Jr\nJeomark Jumawan\nGraceselle Managing',
  ),
  Developer(
    name: 'Clifford Probetso',
    program: 'BS Computer Science',
    role: 'Developer 5',
    email: 'clifford.probetso@gmail.com',
    contribution: 'Point Slope, Finding the Center Radius',
    facebook: 'Clifford Probetso',
    phone: '09510069125',
    groups:
        'Angelie Jerusalem\nIvan Rabanzo\nLausa Dave\nJanwell Nacario\nRoynuj Plaza ',
  ),
  Developer(
    name: 'Johnlin Redido',
    program: 'BS Computer Science',
    role: 'Developer 6',
    facebook: 'Johnlin Redido',
    email: 'linzy21x@gmail.com',
    contribution: 'Slope-Intercept_form',
    phone: '09700455407',
    groups:
        'Gretechen Tumilap\nGonzaga Blessy\nJemson Tubis\nAllysa Sharise Cagui-at\nAlyssa Jean Toso',
  ),
];
```

Note: The phone field was previously `Phone` (capital P) — this has been fixed to `phone` (lowercase) for consistency. The `about_sheets.dart` references must be updated accordingly.

- [ ] **Step 2: Create `lib/widgets/developer_tile.dart`**

Extract `_DeveloperTile` and `_InfoRow` from `about_sheets.dart` as public `DeveloperTile` and `_InfoRow` (keep `_InfoRow` private since it's an internal helper):

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/models/developer.dart';
import 'package:calculus_system/theme/theme_provider.dart';

class DeveloperTile extends StatefulWidget {
  final Developer developer;
  final int index;
  final Color accent;

  const DeveloperTile({
    super.key,
    required this.developer,
    required this.index,
    this.accent = const Color(0xFF6C63FF),
  });

  @override
  State<DeveloperTile> createState() => _DeveloperTileState();
}

class _DeveloperTileState extends State<DeveloperTile> {
  bool _expanded = false;

  static const _avatarColors = [
    Color(0xFF6C63FF),
    Color(0xFF00BFA5),
    Color(0xFFFF6B6B),
    Color(0xFFFFB300),
    Color(0xFF42A5F5),
    Color(0xFFAB47BC),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final dev = widget.developer;
    final color = _avatarColors[widget.index % _avatarColors.length];
    final initials = dev.name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _expanded ? color.withValues(alpha: 0.04) : theme.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _expanded
                  ? color.withValues(alpha: 0.6)
                  : color.withValues(alpha: 0.15),
              width: _expanded ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: _expanded ? 0.25 : 0.08),
                blurRadius: _expanded ? 24 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _expanded ? 4 : 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _expanded
                              ? color.withValues(alpha: 0.15)
                              : color.withValues(alpha: 0.08),
                          border: Border.all(
                            color: _expanded
                                ? color.withValues(alpha: 0.8)
                                : color.withValues(alpha: 0.3),
                            width: _expanded ? 3 : 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dev.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: theme.textPrimary,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dev.program,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                dev.role,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _expanded
                                ? color.withValues(alpha: 0.15)
                                : theme.card,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: _expanded ? color : theme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        Divider(
                          color: color.withValues(alpha: 0.2),
                          height: 1,
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: dev.email.isNotEmpty ? dev.email : 'Not provided',
                          color: color,
                          theme: theme,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.emoji_emotions,
                          label: 'Facebook',
                          value: dev.facebook.isNotEmpty ? dev.facebook : 'Not provided',
                          color: color,
                          theme: theme,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.code_rounded,
                          label: 'Contribution',
                          value: dev.contribution.isNotEmpty ? dev.contribution : 'Not provided',
                          color: color,
                          theme: theme,
                          isMultiline: true,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.phone_android,
                          label: 'Contact',
                          value: dev.phone,
                          color: color,
                          theme: theme,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.groups_rounded,
                          label: 'Members',
                          value: dev.groups.isNotEmpty ? dev.groups : 'Not specified',
                          color: color,
                          theme: theme,
                          isMultiline: true,
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ThemeProvider theme;
  final bool isMultiline;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 0,
          child: Container(
            constraints: const BoxConstraints(minWidth: 70, maxWidth: 90),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.textPrimary,
              height: isMultiline ? 1.5 : 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Update `lib/screens/about_sheets.dart`**

Replace the `_Developer` class, `_developers` list, `_DeveloperTile`, and `_InfoRow` with imports:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/models/developer.dart';
import 'package:calculus_system/widgets/developer_tile.dart';
```

Delete the `_Developer` class (lines 7-28), `_developers` list (lines 30-98), `_DeveloperTile` class (lines 342-613), and `_InfoRow` class (lines 617-684).

In the `_AboutSheet` build method:
- Replace `_developer` references with `developer` from the model
- Replace `_developers.length` with `developers.length`
- Replace `_DeveloperTile(...)` with `DeveloperTile(...)` using the same props but without the `scale` parameter (since the extracted widget doesn't use scale; scale is baked into the values)
- Update the developer count text line (line 196)

The developer list section in `_AboutSheet` becomes:
```dart
...developers.asMap().entries.map(
  (e) => DeveloperTile(
    key: ValueKey(e.value.name),
    developer: e.value,
    index: e.key,
  ),
),
```

Also update the developer count text:
```dart
'${developers.length} developers · Math Solving App',
```

- [ ] **Step 4: Run flutter analyze**

Run: `cd C:\projects\mathcalcu && flutter analyze lib/models/developer.dart lib/widgets/developer_tile.dart lib/screens/about_sheets.dart`
Expected: No errors

- [ ] **Step 5: Run flutter test**

Run: `cd C:\projects\mathcalcu && flutter test`
Expected: All tests pass

- [ ] **Step 6: Commit**

```bash
git add lib/models/developer.dart lib/widgets/developer_tile.dart lib/screens/about_sheets.dart
git commit -m "refactor: extract Developer model and tile widget from about sheets"
```

---

### Task 2: Create Developers screen

**Files:**
- Create: `lib/screens/developers_screen.dart`

- [ ] **Step 1: Create `lib/screens/developers_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/models/developer.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/widgets/developer_tile.dart';

class DevelopersScreen extends StatefulWidget {
  const DevelopersScreen({super.key});

  @override
  State<DevelopersScreen> createState() => _DevelopersScreenState();
}

class _DevelopersScreenState extends State<DevelopersScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + developers.length * 80),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Animation<double> _fadeFor(int index) {
    final start = (index * 0.1).clamp(0.0, 0.8);
    final end = (start + 0.25).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _slideFor(int index) {
    final start = (index * 0.1).clamp(0.0, 0.8);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        title: const Text('Developers'),
        centerTitle: true,
        backgroundColor: theme.surface,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: developers.length,
        itemBuilder: (context, index) {
          return FadeTransition(
            opacity: _fadeFor(index),
            child: SlideTransition(
              position: _slideFor(index),
              child: DeveloperTile(
                developer: developers[index],
                index: index,
              ),
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Run flutter analyze**

Run: `cd C:\projects\mathcalcu && flutter analyze lib/screens/developers_screen.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/screens/developers_screen.dart
git commit -m "feat: add Developers screen with staggered card animation"
```

---

### Task 3: Polish Settings screen with animations and cards

**Files:**
- Modify: `lib/screens/settings_screen.dart`

- [ ] **Step 1: Update `lib/screens/settings_screen.dart`**

Replace the entire file to add:
- `SingleTickerProviderStateMixin` and `AnimationController` for staggered entrance
- Each `_SettingsRow` wrapped in `FadeTransition` + `SlideTransition` (staggered)
- Each row wrapped in a card container (rounded 16, theme.card, soft shadow)
- Tap animation (AnimatedScale 0.97) on tappable rows
- Gradient section dividers between sections
- "Developers" row in About section
- Navigate to `/developers` on tap

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/widgets/donate_sheet.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  static const _accent = Color(0xFF6C63FF);
  static const int _rowCount = 8;
  String _appVersion = '';
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _loadVersion();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _appVersion = 'v${info.version}');
    } catch (_) {
      if (mounted) setState(() => _appVersion = 'v1.3.0');
    }
  }

  Animation<double> _fadeFor(int index) {
    final start = (index * 0.07).clamp(0.0, 0.8);
    final end = (start + 0.25).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _slideFor(int index) {
    final start = (index * 0.07).clamp(0.0, 0.8);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    Widget _buildAnimatedRow(int index, Widget row) {
      return FadeTransition(
        opacity: _fadeFor(index),
        child: SlideTransition(
          position: _slideFor(index),
          child: row,
        ),
      );
    }

    Widget _sectionDivider() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                _accent.withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
      );
    }

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
          _buildAnimatedRow(0, _buildCard(
            child: _SettingsRow(
              icon: theme.isLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              label: 'Dark Mode',
              trailing: Switch.adaptive(
                value: !theme.isLight,
                onChanged: (_) => theme.toggle(),
              ),
            ),
          )),
          _sectionDivider(),
          _sectionHeader('Support'),
          _buildAnimatedRow(1, _buildTappableCard(
            child: _SettingsRow(
              icon: Icons.coffee_rounded,
              label: 'Donate',
              subtitle: 'Support the developer',
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _accent.withValues(alpha: 0.6)),
            ),
            onTap: () => showDonateSheet(context),
          )),
          _sectionDivider(),
          _sectionHeader('GitHub'),
          _buildAnimatedRow(2, _buildTappableCard(
            child: _SettingsRow(
              icon: Icons.code_rounded,
              label: 'Shuash11',
              subtitle: 'View developer profile & repos',
              trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: _accent),
            ),
            onTap: () async {
              final uri = Uri.parse('https://github.com/Shuash11');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          )),
          _sectionDivider(),
          _sectionHeader('About'),
          _buildAnimatedRow(3, _buildCard(
            child: _SettingsRow(
              icon: Icons.info_outline_rounded,
              label: 'MathCalcu',
              subtitle: _appVersion,
            ),
          )),
          _buildAnimatedRow(4, _buildCard(
            child: const _SettingsRow(
              icon: Icons.person_rounded,
              label: 'Developer',
              subtitle: 'Joashua Marl Barimbao',
            ),
          )),
          _buildAnimatedRow(5, _buildTappableCard(
            child: _SettingsRow(
              icon: Icons.people_rounded,
              label: 'Developers',
              subtitle: 'View all ${developers.length} contributors',
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _accent.withValues(alpha: 0.6)),
            ),
            onTap: () => context.push('/developers'),
          )),
          _buildAnimatedRow(6, _buildTappableCard(
            child: _SettingsRow(
              icon: Icons.email_outlined,
              label: 'Contact',
              subtitle: 'joashuabarimbao10@gmail.com',
            ),
            onTap: () async {
              final uri = Uri.parse('mailto:joashuabarimbao10@gmail.com');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          )),
          _buildAnimatedRow(7, _buildTappableCard(
            child: _SettingsRow(
              icon: Icons.language_rounded,
              label: 'Website',
              subtitle: 'mathcalc-calculus.netlify.app',
              trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: _accent),
            ),
            onTap: () async {
              final uri = Uri.parse('https://mathcalc-calculus.netlify.app/');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    final theme = context.watch<ThemeProvider>();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTappableCard({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: _TappableCard(child: child),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4, top: 8),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _accent,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accent.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TappableCard extends StatefulWidget {
  final Widget child;
  const _TappableCard({required this.child});

  @override
  State<_TappableCard> createState() => _TappableCardState();
}

class _TappableCardState extends State<_TappableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _SettingsScreenState._accent.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
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

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Run flutter analyze**

Run: `cd C:\projects\mathcalcu && flutter analyze lib/screens/settings_screen.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/screens/settings_screen.dart
git commit -m "feat: polish Settings screen with staggered animation and card containers"
```

---

### Task 4: Update app_router.dart

**Files:**
- Modify: `lib/app_router.dart`

- [ ] **Step 1: Add `/developers` route**

Add import:
```dart
import 'package:calculus_system/screens/developers_screen.dart';
```

Add route entry in the GoRouter route list:
```dart
GoRoute(
  path: '/developers',
  parentNavigatorKey: navigatorKey,
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: const DevelopersScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
),
```

- [ ] **Step 2: Run flutter analyze**

Run: `cd C:\projects\mathcalcu && flutter analyze lib/app_router.dart`
Expected: No errors

- [ ] **Step 3: Run flutter test**

Run: `cd C:\projects\mathcalcu && flutter test`
Expected: All tests pass

- [ ] **Step 4: Commit**

```bash
git add lib/app_router.dart
git commit -m "feat: add /developers route"
```

---

### Task 5: Final verification

**Files:** (no file changes — verification only)

- [ ] **Step 1: Run full flutter analyze**

Run: `cd C:\projects\mathcalcu && flutter analyze`
Expected: No errors in any changed files

- [ ] **Step 2: Run all tests**

Run: `cd C:\projects\mathcalcu && flutter test`
Expected: All tests pass

- [ ] **Step 3: Complete**

All tasks done. Ready for release.
