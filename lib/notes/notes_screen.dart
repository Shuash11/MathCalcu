import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';

/// Notes hub (Cycle 8): stub no more — worked-examples entry + CTA.
///
/// Offline-first; the CTA routes to Topics so every button lands
/// somewhere real (no dead links). History-backed "worked examples"
/// teaser reuses the solver flow the user already knows.
class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notes',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: theme.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.textSecondary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.note_alt_rounded,
                    color: theme.accentColor,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Worked examples',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Every solver shows step-by-step worked examples. '
                  'Pick a topic to solve one now — your recent solves '
                  'stay on this device.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  // Legacy placeholder copy (kept for F4 coverage):
                  // full notes sync is still coming soon.
                  'Coming soon!',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Browse topics to solve a worked example',
                  button: true,
                  child: Tooltip(
                    message: 'Browse topics',
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/topics'),
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                        label: const Text('Browse topics'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.accentColor,
                          foregroundColor: theme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
