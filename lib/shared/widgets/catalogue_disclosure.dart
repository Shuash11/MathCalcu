import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';

/// Truthful catalogue disclosure (P0-2).
///
/// States how many entries are solver-backed vs catalogue-only so
/// counts never over-claim. One responsibility: honest labelling.
class CatalogueDisclosure extends StatelessWidget {
  final int solverBacked;
  final int catalogueOnly;
  final String catalogueName;

  const CatalogueDisclosure({
    super.key,
    required this.solverBacked,
    required this.catalogueOnly,
    required this.catalogueName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final total = solverBacked + catalogueOnly;
    return Semantics(
      label: '$catalogueName catalogue: $solverBacked of $total with solvers',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.textSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: theme.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$solverBacked of $total $catalogueName topics have '
                'solvers now; the rest are catalogue previews.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: theme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small section pill (Foundations / Advanced / subject name).
class SectionPill extends StatelessWidget {
  final String label;
  final Color accent;

  const SectionPill({super.key, required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
