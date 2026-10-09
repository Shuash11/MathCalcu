// lib/Screens/SubScreens/steps_section.dart
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:material_ui/material_ui.dart';

/// Step panel for the "Find the Center" solver.
///
/// When a per-line LaTeX view ([stepsLatex]) is supplied, each math line is
/// rendered through the LaTeX renderer (with horizontal safety and an explicit
/// readable fallback); otherwise it falls back to the pre-formatted monospace
/// [steps] string, so the string path stays working for any other consumer.
class CenterStepsSection extends StatelessWidget {
  final String? steps;

  /// Per-line LaTeX view of [steps] (KaTeX subset), aligned line-for-line with
  /// [steps] -- a blank entry renders as a vertical gap.
  final List<String>? stepsLatex;

  const CenterStepsSection({super.key, required this.steps, this.stepsLatex});

  static const TextStyle _bodyStyle = TextStyle(
    fontSize: 13,
    color: Color(0xFFE8E8F0),
    height: 1.5,
  );

  @override
  Widget build(BuildContext context) {
    if (steps == null) return const SizedBox.shrink();
    final latex = stepsLatex;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF334155).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF334155).withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list_alt_rounded,
                color: const Color(0xFF334155).withValues(alpha: 0.8),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'SOLUTION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155).withValues(alpha: 0.8),
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (latex != null && latex.isNotEmpty)
            ...latex.map(_latexLine)
          else
            ...steps!.split('\n').map(_plainLine),
        ],
      ),
    );
  }

  /// One math line via [SelectableMath.tex] with horizontal safety and an
  /// explicit readable fallback (a plain text line -- never a red error box).
  Widget _latexLine(String line) {
    if (line.trim().isEmpty) return const SizedBox(height: 12);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableMath.tex(
          line,
          textStyle: _bodyStyle,
          onErrorFallback: (error) => Text(
            line,
            style: _bodyStyle.copyWith(fontFamily: 'monospace'),
          ),
        ),
      ),
    );
  }

  /// Legacy plain-text path: one monospace [Text] per line.
  Widget _plainLine(String line) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          line,
          style: _bodyStyle.copyWith(fontFamily: 'monospace'),
        ),
      );
}
