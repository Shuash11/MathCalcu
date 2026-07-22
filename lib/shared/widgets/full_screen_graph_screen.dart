import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:calculus_system/theme/theme_provider.dart';

/// A full-screen page that displays a graph widget, formula, and key info.
///
/// Used when user taps on any graph to expand it to full screen.
class FullScreenGraphScreen extends StatelessWidget {
  final String title;
  final Widget graph;
  final String? formula;
  final List<FullScreenInfoItem>? keyInfo;
  final Widget? formulaWidget;
  final Color accentColor;

  const FullScreenGraphScreen({
    super.key,
    required this.title,
    required this.graph,
    this.formula,
    this.keyInfo,
    this.formulaWidget,
    this.accentColor = const Color(0xFF334155),
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Semantics(
                    label: 'Close full-screen graph',
                    button: true,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.textPrimary.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: theme.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Graph area (expanded)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: graph,
                  ),
                ),
              ),
            ),

            // Info section
            if (formulaWidget != null ||
                formula != null ||
                (keyInfo?.isNotEmpty ?? false))
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Formula
                    if (formulaWidget != null) ...[
                      formulaWidget!,
                    ] else if (formula != null) ...[
                      Text(
                        formula!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],

                    // Key info
                    if (keyInfo != null && keyInfo!.isNotEmpty) ...[
                      if (formula != null || formulaWidget != null)
                        const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: keyInfo!.map((item) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: item.color ?? accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.value,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textPrimary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A key-value info item for the full-screen graph view.
class FullScreenInfoItem {
  final String label;
  final String value;
  final Color? color;

  const FullScreenInfoItem({
    required this.label,
    required this.value,
    this.color,
  });
}
