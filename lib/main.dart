import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_router.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';

void main() async {
  // ── PRE-RUN INITIALIZATION ──
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create and asynchronously load theme preferences before running the app
  final themeProvider = ThemeProvider();
  await themeProvider.load();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const CalculusApp(),
    ),
  );
}

class CalculusApp extends StatelessWidget {
  const CalculusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return MaterialApp.router(
      title: 'Calculus System',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.isLight ? AppTheme.light() : AppTheme.dark(), 
      routerConfig: AppRouter.router,
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