import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_router.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'services/update_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/update_dialog.dart';
import 'widgets/web_update_dialog.dart';
import 'version.dart';

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
  const CalculusApp({super.key});

  @override
  State<CalculusApp> createState() => _CalculusAppState();
}

class _CalculusAppState extends State<CalculusApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestInstallPermission();
      _checkForUpdates();
    });
  }

  Future<void> _requestInstallPermission() async {
    if (!Platform.isAndroid) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('asked_install_permission') == true) return;
    await prefs.setBool('asked_install_permission', true);

    final canInstall = await UpdateService.canInstallPackages();
    if (canInstall || !mounted) return;

    final ctx = AppRouter.navigatorKey.currentContext;
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

  Future<void> _checkForUpdates() async {
    try {
      if (!mounted) return;

      // Web: fetch version.json and compare against current
      if (kIsWeb) {
        await _checkForWebUpdate();
        return;
      }

      // Android/Windows: use GitHub API
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final info = await UpdateService.checkForUpdate(currentVersion);
      if (!mounted) return;
      final ctx = AppRouter.navigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) return;
      if (info != null && info.hasUpdate) {
        if (Platform.isAndroid || Platform.isWindows) {
          showUpdateDialog(ctx, info);
        } else {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text('Update v${info.latestVersion} available'),
              action: SnackBarAction(
                label: 'Open',
                onPressed: () => launchUrl(Uri.parse(info.releaseUrl)),
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 10),
            ),
          );
        }
      } else if (info != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(
                '\u2713 MathCalcu is up to date (v${info.currentVersion})'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('v$currentVersion - Could not check for updates'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      final ctx = AppRouter.navigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Could not check for updates'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _checkForWebUpdate() async {
    try {
      // Fetch version.json with cache-bust timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await http
          .get(Uri.parse('version.json?v=$timestamp'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      final latestVersion = data['version'] as String?;
      if (latestVersion == null) return;

      // Get current version from the version constant
      final currentVersion = kAppVersion;

      if (latestVersion != currentVersion && mounted) {
        final ctx = AppRouter.navigatorKey.currentContext;
        if (ctx != null && ctx.mounted) {
          showWebUpdateDialog(ctx, latestVersion);
        }
      }
    } catch (_) {
      // Silently ignore ? not critical
    }
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
