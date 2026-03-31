// ─────────────────────────────────────────────────────────────
// STEP MODEL — one step in the solution walkthrough
// Used by StepsDrawer shared widget.
// ─────────────────────────────────────────────────────────────
class StepModel {
  final int stepNumber;
  final String title;
  final String explanation;
  final String? latex; // optional: rendered math expression

  const StepModel({
    required this.stepNumber,
    required this.title,
    required this.explanation,
    this.latex,
  });
}
