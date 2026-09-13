import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_router.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'services/update_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/update_dialog.dart';
import 'widgets/web_update_dialog.dart';

void main() async {
  // ── PRE-RUN INITIALIZATION ──
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  // Only set system UI overlay style on mobile platforms (not on web or desktop)
  try {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            themeProvider.isDark ? Brightness.light : Brightness.dark,
      ),
    );
  } catch (_) {
    // Ignore errors on unsupported platforms (web, linux, windows, macos)
  }

  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const CalculusApp(),
    ),
  );
}

class CalculusApp extends StatefulWidget {
  const CalculusApp({
    super.key,
    this.updateChecker,
    this.isWeb,
    this.isAndroid,
    this.isWindows,
    this.showNativeUpdate,
    this.showWebUpdate,
    this.showReleaseLinkUpdate,
    this.navigatorContext,
  });

  final Future<UpdateInfo> Function()? updateChecker;
  final bool? isWeb;
  final bool Function()? isAndroid;
  final bool Function()? isWindows;
  final void Function(BuildContext, UpdateInfo)? showNativeUpdate;
  final void Function(BuildContext, String)? showWebUpdate;
  final void Function(BuildContext, UpdateInfo)? showReleaseLinkUpdate;
  final BuildContext? Function()? navigatorContext;

  @override
  State<CalculusApp> createState() => _CalculusAppState();
}

class _CalculusAppState extends State<CalculusApp> with WidgetsBindingObserver {
  bool _hasCheckedForUpdates = false;
  bool _retryScheduled = false;
  bool _needsResumeRecheck = false;
  UpdateInfo? _pendingUpdate;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestInstallPermission();
      if (!mounted) return;
      await _checkForUpdates();
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _retryTimer = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    if (_pendingUpdate != null) {
      _tryPresentPending();
    } else if (_needsResumeRecheck) {
      _needsResumeRecheck = false;
      _checkForUpdates(isRetry: true);
    }
  }

  Future<void> _requestInstallPermission() async {
    if (kIsWeb || !Platform.isAndroid) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('asked_install_permission') == true) return;
    await prefs.setBool('asked_install_permission', true);

    final canInstall = await UpdateService.canInstallPackages();
    if (canInstall || !mounted) return;

    final ctx = _navigatorContext();
    if (ctx == null || !ctx.mounted) return;

    await showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogContext) {
        final theme = dialogContext.watch<ThemeProvider>();
        return AlertDialog(
          backgroundColor: theme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.system_update_rounded,
                    size: 32, color: theme.accentColor),
              ),
              const SizedBox(height: 16),
              Text(
                'Allow app updates',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'MathCalcu needs permission to install updates automatically.\n'
                  'Grant this once and future updates will work seamlessly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: theme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        UpdateService.openInstallSettings();
                      },
                      style: FilledButton.styleFrom(
                          backgroundColor: theme.accentColor),
                      child: const Text('Open Settings'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: TextButton.styleFrom(
                          foregroundColor: theme.textSecondary),
                      child: const Text('Not now'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _checkForUpdates({bool isRetry = false}) async {
    if (!mounted) return;
    if (_hasCheckedForUpdates && !isRetry) return;
    _hasCheckedForUpdates = true;

    try {
      final info = await (widget.updateChecker?.call() ??
          UpdateService.checkForUpdate());
      if (!mounted) {
        debugPrint('Update check: widget unmounted before result handled.');
        return;
      }
      final ctx = _navigatorContext();
      if (ctx == null || !ctx.mounted) {
        debugPrint(
          'Update check: navigator context unavailable '
          '(status=${info.status}). Scheduling retry.',
        );
        if (info.status == UpdateStatus.updateAvailable) {
          _pendingUpdate = info;
        } else if (info.status == UpdateStatus.unavailable) {
          _needsResumeRecheck = true;
        }
        _scheduleRetry();
        return;
      }

      switch (info.status) {
        case UpdateStatus.updateAvailable:
          _pendingUpdate = info;
          _presentUpdate(ctx, info);
          _pendingUpdate = null;
          break;
        case UpdateStatus.upToDate:
          final installedVersion = info.installedVersion;
          final versionSuffix =
              installedVersion == null || installedVersion.isEmpty
                  ? ''
                  : ' (v$installedVersion)';
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text('MathCalcu is up to date$versionSuffix'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
          break;
        case UpdateStatus.unavailable:
          debugPrint(
            'Update check: release status unavailable. '
            'Will retry once and on app resume.',
          );
          _needsResumeRecheck = true;
          _scheduleRetry();
          break;
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Update check failed: $e. Scheduling one retry.');
      // Update checks are nonblocking. The Settings screen can report the
      // unavailable status when the user opens it.
      _needsResumeRecheck = true;
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    if (_retryScheduled || !mounted) return;
    _retryScheduled = true;
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_pendingUpdate != null) {
        _tryPresentPending();
      } else {
        _checkForUpdates(isRetry: true);
      }
    });
  }

  void _tryPresentPending() {
    final info = _pendingUpdate;
    if (info == null || !mounted) return;
    final ctx = _navigatorContext();
    if (ctx == null || !ctx.mounted) {
      debugPrint('Update check: pending update still has no context.');
      return;
    }
    _presentUpdate(ctx, info);
    _pendingUpdate = null;
  }

  void _presentUpdate(BuildContext context, UpdateInfo info) {
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
            } catch (_) {}
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

  BuildContext? _navigatorContext() {
    final contextLookup = widget.navigatorContext;
    if (contextLookup != null) {
      return contextLookup();
    }
    return AppRouter.navigatorKey.currentContext;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'MathCalcu',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.isDark ? AppTheme.dark() : AppTheme.light(),
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return child ??
            const Scaffold(body: Center(child: Text('Error loading app')));
      },
    );
  }
}

// ─────────────────────────────────────────────
// GLOBAL THEME — shared across all modules
// Each module can layer their own theme on top
// via their own theme/ folder.
// ─────────────────────────────────────────────
class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF4F4F1),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF334155),
        secondary: Color(0xFF0C0C09),
        tertiary: Color(0xFF16A34A),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF1E1E28),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE9ECEF),
        secondary: Color(0xFFF4F4F1),
        tertiary: Color(0xFF16A34A),
        surface: Color(0xFF232340),
        onSurface: Color(0xFFF4F4F1),
      ),
      useMaterial3: true,
    );
  }
}
