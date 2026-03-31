// ─────────────────────────────────────────────────────────────
// SOLVE RESULT — returned by every BaseEquation.solve()
// ─────────────────────────────────────────────────────────────

class SolveResult {
  final String answer;         // e.g. "x > 3"
  final String? latex;         // optional LaTeX for rendering
  final List<double> points;   // x-axis points for the graph
  final String? intervalNotation; // e.g. "(3, ∞)"
  final bool hasError;
  final String? errorMessage;

  const SolveResult({
    required this.answer,
    required this.points,
    this.latex,
    this.intervalNotation,
    this.hasError = false,
    this.errorMessage,
  });

  factory SolveResult.error(String message) => SolveResult(
        answer: '',
        points: [],
        hasError: true,
        errorMessage: message,
      );
}
