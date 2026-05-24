// ─────────────────────────────────────────────────────────────
// STEP MODEL — one step in the solution walkthrough
// Used by StepsDrawer shared widget.
// ─────────────────────────────────────────────────────────────
class StepModel {
  final int stepNumber;
  final String title;
  final String explanation;
  final String? hint; // brief operation hint (e.g. "Subtract 5 from both sides")
  final String? latex;
  final List<String>? subLatex;
  final List<String>? details; // expanded arithmetic work (LaTeX strings)

  const StepModel({
    required this.stepNumber,
    this.title = '',
    this.explanation = '',
    this.hint,
    this.latex,
    this.subLatex,
    this.details,
  });
}
