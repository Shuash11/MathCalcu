import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:calculus_system/services/update_service.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/widgets/donate_sheet.dart';
import 'package:calculus_system/widgets/update_dialog.dart';
import 'package:calculus_system/widgets/web_update_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.updateChecker,
    this.isWeb,
    this.isAndroid,
    this.isWindows,
    this.showNativeUpdate,
    this.showWebUpdate,
    this.showReleaseLinkUpdate,
  });

  final Future<UpdateInfo> Function()? updateChecker;
  final bool? isWeb;
  final bool Function()? isAndroid;
  final bool Function()? isWindows;
  final void Function(BuildContext, UpdateInfo)? showNativeUpdate;
  final void Function(BuildContext, String)? showWebUpdate;
  final void Function(BuildContext, UpdateInfo)? showReleaseLinkUpdate;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  Color get _accent => context.read<ThemeProvider>().accentColor;
  UpdateInfo? _updateInfo;
  bool _updateFailed = false;
  bool _checkingUpdate = false;
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _loadUpdateStatus();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _loadUpdateStatus() async {
    try {
      final info = await (widget.updateChecker?.call() ??
          UpdateService.checkForUpdate());
      if (!mounted) return;
      setState(() {
        _updateInfo = info;
        _updateFailed = false;
      });
    } catch (e) {
      debugPrint('Settings update status check failed: $e');
      if (!mounted) return;
      setState(() => _updateFailed = true);
    }
  }

  /// Manual "Check for updates": refreshes [_updateInfo] and always presents
  /// the update dialog when the result is [UpdateStatus.updateAvailable].
  Future<void> _manualCheckForUpdates() async {
    if (_checkingUpdate) return;
    setState(() {
      _checkingUpdate = true;
      _updateFailed = false;
    });
    try {
      final info = await (widget.updateChecker?.call() ??
          UpdateService.checkForUpdate());
      if (!mounted) return;
      setState(() {
        _updateInfo = info;
        _checkingUpdate = false;
        _updateFailed = false;
      });
      if (!mounted) return;
      switch (info.status) {
        case UpdateStatus.updateAvailable:
          _presentUpdate(info);
          break;
        case UpdateStatus.upToDate:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                info.installedVersion == null || info.installedVersion!.isEmpty
                    ? 'MathCalcu is up to date'
                    : 'MathCalcu is up to date (v${info.installedVersion})',
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
          break;
        case UpdateStatus.unavailable:
          debugPrint('Settings manual update check: status unavailable.');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Update status unavailable. Try again later.'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
          break;
      }
    } catch (e) {
      debugPrint('Settings manual update check failed: $e');
      if (!mounted) return;
      setState(() {
        _checkingUpdate = false;
        _updateFailed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Update status unavailable. Try again later.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _presentUpdate(UpdateInfo info) {
    if (!mounted) return;
    final context = this.context;
    final isWeb = widget.isWeb ?? kIsWeb;
    if (isWeb) {
      (widget.showWebUpdate ?? showWebUpdateDialog)(
          context, info.latestVersion);
      return;
    }
    final isAndroid = widget.isAndroid?.call() ?? Platform.isAndroid;
    final isWindows = widget.isWindows?.call() ?? Platform.isWindows;
    if (isAndroid || isWindows) {
      (widget.showNativeUpdate ?? showUpdateDialog)(context, info);
      return;
    }
    if (_trustedReleaseUri(info.releaseUrl) == null) {
      debugPrint('Settings update: untrusted release URL, dialog suppressed.');
      return;
    }
    (widget.showReleaseLinkUpdate ?? _showReleaseLinkUpdate)(context, info);
  }

  void _showReleaseLinkUpdate(BuildContext context, UpdateInfo info) {
    final releaseUri = _trustedReleaseUri(info.releaseUrl);
    if (releaseUri == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Update v${info.latestVersion} available'),
        action: SnackBarAction(
          label: 'Open',
          onPressed: () async {
            try {
              await launchUrl(
                releaseUri,
                mode: LaunchMode.externalApplication,
              );
            } catch (e) {
              debugPrint('Settings update: failed to open release link: $e');
            }
          },
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 10),
      ),
    );
  }

  Uri? _trustedReleaseUri(String releaseUrl) {
    final releaseUri = Uri.tryParse(releaseUrl);
    if (releaseUri == null ||
        !releaseUri.isAbsolute ||
        releaseUri.scheme != 'https' ||
        releaseUri.host != 'github.com' ||
        releaseUri.userInfo.isNotEmpty ||
        !releaseUri.path.startsWith('/Shuash11/MathCalcu/releases/')) {
      return null;
    }
    return releaseUri;
  }

  String get _versionSubtitle {
    if (_updateFailed) return 'Update status unavailable';
    final info = _updateInfo;
    if (info == null) return 'Checking for updates…';
    final installed = info.installedVersion;
    switch (info.status) {
      case UpdateStatus.updateAvailable:
        final base = installed == null || installed.isEmpty
            ? 'v${info.latestVersion}'
            : 'v$installed';
        return '$base — update to v${info.latestVersion}';
      case UpdateStatus.upToDate:
        final base = installed == null || installed.isEmpty
            ? 'v${info.latestVersion}'
            : 'v$installed';
        return '$base — up to date';
      case UpdateStatus.unavailable:
        if (installed == null || installed.isEmpty) {
          return 'Update status unavailable';
        }
        return 'v$installed — update status unavailable';
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

    Widget buildAnimatedRow(int index, Widget row) {
      return FadeTransition(
        opacity: _fadeFor(index),
        child: SlideTransition(
          position: _slideFor(index),
          child: row,
        ),
      );
    }

    Widget sectionDivider() {
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
          buildAnimatedRow(
              0,
              _buildCard(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9CA3AF).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          theme.isDark ? Icons.dark_mode : Icons.light_mode,
                          size: 20,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dark Mode',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.textPrimary,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                theme.isDark
                                    ? 'Dark theme active'
                                    : 'Light theme active',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: theme.isDark,
                        activeThumbColor: const Color(0xFF9CA3AF),
                        onChanged: (_) {
                          theme.toggleTheme();
                          theme.saveTheme();
                        },
                      ),
                    ],
                  ),
                ),
              )),
          sectionDivider(),
          _sectionHeader('Support'),
          buildAnimatedRow(
              1,
              _buildTappableCard(
                child: _SettingsRow(
                  icon: Icons.coffee_rounded,
                  label: 'Donate',
                  subtitle: 'Support the developer',
                  trailing: Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: _accent.withValues(alpha: 0.6)),
                ),
                onTap: () => showDonateSheet(context),
              )),
          sectionDivider(),
          _sectionHeader('About'),
          buildAnimatedRow(
              2,
              _buildCard(
                child: _SettingsRow(
                  icon: Icons.info_outline_rounded,
                  label: 'MathCalcu',
                  subtitle: _versionSubtitle,
                ),
              )),
          buildAnimatedRow(
            3,
            _buildTappableCard(
              child: _SettingsRow(
                icon: Icons.refresh_rounded,
                label: _checkingUpdate ? 'Checking…' : 'Check for updates',
                subtitle: _checkingUpdate
                    ? 'Contacting GitHub releases…'
                    : 'Check now for the latest version',
                trailing: _checkingUpdate
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: _accent.withValues(alpha: 0.6)),
              ),
              onTap: () => _manualCheckForUpdates(),
            ),
          ),
          buildAnimatedRow(
              4,
              _buildTappableCard(
                child: _SettingsRow(
                  icon: Icons.language_rounded,
                  label: 'Website',
                  subtitle: 'mathcalc-calculus.netlify.app',
                  trailing:
                      Icon(Icons.open_in_new_rounded, size: 16, color: _accent),
                ),
                onTap: () async {
                  try {
                    await launchUrl(
                        Uri.parse('https://mathcalc-calculus.netlify.app/'),
                        mode: LaunchMode.externalApplication);
                  } catch (_) {}
                },
              )),
          buildAnimatedRow(
              5,
              _buildTappableCard(
                child: _SettingsRow(
                  icon: Icons.code_rounded,
                  label: 'GitHub',
                  subtitle: 'Shuash11',
                  trailing:
                      Icon(Icons.open_in_new_rounded, size: 16, color: _accent),
                ),
                onTap: () async {
                  try {
                    await launchUrl(Uri.parse('https://github.com/Shuash11'),
                        mode: LaunchMode.externalApplication);
                  } catch (_) {}
                },
              )),
          sectionDivider(),
          _sectionHeader('Team'),
          buildAnimatedRow(
              6,
              _buildTappableCard(
                child: _SettingsRow(
                  icon: Icons.group_rounded,
                  label: 'Meet the Team',
                  subtitle: 'mathcalcu-build.netlify.app',
                  trailing:
                      Icon(Icons.open_in_new_rounded, size: 16, color: _accent),
                ),
                onTap: () async {
                  try {
                    await launchUrl(
                        Uri.parse('https://mathcalcu-build.netlify.app/'),
                        mode: LaunchMode.externalApplication);
                  } catch (_) {}
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

  Widget _buildTappableCard(
      {required Widget child, required VoidCallback onTap}) {
    return _TappableCard(onTap: onTap, child: child);
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4, top: 8),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
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
  final VoidCallback onTap;
  const _TappableCard({required this.onTap, required this.child});

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
      onTap: widget.onTap,
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
                color: theme.accentColor.withValues(alpha: 0.06),
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
              color: const Color(0xFF9CA3AF).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
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
