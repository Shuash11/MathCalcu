// radius_steps.dart
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:material_ui/material_ui.dart';

/// Step panel for the "Find the Radius" solver.
///
/// When a per-line LaTeX view ([stepsLatex]) is supplied, each math line is
/// rendered through the LaTeX renderer (with horizontal safety and an explicit
/// readable fallback); otherwise it falls back to the pre-formatted monospace
/// [steps] string, so the string path stays working for any other consumer.
class RadiusStepsCard extends StatelessWidget {
  /// Pre-formatted multiline solution string from [RadiusResult.steps].
  final String steps;
  final List<String>? stepsLatex;

  const RadiusStepsCard({super.key, required this.steps, this.stepsLatex});

  static const TextStyle _bodyStyle = TextStyle(
    fontSize: 14,
    color: Color(0xFFE8E8F0),
    height: 1.5,
  );

  @override
  Widget build(BuildContext context) {
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
            ...steps.split('\n').map(_plainLine),
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
          onErrorFallback: (error) =>
              Text(line, style: _bodyStyle.copyWith(fontFamily: 'monospace')),
        ),
      ),
    );
  }

  /// Legacy plain-text path: one monospace [Text] per line.
  Widget _plainLine(String line) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(line, style: _bodyStyle.copyWith(fontFamily: 'monospace')),
  );
}
