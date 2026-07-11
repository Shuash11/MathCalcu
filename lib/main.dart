import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_router.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'services/update_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/update_dialog.dart';

void main() async {
  // â”€â”€ PRE-RUN INITIALIZATION â”€â”€
  WidgetsFlutterBinding.ensureInitialized();

  // Create theme provider (load asynchronously in background)
  final themeProvider = ThemeProvider();
  // Don't await - let it load in background while app starts
  themeProvider.load();

  // Only set system UI overlay style on mobile platforms (not on web or desktop)
  try {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
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
      builder: (_) => AlertDialog(
        backgroundColor: ctx.watch<ThemeProvider>().surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB020).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.system_update_rounded, size: 32, color: Color(0xFFFFB020)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Allow app updates',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'MathCalcu needs permission to install updates automatically.\n'
                'Grant this once and future updates will work seamlessly.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: TextButton.styleFrom(foregroundColor: ctx.watch<ThemeProvider>().textSecondary),
                  child: const Text('Not now'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    UpdateService.openInstallSettings();
                  },
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFFB020)),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkForUpdates() async {
    try {
      if (!mounted) return;
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
            content: Text('\u2713 MathCalcu is up to date (v${info.currentVersion})'),
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'MathCalcu',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.isLight ? AppTheme.light() : AppTheme.dark(),
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return child ?? const Scaffold(body: Center(child: Text('Error loading app')));
      },
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// GLOBAL THEME â€” shared across all modules
// Each module can layer their own theme on top
// via their own theme/ folder.
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF7F7FA),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6C63FF),
        secondary: Color(0xFF00D4AA),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF1E1E28),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A0F),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6C63FF),
        secondary: Color(0xFF00D4AA),
        surface: Color(0xFF12121A),
        onSurface: Color(0xFFE8E8F0),
      ),
      useMaterial3: true,
    );
  }
}
